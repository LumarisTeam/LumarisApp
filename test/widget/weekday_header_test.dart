import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/components/schedule/weekday_header.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: McThemeData.materialTheme(McColors.light),
    home: Scaffold(body: child),
  );
}

void main() {
  final weekStart = DateTime(2026, 10, 26);

  testWidgets('should show date by default', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeekdayHeader(weekStartDate: weekStart, currentWeek: 1, height: 60),
      ),
    );

    expect(find.text('26'), findsOneWidget);
  });

  testWidgets('should hide date when hideDateUnderDay is true', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeekdayHeader(
          weekStartDate: weekStart,
          currentWeek: 1,
          height: 60,
          hideDateUnderDay: true,
        ),
      ),
    );

    expect(find.text('26'), findsNothing);
  });

  testWidgets('should auto-hide date when header is shorter than 42', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        WeekdayHeader(weekStartDate: weekStart, currentWeek: 1, height: 40),
      ),
    );

    expect(find.text('26'), findsNothing);
  });

  testWidgets('should stretch cells to the header height', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeekdayHeader(
          weekStartDate: weekStart,
          currentWeek: 1,
          height: 45,
          timeColumnWidth: 45,
        ),
      ),
    );

    final row = tester.widget<Row>(
      find
          .descendant(
            of: find.byType(WeekdayHeader),
            matching: find.byType(Row),
          )
          .first,
    );
    expect(row.crossAxisAlignment, CrossAxisAlignment.stretch);
    expect(tester.getSize(find.byType(WeekdayHeader)).height, 45);
  });

  testWidgets('should default to a 45px header height', (tester) async {
    await tester.pumpWidget(
      _wrap(WeekdayHeader(weekStartDate: weekStart, currentWeek: 1)),
    );

    expect(tester.getSize(find.byType(WeekdayHeader)).height, 45);
  });

  testWidgets('should align header width with a narrow time column', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        WeekdayHeader(
          weekStartDate: weekStart,
          currentWeek: 1,
          height: 60,
          timeColumnWidth: 40,
        ),
      ),
    );

    expect(tester.getSize(find.byType(WeekdayHeader)).height, 60);
  });
}
