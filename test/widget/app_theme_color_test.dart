import 'package:flutter_test/flutter_test.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/ui/theme/app_theme_color.dart';

void main() {
  test('should preserve the existing blue theme', () {
    expect(AppThemeColor.blue.colorsFor(Brightness.light), McColors.light);
    expect(AppThemeColor.blue.colorsFor(Brightness.dark), McColors.dark);
  });

  test('should keep preset foregrounds legible in both modes', () {
    for (final color in AppThemeColor.values.where(
      (c) => c != AppThemeColor.blue,
    )) {
      for (final brightness in Brightness.values) {
        final colors = color.colorsFor(brightness);
        final contrast =
            (colors.primary.computeLuminance() + 0.05) /
            (colors.primaryForeground.computeLuminance() + 0.05);
        expect(
          contrast,
          greaterThanOrEqualTo(4.5),
          reason: '${color.name} $brightness',
        );
        final theme = color.materialTheme(brightness);
        expect(theme.colorScheme.primary, colors.primary);
        expect(theme.colorScheme.onPrimary, colors.primaryForeground);
        expect(theme.colorScheme.onError, McColors.light.onAccent);
        expect(theme.extension<McColors>()!.primary, colors.primary);
      }
    }
  });

  testWidgets('should update the accent immediately in light and dark mode', (
    tester,
  ) async {
    final color = ValueNotifier(AppThemeColor.blue);
    final mode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(
      ValueListenableBuilder<AppThemeColor>(
        valueListenable: color,
        builder: (context, selected, _) => ValueListenableBuilder<ThemeMode>(
          valueListenable: mode,
          builder: (context, selectedMode, _) => MaterialApp(
            theme: selected.materialTheme(Brightness.light),
            darkTheme: selected.materialTheme(Brightness.dark),
            themeMode: selectedMode,
            home: Builder(
              builder: (context) => Text(
                'accent',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
    color.value = AppThemeColor.orange;
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('accent')).style!.color,
      AppThemeColor.orange.light,
    );
    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('accent')).style!.color,
      AppThemeColor.orange.dark,
    );
    color.dispose();
    mode.dispose();
  });
}
