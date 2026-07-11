import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/services/electricity_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';
import 'package:ios_club_app/ui/pages/electricity_page.dart';
import 'package:ios_club_app/ui/pages/payment_page.dart';
import 'package:ios_club_app/ui/pages/program_page.dart';
import 'package:ios_club_app/ui/pages/school_bus_page.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ClubTheme.lightTheme(),
    darkTheme: ClubTheme.darkTheme(),
    home: child,
  );
}

class _LoggedInUserStore extends UserStore {
  @override
  UserState build() => UserState(
        isLogin: true,
        userData: UserData(studentId: 'widget-test', cookie: 'test-cookie'),
      );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    await PrefsService.instance.clear();
    await PrefsService.instance.setString(
      PrefsKeys.USER_DATA,
      '{"studentId":"widget-test","cookie":"test-cookie"}',
    );
    await PrefsService.instance.setInt(
      PrefsKeys.LAST_FETCH_TIME,
      DateTime.now().millisecondsSinceEpoch,
    );
  });

  testWidgets('ProgramPage should not expose pull to refresh', (tester) async {
    final container = ProviderContainer(
      overrides: [
        programAutoLoadProvider.overrideWithValue(false),
        programsFetcherProvider.overrideWithValue(
          ({bool forceRefresh = false}) async => [
            PlanCourseList(
              term: '1',
              courses: [
                PlanCourse(
                  name: '高等数学',
                  courseTypeName: '必修',
                  credits: 4,
                  examMode: '考试',
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(programControllerProvider.notifier).loadPrograms();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _wrapWithApp(const ProgramPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('PaymentPage should expose pull to refresh', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tileStoreAutoLoadProvider.overrideWithValue(false),
          userStoreProvider.overrideWith(_LoggedInUserStore.new),
        ],
        child: _wrapWithApp(const PaymentPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('ElectricityPage should expose pull to refresh', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tileStoreAutoLoadProvider.overrideWithValue(false),
        ],
        child: _wrapWithApp(const ElectricityPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('ElectricityPage should render subscription section',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        tileStoreAutoLoadProvider.overrideWithValue(false),
        electricityReaderProvider.overrideWithValue(() async => 23.5),
        electricityWeeklyReaderProvider
            .overrideWithValue(() async => <ElectricData>[]),
        electricityTileVisibilityReaderProvider
            .overrideWithValue((_) async => false),
        electricityServiceProvider.overrideWithValue(
          ElectricityService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(electricityStoreProvider.notifier)
        .loadElectricityData();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _wrapWithApp(const ElectricityPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('低余额订阅'), findsOneWidget);
    expect(find.text('添加低余额提醒'), findsOneWidget);
  });

  testWidgets(
      'ElectricityPage should show delete entry for active subscription',
      (tester) async {
    final service = ElectricityService(
      subscriptionQueryReader: (email) async =>
          const ElectricitySubscriptionQueryResponse(
        email: 'codex@example.com',
        hasSubscription: true,
        subscriptionId: 'sub-1',
        threshold: 10,
      ),
    );
    await service.saveSubscriptionEmail('codex@example.com');

    final container = ProviderContainer(
      overrides: [
        tileStoreAutoLoadProvider.overrideWithValue(false),
        electricityReaderProvider.overrideWithValue(() async => 23.5),
        electricityWeeklyReaderProvider
            .overrideWithValue(() async => <ElectricData>[]),
        electricityTileVisibilityReaderProvider
            .overrideWithValue((_) async => false),
        electricityServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(electricityStoreProvider.notifier)
        .loadElectricityData();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _wrapWithApp(const ElectricityPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已开启低余额提醒'), findsOneWidget);
    expect(find.text('删除订阅'), findsOneWidget);
  });

  testWidgets('ElectricityPage should show subscription details dialog',
      (tester) async {
    final service = ElectricityService(
      subscriptionQueryReader: (email) async =>
          const ElectricitySubscriptionQueryResponse(
        email: 'codex@example.com',
        hasSubscription: true,
        subscriptionId: 'sub-1',
        threshold: 12.5,
      ),
    );
    await service.saveSubscriptionEmail('cached@example.com');

    final container = ProviderContainer(
      overrides: [
        tileStoreAutoLoadProvider.overrideWithValue(false),
        electricityReaderProvider.overrideWithValue(() async => 23.5),
        electricityWeeklyReaderProvider
            .overrideWithValue(() async => <ElectricData>[]),
        electricityTileVisibilityReaderProvider
            .overrideWithValue((_) async => false),
        electricityServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(electricityStoreProvider.notifier)
        .loadElectricityData();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _wrapWithApp(const ElectricityPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('已开启低余额提醒'));
    await tester.tap(find.text('已开启低余额提醒'));
    await tester.pumpAndSettle();

    expect(find.text('提醒邮箱'), findsOneWidget);
    expect(find.text('codex@example.com'), findsOneWidget);
    expect(find.text('提醒阈值'), findsOneWidget);
    expect(find.text('12.50 元'), findsOneWidget);
  });

  testWidgets('ElectricityPage should delete active subscription',
      (tester) async {
    var deletedId = '';
    var hasSubscription = true;
    final service = ElectricityService(
      subscriptionQueryReader: (email) async =>
          ElectricitySubscriptionQueryResponse(
        email: 'codex@example.com',
        hasSubscription: hasSubscription,
        subscriptionId: hasSubscription ? 'sub-1' : '',
        threshold: hasSubscription ? 10 : 0,
      ),
      subscriptionDeleter: (id) async {
        deletedId = id;
        hasSubscription = false;
      },
    );
    await service.saveSubscriptionEmail('codex@example.com');

    final container = ProviderContainer(
      overrides: [
        tileStoreAutoLoadProvider.overrideWithValue(false),
        electricityReaderProvider.overrideWithValue(() async => 23.5),
        electricityWeeklyReaderProvider
            .overrideWithValue(() async => <ElectricData>[]),
        electricityTileVisibilityReaderProvider
            .overrideWithValue((_) async => false),
        electricityServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(electricityStoreProvider.notifier)
        .loadElectricityData();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _wrapWithApp(const ElectricityPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('删除订阅'));
    await tester.tap(find.text('删除订阅'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(deletedId, 'sub-1');
    expect(find.text('添加低余额提醒'), findsOneWidget);
  });

  testWidgets('SchoolBusPage should expose pull to refresh', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          busPageAutoLoadProvider.overrideWithValue(false),
        ],
        child: _wrapWithApp(const SchoolBusPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
