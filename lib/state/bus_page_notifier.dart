import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';

typedef BusPageFetcher = Future<BusModel> Function({
  String? dayDate,
  bool forceRefresh,
});

final busPageAutoLoadProvider = Provider<bool>((ref) => true);
final busPageFetcherProvider = Provider<BusPageFetcher>((ref) {
  return ({String? dayDate, bool forceRefresh = false}) async {
    final result = await ref.read(busRepositoryProvider).getBus(
          dayDate: dayDate,
          forceRefresh: forceRefresh,
        );
    if (!result.isSuccess) throw result.error;
    return result.data;
  };
});

final busControllerProvider =
    NotifierProvider<BusPageNotifier, BusPageState>(BusPageNotifier.new);

class BusPageNotifier extends Notifier<BusPageState> {
  final Map<String, String> availableDates = {};

  @override
  BusPageState build() {
    _generateWeeklyDates();
    final selectedDate =
        availableDates.isNotEmpty ? availableDates.keys.first : '';
    if (ref.read(busPageAutoLoadProvider)) {
      Future<void>.microtask(() async {
        state = state.copyWith(selectedDate: selectedDate);
        if (selectedDate.isNotEmpty) {
          await _fetchBusData(isInit: true);
        }
        await _loadTiles();
      });
    }
    return BusPageState(selectedDate: selectedDate);
  }

  void _generateWeeklyDates() {
    availableDates.clear();
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      availableDates[DateFormat('yyyy-MM-dd').format(date)] =
          DateFormat('M月d日').format(date);
    }
  }

  Future<void> selectDateByIndex(int index) async {
    if (index < 0 || index >= availableDates.length) {
      return;
    }
    state = state.copyWith(selectedDate: availableDates.keys.elementAt(index));
    await _fetchBusData();
  }

  Future<void> _loadTiles() async {
    final config = await TileService.getTileConfigurations();
    final tiles = config.getVisibleTiles().map((tile) => tile.id).toList();
    state = state.copyWith(
      tiles: tiles,
      isShowBus: tiles.contains('校车'),
    );
  }

  Future<void> _fetchBusData({
    bool isInit = false,
    bool forceRefresh = false,
  }) async {
    final currentSelectedDate = state.selectedDate;
    final previousTodayBusData = state.todayBusData;
    final previousBusData = state.busData;
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final BusModel data = await ref.read(busPageFetcherProvider)(
        dayDate: state.selectedDate,
        forceRefresh: forceRefresh,
      );

      // 检查在异步请求期间用户是否切换了日期
      if (state.selectedDate != currentSelectedDate) {
        return;
      }

      final todayBusData = data.records;
      final campusOptions = _extractCampusOptions(todayBusData);
      final selectedCampus = campusOptions.contains(state.selectedCampus) &&
              state.selectedCampus.isNotEmpty
          ? state.selectedCampus
          : (campusOptions.isNotEmpty ? campusOptions.first : '');
      final busData = _filterBusData(todayBusData, selectedCampus);

      state = state.copyWith(
        todayBusData: todayBusData,
        campusOptions: campusOptions,
        selectedCampus: selectedCampus,
        busData: busData,
      );
    } catch (e) {
      if (state.selectedDate != currentSelectedDate) {
        return;
      }
      state = state.copyWith(
        errorMessage: '刷新失败，已保留上次校车数据',
        todayBusData: previousTodayBusData,
        busData: previousBusData,
      );
    } finally {
      if (state.selectedDate == currentSelectedDate) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void selectCampus(String campus) {
    if (campus.isEmpty || campus == state.selectedCampus) {
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
