import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/ui/components/study_credit_card.dart';
import 'package:material_ui/material_ui.dart';

import 'theme_test_helpers.dart';

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

  testWidgets('should_show_compact_names_and_totals_when_credit_data_loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      themedTestApp(child: StudyCreditCard(data: credits)),
    );

    expect(find.text('主修'), findsOneWidget);
    expect(find.text('总学分'), findsOneWidget);
    expect(find.text('56 / 179'), findsOneWidget);
    expect(find.text('通识教育'), findsOneWidget);
    expect(find.text('46.5 / 69.5'), findsOneWidget);
    expect(find.text('创新创业与课外素质'), findsOneWidget);
    expect(find.text('校本选修模块'), findsOneWidget);

    final Iterable<LinearProgressIndicator> bars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
    expect(bars.map((LinearProgressIndicator bar) => bar.value), [
      56 / 179,
      46.5 / 69.5,
      1 / 14,
      0,
    ]);
  });

  testWidgets('should_fit_long_labels_when_narrow_screen_uses_large_text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      themedTestApp(
        themeMode: ThemeMode.dark,
        child: Center(
          child: SizedBox(
            width: 320,
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: StudyCreditCard(data: credits),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('创新创业与课外素质'), findsOneWidget);
    expect(find.text('46.5 / 69.5'), findsOneWidget);
  });
}
