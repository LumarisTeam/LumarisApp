import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/external_navigation_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/campus_map_page/navigation_app_picker.dart';
import 'package:material_ui/material_ui.dart';

/// The picker is shown by the map page's `showModalBottomSheet`, which comes
/// from `material_ui`. If the picker pulls its widgets from the legacy
/// `package:flutter/material.dart` instead, its `ListTile` ink has no
/// `Material` ancestor to attach to and the sheet throws while building.
void main() {
  Future<void> showPicker(
    WidgetTester tester, {
    void Function(ExternalMap?)? onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  final ExternalMap? selected =
                      await showModalBottomSheet<ExternalMap>(
                        context: context,
                        builder: (_) =>
                            const NavigationAppPicker(maps: ExternalMap.values),
                      );
                  onSelected?.call(selected);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders inside a material_ui bottom sheet', (
    WidgetTester tester,
  ) async {
    await showPicker(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('选择导航应用'), findsOneWidget);
    expect(find.text('高德地图'), findsOneWidget);
    expect(find.text('百度地图'), findsOneWidget);
  });

  testWidgets('returns the chosen map', (WidgetTester tester) async {
    ExternalMap? selected;
    await showPicker(tester, onSelected: (map) => selected = map);

    await tester.tap(find.text('高德地图'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(selected, ExternalMap.amap);
  });
}
