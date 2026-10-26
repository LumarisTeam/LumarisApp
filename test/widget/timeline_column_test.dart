import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/ui/components/schedule/timeline_column.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: McThemeData.materialTheme(McColors.light),
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(TimeService.useBuiltInTables);

  testWidgets('should show section number and times by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          height: 600,
          child: TimelineColumn(periodCount: 12, cellHeight: 50),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('8:30'), findsOneWidget);
    expect(find.text('9:15'), findsOneWidget);
  });

  testWidgets('should hide section times when hideSectionTime is true', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          height: 600,
          child: TimelineColumn(
            periodCount: 12,
            cellHeight: 50,
            hideSectionTime: true,
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('8:30'), findsNothing);
    expect(find.text('9:15'), findsNothing);
  });

  testWidgets('should respect the configured time column width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          height: 600,
          child: TimelineColumn(
            periodCount: 12,
            cellHeight: 50,
            timeColumnWidth: 40,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(TimelineColumn)).width, 40);
  });
}
