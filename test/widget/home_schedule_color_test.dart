import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/ui/pages/home_page/schedule_widget.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _course = CourseModel(
  courseName: '测试课程',
  lessonId: 'L1',
  weekday: 1,
  weekIndexes: [1],
  startUnit: 1,
  endUnit: 2,
);

class _FakeScheduleStore extends ScheduleStore {
  @override
  ScheduleState build() => const ScheduleState();

  @override
  ({bool showTomorrow, List<CourseModel> courses}) getHomeCourses({
    required bool showTomorrow,
  }) => (showTomorrow: false, courses: [_course]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'should synchronize home colors with schedule themes and overrides',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await PrefsService.init();
      final container = ProviderContainer(
        overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
      );
      addTearDown(container.dispose);
      final styleStore = container.read(scheduleStyleStoreProvider.notifier);
      final settings = container.read(settingsStoreProvider.notifier);

      Future<void> showHome(McColors colors) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              locale: const Locale('zh'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: McThemeData.materialTheme(colors),
            builder: (context, child) => Material(child: child),
              home: const Scaffold(body: ScheduleWidget()),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Color barColor() {
        final bar = tester.widget<Container>(
          find.byKey(const ValueKey('homeCourseColorBar')),
        );
        return (bar.decoration! as ShapeDecoration).color!;
      }

      Color expected(bool isDark) {
        final style = container.read(scheduleStyleStoreProvider);
        return ScheduleColorResolver.colorForCourse(
          _course,
          isDark ? style.darkColorPool : style.lightColorPool,
          style.courseColorOverrides,
          themeId: isDark
              ? style.darkColorPoolThemeId
              : style.lightColorPoolThemeId,
        );
      }

      await showHome(McColors.light);
      expect(
        barColor(),
        CourseColorManager.generateSoftColor(_course.courseName),
      );

      await styleStore.applyColorPoolTheme(isDark: false, themeId: 'latte');
      await tester.pumpAndSettle();
      expect(barColor(), expected(false));

      final customId = await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '测试主题',
      );
      final index =
          ScheduleColorResolver.stableHash(_course.courseName) %
          container.read(scheduleStyleStoreProvider).lightColorPool.length;
      await styleStore.setCustomColorThemeColor(
        id: customId!,
        index: index,
        color: const Color(0xFF123456),
      );
      await tester.pumpAndSettle();
      expect(barColor(), const Color(0xFF123456));
      expect(barColor(), expected(false));

      await styleStore.applyColorPoolTheme(isDark: true, themeId: 'macchiato');
      await showHome(McColors.dark);
      expect(barColor(), expected(true));

      await showHome(McColors.light);
      await settings.setBackgroundImageFor(
        isDark: false,
        path: 'wallpaper.png',
      );
      await settings.setBackgroundIsDarkFor(isDark: false, value: true);
      await tester.pumpAndSettle();
      expect(barColor(), expected(true));

      await tester.tap(find.text(_course.courseName));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CourseDetailSheet>(find.byType(CourseDetailSheet)).isDark,
        isTrue,
      );
      final dot = tester.widget<Container>(
        find.byKey(const ValueKey('courseColorSwatchDot')),
      );
      expect((dot.decoration! as BoxDecoration).color, expected(true));
      Navigator.of(tester.element(find.byType(CourseDetailSheet))).pop();
      await tester.pumpAndSettle();

      await styleStore.setCourseColorOverride('id:L1', const Color(0xFFABCDEF));
      await tester.pumpAndSettle();
      expect(barColor(), const Color(0xFFABCDEF));
      await styleStore.clearCourseColorOverride('id:L1');
      await tester.pumpAndSettle();
      expect(barColor(), expected(true));
    },
  );
}
