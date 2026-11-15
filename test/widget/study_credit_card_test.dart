import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/components/study_credit_card.dart';
import 'package:ios_club_app/ui/theme/app_theme_color.dart';
import 'package:material_ui/material_ui.dart';

Widget _creditTestApp({
  required Widget child,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: AppThemeColor.blue.materialTheme(brightness),
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  final InfoModel credits = InfoModel(
    type: '主修',
    total: TotalData(name: '总学分', actual: 56, full: 179),
    other: [
      TotalData(name: '通识教育教学模块', actual: 46.5, full: 69.5),
      TotalData(name: '创新创业教育及课外素质教育模块', actual: 1, full: 14),
      TotalData(name: '校本选修模块', actual: 0, full: 0),
    ],
  );

  testWidgets('should_show_one_progress_ring_when_credit_data_loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _creditTestApp(child: StudyCreditCard(data: credits)),
    );

    expect(find.text('主修学分'), findsOneWidget);
    expect(find.text('56 / 179'), findsOneWidget);
    expect(find.text('通识教育'), findsOneWidget);
    expect(find.text('46.5 / 69.5'), findsOneWidget);
    expect(find.text('创新创业与课外素质'), findsOneWidget);
    expect(find.text('校本选修模块'), findsOneWidget);

    final Finder ring = find.byType(CircularProgressIndicator);
    expect(ring, findsOneWidget);
    expect(tester.widget<CircularProgressIndicator>(ring).value, 56 / 179);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('should_fit_long_labels_when_narrow_screen_uses_large_text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _creditTestApp(
        brightness: Brightness.dark,
        child: Center(
          child: SizedBox(
            width: 320,
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SingleChildScrollView(
                child: StudyCreditCard(data: credits),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('创新创业与课外素质'), findsOneWidget);
    expect(find.text('46.5 / 69.5'), findsOneWidget);
    final Finder lastCredit = find.text('校本选修模块');
    await tester.ensureVisible(lastCredit);
    await tester.pumpAndSettle();
    expect(lastCredit.hitTestable(), findsOneWidget);
  });
}
