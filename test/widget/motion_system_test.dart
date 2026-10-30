import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';

import 'theme_test_helpers.dart';

Widget wrap(Widget child, {bool reduced = false}) => themedTestApp(
  child: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Center(child: child),
  ),
);

Finder inside(Type type, Type descendant) => find.descendant(
  of: find.byType(type).first,
  matching: find.byType(descendant),
);

double entranceOpacity(WidgetTester tester) =>
    tester.widget<Opacity>(inside(AnimatedCard, Opacity).first).opacity;

void main() {
  testWidgets('should_wait_then_animate_when_entrance_has_delay', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AnimatedCard(
          delay: Duration(milliseconds: 100),
          duration: Duration(milliseconds: 200),
          child: Text('card'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(entranceOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 100));
    expect(entranceOpacity(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(entranceOpacity(tester), 1);
  });

  testWidgets('should_show_immediately_when_reduced_motion_changes', (
    tester,
  ) async {
    const Widget card = AnimatedCard(
      delay: Duration(seconds: 1),
      child: Text('card'),
    );
    await tester.pumpWidget(wrap(card));
    expect(entranceOpacity(tester), 0);
    await tester.pumpWidget(wrap(card, reduced: true));
    expect(entranceOpacity(tester), 1);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(wrap(card));
    expect(entranceOpacity(tester), 1);
  });

  testWidgets('should_skip_nested_entrance_when_parent_orchestrates', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AnimatedCard(
          child: AnimatedListItem(index: 5, child: Text('nested')),
        ),
      ),
    );
    final List<Opacity> opacities = tester
        .widgetList<Opacity>(inside(AnimatedCard, Opacity))
        .toList();
    expect(opacities.map((opacity) => opacity.opacity), [0, 1]);
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('should_restore_scale_when_press_is_cancelled', (tester) async {
    await tester.pumpWidget(
      wrap(
        AnimatedButton(
          onTap: () {},
          child: const SizedBox(width: 80, height: 44),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AnimatedButton)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.98,
    );
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('should_keep_feedback_without_scale_when_motion_reduced', (
    tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      wrap(
        AnimatedButton(
          onTap: () => taps++,
          child: const SizedBox(width: 80, height: 44),
        ),
        reduced: true,
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AnimatedButton)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      0.88,
    );
    await gesture.up();
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('should_activate_once_when_keyboard_used_and_ignore_disabled', (
    tester,
  ) async {
    int taps = 0;
    Widget button(bool enabled) => AnimatedButton(
      enabled: enabled,
      onTap: () => taps++,
      child: const Text('button'),
    );
    await tester.pumpWidget(wrap(button(true)));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 2);
    await tester.pumpWidget(wrap(button(false)));
    await tester.tap(find.text('button'));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 2);
  });

  testWidgets('should_stop_shimmer_when_loaded_or_reduced_or_hidden', (
    tester,
  ) async {
    Widget loading({
      bool active = true,
      bool reduced = false,
      bool visible = true,
    }) => wrap(
      TickerMode(
        enabled: visible,
        child: ShimmerLoading(
          isLoading: active,
          skeleton: const SizedBox(width: 100, height: 44),
          child: const Text('loaded'),
        ),
      ),
      reduced: reduced,
    );
    await tester.pumpWidget(loading());
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(loading(reduced: true));
    await tester.pumpAndSettle();
    expect(find.byType(ShaderMask), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(loading());
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(loading(visible: false));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(loading(active: false));
    await tester.pumpAndSettle();
    expect(find.text('loaded'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('should_cancel_pending_delay_when_disposed', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AnimatedCard(delay: Duration(seconds: 1), child: Text('card')),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
