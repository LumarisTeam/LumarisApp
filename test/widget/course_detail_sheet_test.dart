import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

CourseModel _course({bool isCustom = false}) => CourseModel(
  courseName: '高等数学A1',
  lessonId: 'L1',
  room: 'A101',
  teachers: const ['张老师'],
  weekday: 1,
  startUnit: 1,
  endUnit: 2,
  isCustom: isCustom,
);

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: McThemeData.materialTheme(McColors.light),
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

Color? _swatchColor(WidgetTester tester) {
  final dot = tester.widget<Container>(
    find.byKey(const ValueKey('courseColorSwatchDot')),
  );
  return (dot.decoration! as BoxDecoration).color;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    // PrefsService 缓存的是同一个实例，这里显式清掉上一个用例写入的覆盖色。
    await PrefsService.instance.remove(
      PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
    );
    await PrefsService.instance.setInt(
      PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA,
      ScheduleStyleStore.colorPoolSchema,
    );
  });

  testWidgets('should show the auto pool color on the swatch', (tester) async {
    final course = _course();
    await tester.pumpWidget(_wrap(CourseDetailSheet(course: course)));

    expect(
      _swatchColor(tester),
      ScheduleColorResolver.colorFor(
        course.courseName,
        scheduleDefaultLightColorPool,
      ),
    );
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
  });

  testWidgets('should show the persisted override color', (tester) async {
    await PrefsService.instance.setString(
      PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
      '{"id:L1":"FF123456"}',
    );

    await tester.pumpWidget(_wrap(CourseDetailSheet(course: _course())));

    expect(_swatchColor(tester), const Color(0xFF123456));
  });

  testWidgets('should use the dark pool when isDark is true', (tester) async {
    final course = _course();
    await tester.pumpWidget(
      _wrap(CourseDetailSheet(course: course, isDark: true)),
    );

    expect(
      _swatchColor(tester),
      ScheduleColorResolver.colorFor(
        course.courseName,
        scheduleDefaultDarkColorPool,
      ),
    );
  });

  testWidgets('should open the HSV picker when tapping the swatch', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(CourseDetailSheet(course: _course())));

    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pumpAndSettle();

    expect(find.text('H'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(find.text('V'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should show the swatch next to the custom course menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CourseDetailSheet(
          course: _course(isCustom: true),
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.ellipsis_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should center the swatch with the single-line title', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(CourseDetailSheet(course: _course())));

    final titleCenter = tester.getCenter(
      find.byKey(const ValueKey('courseDetailTitle')),
    );
    final dotCenter = tester.getCenter(
      find.byKey(const ValueKey('courseColorSwatchDot')),
    );

    expect((titleCenter.dy - dotCenter.dy).abs(), lessThan(0.5));
  });

  testWidgets('should center the swatch with the two-line title block', (
    tester,
  ) async {
    final course = CourseModel(
      courseName: '高等数学A1（超长课程名称用于测试两行标题对齐效果）',
      lessonId: 'L1',
      room: 'A101',
      teachers: const ['张老师'],
      weekday: 1,
      startUnit: 1,
      endUnit: 2,
    );

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 220,
          child: CourseDetailSheet(course: course, isDark: false),
        ),
      ),
    );

    final titleFinder = find.byKey(const ValueKey('courseDetailTitle'));
    expect(tester.getSize(titleFinder).height, greaterThan(40));

    final titleCenter = tester.getCenter(titleFinder);
    final dotCenter = tester.getCenter(
      find.byKey(const ValueKey('courseColorSwatchDot')),
    );

    expect((titleCenter.dy - dotCenter.dy).abs(), lessThan(0.5));
  });
}
