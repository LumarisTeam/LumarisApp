import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    container = ProviderContainer(
      overrides: [
        tileConfigurationReaderProvider.overrideWithValue(
          () async => TileConfigurationList.defaultConfig(),
        ),
        tileConfigurationWriterProvider.overrideWithValue((config) async {}),
        availableTilesReaderProvider.overrideWithValue(
          () => const ['电费', '校车', '饭卡'],
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> waitForLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  TileEditNotifier controller() =>
      container.read(tileEditControllerProvider.notifier);

  group('TileEditController', () {
    test('should_initialize_with_default_configuration', () async {
      final store = controller();
      await waitForLoad();
      final state = container.read(tileEditControllerProvider);

      expect(state.isEditMode, false);
      expect(state.config.configurations.length, 3);
      expect(state.isLoading, false);
      expect(store.visibleTiles, hasLength(3));
    });

    test('should_toggle_edit_mode_on_and_off', () async {
      final store = controller();
      await waitForLoad();

      expect(container.read(tileEditControllerProvider).isEditMode, false);

      await store.toggleEditMode();
      expect(container.read(tileEditControllerProvider).isEditMode, true);

      await store.toggleEditMode();
      expect(container.read(tileEditControllerProvider).isEditMode, false);
    });

    test('should_reorder_tiles_correctly', () async {
      final store = controller();
      await waitForLoad();

      final initialOrder = store.visibleTiles.map((t) => t.id).toList();
      expect(initialOrder[0], '电费');

      await store.reorderTile('电费', 0, 2);

      final newOrder = store.visibleTiles.map((t) => t.id).toList();
      expect(newOrder[0], '校车');
      expect(newOrder[2], '电费');
    });

    test('should_toggle_tile_visibility', () async {
      final store = controller();
      await waitForLoad();

      expect(store.visibleTiles.length, 3);
      expect(store.isTileVisible('电费'), true);

      await store.toggleVisibility('电费');

      expect(store.visibleTiles.length, 2);
      expect(store.isTileVisible('电费'), false);
    });

    test('should_force_exit_edit_mode_and_save', () async {
      final store = controller();
      await waitForLoad();

      await store.toggleEditMode();
      expect(container.read(tileEditControllerProvider).isEditMode, true);

      await store.forceExitEditMode();
      expect(container.read(tileEditControllerProvider).isEditMode, false);
    });

    test('should_reload_configuration_from_storage', () async {
      final store = controller();
      await waitForLoad();

      final initialCount = container
          .read(tileEditControllerProvider)
          .config
          .configurations
          .length;

      await store.reload();

      expect(
        container.read(tileEditControllerProvider).config.configurations.length,
        initialCount,
      );
    });

    test('should_get_visible_tiles_list', () async {
      final store = controller();
      await waitForLoad();

      final visible = store.visibleTiles;

      expect(visible.length, 3);
      expect(visible.every((t) => t.isVisible), true);
    });

    test('should_get_all_tiles_list', () async {
      final store = controller();
      await waitForLoad();

      final all = store.allTiles;

      expect(all.length, 3);
    });

    test('should_check_if_tile_is_visible', () async {
      final store = controller();
      await waitForLoad();

      expect(store.isTileVisible('电费'), true);
      expect(store.isTileVisible('不存在'), false);
    });
  });
}
