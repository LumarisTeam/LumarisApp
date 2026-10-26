import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';

void main() {
  group('TileConfiguration', () {
    test('should_create_tile_configuration_with_required_fields', () {
      const tile = TileConfiguration(id: '电费', order: 0, isVisible: true);

      expect(tile.id, '电费');
      expect(tile.order, 0);
      expect(tile.isVisible, true);
    });

    test('should_serialize_to_json_correctly', () {
      const tile = TileConfiguration(id: '校车', order: 1, isVisible: false);

      final json = tile.toJson();

      expect(json['id'], '校车');
      expect(json['order'], 1);
      expect(json['isVisible'], false);
    });

    test('should_deserialize_from_json_correctly', () {
      final json = {'id': '饭卡', 'order': 2, 'isVisible': true};

      final tile = TileConfiguration.fromJson(json);

      expect(tile.id, '饭卡');
      expect(tile.order, 2);
      expect(tile.isVisible, true);
    });

    test('should_create_copy_with_modified_fields', () {
      const original = TileConfiguration(id: '电费', order: 0, isVisible: true);

      final modified = original.copyWith(order: 2, isVisible: false);

      expect(modified.id, '电费');
      expect(modified.order, 2);
      expect(modified.isVisible, false);
      expect(original.order, 0); // Original unchanged
    });

    test('should_compare_equality_correctly', () {
      const tile1 = TileConfiguration(id: '电费', order: 0, isVisible: true);

      const tile2 = TileConfiguration(id: '电费', order: 0, isVisible: true);

      const tile3 = TileConfiguration(id: '校车', order: 0, isVisible: true);

      expect(tile1, equals(tile2));
      expect(tile1, isNot(equals(tile3)));
    });

    test('should_have_consistent_hashcode', () {
      const tile1 = TileConfiguration(id: '电费', order: 0, isVisible: true);

      const tile2 = TileConfiguration(id: '电费', order: 0, isVisible: true);

      expect(tile1.hashCode, equals(tile2.hashCode));
    });

    test('should_convert_to_string_correctly', () {
      const tile = TileConfiguration(id: '电费', order: 0, isVisible: true);

      final str = tile.toString();

      expect(str, contains('电费'));
      expect(str, contains('0'));
      expect(str, contains('true'));
    });
  });

  group('TileConfigurationList', () {
    test('should_create_default_configuration', () {
      final config = TileConfigurationList.defaultConfig();

      expect(config.configurations.length, 3);
      expect(config.configurations[0].id, '电费');
      expect(config.configurations[1].id, '校车');
      expect(config.configurations[2].id, '饭卡');
      expect(config.configurations.every((t) => t.isVisible), true);
    });

    test('should_serialize_to_json_correctly', () {
      final config = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
          const TileConfiguration(id: '校车', order: 1, isVisible: false),
        ],
        lastModified: DateTime(2026, 2, 15, 10, 30),
      );

      final json = config.toJson();

      expect(json['configurations'], isA<List>());
      expect(json['configurations'].length, 2);
      expect(json['lastModified'], '2026-02-15T10:30:00.000');
    });

    test('should_deserialize_from_json_correctly', () {
      final json = {
        'configurations': [
          {'id': '电费', 'order': 0, 'isVisible': true},
          {'id': '校车', 'order': 1, 'isVisible': false},
        ],
        'lastModified': '2026-02-15T10:30:00.000',
      };

      final config = TileConfigurationList.fromJson(json);

      expect(config.configurations.length, 2);
      expect(config.configurations[0].id, '电费');
      expect(config.configurations[1].isVisible, false);
      expect(config.lastModified, DateTime(2026, 2, 15, 10, 30));
    });

    test('should_get_visible_tiles_sorted_by_order', () {
      final config = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 2, isVisible: true),
          const TileConfiguration(id: '校车', order: 0, isVisible: true),
          const TileConfiguration(id: '饭卡', order: 1, isVisible: false),
        ],
        lastModified: DateTime.now(),
      );

      final visible = config.getVisibleTiles();

      expect(visible.length, 2);
      expect(visible[0].id, '校车'); // order 0
      expect(visible[1].id, '电费'); // order 2
    });

    test('should_reorder_tile_correctly', () {
      final config = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
          const TileConfiguration(id: '校车', order: 1, isVisible: true),
          const TileConfiguration(id: '饭卡', order: 2, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );

      // Move "电费" from position 0 to position 2
      final reordered = config.reorderTile('电费', 0, 2);
      final visible = reordered.getVisibleTiles();

      expect(visible[0].id, '校车'); // Now at position 0
      expect(visible[1].id, '饭卡'); // Now at position 1
      expect(visible[2].id, '电费'); // Now at position 2
      expect(visible[0].order, 0);
      expect(visible[1].order, 1);
      expect(visible[2].order, 2);
    });

    test('should_throw_error_when_reordering_with_invalid_indices', () {
      final config = TileConfigurationList.defaultConfig();

      expect(
        () => config.reorderTile('电费', -1, 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => config.reorderTile('电费', 0, 10),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should_toggle_visibility_from_visible_to_hidden', () {
      final config = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
          const TileConfiguration(id: '校车', order: 1, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );

      final toggled = config.toggleVisibility('电费');
      final tile = toggled.configurations.firstWhere((t) => t.id == '电费');

      expect(tile.isVisible, false);
      expect(toggled.getVisibleTiles().length, 1);
    });

    test('should_toggle_visibility_from_hidden_to_visible', () {
      final config = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: false),
          const TileConfiguration(id: '校车', order: 1, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );

      final toggled = config.toggleVisibility('电费');
      final tile = toggled.configurations.firstWhere((t) => t.id == '电费');
      final visibleOrders =
          toggled.getVisibleTiles().map((t) => t.order).toList()..sort();

      expect(tile.isVisible, true);
      expect(toggled.getVisibleTiles().length, 2);
      // Order is normalized after toggle, and visible orders remain contiguous.
      expect(visibleOrders, equals([0, 1]));
    });

    test('should_throw_error_when_toggling_nonexistent_tile', () {
      final config = TileConfigurationList.defaultConfig();

      expect(
        () => config.toggleVisibility('不存在'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should_allow_hiding_all_tiles', () {
      final config = TileConfigurationList(
        configurations: [
          TileConfiguration(id: '电费', order: 0, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );

      final newConfig = config.toggleVisibility('电费');
      expect(newConfig.getVisibleTiles().length, 0);
      expect(newConfig.configurations[0].isVisible, false);
    });

    test('should_normalize_orders_correctly', () {
      final config = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 5, isVisible: true),
          const TileConfiguration(id: '校车', order: 10, isVisible: true),
          const TileConfiguration(id: '饭卡', order: 3, isVisible: false),
        ],
        lastModified: DateTime.now(),
      );

      final normalized = config.normalizeOrders();
      final visible = normalized.getVisibleTiles();

      expect(visible[0].order, 0);
      expect(visible[1].order, 1);
    });

    test('should_create_copy_with_modified_fields', () {
      final original = TileConfigurationList.defaultConfig();
      final newConfigs = [
        const TileConfiguration(id: '电费', order: 0, isVisible: true),
      ];

      final modified = original.copyWith(configurations: newConfigs);

      expect(modified.configurations.length, 1);
      expect(original.configurations.length, 3); // Original unchanged
    });

    test('should_compare_equality_correctly', () {
      final config1 = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
        ],
        lastModified: DateTime(2026, 2, 15),
      );

      final config2 = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
        ],
        lastModified: DateTime(2026, 2, 15),
      );

      final config3 = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '校车', order: 0, isVisible: true),
        ],
        lastModified: DateTime(2026, 2, 15),
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test(
      'should_recover_order_consistency_after_high_frequency_operations',
      () {
        var config = TileConfigurationList.defaultConfig();

        for (var i = 0; i < 100; i++) {
          config = config.reorderTile('电费', 0, 2);
          config = config.reorderTile('电费', 2, 0);
        }

        final visible = config.getVisibleTiles();
        for (var i = 0; i < visible.length; i++) {
          expect(visible[i].order, i);
        }
        expect(visible.map((e) => e.id).toSet().length, visible.length);
      },
    );
  });
}
