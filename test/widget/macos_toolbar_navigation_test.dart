import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/platform/macos/macos_sidebar.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/pages/agreement_page/agreement_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  testWidgets(
    'should_keep_toolbar_and_sidebar_when_returning_from_detail_route',
    (tester) async {
      AppRouter.go(AppRoutes.agreement);
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            locale: const Locale('zh'),
            theme: McThemeData.materialTheme(McColors.light),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AgreementPage), findsOneWidget);
      expect(find.byType(McToolBar), findsOneWidget);
      expect(find.byType(MacosSidebar), findsOneWidget);
      expect(
        find.descendant(of: find.byType(McToolBar), matching: find.text('光序')),
        findsOneWidget,
      );

      final backButton = find.descendant(
        of: find.byType(McToolBar),
        matching: find.byIcon(CupertinoIcons.chevron_back),
      );
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(AppRouter.currentLocation, AppRoutes.about);
      expect(find.byType(AgreementPage), findsNothing);
      expect(find.byType(McToolBar), findsOneWidget);

      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(AppRouter.currentLocation, AppRoutes.profile);
      final back = tester.widget<McToolBarIconButton>(
        find
            .ancestor(
              of: backButton,
              matching: find.byType(McToolBarIconButton),
            )
            .first,
      );
      expect(back.onPressed, isNull);

      final toggle = find.descendant(
        of: find.byType(McToolBar),
        matching: find.byIcon(CupertinoIcons.sidebar_left),
      );
      await tester.tap(toggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(MacosSidebar), findsNothing);
      expect(find.byType(McToolBar), findsOneWidget);
      await tester.tap(toggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(MacosSidebar), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );
}
