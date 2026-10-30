import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/apis/login_api.dart';
import 'package:ios_club_app/state/auth_state_notifier.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppAnimations', () {
    test('should provide expected constants and delay cap', () {
      expect(AppAnimations.fast, const Duration(milliseconds: 120));
      expect(AppAnimations.standard, const Duration(milliseconds: 240));
      expect(AppAnimations.extraSlow, const Duration(milliseconds: 1000));

      expect(
        AppAnimations.getListItemDelay(2),
        const Duration(milliseconds: 48),
      );
      expect(
        AppAnimations.getListItemDelay(20),
        AppAnimations.listItemMaxDelay,
      );
      expect(AppAnimations.slideOffset, 8.0);
      expect(AppAnimations.pressScale, 0.98);
      expect(AppAnimations.secondaryOpacity, 0.6);
    });
  });

  group('TimeService', () {
    test('should use Caotang schedule for Caotang campus', () {
      final course = CourseModel(
        campus: '草堂校区',
        room: 'A101',
        startUnit: 1,
        endUnit: 2,
      );
      final result = TimeService.getStartAndEnd(course);

      expect(result.start, TimeService.CanTangTimeStart[1]);
      expect(result.end, TimeService.CanTangTimeEnd[2]);
    });

    test('should use Caotang schedule when room starts with 草堂', () {
      final course = CourseModel(
        campus: '雁塔校区',
        room: '草堂-101',
        startUnit: 3,
        endUnit: 4,
      );
      final result = TimeService.getStartAndEnd(course);

      expect(result.start, TimeService.CanTangTimeStart[3]);
      expect(result.end, TimeService.CanTangTimeEnd[4]);
    });

    test('should use Yanta schedule for non-Caotang campus', () {
      final course = CourseModel(
        campus: '雁塔校区',
        room: '主楼201',
        startUnit: 1,
        endUnit: 2,
      );
      final result = TimeService.getStartAndEnd(course);

      // Current month in test runtime determines summer/winter table.
      final winterStart = TimeService.YanTaDongStart[1];
      final winterEnd = TimeService.YanTaDongEnd[2];
      final summerStart = TimeService.YanTaXiaStart[1];
      final summerEnd = TimeService.YanTaXiaEnd[2];

      expect(<String>[winterStart, summerStart], contains(result.start));
      expect(<String>[winterEnd, summerEnd], contains(result.end));
    });
  });

  group('AuthStateNotifier', () {
    test('should transition states and auto-reset after delay', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(authStateNotifierProvider.notifier);

        notifier.startRelogging();
        expect(notifier.authState, AuthState.relogging);
        expect(notifier.isRelogging, isTrue);

        notifier.relogSuccess();
        expect(notifier.authState, AuthState.relogSuccess);
        expect(notifier.relogMessage, '重新登录成功');

        async.elapse(const Duration(seconds: 2));
        expect(notifier.authState, AuthState.normal);
        expect(notifier.relogMessage, '');

        notifier.relogFailed('bad credentials');
        expect(notifier.authState, AuthState.relogFailed);
        expect(notifier.relogMessage, '重新登录失败: bad credentials');

        async.elapse(const Duration(seconds: 5));
        expect(notifier.authState, AuthState.normal);
        expect(notifier.relogMessage, '');
      });
    });

    test('reset should restore normal state immediately', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authStateNotifierProvider.notifier);
      notifier.startRelogging();
      notifier.reset();

      expect(notifier.authState, AuthState.normal);
      expect(notifier.relogMessage, '');
    });
  });

  group('LoginApi', () {
    late Directory tempDir;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();
      tempDir = await Directory.systemTemp.createTemp('login_service_test_');
      Hive.init(tempDir.path);
    });

    tearDownAll(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should throw NetworkException when login request fails', () async {
      await expectLater(
        () => LoginApi.login('u1', 'p1'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
