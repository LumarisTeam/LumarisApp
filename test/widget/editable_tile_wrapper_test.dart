import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/components/tiles/editable_tile_wrapper.dart';
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

  testWidgets('should_show_hide_button_in_edit_mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _tileOverrides(),
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'),
          home: Scaffold(
            body: Column(
              children: [
                TileEditControls(),
                EditableTileWrapper(
                  tileId: '电费',
                  index: 0,
                  child: SizedBox(width: 80, height: 80, child: Text('电费')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(EditableTileWrapper),
        matching: find.byType(RepaintBoundary),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.remove), findsNothing);

    await tester.tap(find.text('编辑'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });
}
