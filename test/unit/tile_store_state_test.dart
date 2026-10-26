import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

BusModel _busModel(int count) {
  return BusModel(
    total: count,
    records: List.generate(
      count,
      (index) => BusItem(
        lineName: 'line-$index',
        description: '',
        departureStation: 'A',
        arrivalStation: 'B',
        runTime: '10:00',
        arrivalStationTime: '01:00',
      ),
    ),
  );
}

ProviderContainer _container(List<Override> overrides) {
  final container = ProviderContainer(
    overrides: [
      tileConfigurationReaderProvider.overrideWithValue(
        () async => TileConfigurationList.defaultConfig(),
      ),
      tileConfigurationWriterProvider.overrideWithValue((config) async {}),
      availableTilesReaderProvider.overrideWithValue(
        () => const ['电费', '校车', '饭卡'],
      ),
      tileStoreAutoLoadProvider.overrideWithValue(false),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  group('PaymentStore', () {
    test('should_set_login_error_when_student_id_is_empty', () async {
      final container = _container([
        paymentStudentIdReaderProvider.overrideWithValue(() async => ''),
        paymentPasswordReaderProvider.overrideWithValue(() async => null),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.loadData();

      final state = container.read(paymentStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'auth_required');
      expect(state.records, isEmpty);
    });

    test('should_set_login_error_when_student_id_is_null', () async {
      final container = _container([
        paymentStudentIdReaderProvider.overrideWithValue(() async => null),
        paymentPasswordReaderProvider.overrideWithValue(() async => null),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.loadData();

      final state = container.read(paymentStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'auth_required');
      expect(state.records, isEmpty);
    });

    test(
      'should_load_payment_records_and_tile_visibility_when_student_exists',
      () async {
        final container = _container([
          studentIsLoginReaderProvider.overrideWithValue(() => true),
          paymentStudentIdReaderProvider.overrideWithValue(
            () async => 'student-1',
          ),
          paymentPasswordReaderProvider.overrideWithValue(
            () async => 'meal-card-secret',
          ),
          paymentDataFetcherProvider.overrideWithValue((
            cardNumber,
            password,
          ) async {
            expect(cardNumber, 'student-1');
            expect(password, 'meal-card-secret');
            return const PaymentData([
              PaymentModel(
                turnoverType: '充值',
                datetimeStr: '2026-04-27 10:00:00',
                resume: '测试充值',
                amount: 1000,
              ),
            ], 1000);
          }),
          tileVisibilityReaderProvider.overrideWithValue((tileId) async {
            expect(tileId, '饭卡');
            return true;
          }),
        ]);
        final store = container.read(paymentStoreProvider.notifier);

        await store.loadData();

        final state = container.read(paymentStoreProvider);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, '');
        expect(state.records, hasLength(1));
        expect(state.totalRecharge, 1000);
        expect(state.isShowTile, isTrue);
        expect(state.hasData, isTrue);
        expect(state.password, 'meal-card-secret');
      },
    );

    test('should_set_error_message_when_fetch_throws', () async {
      final container = _container([
        studentIsLoginReaderProvider.overrideWithValue(() => true),
        paymentStudentIdReaderProvider.overrideWithValue(
          () async => 'student-1',
        ),
        paymentPasswordReaderProvider.overrideWithValue(
          () async => 'meal-card-secret',
        ),
        paymentDataFetcherProvider.overrideWithValue((_, _) async {
          throw Exception('network error');
        }),
        tileVisibilityReaderProvider.overrideWithValue((_) async => true),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.loadData();

      final state = container.read(paymentStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'load_failed');
      expect(state.hasData, isFalse);
      expect(state.password, 'meal-card-secret');
    });

    test('should_toggle_tile_and_reload_tile_edit_controller', () async {
      final touchedTiles = <String>[];
      final container = _container([
        tileAdderProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('add:$tileId'),
        ),
        tileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.toggleTileShow(true);
      await store.toggleTileShow(false);

      expect(container.read(paymentStoreProvider).isShowTile, isFalse);
      expect(touchedTiles, ['add:饭卡', 'remove:饭卡']);
    });

    test('should_save_trimmed_payment_password', () async {
      String? savedPassword;
      final container = _container([
        paymentPasswordWriterProvider.overrideWithValue((password) async {
          savedPassword = password;
          return true;
        }),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      final success = await store.savePassword('  card-pass  ');

      expect(success, isTrue);
      expect(savedPassword, 'card-pass');
      expect(container.read(paymentStoreProvider).password, 'card-pass');
    });
  });

  group('ElectricityStore', () {
    test(
      'should_load_electricity_value_weekly_data_and_visible_tile',
      () async {
        final weekly = [
          ElectricData(timestamp: DateTime(2026, 4, 27, 8), value: 1.5),
        ];
        final container = _container([
          electricityReaderProvider.overrideWithValue(() async => 23.5),
          electricityWeeklyReaderProvider.overrideWithValue(() async => weekly),
          electricityTileVisibilityReaderProvider.overrideWithValue(
            (_) async => true,
          ),
        ]);
        final store = container.read(electricityStoreProvider.notifier);

        await store.loadElectricityData();

        final state = container.read(electricityStoreProvider);
        expect(state.isLoading, isFalse);
        expect(state.hasData, isTrue);
        expect(state.electricity, 23.5);
        expect(state.tiles, contains('电费'));
        expect(state.weeklyData, weekly);
      },
    );

    test(
      'should_keep_has_data_false_when_electricity_value_is_missing',
      () async {
        final container = _container([
          electricityReaderProvider.overrideWithValue(() async => null),
          electricityWeeklyReaderProvider.overrideWithValue(() async => []),
          electricityTileVisibilityReaderProvider.overrideWithValue(
            (_) async => false,
          ),
        ]);
        final store = container.read(electricityStoreProvider.notifier);

        await store.loadElectricityData();

        final state = container.read(electricityStoreProvider);
        expect(state.isLoading, isFalse);
        expect(state.hasData, isFalse);
        expect(state.tiles, isNot(contains('电费')));
        expect(state.weeklyData, isEmpty);
      },
    );

    test(
      'should_refresh_electricity_without_touching_tile_visibility',
      () async {
        final container = _container([
          electricityReaderProvider.overrideWithValue(() async => 18.0),
          electricityWeeklyReaderProvider.overrideWithValue(
            () async => [
              ElectricData(timestamp: DateTime(2026, 4, 27, 9), value: 2),
            ],
          ),
        ]);
        final store = container.read(electricityStoreProvider.notifier);

        await store.refreshElectricityData();

        final state = container.read(electricityStoreProvider);
        expect(state.isLoading, isFalse);
        expect(state.hasData, isTrue);
        expect(state.electricity, 18.0);
        expect(state.weeklyData.single.value, 2);
      },
    );

    test('should_toggle_tile_and_reload_tile_edit_controller', () async {
      final touchedTiles = <String>[];
      final container = _container([
        electricityTileAdderProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('add:$tileId'),
        ),
        electricityTileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.toggleTile('电费', true);
      await store.toggleTile('电费', false);

      expect(
        container.read(electricityStoreProvider).tiles,
        isNot(contains('电费')),
      );
      expect(touchedTiles, ['add:电费', 'remove:电费']);
    });
  });

  group('BusTileStore', () {
    test('should_load_bus_data', () async {
      var calls = 0;
      final container = _container([
        busFetcherProvider.overrideWithValue(() async {
          calls++;
          return _busModel(2);
        }),
      ]);
      final store = container.read(busTileStoreProvider.notifier);

      await store.loadBusData();

      final state = container.read(busTileStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.busCount, 2);
      expect(calls, 1);
    });
  });
}
