import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// Custom exception for tile configuration errors
class TileConfigurationException implements Exception {
  final String message;
  final String? details;

  TileConfigurationException(this.message, {this.details});

  @override
  String toString() =>
      'TileConfigurationException: $message${details != null ? ' ($details)' : ''}';
}

class TileService {
  static AppLocalizations get _l10n => AppLocaleService.currentL10n();

  static Future<bool> isTileVisible(String tileId) async {
    final config = await getTileConfigurations();
    return config.configurations.any((t) => t.id == tileId && t.isVisible);
  }

  static Future<void> addTile(String tileId) async {
    final config = await getTileConfigurations();
    final index = config.configurations.indexWhere((t) => t.id == tileId);

    if (index != -1) {
      // 已存在配置中
      if (!config.configurations[index].isVisible) {
        // 如果不可见，则切换为可见
        await toggleTileVisibility(tileId);
      }
    } else {
      // 不在配置中，添加新配置
      final visibleTiles = config.getVisibleTiles();
      final maxOrder = visibleTiles.isEmpty
          ? -1
          : visibleTiles.map((t) => t.order).reduce((a, b) => a > b ? a : b);

      final newTile = TileConfiguration(
        id: tileId,
        order: maxOrder + 1,
        isVisible: true,
      );

      final newConfigs = List<TileConfiguration>.from(config.configurations)
        ..add(newTile);

      final newList = config.copyWith(configurations: newConfigs);
      await saveTileConfigurations(newList.normalizeOrders());
    }
  }

  static Future<void> removeTile(String tileId) async {
    final config = await getTileConfigurations();
    final index = config.configurations.indexWhere((t) => t.id == tileId);

    if (index != -1 && config.configurations[index].isVisible) {
      await toggleTileVisibility(tileId);
    }
  }

  // ========== New Tile Configuration Methods ==========

  /// Get the complete tile configuration from local storage
  static Future<TileConfigurationList> getTileConfigurations() async {
    final prefs = PrefsService.instance;

    try {
      // Try new format first
      final newFormatJson = prefs.getString(PrefsKeys.TILE_CONFIGURATIONS);
      if (newFormatJson != null && newFormatJson.isNotEmpty) {
        final json = jsonDecode(newFormatJson) as Map<String, dynamic>;
        return TileConfigurationList.fromJson(json);
      }

      // Fall back to old format and migrate (only if not empty)
      final oldFormatList = prefs.getStringList(PrefsKeys.TILES);
      if (oldFormatList != null && oldFormatList.isNotEmpty) {
        final config = _migrateFromOldFormat(oldFormatList);
        await saveTileConfigurations(config);
        return config;
      }

      // No data, return default
      return TileConfigurationList.defaultConfig();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to load tile configuration: $e');
      }
      return TileConfigurationList.defaultConfig();
    }
  }

  /// Save the complete tile configuration to local storage
  static Future<void> saveTileConfigurations(
    TileConfigurationList config,
  ) async {
    final prefs = PrefsService.instance;

    try {
      // Update lastModified timestamp
      final updatedConfig = config.copyWith(lastModified: DateTime.now());

      // Serialize to JSON
      final json = jsonEncode(updatedConfig.toJson());

      // Save to storage
      await prefs.setString(PrefsKeys.TILE_CONFIGURATIONS, json);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to save tile configuration: $e');
      }
      throw TileConfigurationException(
        _l10n.saveFailedRetry,
        details: e.toString(),
      );
    }
  }

  /// Move a tile to a new position in the display order
  static Future<void> reorderTile(
    String tileId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final config = await getTileConfigurations();
      final reordered = config.reorderTile(tileId, oldIndex, newIndex);
      await saveTileConfigurations(reordered);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to reorder tile: $e');
      }
      throw TileConfigurationException(
        _l10n.reorderFailed,
        details: e.toString(),
      );
    }
  }

  /// Show or hide a tile
  static Future<void> toggleTileVisibility(String tileId) async {
    try {
      final config = await getTileConfigurations();
      final toggled = config.toggleVisibility(tileId);
      await saveTileConfigurations(toggled);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to toggle tile visibility: $e');
      }
      throw TileConfigurationException(
        _l10n.toggleTileVisibilityFailed,
        details: e.toString(),
      );
    }
  }

  /// Reset tile configuration to default state
  static Future<void> resetToDefault() async {
    try {
      final defaultConfig = TileConfigurationList.defaultConfig();
      await saveTileConfigurations(defaultConfig);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to reset tile configuration: $e');
      }
      throw TileConfigurationException(
        _l10n.resetFailed,
        details: e.toString(),
      );
    }
  }

  /// Get list of all available tile types
  static List<String> getAvailableTiles() {
    return ['电费', '校车', '饭卡'];
  }

  /// Migrate from old format (List&lt;String>) to new format (TileConfigurationList)
  static TileConfigurationList _migrateFromOldFormat(List<String> oldList) {
    final configurations = oldList.asMap().entries.map((entry) {
      return TileConfiguration(
        id: entry.value,
        order: entry.key,
        isVisible: true,
      );
    }).toList();

    return TileConfigurationList(
      configurations: configurations,
      lastModified: DateTime.now(),
    );
  }
}
