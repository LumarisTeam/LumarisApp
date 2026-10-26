import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
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
  electricityTileVisibilityReaderProvider.overrideWithValue((_) async => true),
  studentIsLoginReaderProvider.overrideWithValue(() => true),
  paymentStudentIdReaderProvider.overrideWithValue(() async => 'student-1'),
  paymentPasswordReaderProvider.overrideWithValue(() async => null),
  paymentDataFetcherProvider.overrideWithValue(
    (_, _) async => const PaymentData([
      PaymentModel(
        turnoverType: '充值',
        datetimeStr: '2026-04-27',
        resume: '测试',
        amount: 20,
      ),
    ], 20),
  ),
  tileVisibilityReaderProvider.overrideWithValue((_) async => true),
  // 校车磁贴默认会请求真实接口，测试里用固定数据替换。
  busFetcherProvider.overrideWithValue(
    () async => BusModel(
      total: 3,
      records: List.generate(
        3,
        (index) => BusItem(
          lineName: '线路$index',
          description: '',
          departureStation: '雁塔',
          arrivalStation: '草堂',
          runTime: '01:00',
          arrivalStationTime: '02:00',
        ),
      ),
    ),
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'username': 'student-1'});
    await PrefsService.init();
  });

  testWidgets('tiles_render_loaded_states', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
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
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 电费磁贴与饭卡磁贴都显示「当前余额」，用金额区分两者。
    expect(find.text('¥23.50'), findsOneWidget);
    expect(find.text('¥20.00'), findsOneWidget);
    expect(find.text('校车'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
