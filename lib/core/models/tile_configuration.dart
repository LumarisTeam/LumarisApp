import 'package:json_annotation/json_annotation.dart';

part 'tile_configuration.g.dart';

/// Represents the configuration for a single tile on the home page
@JsonSerializable(explicitToJson: true)
class TileConfiguration {
  /// Unique identifier for the tile (e.g., "电费", "校车", "饭卡")
  final String id;

  /// Display order index (0-based)
  final int order;

  /// Whether tile is shown on home page
  final bool isVisible;

  const TileConfiguration({
    required this.id,
    required this.order,
    required this.isVisible,
  });

  factory TileConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TileConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$TileConfigurationToJson(this);

  /// Create a copy with modified fields
  TileConfiguration copyWith({String? id, int? order, bool? isVisible}) {
    return TileConfiguration(
      id: id ?? this.id,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileConfiguration &&
        other.id == id &&
        other.order == order &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode => Object.hash(id, order, isVisible);

  @override
  String toString() =>
      'TileConfiguration(id: $id, order: $order, isVisible: $isVisible)';
}

/// Represents the complete set of tile configurations for a user
@JsonSerializable(explicitToJson: true)
class TileConfigurationList {
  /// Ordered list of tile configurations
  final List<TileConfiguration> configurations;

  /// Timestamp of last modification
  final DateTime lastModified;

  const TileConfigurationList({
    required this.configurations,
    required this.lastModified,
  });

  /// Create default configuration with all tiles visible
  factory TileConfigurationList.defaultConfig() {
    return TileConfigurationList(
      configurations: [
        const TileConfiguration(id: '电费', order: 0, isVisible: true),
        const TileConfiguration(id: '校车', order: 1, isVisible: true),
        const TileConfiguration(id: '饭卡', order: 2, isVisible: true),
      ],
      lastModified: DateTime.now(),
    );
  }

  factory TileConfigurationList.fromJson(Map<String, dynamic> json) =>
      _$TileConfigurationListFromJson(json);

  Map<String, dynamic> toJson() => _$TileConfigurationListToJson(this);

  /// Get list of visible tiles sorted by order
  List<TileConfiguration> getVisibleTiles() {
    final visible = configurations.where((tile) => tile.isVisible).toList();
    visible.sort((a, b) => a.order.compareTo(b.order));
    return visible;
  }

  /// Reorder a tile to a new position
  TileConfigurationList reorderTile(String tileId, int oldIndex, int newIndex) {
    final visibleTiles = getVisibleTiles();

    if (oldIndex < 0 ||
        oldIndex >= visibleTiles.length ||
        newIndex < 0 ||
        newIndex >= visibleTiles.length) {
      throw ArgumentError('Invalid indices for reordering');
    }

    // Find the tile to move
    final tileToMove = visibleTiles[oldIndex];
    if (tileToMove.id != tileId) {
      throw ArgumentError('Tile ID mismatch at old index');
    }

    // Remove from old position and insert at new position
    visibleTiles.removeAt(oldIndex);
    visibleTiles.insert(newIndex, tileToMove);

    // Update order values for all visible tiles
    for (int i = 0; i < visibleTiles.length; i++) {
      visibleTiles[i] = visibleTiles[i].copyWith(order: i);
    }

    // Merge back with hidden tiles
    final hiddenTiles = configurations
        .where((tile) => !tile.isVisible)
        .toList();
    final newConfigurations = [...visibleTiles, ...hiddenTiles];

    return TileConfigurationList(
      configurations: newConfigurations,
      lastModified: DateTime.now(),
    );
  }

  /// Toggle visibility of a tile
  TileConfigurationList toggleVisibility(String tileId) {
    final tileIndex = configurations.indexWhere((tile) => tile.id == tileId);

    if (tileIndex == -1) {
      throw ArgumentError('Tile not found: $tileId');
    }

    final tile = configurations[tileIndex];
    final nextVisible = !tile.isVisible;
    final visibleCount = configurations.where((t) => t.isVisible).length;

    // We allow hiding all tiles, so no restriction is needed.
    // The UI handles empty state.

    final newConfigurations = List<TileConfiguration>.from(configurations);
    if (nextVisible) {
      // Showing a tile: append after the current visible tiles.
      newConfigurations[tileIndex] = tile.copyWith(
        isVisible: true,
        order: visibleCount,
      );
    } else {
      // Hiding a tile: keep order for now and normalize below.
      newConfigurations[tileIndex] = tile.copyWith(isVisible: false);
    }

    // Re-normalize orders for visible tiles to keep ordering stable.
    final visibleTiles = newConfigurations.where((t) => t.isVisible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    for (int i = 0; i < visibleTiles.length; i++) {
      final index = newConfigurations.indexWhere(
        (t) => t.id == visibleTiles[i].id,
      );
      if (index != -1) {
        newConfigurations[index] = newConfigurations[index].copyWith(order: i);
      }
    }

    return TileConfigurationList(
      configurations: newConfigurations,
      lastModified: DateTime.now(),
    );
  }

  /// Normalize order values to be sequential (0, 1, 2, ...)
  TileConfigurationList normalizeOrders() {
    final visibleTiles = getVisibleTiles();

    // Update order values
    for (int i = 0; i < visibleTiles.length; i++) {
      visibleTiles[i] = visibleTiles[i].copyWith(order: i);
    }

    // Merge back with hidden tiles
    final hiddenTiles = configurations
        .where((tile) => !tile.isVisible)
        .toList();
    final newConfigurations = [...visibleTiles, ...hiddenTiles];

    return TileConfigurationList(
      configurations: newConfigurations,
      lastModified: DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  TileConfigurationList copyWith({
    List<TileConfiguration>? configurations,
    DateTime? lastModified,
  }) {
    return TileConfigurationList(
      configurations: configurations ?? this.configurations,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileConfigurationList &&
        _listEquals(other.configurations, configurations) &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode => Object.hash(configurations, lastModified);

  @override
  String toString() =>
      'TileConfigurationList(configurations: $configurations, lastModified: $lastModified)';

  /// Helper to compare lists
  static bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
