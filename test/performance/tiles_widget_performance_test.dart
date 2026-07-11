@Tags(['performance'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/pages/homePages/tiles_widget.dart';
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
      electricityWeeklyReaderProvider.overrideWithValue(() async => []),
      electricityTileVisibilityReaderProvider
          .overrideWithValue((_) async => true),
      studentIsLoginReaderProvider.overrideWithValue(() => true),
      paymentStudentIdReaderProvider.overrideWithValue(() async => 'student-1'),
      paymentPasswordReaderProvider.overrideWithValue(() async => null),
      paymentDataFetcherProvider.overrideWithValue(
        (_, __) async => const PaymentData([], 20),
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

  testWidgets('tiles_widget_builds_without_excessive_frames', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: const MaterialApp(home: Scaffold(body: TilesWidget())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    stopwatch.stop();

    expect(find.byType(TilesWidget), findsOneWidget);
    expect(stopwatch.elapsedMilliseconds, lessThan(5000));
  });
}
