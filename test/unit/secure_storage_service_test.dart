import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    store.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SecureStorageService', () {
    test('should write read delete and deleteAll successfully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'write':
                final key = call.arguments['key'] as String;
                final value = call.arguments['value'] as String?;
                if (value != null) {
                  store[key] = value;
                }
                return null;
              case 'read':
                return store[call.arguments['key'] as String];
              case 'delete':
                store.remove(call.arguments['key'] as String);
                return null;
              case 'deleteAll':
                store.clear();
                return null;
              default:
                return null;
            }
          });

      final service = SecureStorageService.instance;
      expect(await service.write(key: 'k1', value: 'v1'), isTrue);
      expect(await service.read(key: 'k1'), 'v1');

      expect(await service.delete(key: 'k1'), isTrue);
      expect(await service.read(key: 'k1'), isNull);

      expect(await service.write(key: 'a', value: '1'), isTrue);
      expect(await service.write(key: 'b', value: '2'), isTrue);
      expect(await service.deleteAll(), isTrue);
      expect(await service.read(key: 'a'), isNull);
      expect(await service.read(key: 'b'), isNull);
    });

    test('write with null should fallback to delete behavior', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'write') {
              final key = call.arguments['key'] as String;
              final value = call.arguments['value'] as String?;
              if (value == null) {
                store.remove(key);
              } else {
                store[key] = value;
              }
            }
            if (call.method == 'delete') {
              store.remove(call.arguments['key'] as String);
            }
            if (call.method == 'read') {
              return store[call.arguments['key'] as String];
            }
            return null;
          });

      final service = SecureStorageService.instance;
      expect(await service.write(key: 'k2', value: 'v2'), isTrue);
      expect(await service.read(key: 'k2'), 'v2');

      expect(await service.write(key: 'k2', value: null), isTrue);
      expect(await service.read(key: 'k2'), isNull);
    });

    test(
      'should swallow platform exceptions and expose failure status',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              throw PlatformException(code: 'err', message: 'mock error');
            });

        final service = SecureStorageService.instance;
        expect(await service.write(key: 'k3', value: 'v3'), Platform.isMacOS);
        expect(await service.delete(key: 'k3'), Platform.isMacOS);
        expect(await service.deleteAll(), Platform.isMacOS);

        final result = await service.read(key: 'k3');
        expect(result, isNull);
      },
    );
  });
}
