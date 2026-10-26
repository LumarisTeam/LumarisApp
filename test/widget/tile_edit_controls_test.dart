import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/components/tiles/tile_edit_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Override> _tileOverrides() => [
  tileConfigurationReaderProvider.overrideWithValue(
    () async => TileConfigurationList.defaultConfig(),
  ),
  tileConfigurationWriterProvider.overrideWithValue((config) async {}),
  availableTilesReaderProvider.overrideWithValue(
    () => const ['电费', '校车', '饭卡'],
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  testWidgets('should_toggle_edit_button_to_done_button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _tileOverrides(),
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TileEditControls()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('编辑'), findsOneWidget);
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    expect(find.text('完成'), findsOneWidget);
  });

  testWidgets('available_tiles_list_is_hidden_when_no_hidden_tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _tileOverrides(),
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AvailableTilesList()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('更多功能'), findsNothing);
  });
}
