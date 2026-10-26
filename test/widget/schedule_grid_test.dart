import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/schedule_color_themes.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_visual_style.dart';

CourseModel _course() => CourseModel(
  courseName: '高等数学',
  room: 'A101',
  teachers: const ['张老师'],
  weekday: 1,
  startUnit: 1,
  endUnit: 2,
  campus: TimeService.caoTangCampus,
);

ScheduleVisualStyle _style() {
  return const ScheduleVisualStyle(
    cellHeight: 50,
    headerHeight: 45,
    brightness: Brightness.light,
    colorPool: scheduleDefaultLightColorPool,
    showGrid: true,
  );
}

void main() {
  setUp(TimeService.useBuiltInTables);

  testWidgets(
    'should update rendered text when switching between Latte and Macchiato',
    (WidgetTester tester) async {
      for (final McColors appColors in [McColors.light, McColors.dark]) {
        for (final String themeId in ['latte', 'macchiato', 'latte']) {
          final Color background =
              ScheduleColorThemeCatalog.accentsById[themeId]![2];
          final Color expectedText = themeId == 'latte'
              ? McColors.dark.foreground
              : McColors.light.foreground;
          await tester.pumpWidget(
            MaterialApp(
              theme: McThemeData.materialTheme(appColors),
              home: Scaffold(
                body: SizedBox(
                  width: 400,
                  height: 600,
                  child: ScheduleGrid(
                    courses: [_course()],
                    cellHeight: 50,
                    visualStyle: ScheduleVisualStyle(
                      cellHeight: 50,
                      headerHeight: 45,
                      brightness: appColors == McColors.dark
                          ? Brightness.dark
                          : Brightness.light,
                      colorThemeId: themeId,
                      colorPool: [background],
                      showGrid: true,
                    ),
                    preview: true,
                  ),
                ),
              ),
            ),
          );
          for (final String label in ['高等数学', 'A101', '张老师']) {
            final Text text = tester.widget<Text>(find.text(label));
            expect(
              text.style?.color,
              expectedText.withValues(alpha: 0.92),
              reason: '$themeId: $label',
            );
          }
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets('should render a course in section mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: McThemeData.materialTheme(McColors.light),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 12 * 50,
            child: ScheduleGrid(
              courses: [_course()],
              cellHeight: 50,
              visualStyle: _style(),
              preview: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('高等数学'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should apply a course color override to the block', (
    tester,
  ) async {
    const overrideColor = Color(0xFF123456);
    final course = CourseModel(
      courseName: '高等数学',
      lessonId: 'L1',
      room: 'A101',
      teachers: const ['张老师'],
      weekday: 1,
      startUnit: 1,
      endUnit: 2,
      campus: TimeService.caoTangCampus,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: McThemeData.materialTheme(McColors.light),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 12 * 50,
            child: ScheduleGrid(
              courses: [course],
              cellHeight: 50,
              visualStyle: const ScheduleVisualStyle(
                cellHeight: 50,
                headerHeight: 45,
                brightness: Brightness.light,
                colorPool: scheduleDefaultLightColorPool,
                showGrid: true,
                courseColorOverrides: {'id:L1': overrideColor},
              ),
              preview: true,
            ),
          ),
        ),
      ),
    );

    final card = tester.widget<CourseCard>(find.byType(CourseCard));
    expect(card.backgroundColor, overrideColor);
  });
}
