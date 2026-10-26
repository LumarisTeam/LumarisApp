import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';

CourseModel _course() => CourseModel(
  courseName: '高等数学',
  room: 'A101',
  teachers: const ['张老师'],
  weekday: 1,
  startUnit: 1,
  endUnit: 2,
);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: McThemeData.materialTheme(McColors.light),
    home: Scaffold(body: SizedBox(width: 200, height: 120, child: child)),
  );
}

void main() {
  testWidgets('should hide teacher when hideTeacher is true', (tester) async {
    await tester.pumpWidget(
      _wrap(CourseCard(course: _course(), height: 120, hideTeacher: true)),
    );

    expect(find.text('张老师'), findsNothing);
    expect(find.text('高等数学'), findsOneWidget);
    expect(find.text('A101'), findsOneWidget);
  });

  testWidgets('should show teacher by default', (tester) async {
    await tester.pumpWidget(_wrap(CourseCard(course: _course(), height: 120)));

    expect(find.text('张老师'), findsOneWidget);
  });

  testWidgets('should apply the custom course text color', (tester) async {
    const textColor = Color(0xFF123456);
    await tester.pumpWidget(
      _wrap(CourseCard(course: _course(), height: 120, textColor: textColor)),
    );

    final text = tester.widget<Text>(find.text('高等数学'));
    expect(text.style?.color, textColor.withValues(alpha: 0.92));
  });

  testWidgets('should render all border styles without errors', (tester) async {
    for (final borderStyle in ScheduleBorderStyle.values) {
      await tester.pumpWidget(
        _wrap(
          CourseCard(course: _course(), height: 120, borderStyle: borderStyle),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('should hide location when requested', (tester) async {
    await tester.pumpWidget(
      _wrap(CourseCard(course: _course(), height: 120, hideLocation: true)),
    );

    expect(find.text('A101'), findsNothing);
    expect(find.text('高等数学'), findsOneWidget);
  });

  testWidgets('should render the time label and scale fonts', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CourseCard(
          course: _course(),
          height: 120,
          timeLabel: '8:00',
          fontScale: 2,
        ),
      ),
    );

    expect(find.text('8:00'), findsOneWidget);
    final name = tester.widget<Text>(find.text('高等数学'));
    expect(name.style?.fontSize, greaterThan(20));
  });

  testWidgets('should visibly scale preview text with fontScale', (
    tester,
  ) async {
    Future<double> renderHeight(double scale) async {
      await tester.pumpWidget(
        _wrap(
          CourseCard(
            course: _course(),
            height: 120,
            preview: true,
            fontScale: scale,
          ),
        ),
      );
      return tester.getSize(find.text('高等数学')).height;
    }

    final normalHeight = await renderHeight(1);
    final largeHeight = await renderHeight(2);

    expect(largeHeight, greaterThan(normalHeight));
  });

  testWidgets('should center text vertically in the preview', (tester) async {
    Column textColumn() => tester.widget<Column>(
      find.ancestor(of: find.text('高等数学'), matching: find.byType(Column)).first,
    );

    await tester.pumpWidget(
      _wrap(
        CourseCard(
          course: _course(),
          height: 120,
          preview: true,
          centerVertically: true,
        ),
      ),
    );
    expect(textColumn().mainAxisAlignment, MainAxisAlignment.center);

    await tester.pumpWidget(
      _wrap(CourseCard(course: _course(), height: 120, preview: true)),
    );
    expect(textColumn().mainAxisAlignment, MainAxisAlignment.start);
  });

  testWidgets(
    'should render custom radius, padding and opacity without errors',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          CourseCard(
            course: _course(),
            height: 120,
            cornerRadius: 0,
            innerPadding: 8,
            outerPadding: 4,
            opacity: 0.5,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('should center text horizontally when requested', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CourseCard(
          course: _course(),
          height: 120,
          centerHorizontally: true,
          centerVertically: true,
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('高等数学'));
    expect(text.textAlign, TextAlign.center);
  });
}
