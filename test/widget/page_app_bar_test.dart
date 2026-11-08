import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ios_club_app/ui/components/page_app_bar.dart';

void main() {
  testWidgets('should_show_cupertino_back_button_when_route_can_pop', (
    WidgetTester tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(appBar: PageAppBar(title: 'Home')),
      ),
    );

    final backButton = find.byIcon(CupertinoIcons.chevron_back);
    expect(backButton, findsNothing);

    navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(appBar: PageAppBar(title: 'Details')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(backButton, findsNothing);
  });
}
