import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/pages/home_page/schedule_widget.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduleStore extends ScheduleStore {
  @override
  ScheduleState build() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final course = CourseModel(
      courseName: '明日测试课程',
      weekday: tomorrow.weekday,
      weekIndexes: [1, 2],
      startUnit: 1,
      endUnit: 2,
    );
    return ScheduleState(
      currentWeek: 1,
      allCourses: [
        [],
        [course],
        [course],
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should update home when tomorrow setting changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    final container = ProviderContainer(
      overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
    );
    addTearDown(container.dispose);

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
          theme: McThemeData.materialTheme(McColors.light),
          home: const Scaffold(body: ScheduleWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('明日课表'), findsNothing);
    expect(find.text('明日测试课程'), findsNothing);

    await container
        .read(settingsStoreProvider.notifier)
        .setIsShowTomorrow(true);
    await tester.pumpAndSettle();
    expect(find.text('明日课表'), findsOneWidget);
    expect(find.text('明日测试课程'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.gear_solid));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CupertinoSwitch).first);
    await tester.pumpAndSettle();
    expect(find.text('明日课表'), findsNothing);
    expect(find.text('明日测试课程'), findsNothing);
    expect(container.read(settingsStoreProvider).isShowTomorrow, isFalse);
  });
}
