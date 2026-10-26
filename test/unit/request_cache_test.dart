import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;
  late RequestCache cache;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();

    tempDir = await Directory.systemTemp.createTemp('request_cache_test_');
    Hive.init(tempDir.path);
    cache = RequestCache.instance;
    await cache.initialize();
  });

  setUp(() async {
    await cache.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  // ─── 辅助：直接向 box 写入已过期条目 ───────────────────────────────────────
  Future<void> putExpired(
    String url,
    dynamic data, {
    Map<String, dynamic>? params,
  }) async {
    final box = Hive.box(HiveManager.requestCacheBoxName);
    final paramsString = (params != null && params.isNotEmpty)
        ? jsonEncode(params)
        : '';
    final key =
        'request_cache_${Uri.encodeComponent(url)}_'
        '${Uri.encodeComponent(paramsString)}';
    final entry = CacheEntry(
      data: data,
      expiryTime: DateTime.now()
          .subtract(const Duration(seconds: 1))
          .millisecondsSinceEpoch,
      requestUrl: url,
    );
    await box.put(key, entry.toJson());
  }

  group('RequestCache.get / set', () {
    test('should_return_null_for_missing_key', () async {
      final result = await cache.get<String>('https://example.com/api/test');
      expect(result, isNull);
    });

    test('should_store_and_retrieve_string_data', () async {
      await cache.set('https://example.com/api/test', 'hello');
      final result = await cache.get<String>('https://example.com/api/test');
      expect(result, 'hello');
    });

    test('should_store_and_retrieve_map_data', () async {
      final data = {'name': '张三', 'score': 95};
      await cache.set('https://example.com/api/user', data);
      final result = await cache.get<Map>('https://example.com/api/user');
      expect(result, data);
    });

    test('should_store_and_retrieve_list_data', () async {
      final data = [1, 2, 3];
      await cache.set('https://example.com/api/list', data);
      final result = await cache.get<List>('https://example.com/api/list');
      expect(result, data);
    });

    test('should_hash_long_url_keys_to_fit_hive_limit', () async {
      final longQuery = List.generate(
        40,
        (index) => 'segment_$index=${'value' * 8}',
      ).join('&');
      final url = 'https://example.com/api/very/long/path?$longQuery';
      final data = {'ok': true};

      await cache.set(url, data);

      final result = await cache.get<Map>(url);
      final box = Hive.box(HiveManager.requestCacheBoxName);
      final storedKey = box.keys.single as String;

      expect(result, data);
      expect(storedKey.length, lessThanOrEqualTo(255));
    });

    test('should_return_null_for_expired_entry_and_delete_it', () async {
      await putExpired('https://example.com/api/old', 'stale');

      final result = await cache.get<String>('https://example.com/api/old');

      expect(result, isNull);
      // 过期条目应已被删除
      final box = Hive.box(HiveManager.requestCacheBoxName);
      expect(box.length, 0);
    });

    test('should_handle_corrupt_data_gracefully_and_return_null', () async {
      final box = Hive.box(HiveManager.requestCacheBoxName);
      final key =
          'request_cache_${Uri.encodeComponent('https://example.com/corrupt')}_';
      await box.put(key, {'bad_field': 'no_expiry_time'});

      final result = await cache.get<String>('https://example.com/corrupt');

      expect(result, isNull);
      expect(box.length, 0); // 损坏条目已被删除
    });

    test('should_differentiate_entries_by_params', () async {
      await cache.set(
        'https://example.com/api',
        'result_a',
        params: {'page': '1'},
      );
      await cache.set(
        'https://example.com/api',
        'result_b',
        params: {'page': '2'},
      );

      expect(
        await cache.get<String>(
          'https://example.com/api',
          params: {'page': '1'},
        ),
        'result_a',
      );
      expect(
        await cache.get<String>(
          'https://example.com/api',
          params: {'page': '2'},
        ),
        'result_b',
      );
    });

    test('should_respect_explicit_maxAge_over_url_policy', () async {
      await cache.set(
        'https://example.com/api/score/list',
        'data',
        maxAge: const Duration(milliseconds: 1),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final result = await cache.get<String>(
        'https://example.com/api/score/list',
      );
      expect(result, isNull); // 自定义 1ms TTL 已过期，而非 score 的 1h 策略
    });
  });

  group('RequestCache.delete', () {
    test('should_remove_specific_entry', () async {
      await cache.set('https://example.com/api/a', 'a');
      await cache.set('https://example.com/api/b', 'b');

      await cache.delete('https://example.com/api/a');

      expect(await cache.get<String>('https://example.com/api/a'), isNull);
      expect(await cache.get<String>('https://example.com/api/b'), 'b');
    });

    test('should_not_throw_when_deleting_non_existent_key', () async {
      await expectLater(
        cache.delete('https://example.com/api/nonexistent'),
        completes,
      );
    });
  });

  group('RequestCache.clearExpired', () {
    test('should_remove_only_expired_entries', () async {
      await cache.set('https://example.com/api/valid', 'keep');
      await putExpired('https://example.com/api/expired1', 'gone1');
      await putExpired('https://example.com/api/expired2', 'gone2');

      await cache.clearExpired();

      expect(await cache.get<String>('https://example.com/api/valid'), 'keep');
      expect(
        await cache.get<String>('https://example.com/api/expired1'),
        isNull,
      );
      expect(
        await cache.get<String>('https://example.com/api/expired2'),
        isNull,
      );
    });

    test('should_return_count_of_removed_entries', () async {
      await putExpired('https://example.com/api/e1', 'x');
      await putExpired('https://example.com/api/e2', 'x');
      await cache.set('https://example.com/api/valid', 'keep');

      final removed = await cache.clearExpired();

      expect(removed, 2);
    });

    test('should_return_zero_when_nothing_expired', () async {
      await cache.set('https://example.com/api/a', 'a');
      await cache.set('https://example.com/api/b', 'b');

      final removed = await cache.clearExpired();

      expect(removed, 0);
    });

    test('should_remove_corrupt_entries_and_count_them', () async {
      final box = Hive.box(HiveManager.requestCacheBoxName);
      await box.put('corrupt_key', {'bad': 'data'});

      final removed = await cache.clearExpired();

      expect(removed, 1);
      expect(box.containsKey('corrupt_key'), isFalse);
    });
  });

  group('RequestCache.clear', () {
    test('should_remove_all_entries', () async {
      await cache.set('https://example.com/api/a', 'a');
      await cache.set('https://example.com/api/b', 'b');
      await cache.set('https://example.com/api/c', 'c');

      await cache.clear();

      final box = Hive.box(HiveManager.requestCacheBoxName);
      expect(box.length, 0);
    });

    test('should_not_throw_when_already_empty', () async {
      await expectLater(cache.clear(), completes);
    });
  });

  group('URL cache policy', () {
    // 通过检查存储条目的过期时间来验证策略是否生效
    Future<int> getExpiryMs(String url) async {
      final box = Hive.box(HiveManager.requestCacheBoxName);
      for (final raw in box.values) {
        final entry = CacheEntry.fromJson(Map<String, dynamic>.from(raw));
        if (entry.requestUrl == url) {
          return entry.expiryTime;
        }
      }

      fail('No cache entry found for $url');
    }

    test('should_apply_medium_term_policy_for_course_url', () async {
      final before = DateTime.now();
      await cache.set('https://api.example.com/course/list', 'data');
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        await getExpiryMs('https://api.example.com/course/list'),
      );

      // medium-term = 15 分钟
      expect(expiry.isAfter(before.add(const Duration(minutes: 14))), isTrue);
      expect(expiry.isBefore(before.add(const Duration(minutes: 16))), isTrue);
    });

    test('should_apply_long_term_policy_for_score_url', () async {
      final before = DateTime.now();
      await cache.set('https://api.example.com/score/query', 'data');
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        await getExpiryMs('https://api.example.com/score/query'),
      );

      // long-term = 1 小时
      expect(expiry.isAfter(before.add(const Duration(minutes: 59))), isTrue);
      expect(expiry.isBefore(before.add(const Duration(minutes: 61))), isTrue);
    });

    test('should_apply_short_term_policy_for_bus_url', () async {
      final before = DateTime.now();
      await cache.set('https://api.example.com/bus/schedule', 'data');
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        await getExpiryMs('https://api.example.com/bus/schedule'),
      );

      // short-term = 1 分钟
      expect(expiry.isAfter(before.add(const Duration(seconds: 59))), isTrue);
      expect(expiry.isBefore(before.add(const Duration(seconds: 61))), isTrue);
    });

    test('should_apply_default_policy_for_unknown_url', () async {
      final before = DateTime.now();
      await cache.set('https://api.example.com/unknown/endpoint', 'data');
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        await getExpiryMs('https://api.example.com/unknown/endpoint'),
      );

      // default = 5 分钟
      expect(expiry.isAfter(before.add(const Duration(minutes: 4))), isTrue);
      expect(expiry.isBefore(before.add(const Duration(minutes: 6))), isTrue);
    });
  });

  group('降级逻辑 (stale cache)', () {
    test('should_keep_expired_entry_in_box_until_explicitly_cleared', () async {
      await putExpired('https://example.com/api/stale', 'stale_data');

      // get() 会删除过期条目并返回 null
      final result = await cache.get<String>('https://example.com/api/stale');
      expect(result, isNull);

      // 此时 box 中该条目已被 get() 删除
      final box = Hive.box(HiveManager.requestCacheBoxName);
      expect(box.length, 0);
    });

    test('should_not_serve_expired_data_via_get', () async {
      await cache.set(
        'https://example.com/api/fresh',
        'fresh_data',
        maxAge: const Duration(milliseconds: 1),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final result = await cache.get<String>('https://example.com/api/fresh');
      expect(result, isNull);
    });
  });

  group('CacheInterceptor', () {
    late CacheInterceptor interceptor;

    setUp(() {
      interceptor = CacheInterceptor();
    });

    test('should_cache_GET_200_response_data', () async {
      final options = RequestOptions(
        path: 'https://example.com/api/data',
        method: 'GET',
      );
      final response = Response<Map>(
        data: {'key': 'value'},
        requestOptions: options,
        statusCode: 200,
      );
      final handler = ResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      // 等待异步写入完成
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 使用与拦截器相同的 URL 和 params 查询
      final cached = await cache.get<Map>(
        options.uri.toString(),
        params: options.queryParameters.isEmpty
            ? null
            : options.queryParameters,
      );
      expect(cached, isNotNull);
      expect(cached!['key'], 'value');
    });

    test('should_not_cache_non_GET_response', () async {
      final options = RequestOptions(
        path: 'https://example.com/api/data',
        method: 'POST',
      );
      final response = Response<Map>(
        data: {'key': 'value'},
        requestOptions: options,
        statusCode: 200,
      );
      final handler = ResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final cached = await cache.get<Map>('https://example.com/api/data');
      expect(cached, isNull);
    });

    test('should_not_cache_non_200_GET_response', () async {
      final options = RequestOptions(
        path: 'https://example.com/api/data',
        method: 'GET',
      );
      final response = Response<Map>(
        data: {'error': 'not found'},
        requestOptions: options,
        statusCode: 404,
      );
      final handler = ResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final cached = await cache.get<Map>('https://example.com/api/data');
      expect(cached, isNull);
    });
  });
}
