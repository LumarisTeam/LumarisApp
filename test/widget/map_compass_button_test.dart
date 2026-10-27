import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/pages/campus_map_page/map_compass_button.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Transform _needleTransform(WidgetTester tester) {
  return tester.widget<Transform>(
    find
        .ancestor(
          of: find.byIcon(Icons.navigation_rounded),
          matching: find.byType(Transform),
        )
        .first,
  );
}

void main() {
  group('MapCompassButton', () {
    testWidgets('should_render_compass_needle_and_tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MapCompassButton(rotation: 0, tooltip: '正北朝上', onResetNorth: () {}),
        ),
      );

      expect(find.byIcon(Icons.navigation_rounded), findsOneWidget);
      expect(find.byTooltip('正北朝上'), findsOneWidget);
    });

    testWidgets('should_point_needle_up_when_map_faces_north', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MapCompassButton(rotation: 0, tooltip: '正北朝上', onResetNorth: () {}),
        ),
      );

      final transform = _needleTransform(tester).transform;
      expect(transform.entry(0, 0), closeTo(1.0, 1e-9));
      expect(transform.entry(1, 0), closeTo(0.0, 1e-9));
    });

    testWidgets('should_rotate_needle_with_map_rotation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MapCompassButton(rotation: 90, tooltip: '正北朝上', onResetNorth: () {}),
        ),
      );

      // The needle has to follow the map's north direction, i.e. the same
      // clockwise rotation the map content receives.
      final transform = _needleTransform(tester).transform;
      expect(transform.entry(0, 0), closeTo(math.cos(math.pi / 2), 1e-9));
      expect(transform.entry(1, 0), closeTo(math.sin(math.pi / 2), 1e-9));
    });

    testWidgets('should_normalize_rotation_before_drawing_needle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MapCompassButton(
            rotation: -270,
            tooltip: '正北朝上',
            onResetNorth: () {},
          ),
        ),
      );

      // -270° is equivalent to +90°: the needle must not spin the long way.
      final transform = _needleTransform(tester).transform;
      expect(transform.entry(0, 0), closeTo(math.cos(math.pi / 2), 1e-9));
      expect(transform.entry(1, 0), closeTo(math.sin(math.pi / 2), 1e-9));
    });

    testWidgets('should_invoke_callback_when_pressed', (
      WidgetTester tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          MapCompassButton(
            rotation: 45,
            tooltip: '正北朝上',
            onResetNorth: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('map-compass-button')));
      await tester.pump();

      expect(taps, 1);
    });
  });
}
