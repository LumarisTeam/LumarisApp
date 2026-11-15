import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/utils/app_logger.dart';
import '../core/utils/stale_request_guard.dart';
import '../features/education/models/bus_model.dart';
import '../features/education/services/bus_service.dart';
import '../features/system/tile_service.dart';
import 'app_states.dart';
import 'tile_edit_notifier.dart';

typedef BusPageFetcher =
    Future<BusModel> Function({String? dayDate, bool forceRefresh});

final busPageAutoLoadProvider = Provider<bool>((ref) => true);
final busPageFetcherProvider = Provider<BusPageFetcher>((ref) {
  return ({String? dayDate, bool forceRefresh = false}) {
    return BusService.getBus(
      dayDate: dayDate,
      forceRefresh: forceRefresh,
      throwOnError: true,
    );
  };
});

final busControllerProvider = NotifierProvider<BusPageNotifier, BusPageState>(
  BusPageNotifier.new,
);

class BusPageNotifier extends Notifier<BusPageState> {
  final Map<String, String> availableDates = {};
  final StaleRequestGuard _requests = StaleRequestGuard();
  bool _disposed = false;

  @override
  BusPageState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _requests.beginRequest();
    });
    _generateWeeklyDates();
    final selectedDate = availableDates.isNotEmpty
        ? availableDates.keys.first
        : '';
    if (ref.read(busPageAutoLoadProvider)) {
      Future<void>.microtask(() async {
        if (_disposed) return;
        if (state.selectedDate == selectedDate && !state.isLoading) {
          await _fetchBusData();
        }
        if (!_disposed) await _loadTiles();
      });
    }
    return BusPageState(selectedDate: selectedDate);
  }

  void _generateWeeklyDates() {
    availableDates.clear();
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      availableDates[DateFormat('yyyy-MM-dd').format(date)] = DateFormat(
        'M月d日',
      ).format(date);
    }
  }

  Future<void> selectDateByIndex(int index) async {
    if (index < 0 || index >= availableDates.length) {
      return;
    }
    final String date = availableDates.keys.elementAt(index);
    if (date != state.selectedDate) {
      state = state.copyWith(
        selectedDate: date,
        todayBusData: const [],
        busData: const [],
      );
    }
    await _fetchBusData();
  }

  Future<void> _loadTiles() async {
    final config = await TileService.getTileConfigurations();
    final tiles = config.getVisibleTiles().map((tile) => tile.id).toList();
    if (!_disposed) {
      state = state.copyWith(tiles: tiles, isShowBus: tiles.contains('校车'));
    }
  }

  Future<void> _fetchBusData({bool forceRefresh = false}) async {
    final int requestId = _requests.beginRequest();
    final String date = state.selectedDate;
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final BusModel data = await ref.read(busPageFetcherProvider)(
        dayDate: date,
        forceRefresh: forceRefresh,
      );
      if (_disposed || !_requests.isCurrent(requestId)) return;

      final List<String> campusOptions = _extractCampusOptions(data.records);
      final String selectedCampus = state.selectedCampus.isNotEmpty
          ? state.selectedCampus
          : campusOptions.firstOrNull ?? '';
      if (campusOptions.isNotEmpty && !campusOptions.contains(selectedCampus)) {
        campusOptions.insert(0, selectedCampus);
      }

      state = state.copyWith(
        isLoading: false,
        todayBusData: data.records,
        campusOptions: campusOptions,
        selectedCampus: selectedCampus,
        busData: _filterBusData(data.records, selectedCampus),
      );
    } catch (error, stackTrace) {
      if (_disposed || !_requests.isCurrent(requestId)) return;
      AppLogger.warning(
        'Could not load school bus schedule for $date',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.todayBusData.isEmpty ? 'load_failed' : 'stale_data',
      );
    }
  }

  void selectCampus(String campus) {
    if (campus == state.selectedCampus ||
        !state.campusOptions.contains(campus)) {
      return;
    }

    state = state.copyWith(
      selectedCampus: campus,
      busData: _filterBusData(state.todayBusData, campus),
    );
  }

  Future<void> refreshData() async {
    await _fetchBusData(forceRefresh: true);
  }

  Future<void> toggleShowBus(bool value) async {
    if (value) {
      await TileService.addTile('校车');
    } else {
      await TileService.removeTile('校车');
    }
    await ref.read(tileEditControllerProvider.notifier).reload();
    await _loadTiles();
  }

  List<String> _extractCampusOptions(List<BusItem> busItems) {
    final campusCounts = <String, int>{};
    for (final bus in busItems) {
      final campus = bus.departureStation.trim();
      if (campus.isEmpty) {
        continue;
      }
      campusCounts.update(campus, (count) => count + 1, ifAbsent: () => 1);
    }
    return campusCounts.keys.toList();
  }

  List<BusItem> _filterBusData(List<BusItem> busItems, String selectedCampus) {
    if (selectedCampus.isEmpty) {
      return <BusItem>[];
    }
    return busItems
        .where((bus) => bus.departureStation.trim() == selectedCampus)
        .toList();
  }
}
