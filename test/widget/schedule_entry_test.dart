import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/platform/mobile/bottom_navigation.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page/html_import_page.dart';

final CourseModel _course = CourseModel(
  courseName: '计算机组成原理',
  room: '信息工程学院实验教学中心三楼东侧实验教室 301',
  teachers: ['张老师'],
  weekday: 1,
  startUnit: 1,
  endUnit: 2,
  weekIndexes: [1],
);

class _GuestScheduleStore extends ScheduleStore {
  _GuestScheduleStore({this.hasTimetable = false, this.hasCourseToday = false});

  final bool hasTimetable;
  final bool hasCourseToday;

  @override
  ScheduleState build() => ScheduleState(
    isLoading: false,
    maxWeek: 1,
    currentWeek: 1,
    currentPage: 1,
    allCourses: hasTimetable
        ? [
            [_course],
            [_course],
          ]
        : [],
  );

  @override
  ({bool showTomorrow, List<CourseModel> courses}) getHomeCourses({
    required bool showTomorrow,
  }) => (showTomorrow: false, courses: hasCourseToday ? [_course] : []);

  void finishImport() {
    state = state.copyWith(
      allCourses: [
        [_course],
        [_course],
      ],
    );
  }
}

class _GuestUserStore extends UserStore {
  @override
  UserState build() => const UserState();
}

Future<void> _showPage(
  WidgetTester tester,
  String location,
  _GuestScheduleStore schedule, {
  double width = 393,
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 852);
  const safeArea = FakeViewPadding(top: 59, bottom: 34);
  tester.view.padding = safeArea;
  tester.view.viewPadding = safeArea;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
  });

  AppRouter.go(location);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scheduleStoreProvider.overrideWith(() => schedule),
        userStoreProvider.overrideWith(_GuestUserStore.new),
      ],
      child: MaterialApp.router(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.router,
        theme: McThemeData.materialTheme(McColors.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mobile = TargetPlatformVariant({TargetPlatform.iOS});

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    TimeService.useBuiltInTables();
  });

  for (final location in [AppRoutes.home, AppRoutes.schedule]) {
    testWidgets('should open import when $location has no guest timetable', (
      tester,
    ) async {
      final schedule = _GuestScheduleStore();
      await _showPage(tester, location, schedule);

      expect(find.text('尚未导入课表'), findsOneWidget);
      expect(find.text('今天没有课了'), findsNothing);
      await tester.tap(find.text('导入课表'));
      await tester.pumpAndSettle();
      expect(find.byType(HtmlImportPage), findsOneWidget);

      schedule.finishImport();
      AppRouter.pop(true);
      await tester.pumpAndSettle();
      expect(find.text('导入课表'), findsNothing);
      if (location == AppRoutes.schedule) {
        expect(find.byType(CourseCard), findsOneWidget);
      } else {
        expect(find.text('今天没有课了'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }, variant: mobile);
  }

  testWidgets('should fit course details and tabs when text is larger', (
    tester,
  ) async {
    await _showPage(
      tester,
      AppRoutes.home,
      _GuestScheduleStore(hasTimetable: true, hasCourseToday: true),
      width: 320,
      scale: 1.5,
    );

    final room = tester.getRect(find.text(_course.room));
    expect(room.right, lessThan(320));
    expect(room.height, greaterThan(25));
    expect(tester.getRect(find.text('课表')).bottom, lessThanOrEqualTo(818));
    expect(tester.takeException(), isNull);
  }, variant: mobile);

  testWidgets('should keep the tab bar flush with the bottom safe area', (
    tester,
  ) async {
    await _showPage(
      tester,
      AppRoutes.home,
      _GuestScheduleStore(hasTimetable: true),
    );

    final bar = tester.getRect(find.byType(BottomNavigation));
    expect(bar.left, 0);
    expect(bar.right, 393);
    expect(bar.bottom, 852);
    expect(bar.height, inInclusiveRange(83, 85));
    expect(tester.getRect(find.text('课表')).bottom, lessThanOrEqualTo(818));

    await tester.tap(find.text('课表'));
    await tester.pumpAndSettle();
    expect(AppRouter.currentLocation, AppRoutes.schedule);
    expect(tester.getRect(find.byType(BottomNavigation)), bar);
  }, variant: mobile);

  testWidgets(
    'should update the tab selection on the first frame when tapped',
    (tester) async {
      await _showPage(
        tester,
        AppRoutes.home,
        _GuestScheduleStore(hasTimetable: true),
      );

      final Finder bottomBar = find.byType(BottomNavigation);
      final BuildContext barContext = tester.element(bottomBar);
      final Color selectedColor = Theme.of(barContext).colorScheme.primary;
      final Color unselectedColor = barContext.mc.colors.secondaryLabel;
      final Finder homeLabel = find.descendant(
        of: bottomBar,
        matching: find.text('首页'),
      );
      final Finder scheduleLabel = find.descendant(
        of: bottomBar,
        matching: find.text('课表'),
      );

      await tester.tap(scheduleLabel);
      await tester.pump();

      expect(AppRouter.currentLocation, AppRoutes.schedule);
      expect(find.byIcon(CupertinoIcons.house_fill), findsNothing);
      expect(find.byIcon(CupertinoIcons.clock_fill), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(homeLabel)).style.color,
        unselectedColor,
      );
      expect(
        DefaultTextStyle.of(tester.element(scheduleLabel)).style.color,
        selectedColor,
      );
      await tester.pumpAndSettle();
    },
    variant: mobile,
  );

  testWidgets(
    'should choose a week by tapping the picker and still swipe',
    (tester) async {
      final isDesktop = defaultTargetPlatform == TargetPlatform.windows;
      final currentWeekLabel = isDesktop ? '1周 (本周)' : '1周';
      await _showPage(
        tester,
        AppRoutes.schedule,
        _GuestScheduleStore(hasTimetable: true),
        width: isDesktop ? 1200 : 320,
        scale: 1.5,
      );

      await tester.tap(find.text(currentWeekLabel));
      await tester.pumpAndSettle();
      expect(find.text('本周 · 1周'), findsOneWidget);
      await tester.tap(find.text('全部课表'));
      await tester.pumpAndSettle();
      expect(find.text('全部课表'), findsOneWidget);
      expect(find.text('本周 · 1周'), findsNothing);

      final pageView = find.byType(PageView);
      await tester.drag(
        pageView,
        Offset(-tester.getSize(pageView).width * 0.8, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text(currentWeekLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.windows,
    }),
  );
}
