import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/components/tiles/bus_tile.dart';
import 'package:ios_club_app/ui/components/tiles/electricity_tile.dart';
import 'package:ios_club_app/ui/components/tiles/payment_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Override> _overrides() => [
      tileConfigurationReaderProvider.overrideWithValue(
        () async => TileConfigurationList.defaultConfig(),
      ),
      tileConfigurationWriterProvider.overrideWithValue((config) async {}),
      availableTilesReaderProvider.overrideWithValue(
        () => const ['电费', '校车', '饭卡'],
      ),
      electricityReaderProvider.overrideWithValue(() async => 23.5),
      electricityWeeklyReaderProvider.overrideWithValue(
        () async => [ElectricData(timestamp: DateTime(2026), value: 1)],
      ),
      electricityTileVisibilityReaderProvider
          .overrideWithValue((_) async => true),
      studentIsLoginReaderProvider.overrideWithValue(() => true),
      paymentStudentIdReaderProvider.overrideWithValue(() async => 'student-1'),
      paymentPasswordReaderProvider.overrideWithValue(() async => null),
      paymentDataFetcherProvider.overrideWithValue(
        (_, __) async => const PaymentData(
          [
            PaymentModel(
              turnoverType: '充值',
              datetimeStr: '2026-04-27',
              resume: '测试',
              amount: 20,
            ),
          ],
          20,
        ),
      ),
      tileVisibilityReaderProvider.overrideWithValue((_) async => true),
      busFetcherProvider.overrideWithValue(
        () async => BusModel(records: const [], total: 0),
      ),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'username': 'student-1'});
    await PrefsService.init();
  });

  testWidgets('tiles_render_loaded_states', (tester) async {
    final container = ProviderContainer(overrides: _overrides());
    addTearDown(container.dispose);
    await Future.wait([
      container.read(electricityStoreProvider.notifier).loadElectricityData(),
      container.read(paymentStoreProvider.notifier).loadData(),
      container.read(busTileStoreProvider.notifier).loadBusData(),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Column(
              children: [
                SizedBox(width: 180, height: 180, child: ElectricityTile()),
                SizedBox(width: 180, height: 180, child: PaymentTile()),
                SizedBox(width: 180, height: 180, child: BusTile()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('当前余额'), findsNWidgets(2));
    expect(find.text('校车'), findsOneWidget);
  });
}
