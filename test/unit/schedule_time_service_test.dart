import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/schedule_time_model.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/schedule_time_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 远端下发的作息表。时间故意与内置表不同，用来断言"生效的是远端数据"。
const List<Map<String, dynamic>> _remotePayload = [
  {
    'campusName': '草堂校区',
    'start': ['', '7:07'],
    'end': ['', '7:57'],
  },
  {
    'campusName': '雁塔校区',
    'time': '10/01~04/30',
    'start': ['', '8:08'],
    'end': ['', '8:58'],
  },
  {
    'campusName': '雁塔校区',
    'time': '05/01~09/30',
    'start': ['', '9:09'],
    'end': ['', '9:59'],
  },
];

List<ScheduleTable> _tablesFrom(List<Map<String, dynamic>> payload) => payload
    .map((json) => ScheduleTable.fromModel(ScheduleTimeModel.fromJson(json)))
    .toList();

CourseModel _course({
  String campus = '草堂校区',
  String room = 'A101',
  int startUnit = 1,
  int endUnit = 1,
}) =>
    CourseModel(
      campus: campus,
      room: room,
      startUnit: startUnit,
      endUnit: endUnit,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    tempDir = await Directory.systemTemp.createTemp('schedule_time_service_');
    Hive.init(tempDir.path);
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    await RequestCache.instance.clear();
    EduHttpClientManager.resetForTest();
    TimeService.useBuiltInTables();
    final manager = EduHttpClientManager.initialize();
    manager.updateSchoolConfig(
      School(
        code: 'test',
        name: 'Test',
        website: 'http://api.test',
        features: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  tearDown(() {
    TimeService.useBuiltInTables();
    EduHttpClientManager.resetForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ScheduleTimeService', () {
    test('fetchFromRemote should install remote tables and cache them',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/v1/course/ScheduleTime');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _remotePayload,
              ),
            );
          },
        ),
      );

      final ok = await ScheduleTimeService.fetchFromRemote();

      expect(ok, isTrue);
      expect(TimeService.isUsingRemoteTables, isTrue);
      expect(TimeService.getStartAndEnd(_course()).start, '7:07');

      final cached = PrefsService.instance
          .getString(PrefsKeys.SCHEDULE_TIME_DATA);
      expect(cached, isNotNull);
      expect(jsonDecode(cached!), hasLength(_remotePayload.length));
    });

    test('fetchFromRemote should keep built-in tables when the API fails',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 500,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final ok = await ScheduleTimeService.fetchFromRemote();

      expect(ok, isFalse);
      expect(TimeService.isUsingRemoteTables, isFalse);
      expect(
        TimeService.getStartAndEnd(_course()).start,
        TimeService.CanTangTimeStart[1],
      );
    });

    test('loadFromCache should install the persisted tables', () async {
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_TIME_DATA,
        jsonEncode(_remotePayload),
      );

      await ScheduleTimeService.loadFromCache();

      expect(TimeService.isUsingRemoteTables, isTrue);
      expect(TimeService.getStartAndEnd(_course()).start, '7:07');
    });

    test('loadFromCache should ignore a broken cache', () async {
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_TIME_DATA,
        'not-json',
      );

      await ScheduleTimeService.loadFromCache();

      expect(TimeService.isUsingRemoteTables, isFalse);
      expect(
        TimeService.getStartAndEnd(_course()).start,
        TimeService.CanTangTimeStart[1],
      );
    });

    test('loadFromCache should do nothing when there is no cache', () async {
      await ScheduleTimeService.loadFromCache();

      expect(TimeService.isUsingRemoteTables, isFalse);
      expect(TimeService.tables, TimeService.builtInTables);
    });

    test('ensureLoaded should install from cache and skip once installed',
        () async {
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_TIME_DATA,
        jsonEncode(_remotePayload),
      );

      await ScheduleTimeService.ensureLoaded();

      expect(TimeService.isUsingRemoteTables, isTrue);
      expect(TimeService.getStartAndEnd(_course()).start, '7:07');

      // 已装载远端表后再调用是空操作，缓存被清掉也不会退回内置表
      await PrefsService.instance.remove(PrefsKeys.SCHEDULE_TIME_DATA);
      await ScheduleTimeService.ensureLoaded();

      expect(TimeService.isUsingRemoteTables, isTrue);
      expect(TimeService.getStartAndEnd(_course()).start, '7:07');
    });
  });

  group('TimeService 表选择', () {
    test('should pick the season table by the date range', () {
      TimeService.installTables(_tablesFrom(_remotePayload));
      final yanta = _course(campus: '雁塔校区', room: '主楼201');

      for (final summer in [
        DateTime(2026, 5, 1),
        DateTime(2026, 6, 15),
        DateTime(2026, 9, 30),
      ]) {
        expect(
          TimeService.getStartAndEnd(yanta, date: summer).start,
          '9:09',
          reason: '$summer 应走夏季表',
        );
      }

      // 10/01~04/30 跨年
      for (final winter in [
        DateTime(2026, 10, 1),
        DateTime(2026, 12, 31),
        DateTime(2026, 1, 15),
        DateTime(2026, 4, 30),
      ]) {
        expect(
          TimeService.getStartAndEnd(yanta, date: winter).start,
          '8:08',
          reason: '$winter 应走冬季表',
        );
      }
    });

    test('built-in tables should keep the legacy month rule', () {
      // 雁塔第 7 节冬夏时间不同，用来区分走的是哪张表
      final yanta = _course(
        campus: '雁塔校区',
        room: '主楼201',
        startUnit: 7,
        endUnit: 7,
      );

      expect(
        TimeService.getStartAndEnd(yanta, date: DateTime(2026, 7, 1)).start,
        TimeService.YanTaXiaStart[7],
      );
      expect(
        TimeService.getStartAndEnd(yanta, date: DateTime(2026, 1, 1)).start,
        TimeService.YanTaDongStart[7],
      );
    });

    test('should fall back to built-in tables when a campus is missing', () {
      TimeService.installTables(_tablesFrom([
        {
          'campusName': '未知校区',
          'start': ['', '1:11'],
          'end': ['', '1:12'],
        },
      ]));

      expect(TimeService.isUsingRemoteTables, isTrue);
      expect(
        TimeService.getStartAndEnd(_course()).start,
        TimeService.CanTangTimeStart[1],
      );

      final yanta = _course(
        campus: '雁塔校区',
        room: '主楼201',
        startUnit: 7,
        endUnit: 7,
      );
      expect(
        TimeService.getStartAndEnd(yanta, date: DateTime(2026, 7, 1)).start,
        TimeService.YanTaXiaStart[7],
      );
    });

    test('should fall back to Caotang time when the period is out of range',
        () {
      TimeService.installTables(const [
        ScheduleTable(
          campusName: TimeService.caoTangCampus,
          start: ['8:00', '8:30', '9:20', '10:25', '11:15'],
          end: ['8:20', '9:15', '10:05', '11:10', '12:00'],
        ),
        ScheduleTable(
          campusName: TimeService.yanTaCampus,
          timeRange: '05/01~09/30',
          start: ['', '9:00'],
          end: ['', '9:50'],
        ),
      ]);

      final summer = DateTime(2026, 7, 1);
      // 雁塔表只到第 1 节，第 4 节退回草堂
      final outOfRange = TimeService.getStartAndEndForCampus(
        campus: TimeService.yanTaCampus,
        startUnit: 4,
        endUnit: 4,
        date: summer,
      );
      expect(outOfRange.start, '11:15');
      expect(outOfRange.end, '12:00');

      // 表内为空串表示该节次没课，保持空串而不是回退草堂
      final empty = TimeService.getStartAndEndForCampus(
        campus: TimeService.yanTaCampus,
        startUnit: 0,
        endUnit: 0,
        date: summer,
      );
      expect(empty.start, '');
      expect(empty.end, '');

      // 草堂自己越界时没有可退的表
      final caoTang = TimeService.getStartAndEndForCampus(
        campus: TimeService.caoTangCampus,
        startUnit: 99,
        endUnit: 99,
        date: summer,
      );
      expect(caoTang.start, '');
      expect(caoTang.end, '');
    });

    test('installing an empty list should restore built-in tables', () {
      TimeService.installTables(_tablesFrom(_remotePayload));
      expect(TimeService.isUsingRemoteTables, isTrue);

      TimeService.installTables(const []);

      expect(TimeService.isUsingRemoteTables, isFalse);
      expect(
        TimeService.getStartAndEnd(_course()).start,
        TimeService.CanTangTimeStart[1],
      );
    });
  });
}
