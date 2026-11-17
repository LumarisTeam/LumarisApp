import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/page_app_bar.dart';
import 'package:ios_club_app/ui/components/settings_group.dart';
import 'package:ios_club_app/ui/components/study_credit_card.dart';
import 'package:ios_club_app/ui/pages/profile_page/profile_page.dart';
import 'package:ios_club_app/ui/theme/app_theme_color.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ProfileUserStore extends UserStore {
  _ProfileUserStore({required this.isSignedIn});

  final bool isSignedIn;

  @override
  UserState build() => UserState(isLogin: isSignedIn);

  void signOut() => state = const UserState();
}

Widget _profileApp(
  _ProfileUserStore user, {
  TextScaler? textScaler,
  Brightness brightness = Brightness.light,
}) {
  return ProviderScope(
    overrides: [userStoreProvider.overrideWith(() => user)],
    child: MaterialApp(
      theme: AppThemeColor.blue.materialTheme(brightness),
      locale: const Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
      home: const ProfilePage(),
    ),
  );
}

double? _fontSize(WidgetTester tester, String label) {
  final Finder paragraph = find.descendant(
    of: find.text(label),
    matching: find.byType(RichText),
  );
  return tester.widget<RichText>(paragraph).text.style?.fontSize;
}

void main() {
  const String account = '202601234567890123456789012345';
  const String accountNote = '西安建筑科技大学 · 教务系统账号';

  setUpAll(() async {
    final InfoModel credits = InfoModel(
      type: '主修',
      total: TotalData(name: '总学分', actual: 56, full: 179),
      other: [
        TotalData(name: '通识教育教学模块', actual: 32, full: 38),
        TotalData(name: '创新创业教育及课外素质教育模块', actual: 1, full: 14),
      ],
    );
    SharedPreferences.setMockInitialValues({
      PrefsKeys.INFO_DATA: jsonEncode([credits.toJson()]),
      PrefsKeys.INFO_DATA_TIME: DateTime.now().millisecondsSinceEpoch,
    });
    await PrefsService.init();
    FlutterSecureStorage.setMockInitialValues({PrefsKeys.USERNAME: account});
  });

  testWidgets('should_use_settings_styles_and_align_credits_when_signed_in', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1050);
    addTearDown(tester.view.reset);

    final _ProfileUserStore user = _ProfileUserStore(isSignedIn: true);
    await tester.pumpWidget(_profileApp(user));
    await tester.pumpAndSettle();

    expect(find.byType(PageAppBar), findsOneWidget);
    expect(find.byType(SettingsSectionTitle), findsNWidgets(3));
    expect(find.byType(SettingsGroup), findsNWidgets(4));
    expect(find.byType(Divider), findsNothing);
    expect(_fontSize(tester, '我的'), 22);
    expect(_fontSize(tester, account), 16);
    expect(_fontSize(tester, accountNote), 13);
    expect(_fontSize(tester, '校园服务'), 14);
    expect(_fontSize(tester, '培养方案'), 16);
    expect(_fontSize(tester, '主修学分'), 16);
    expect(_fontSize(tester, '通识教育'), 15);

    final Finder accountTile = find.ancestor(
      of: find.text(account),
      matching: find.byType(McListTile),
    );
    expect(tester.widget<McListTile>(accountTile).onTap, isNull);

    final Finder programTile = find.ancestor(
      of: find.text('培养方案'),
      matching: find.byType(McListTile),
    );
    final Icon programIcon = tester.widget<Icon>(
      find.descendant(of: programTile, matching: find.byType(Icon)).first,
    );
    expect(programIcon.size, 20);
    expect(programIcon.color, tester.element(programTile).mc.primary);

    final Rect program = tester.getRect(programTile);
    final Rect credits = tester.getRect(find.byType(StudyCreditCard));
    expect(program.width, lessThanOrEqualTo(520));
    expect(program.left, credits.left);
    expect(program.right, credits.right);
    expect(credits.top - program.bottom, closeTo(8, 0.01));
    expect(
      tester.getTopLeft(find.text('设置与支持')).dy,
      greaterThan(credits.bottom),
    );
  });

  testWidgets('should_fit_large_text_and_hide_credits_when_signing_out', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 720);
    addTearDown(tester.view.reset);

    final _ProfileUserStore user = _ProfileUserStore(isSignedIn: true);
    await tester.pumpWidget(
      _profileApp(
        user,
        textScaler: const TextScaler.linear(2),
        brightness: Brightness.dark,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(accountNote), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('创新创业与课外素质'), 300);
    expect(tester.takeException(), isNull);
    expect(find.text('创新创业与课外素质'), findsOneWidget);

    user.signOut();
    await tester.pumpAndSettle();
    expect(find.text(account), findsNothing);
    expect(find.byType(StudyCreditCard), findsNothing);
    expect(find.text('教务'), findsNothing);
    expect(find.text('校园服务'), findsNothing);
    expect(find.text('登录教务系统'), findsOneWidget);
    final Finder guestTile = find.ancestor(
      of: find.text('登录教务系统'),
      matching: find.byType(McListTile),
    );
    expect(tester.widget<McListTile>(guestTile).onTap, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
