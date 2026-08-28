import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/features/education/services/electricity_service.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/core/utils/stale_request_guard.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';

typedef ElectricityReader = Future<double?> Function();
typedef ElectricityWeeklyReader = Future<List<ElectricData>> Function();
typedef ElectricitySourceConfigurationReader = Future<bool> Function();
typedef ElectricityTileVisibilityReader = Future<bool> Function(String tileId);
typedef ElectricityTileMutator = Future<void> Function(String tileId);

final electricityServiceProvider = Provider<ElectricityService>((ref) {
  return ElectricityService();
});

final electricityReaderProvider = Provider<ElectricityReader>((ref) {
  return () => ref.read(electricityServiceProvider).fetchCurrentBalance();
});

final electricityWeeklyReaderProvider =
    Provider<ElectricityWeeklyReader>((ref) {
  return ref.read(electricityServiceProvider).fetchWeeklyData;
});

final electricitySourceConfigurationReaderProvider =
    Provider<ElectricitySourceConfigurationReader>((ref) {
  return ref.read(electricityServiceProvider).hasConfiguredSource;
});

final electricityTileVisibilityReaderProvider =
    Provider<ElectricityTileVisibilityReader>((ref) {
  return TileService.isTileVisible;
});

final electricityTileAdderProvider = Provider<ElectricityTileMutator>((ref) {
  return TileService.addTile;
});

final electricityTileRemoverProvider = Provider<ElectricityTileMutator>((ref) {
  return TileService.removeTile;
});

final electricityStoreProvider =
    NotifierProvider<ElectricityStore, ElectricityState>(ElectricityStore.new);

class ElectricityStore extends Notifier<ElectricityState> {
  final _loadGuard = StaleRequestGuard();

  @override
  ElectricityState build() {
    if (ref.read(tileStoreAutoLoadProvider)) {
      Future<void>.microtask(loadElectricityData);
    }
    return const ElectricityState();
  }

  bool get isLoading => state.isLoading;
  bool get hasData => state.hasData;
  double get electricity => state.electricity;
  List<String> get tiles => List.unmodifiable(state.tiles);
  List<ElectricData> get weeklyData => List.unmodifiable(state.weeklyData);

  Future<void> loadElectricityData() async {
    final requestId = _loadGuard.beginRequest();
    bool? hasConfiguredSource;
    try {
      state = state.copyWith(isLoading: true);

      hasConfiguredSource =
          await ref.read(electricitySourceConfigurationReaderProvider)();
      final value = await ref.read(electricityReaderProvider)();
      final isVisible =
          await ref.read(electricityTileVisibilityReaderProvider)('电费');
      final weekly = await ref.read(electricityWeeklyReaderProvider)();

      if (!_loadGuard.isCurrent(requestId)) return;

      final nextTiles = [...state.tiles];
      if (isVisible) {
        if (!nextTiles.contains('电费')) {
          nextTiles.add('电费');
        }
      } else {
        nextTiles.remove('电费');
      }

      state = state.copyWith(
        electricity: value ?? state.electricity,
        hasData: value != null ? true : state.hasData,
        hasConfiguredSource: hasConfiguredSource,
        tiles: nextTiles,
        weeklyData: weekly,
      );
    } catch (_) {
      // Keep the last known values on transient failures.
      if (_loadGuard.isCurrent(requestId) && hasConfiguredSource != null) {
        state = state.copyWith(hasConfiguredSource: hasConfiguredSource);
      }
    } finally {
      if (_loadGuard.isCurrent(requestId)) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> refreshElectricityData() async {
    final requestId = _loadGuard.beginRequest();
    bool? hasConfiguredSource;
    try {
      state = state.copyWith(isLoading: true);

      hasConfiguredSource =
          await ref.read(electricitySourceConfigurationReaderProvider)();
      final value = await ref.read(electricityReaderProvider)();
      final weekly = await ref.read(electricityWeeklyReaderProvider)();

      if (!_loadGuard.isCurrent(requestId)) return;

      state = state.copyWith(
        electricity: value ?? state.electricity,
        hasData: value != null ? true : state.hasData,
        hasConfiguredSource: hasConfiguredSource,
        weeklyData: weekly,
      );
    } catch (_) {
      // Keep the last known values on transient failures.
      if (_loadGuard.isCurrent(requestId) && hasConfiguredSource != null) {
        state = state.copyWith(hasConfiguredSource: hasConfiguredSource);
      }
    } finally {
      if (_loadGuard.isCurrent(requestId)) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> toggleTile(String tileName, bool value) async {
    final nextTiles = [...state.tiles];
    if (value) {
      if (!nextTiles.contains(tileName)) {
        nextTiles.add(tileName);
      }
      await ref.read(electricityTileAdderProvider)(tileName);
    } else {
      nextTiles.remove(tileName);
      await ref.read(electricityTileRemoverProvider)(tileName);
    }

    state = state.copyWith(tiles: nextTiles);
    await ref.read(tileEditControllerProvider.notifier).reload();
  }

  Future<void> setElectricityValue(double value) async {
    state = state.copyWith(
      electricity: value,
      hasData: true,
      hasConfiguredSource: true,
    );
  }

  void setSourceConfigured(bool value) {
    state = state.copyWith(hasConfiguredSource: value);
  }
}
