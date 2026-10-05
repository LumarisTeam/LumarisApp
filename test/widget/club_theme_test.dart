import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

void main() {
  group('ClubTheme', () {
    test('should expose expected semantic colors in light theme', () {
      final theme = ClubTheme.lightTheme();
      final colors = theme.extension<ClubColors>();

      expect(theme.colorScheme.primary, ClubColors.light.primary);
      expect(theme.scaffoldBackgroundColor, ClubColors.light.groupedBackground);
      expect(colors?.label, ClubColors.light.label);
    });

    test('should expose expected semantic colors in dark theme', () {
      final theme = ClubTheme.darkTheme();
      final colors = theme.extension<ClubColors>();

      expect(theme.colorScheme.primary, ClubColors.dark.primary);
      expect(theme.scaffoldBackgroundColor, ClubColors.dark.groupedBackground);
      expect(colors?.label, ClubColors.dark.label);
    });

    testWidgets('should resolve fallback ClubColors from brightness',
        (WidgetTester tester) async {
      late ClubColors resolved;

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              resolved = context.clubColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, ClubColors.dark);
    });

    testWidgets('should bridge dark theme to Cupertino widgets',
        (WidgetTester tester) async {
      late ThemeData resolvedTheme;
      late ClubColors resolvedColors;
      late Brightness cupertinoBrightness;
      late Color cupertinoPrimaryColor;

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ClubTheme.darkTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                resolvedTheme = Theme.of(context);
                resolvedColors = context.clubColors;
                final cupertinoTheme = CupertinoTheme.of(context);
                cupertinoBrightness = cupertinoTheme.brightness!;
                cupertinoPrimaryColor = cupertinoTheme.primaryColor;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolvedTheme.brightness, Brightness.dark);
      expect(
        resolvedTheme.scaffoldBackgroundColor,
        ClubColors.dark.groupedBackground,
      );
      expect(resolvedColors, ClubColors.dark);
      expect(cupertinoBrightness, Brightness.dark);
      expect(cupertinoPrimaryColor, ClubColors.dark.primary);
    });
  });
}
