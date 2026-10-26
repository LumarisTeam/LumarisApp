import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/app_states.dart';

typedef TileConfigurationReader = Future<TileConfigurationList> Function();
typedef TileConfigurationWriter =
    Future<void> Function(TileConfigurationList config);
typedef AvailableTilesReader = List<String> Function();

final tileConfigurationReaderProvider = Provider<TileConfigurationReader>((
  ref,
) {
  return TileService.getTileConfigurations;
});

final tileConfigurationWriterProvider = Provider<TileConfigurationWriter>((
  ref,
) {
  return TileService.saveTileConfigurations;
});

final availableTilesReaderProvider = Provider<AvailableTilesReader>((ref) {
  return TileService.getAvailableTiles;
});

final tileEditControllerProvider =
    NotifierProvider<TileEditNotifier, TileEditState>(TileEditNotifier.new);

class TileEditNotifier extends Notifier<TileEditState> {
  Timer? _inactivityTimer;
  static const Duration _inactivityDuration = Duration(seconds: 30);

  TileConfigurationReader get _readConfigurations =>
      ref.read(tileConfigurationReaderProvider);
  TileConfigurationWriter get _saveConfigurations =>
      ref.read(tileConfigurationWriterProvider);
  AvailableTilesReader get _readAvailableTiles =>
      ref.read(availableTilesReaderProvider);

  @override
  TileEditState build() {
    ref.onDispose(_cancelInactivityTimer);
    Future<void>.microtask(_loadConfiguration);
    return TileEditState(config: TileConfigurationList.defaultConfig());
  }

  bool get isEditMode => state.isEditMode;
  TileConfigurationList get config => state.config;
  bool get isLoading => state.isLoading;

  Future<void> _loadConfiguration() async {
    try {
      state = state.copyWith(isLoading: true);
      var loadedConfig = await _readConfigurations();

      final availableTiles = _readAvailableTiles();
      final existingIds = loadedConfig.configurations.map((t) => t.id).toSet();

      var hasChanges = false;
      final newConfigs = List<TileConfiguration>.from(
        loadedConfig.configurations,
      );

      for (final id in availableTiles) {
        if (!existingIds.contains(id)) {
          newConfigs.add(
            TileConfiguration(
              id: id,
              order: newConfigs.length,
              isVisible: false,
            ),
          );
          hasChanges = true;
        }
      }

      if (hasChanges) {
        loadedConfig = loadedConfig.copyWith(configurations: newConfigs);
        await _saveConfigurations(loadedConfig);
      }

      state = state.copyWith(config: loadedConfig);
    } catch (_) {
      state = state.copyWith(config: TileConfigurationList.defaultConfig());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleEditMode() async {
    if (state.isEditMode) {
      await _saveConfiguration();
      state = state.copyWith(isEditMode: false);
      _cancelInactivityTimer();
    } else {
      state = state.copyWith(isEditMode: true);

      if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
        await HapticFeedback.mediumImpact();
      }

      _resetInactivityTimer();
    }
  }

  Future<void> reorderTile(String tileId, int oldIndex, int newIndex) async {
    try {
      state = state.copyWith(
        config: state.config.reorderTile(tileId, oldIndex, newIndex),
      );
      _resetInactivityTimer();
    } catch (_) {
      await _loadConfiguration();
      rethrow;
    }
  }

  Future<void> toggleVisibility(String tileId) async {
    try {
      state = state.copyWith(config: state.config.toggleVisibility(tileId));

      if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
        await HapticFeedback.selectionClick();
      }

      _resetInactivityTimer();
    } catch (_) {
      await _loadConfiguration();
      rethrow;
    }
  }

  Future<void> _saveConfiguration() async {
    await _saveConfigurations(state.config);
  }

  void _resetInactivityTimer() {
    _cancelInactivityTimer();

    if (state.isEditMode) {
      _inactivityTimer = Timer(_inactivityDuration, () {
        if (state.isEditMode) {
          toggleEditMode();
        }
      });
    }
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  Future<void> forceExitEditMode() async {
    if (state.isEditMode) {
      await _saveConfiguration();
      state = state.copyWith(isEditMode: false);
      _cancelInactivityTimer();
    }
  }

  List<TileConfiguration> get visibleTiles => state.config.getVisibleTiles();
  List<TileConfiguration> get allTiles => state.config.configurations;

  bool isTileVisible(String tileId) {
    for (final tile in state.config.configurations) {
      if (tile.id == tileId) {
        return tile.isVisible;
      }
    }
    return false;
  }

  Future<void> reload() async {
    await _loadConfiguration();
  }
}
