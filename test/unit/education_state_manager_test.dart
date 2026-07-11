import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  tearDown(EduHttpClientManager.resetForTest);

  group('EduHttpClientManager', () {
    test('should initialize with default school url when settings is missing',
        () {
      EduHttpClientManager.initialize();
      expect(
        EduHttpClientManager.instance.baseUrl,
        School.fallbackList.first.website,
      );
    });

    test('should update school config and reinitialize back to settings value',
        () async {
      final container = createContainer();
      final settings = container.read(settingsStoreProvider.notifier);
      expect(settings.schoolId, School.defaultCode);

      final manager = EduHttpClientManager.initialize(
        school: settings.currentSchool,
      );
      final custom = School(
        code: 'xauat',
        name: '自定义',
        website: 'https://custom.edu.example',
        features: [Feature.timetable],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      manager.updateSchoolConfig(custom);
      expect(EduHttpClientManager.instance.baseUrl, custom.website);

      manager.reinitialize(school: settings.currentSchool);
      expect(
        EduHttpClientManager.instance.baseUrl,
        School.fallbackList.first.website,
      );
    });
  });

  group('State Stores', () {
    test('ElectricityStore.toggleTile should update local tile list', () async {
      final touchedTiles = <String>[];
      final container = createContainer(overrides: [
        tileStoreAutoLoadProvider.overrideWithValue(false),
        electricityTileAdderProvider.overrideWithValue(
            (tileId) async => touchedTiles.add('add:$tileId')),
        electricityTileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
        tileConfigurationReaderProvider.overrideWithValue(
          () async => throw StateError('not needed'),
        ),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.toggleTile('电费', false);
      expect(container.read(electricityStoreProvider).tiles,
          isNot(contains('电费')));

      await store.toggleTile('电费', true);
      expect(container.read(electricityStoreProvider).tiles, contains('电费'));
      expect(touchedTiles, ['remove:电费', 'add:电费']);
    });

    test('PaymentStore.toggleTileShow should switch local state', () async {
      final touchedTiles = <String>[];
      final container = createContainer(overrides: [
        tileAdderProvider.overrideWithValue(
            (tileId) async => touchedTiles.add('add:$tileId')),
        tileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
        tileConfigurationReaderProvider.overrideWithValue(
          () async => throw StateError('not needed'),
        ),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.toggleTileShow(false);
      expect(container.read(paymentStoreProvider).isShowTile, isFalse);

      await store.toggleTileShow(true);
      expect(container.read(paymentStoreProvider).isShowTile, isTrue);
      expect(touchedTiles, ['remove:饭卡', 'add:饭卡']);
    });
  });
}
