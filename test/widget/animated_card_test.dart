import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AnimatedCard', () {
    testWidgets('should_render_child_and_finish_animation', (tester) async {
      await tester.pumpWidget(
        _wrap(const AnimatedCard(child: Text('card-child'))),
      );

      expect(find.text('card-child'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('card-child'), findsOneWidget);
    });

    testWidgets('should_accept_custom_duration_and_delay', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AnimatedCard(
            duration: Duration(milliseconds: 100),
            delay: Duration(milliseconds: 200),
            child: Text('custom'),
          ),
        ),
      );

      expect(find.text('custom'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('custom'), findsOneWidget);
    });
  });

  group('InteractiveCard', () {
    testWidgets('should_call_tap_and_long_press_callbacks', (tester) async {
      var tapped = false;
      var longPressed = false;

      await tester.pumpWidget(
        _wrap(
          InteractiveCard(
            onTap: () => tapped = true,
            onLongPress: () => longPressed = true,
            child: const Text('interactive'),
          ),
        ),
      );

      await tester.tap(find.text('interactive'));
      await tester.pump();
      expect(tapped, isTrue);

      await tester.longPress(find.text('interactive'));
      await tester.pump();
      expect(longPressed, isTrue);
    });

    testWidgets('should_toggle_feedback_handlers_by_flag', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const InteractiveCard(
            enableFeedback: false,
            child: Text('no-feedback'),
          ),
        ),
      );

      final detector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(detector.onTapDown, isNull);
      expect(detector.onTapUp, isNull);
      expect(detector.onTapCancel, isNull);
    });

    testWidgets('should_handle_tap_down_and_cancel_without_errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const InteractiveCard(child: Text('gesture'))),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('gesture')),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.cancel();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('gesture'), findsOneWidget);
    });
  });

  group('HoverCard', () {
    testWidgets('should_enable_hover_handlers_by_default', (tester) async {
      await tester.pumpWidget(_wrap(const HoverCard(child: Text('hover'))));

      final mouseRegionFinder = find.descendant(
        of: find.byType(HoverCard),
        matching: find.byType(MouseRegion),
      );
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.onEnter, isNotNull);
      expect(mouseRegion.onExit, isNotNull);
    });

    testWidgets('should_disable_hover_handlers_when_flag_false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const HoverCard(enableHover: false, child: Text('hover-off'))),
      );

      final mouseRegionFinder = find.descendant(
        of: find.byType(HoverCard),
        matching: find.byType(MouseRegion),
      );
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.onEnter, isNull);
      expect(mouseRegion.onExit, isNull);
    });
  });

  testWidgets('AnimatedInteractiveCard should compose both wrappers', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        AnimatedInteractiveCard(
          onTap: () => tapped = true,
          child: const Text('combo'),
        ),
      ),
    );

    expect(find.byType(AnimatedCard), findsOneWidget);
    expect(find.byType(InteractiveCard), findsOneWidget);

    await tester.tap(find.text('combo'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
