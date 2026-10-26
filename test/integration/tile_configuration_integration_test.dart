import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test for tile configuration feature
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tile Configuration Integration Test', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PrefsService.init();
    });

    test('complete_workflow_test', () async {
      if (kDebugMode) {
        print('=== Starting Integration Test ===');
      }

      // 1. Load default configuration
      if (kDebugMode) {
        print('\n1. Loading default configuration...');
      }
      var config = await TileService.getTileConfigurations();
      if (kDebugMode) {
        print('   Loaded ${config.configurations.length} tiles');
      }
      expect(config.configurations.length, 3);

      // 2. Reorder tiles
      if (kDebugMode) {
        print('\n2. Reordering tiles...');
      }
      if (kDebugMode) {
        print(
          '   Before: ${config.getVisibleTiles().map((t) => t.id).toList()}',
        );
      }
      await TileService.reorderTile('电费', 0, 2);
      config = await TileService.getTileConfigurations();
      if (kDebugMode) {
        print(
          '   After: ${config.getVisibleTiles().map((t) => t.id).toList()}',
        );
      }
      expect(config.getVisibleTiles()[0].id, '校车');
      expect(config.getVisibleTiles()[2].id, '电费');

      // 3. Hide a tile
      if (kDebugMode) {
        print('\n3. Hiding a tile...');
        print('   Visible before: ${config.getVisibleTiles().length}');
      }
      await TileService.toggleTileVisibility('校车');
      config = await TileService.getTileConfigurations();
      if (kDebugMode) {
        print('   Visible after: ${config.getVisibleTiles().length}');
      }
      expect(config.getVisibleTiles().length, 2);
      expect(config.getVisibleTiles().any((t) => t.id == '校车'), false);

      // 4. Show the tile again
      if (kDebugMode) {
        print('\n4. Showing the tile again...');
      }
      await TileService.toggleTileVisibility('校车');
      config = await TileService.getTileConfigurations();
      if (kDebugMode) {
        print('   Visible after: ${config.getVisibleTiles().length}');
      }
      expect(config.getVisibleTiles().length, 3);
      expect(config.getVisibleTiles().any((t) => t.id == '校车'), true);

      // 5. Verify persistence
      if (kDebugMode) {
        print('\n5. Verifying persistence...');
      }
      final reloaded = await TileService.getTileConfigurations();
      if (kDebugMode) {
        print('   Reloaded ${reloaded.configurations.length} tiles');
      }
      expect(reloaded.configurations.length, 3);

      // 6. Reset to default
      if (kDebugMode) {
        print('\n6. Resetting to default...');
      }
      await TileService.resetToDefault();
      config = await TileService.getTileConfigurations();
      if (kDebugMode) {
        print('   Reset complete, ${config.configurations.length} tiles');
      }
      expect(config.configurations.length, 3);
      expect(config.getVisibleTiles()[0].id, '电费');

      if (kDebugMode) {
        print('\n=== Integration Test Complete ===');
        print('✅ All operations working correctly!');
      }
    });
  });
}
