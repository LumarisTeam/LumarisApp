import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';

typedef BusFetcher = Future<BusModel> Function();

final busFetcherProvider = Provider<BusFetcher>((ref) {
  return () async {
    final result = await ref.read(busRepositoryProvider).getBus();
    if (!result.isSuccess) throw result.error;
    return result.data;
  };
});

final busTileStoreProvider =
    NotifierProvider<BusTileStore, BusTileState>(BusTileStore.new);

class BusTileStore extends Notifier<BusTileState> {
  @override
  BusTileState build() {
    if (ref.read(tileStoreAutoLoadProvider)) {
      Future<void>.microtask(loadBusData);
    }
    return const BusTileState();
  }

  bool get isLoading => state.isLoading;
  int get busCount => state.busCount;

  Future<void> loadBusData() async {
    try {
      state = state.copyWith(isLoading: true);

      final data = await ref.read(busFetcherProvider)();

      state = state.copyWith(busCount: data.records.length);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshBusData() async {
    await loadBusData();
  }
}
