import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/apis/login_api.dart';
import 'package:ios_club_app/features/education/models/login_response.dart';
import 'package:ios_club_app/features/education/services/auth_service.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';
import 'package:ios_club_app/features/education/services/education_refresh_service.dart';
import 'package:ios_club_app/features/education/services/exam_service.dart';
import 'package:ios_club_app/features/education/services/score_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CourseModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ScoreModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ScoreListAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(SemesterModelAdapter());
  }
}

void mockEduResponse({
  required String path,
  required dynamic data,
  int statusCode = 200,
}) {
  EduHttpClientManager.instance.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == path) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
          );
          return;
        }
        handler.next(options);
      },
    ),
  );
}

CourseModel courseFixture({
  String lessonId = 'L1',
  String courseName = '软件工程',
  int weekday = 1,
}) {
  return CourseModel(
    lessonId: lessonId,
    courseName: courseName,
    weekIndexes: const [1, 2],
    teachers: const ['Teacher'],
    room: 'A101',
    weekday: weekday,
    startUnit: 1,
    endUnit: 2,
    campus: '雁塔校区',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();

    tempDir = await Directory.systemTemp.createTemp(
      'education_domain_services_test_',
    );
    Hive.init(tempDir.path);
    registerHiveAdapters();
  });

  setUp(() async {
    secureStore.clear();
    await PrefsService.instance.clear();
    EduHttpClientManager.resetForTest();
    EducationRefreshService.resetForTest();
    LoginApi.setLoginOverrideForTest(null);

    for (final boxName in <String>[
      'request_cache',
      'courses',
      'scores',
    ]) {
      final box = await Hive.openBox(boxName);
      await box.clear();
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final key = call.arguments['key'] as String?;
      switch (call.method) {
        case 'write':
          final value = call.arguments['value'] as String?;
          if (key != null && value != null) {
            secureStore[key] = value;
          }
          return null;
        case 'read':
          if (key == null) {
            return null;
          }
          return secureStore[key];
        case 'delete':
          if (key != null) {
            secureStore.remove(key);
          }
          return null;
        case 'deleteAll':
          secureStore.clear();
          return null;
      }
      return null;
    });

    final manager = EduHttpClientManager.initialize();
    manager.updateSchoolConfig(
      School(
        code: 'offline',
        name: 'Offline',
        website: 'http://127.0.0.1:1',
        features: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    LoginApi.setLoginOverrideForTest(null);
    EduHttpClientManager.resetForTest();
    EducationRefreshService.resetForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('education domain services', () {
    test('AuthService.loginFromData should persist login payload', () async {
      LoginApi.setLoginOverrideForTest(
        (_, __) async => LoginResponse(
          success: true,
          studentId: '2026888',
          cookie: 'cookie-auth-service',
        ),
      );

      final ok = await AuthService.loginFromData('u', 'p');

      expect(ok, isTrue);
      final storedUserData = jsonDecode(
        PrefsService.instance.getString(PrefsKeys.USER_DATA)!,
      ) as Map<String, dynamic>;
      expect(storedUserData, <String, dynamic>{
        'success': true,
        'studentId': '2026888',
        'cookie': 'cookie-auth-service',
      });
      expect(storedUserData.containsKey('data'), isFalse);
      expect(storedUserData.containsKey('code'), isFalse);
      expect(storedUserData.containsKey('message'), isFalse);
      expect(
          PrefsService.instance.getInt(PrefsKeys.LAST_FETCH_TIME), isNotNull);
    });

    test('CourseService.fetchCoursesFromRemote should persist repository data',
        () async {
      await CourseService.setIgnore(<String>['旧忽略']);
      mockEduResponse(
        path: '/Course',
        data: <String, dynamic>{
          'success': true,
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'lessonId': 'L1',
              'courseName': '软件工程',
              'weekIndexes': <int>[1, 2],
              'teachers': <String>['Teacher'],
              'room': 'A101',
              'weekday': 1,
              'startUnit': 1,
              'endUnit': 2,
              'campus': '雁塔校区',
            },
          ],
          'expirationTime': '2026-03-23T00:00:00.000',
        },
      );

      final courses = await CourseService.fetchCoursesFromRemote(
        userData: UserData(studentId: '2026001', cookie: 'cookie'),
      );

      expect(courses, hasLength(1));
      expect(courses.first.courseName, '软件工程');
      expect(await CourseRepository().getCourses(), hasLength(1));
      expect(await CourseService.getIgnore(), isEmpty);
    });

    test(
        'EducationRefreshService.loginAndRefresh should preload time and courses',
        () async {
      LoginApi.setLoginOverrideForTest(
        (_, __) async => LoginResponse(
          success: true,
          studentId: '2026999',
          cookie: 'cookie-refresh-service',
        ),
      );
      mockEduResponse(
        path: '/Score/Semester',
        data: <String, dynamic>{
          'data': <Map<String, String>>[
            <String, String>{'value': '2025-2', 'text': '2025-2'}
          ]
        },
      );
      mockEduResponse(
        path: '/Info/Time',
        data: <String, dynamic>{
          'startTime': '2026-02-20T00:00:00.000',
          'endTime': '2026-07-20T00:00:00.000',
        },
      );
      mockEduResponse(
        path: '/Exam',
        data: <String, dynamic>{
          'exams': <Map<String, dynamic>>[],
          'canClick': false,
          'error': null,
        },
      );
      mockEduResponse(path: '/Info/Completion', data: <Map<String, dynamic>>[]);
      mockEduResponse(
        path: '/Course',
        data: <String, dynamic>{
          'success': true,
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'lessonId': 'L2',
              'courseName': '数据库系统',
              'weekIndexes': <int>[1, 2],
              'teachers': <String>['Teacher'],
              'room': 'B202',
              'weekday': 2,
              'startUnit': 3,
              'endUnit': 4,
              'campus': '雁塔校区',
            },
          ],
          'expirationTime': '2026-03-23T00:00:00.000',
        },
      );

      final ok = await EducationRefreshService.loginAndRefresh('u', 'p');
      final week = await EduTimeService.getWeek();

      expect(ok, isTrue);
      expect(PrefsService.instance.getString(PrefsKeys.TIME_DATA), isNotNull);
      expect(await CourseRepository().getCourses(), hasLength(1));
      expect(week.maxWeek, greaterThan(0));
    });

    test(
        'EducationRefreshService.refreshWithExistingSession should bypass cache',
        () async {
      await PrefsService.instance.setString(
        PrefsKeys.USER_DATA,
        '{"studentId":"2026999","cookie":"cookie-refresh-service"}',
      );
      await PrefsService.instance.setInt(
        PrefsKeys.LAST_FETCH_TIME,
        DateTime.now().millisecondsSinceEpoch,
      );

      final seenPaths = <String>{};
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (<String>{
              '/Score/Semester',
              '/Info/Time',
              '/Exam',
              '/Info/Completion',
              '/Course',
            }.contains(options.path)) {
              expect(
                options.extra[CacheInterceptor.bypassCacheKey],
                isTrue,
                reason: 'Expected ${options.path} to bypass request cache',
              );
              seenPaths.add(options.path);
            }

            dynamic data;
            switch (options.path) {
              case '/Score/Semester':
                data = <String, dynamic>{
                  'data': <Map<String, String>>[
                    <String, String>{'value': '2025-2', 'text': '2025-2'}
                  ]
                };
              case '/Info/Time':
                data = <String, dynamic>{
                  'startTime': '2026-02-20T00:00:00.000',
                  'endTime': '2026-07-20T00:00:00.000',
                };
              case '/Exam':
                data = <String, dynamic>{
                  'exams': <Map<String, dynamic>>[],
                  'canClick': false,
                  'error': null,
                };
              case '/Info/Completion':
                data = <Map<String, dynamic>>[];
              case '/Course':
                data = <String, dynamic>{
                  'success': true,
                  'data': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'lessonId': 'L2',
                      'courseName': '数据库系统',
                      'weekIndexes': <int>[1, 2],
                      'teachers': <String>['Teacher'],
                      'room': 'B202',
                      'weekday': 2,
                      'startUnit': 3,
                      'endUnit': 4,
                      'campus': '雁塔校区',
                    },
                  ],
                  'expirationTime': '2026-03-23T00:00:00.000',
                };
              default:
                fail('Unexpected path ${options.path}');
            }

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: data,
              ),
            );
          },
        ),
      );

      final ok = await EducationRefreshService.refreshWithExistingSession();

      expect(ok, isTrue);
      expect(seenPaths, {
        '/Score/Semester',
        '/Info/Time',
        '/Exam',
        '/Info/Completion',
        '/Course',
      });
    });

    test('CourseService.getCourses should return local snapshot first',
        () async {
      await CourseRepository().saveCourses([
        courseFixture(courseName: '本地课程'),
      ]);
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            fail('localFirst should not request remote course data');
          },
        ),
      );

      final snapshot = await CourseService.getCourses();

      expect(snapshot.isFromLocal, isTrue);
      expect(snapshot.isStale, isFalse);
      expect(snapshot.data.single.courseName, '本地课程');
    });

    test(
        'CourseService.fetchCoursesFromRemote should fallback to local data '
        'when user data is missing', () async {
      await CourseRepository().saveCourses([
        courseFixture(courseName: '缓存课程'),
      ]);

      final courses = await CourseService.fetchCoursesFromRemote();

      expect(courses, hasLength(1));
      expect(courses.single.courseName, '缓存课程');
    });

    test('ScoreService.readSemestersFromPrefs should parse valid cache',
        () async {
      await PrefsService.instance.setString(
        PrefsKeys.SEMESTER_DATA,
        '{"data":[{"value":"2025-2","text":"2025-2026 第二学期"}]}',
      );

      final semesters = ScoreService.readSemestersFromPrefs();

      expect(semesters, hasLength(1));
      expect(semesters.single.semester, '2025-2');
      expect(semesters.single.name, '2025-2026 第二学期');
    });

    test('ScoreService.readSemestersFromPrefs should return empty on bad cache',
        () async {
      await PrefsService.instance.setString(
        PrefsKeys.SEMESTER_DATA,
        '{"data":{}}',
      );

      expect(ScoreService.readSemestersFromPrefs(), isEmpty);

      await PrefsService.instance.setString(
        PrefsKeys.SEMESTER_DATA,
        '{bad-json',
      );

      expect(ScoreService.readSemestersFromPrefs(), isEmpty);
    });

    test(
        'ScoreService.fetchScoresFromRemote should return sorted cached data '
        'when user data is missing', () async {
      await ScoreRepository().saveScores([
        ScoreList(
          semester: SemesterModel(semester: '2024-1', name: 'old'),
          list: [ScoreModel(lessonName: 'old-score')],
        ),
        ScoreList(
          semester: SemesterModel(semester: '2025-2', name: 'new'),
          list: [ScoreModel(lessonName: 'new-score')],
        ),
      ]);

      final scores = await ScoreService.fetchScoresFromRemote();

      expect(scores.map((item) => item.semester.semester), [
        '2025-2',
        '2024-1',
      ]);
    });

    test(
        'ExamService.getExamResult should return filtered merged exams on refresh',
        () async {
      await PrefsService.instance.setString(
        PrefsKeys.USER_DATA,
        '{"studentId":"2026001","cookie":"session"}',
      );
      await PrefsService.instance.setInt(
        PrefsKeys.LAST_FETCH_TIME,
        DateTime.now().millisecondsSinceEpoch,
      );
      await PrefsService.instance.setString(
        PrefsKeys.EXAM_DATA,
        '{"exams":[{"name":"缓存考试","time":"2099-06-10 09:00-11:00","location":"A101","seat":"01"}],"canClick":true}',
      );

      mockEduResponse(
        path: '/Exam',
        data: <String, dynamic>{
          'data': <Map<String, dynamic>>[
            {
              'name': '缓存考试',
              'time': '2099-06-10 09:00-11:00',
              'location': 'A101',
              'seat': '01',
            },
            {
              'name': '新增考试',
              'time': '2099-06-11 14:00-16:00',
              'location': 'B202',
              'seat': '02',
            },
            {
              'name': '过期考试',
              'time': '2000-06-11 08:00-10:00',
              'location': 'C303',
              'seat': '03',
            },
          ],
          'code': 0,
          'message': 'ok',
        },
      );

      final result = await ExamService.getExamResult(isRefresh: true);

      expect(result.isSuccess, isTrue);
      expect(result.exams.map((item) => item.name).toList(), [
        '缓存考试',
        '新增考试',
      ]);

      final cachedExamData =
          PrefsService.instance.getString(PrefsKeys.EXAM_DATA);
      expect(cachedExamData, isNotNull);
      expect(cachedExamData, isNot(contains('过期考试')));
      expect(cachedExamData, contains('新增考试'));
    });

    test('ScoreService.sortScores should order semesters descending', () {
      final sorted = ScoreService.sortScores([
        ScoreList(
          semester: SemesterModel(semester: '2023-2', name: 'a'),
          list: const [],
        ),
        ScoreList(
          semester: SemesterModel(semester: '2025-1', name: 'b'),
          list: const [],
        ),
      ]);

      expect(sorted.map((item) => item.semester.semester), [
        '2025-1',
        '2023-2',
      ]);
    });
  });
}
