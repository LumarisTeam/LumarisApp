import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Directory? tempDir;

  ProviderContainer createContainer(List<Override> overrides) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();

    if (!Hive.isBoxOpen(HiveManager.requestCacheBoxName)) {
      tempDir = await Directory.systemTemp.createTemp(
        'manual_refresh_behavior_test_',
      );
      Hive.init(tempDir!.path);
      await Hive.openBox(HiveManager.requestCacheBoxName);
    }
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    await RequestCache.instance.clear();
  });

  tearDownAll(() async {
    if (tempDir != null) {
      await Hive.close();
      if (await tempDir!.exists()) {
        await tempDir!.delete(recursive: true);
      }
    }
  });

  group('manual refresh retention', () {
    test('ProgramPageNotifier should retain old data when refresh fails',
        () async {
      final programs = [
        PlanCourseList(
          term: '1',
          courses: [
            PlanCourse(
              name: '高等数学',
              courseTypeName: '必修',
              credits: 4,
              examMode: '考试',
            ),
          ],
        ),
      ];
      final container = createContainer([
        programAutoLoadProvider.overrideWithValue(false),
        programsFetcherProvider.overrideWithValue(
          ({bool forceRefresh = false}) async {
            if (forceRefresh) {
              throw Exception('refresh failed');
            }
            return programs;
          },
        ),
      ]);
      final store = container.read(programControllerProvider.notifier);

      await store.loadPrograms();
      await store.refreshPrograms();

      final state = container.read(programControllerProvider);
      expect(state.programs, hasLength(1));
      expect(state.programs.single.courses.single.name, '高等数学');
      expect(state.isError, isFalse);
      expect(state.errorMessage, isNotEmpty);
    });

    test('BusPageNotifier should retain old data when refresh fails', () async {
      final initialModel = BusModel(
        total: 1,
        records: [
          BusItem(
            lineName: '草堂-雁塔',
            description: 'A1',
            departureStation: '雁塔',
            arrivalStation: '草堂',
            runTime: '23:59:00',
            arrivalStationTime: '01:00',
          ),
        ],
      );
      final container = createContainer([
        busPageAutoLoadProvider.overrideWithValue(false),
        busPageFetcherProvider.overrideWithValue(
          ({String? dayDate, bool forceRefresh = false}) async {
            if (forceRefresh) {
              throw Exception('refresh failed');
            }
            return initialModel;
          },
        ),
      ]);
      final store = container.read(busControllerProvider.notifier);

      await store.selectDateByIndex(0);
      await store.refreshData();

      final state = container.read(busControllerProvider);
      expect(state.busData, hasLength(1));
      expect(state.todayBusData, hasLength(1));
      expect(state.busData.single.lineName, '草堂-雁塔');
      expect(state.errorMessage, '刷新失败，已保留上次校车数据');
    });
  });
}
