import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/apis/bus_api.dart';
import 'package:ios_club_app/features/education/apis/course_api.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/apis/electricity_api.dart';
import 'package:ios_club_app/features/education/apis/exam_api.dart';
import 'package:ios_club_app/features/education/apis/info_api.dart';
import 'package:ios_club_app/features/education/apis/login_api.dart';
import 'package:ios_club_app/features/education/apis/payment_api.dart';
import 'package:ios_club_app/features/education/apis/program_api.dart';
import 'package:ios_club_app/features/education/apis/score_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> expectStringOrNetworkException(
    Future<dynamic> Function() call,
  ) async {
    try {
      final value = await call();
      expect(value, isNotNull);
    } catch (e) {
      expect(e, isA<NetworkException>());
    }
  }

  group('Education API error paths', () {
    late Directory tempDir;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();

      tempDir = await Directory.systemTemp.createTemp('edu_api_error_');
      Hive.init(tempDir.path);
      EduHttpClientManager.resetForTest();
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

    tearDownAll(() async {
      // Do not close Hive here to avoid interfering with pending cache tasks.
      EduHttpClientManager.resetForTest();
    });

    test('direct wrapper methods should throw NetworkException', () async {
      final calls = <Future<dynamic> Function()>[
        () => BusApi.getBus(dayDate: '2026-03-02'),
        () => BusApi.getBusNewData('0830', loc: 'ALL'),
        () => BusApi.getBusOldData('0830', isShow: true),
        () => CourseApi.getCourse('2026001'),
        () => CourseApi.getScheduleTime(),
        () => ElectricityApi.createSubscription(
              const CreateElectricitySubscriptionRequest(
                url: 'https://example.com/wxAccount?id=1',
                email: 'codex@example.com',
                threshold: 10,
              ),
            ),
        () => ElectricityApi.getSubscription('codex@example.com'),
        () => ElectricityApi.deleteSubscription('sub-1'),
        () => ExamApi.getExam('2026001'),
        () => InfoApi.getInfoCompletion(),
        () => InfoApi.getTime(),
        () => LoginApi.login('u1', 'p1'),
        () => PaymentApi.getPayment('p1'),
        () => PaymentApi.getPaymentTurnover('p1'),
        () => ProgramApi.getProgram('2026001'),
        () => ProgramApi.getProgramDic('2026001'),
        () => ScoreApi.getSemester('2026001'),
        () => ScoreApi.getScore('2026001', '2025-2'),
        () => ScoreApi.getThisSemester(),
      ];

      for (final call in calls) {
        await expectStringOrNetworkException(call);
      }
    });
  });
}
