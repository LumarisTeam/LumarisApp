import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/agreement_page/agreement_page.dart';
import 'package:ios_club_app/ui/pages/home_page/home_page.dart';
import 'package:ios_club_app/ui/pages/link_page/link_page.dart';
import 'package:ios_club_app/ui/pages/login_page/login_page.dart';
import 'package:ios_club_app/ui/pages/mcp_page/mcp_page.dart';
import 'package:ios_club_app/ui/pages/permission_page/permission_page.dart';
import 'package:ios_club_app/ui/pages/profile_page/profile_page.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page/schedule_list_page.dart';
import 'package:ios_club_app/ui/pages/score_page/score_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    AppRouter.go(AppRoutes.agreement);
  });

  Widget buildMatchedRoute(BuildContext context, String location) {
    final match = AppRouter.router.configuration.findMatch(Uri.parse(location));
    expect(match.isError, isFalse);

    final state = match.last.buildState(
      AppRouter.router.configuration,
      match,
      metadata: const {},
    );
    return match.last.route.builder!(context, state);
  }

  Widget buildRouterApp() {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
      ),
    );
  }

  testWidgets('matches and builds the core route table', (tester) async {
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: SizedBox()),
    );
    final context = tester.element(find.byType(SizedBox));

    expect(buildMatchedRoute(context, AppRoutes.home), isA<HomePage>());
    expect(
      buildMatchedRoute(context, AppRoutes.schedule),
      isA<ScheduleListPage>(),
    );
    expect(buildMatchedRoute(context, AppRoutes.score), isA<ScorePage>());
    expect(buildMatchedRoute(context, AppRoutes.profile), isA<ProfilePage>());
    expect(buildMatchedRoute(context, AppRoutes.login), isA<LoginPage>());
    expect(buildMatchedRoute(context, AppRoutes.link), isA<LinkPage>());
    expect(buildMatchedRoute(context, AppRoutes.mcp), isA<McpPage>());
    expect(
      buildMatchedRoute(context, AppRoutes.permissions),
      isA<PermissionPage>(),
    );
  });

  testWidgets('login route can return true when popped', (tester) async {
    await tester.pumpWidget(buildRouterApp());
    await tester.pumpAndSettle();

    final resultFuture = AppRouter.push<bool>(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);

    AppRouter.pop(true);
    await tester.pumpAndSettle();

    await expectLater(resultFuture, completion(isTrue));
  });

  testWidgets('go switches the active route without GetX routing', (
    tester,
  ) async {
    AppRouter.go(AppRoutes.login);
    await tester.pumpWidget(buildRouterApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    AppRouter.go(AppRoutes.agreement);
    await tester.pumpAndSettle();

    expect(AppRouter.currentLocation, AppRoutes.agreement);
    expect(find.byType(AgreementPage), findsOneWidget);
  });
}
