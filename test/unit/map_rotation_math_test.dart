import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/pages/campus_map_page/map_compass_button.dart';

void main() {
  group('normalizeMapRotation', () {
    test('should_keep_rotation_when_within_half_turn', () {
      expect(normalizeMapRotation(0), 0);
      expect(normalizeMapRotation(35.5), closeTo(35.5, 1e-9));
      expect(normalizeMapRotation(-42), closeTo(-42, 1e-9));
    });

    test('should_wrap_rotation_when_beyond_half_turn', () {
      expect(normalizeMapRotation(370), closeTo(10, 1e-9));
      expect(normalizeMapRotation(-370), closeTo(-10, 1e-9));
      expect(normalizeMapRotation(270), closeTo(-90, 1e-9));
      expect(normalizeMapRotation(720), closeTo(0, 1e-9));
    });

    test('should_map_half_turn_to_positive_range', () {
      expect(normalizeMapRotation(180), closeTo(180, 1e-9));
      expect(normalizeMapRotation(-180), closeTo(180, 1e-9));
    });

    test('should_return_zero_when_rotation_is_not_finite', () {
      expect(normalizeMapRotation(double.nan), 0);
      expect(normalizeMapRotation(double.infinity), 0);
      expect(normalizeMapRotation(double.negativeInfinity), 0);
    });
  });

  group('shortestRotationToNorth', () {
    test('should_negate_current_rotation_when_map_is_tilted', () {
      expect(shortestRotationToNorth(30), closeTo(-30, 1e-9));
      expect(shortestRotationToNorth(-30), closeTo(30, 1e-9));
    });

    test('should_take_short_path_when_map_is_near_half_turn', () {
      expect(shortestRotationToNorth(170), closeTo(-170, 1e-9));
      expect(shortestRotationToNorth(-170), closeTo(170, 1e-9));
      expect(shortestRotationToNorth(270), closeTo(90, 1e-9));
    });

    test('should_return_zero_when_map_already_faces_north', () {
      expect(shortestRotationToNorth(0), 0);
      expect(shortestRotationToNorth(360), 0);
    });

    test('should_land_on_north_when_delta_is_applied', () {
      for (final rotation in <double>[12.5, -78.0, 179.0, -179.0, 359.0]) {
        final target = rotation + shortestRotationToNorth(rotation);
        expect(normalizeMapRotation(target), closeTo(0, 1e-9));
      }
    });

    test('should_stay_within_half_turn', () {
      for (var rotation = -720.0; rotation <= 720.0; rotation += 7.5) {
        final delta = shortestRotationToNorth(rotation);
        expect(delta, inInclusiveRange(-180, 180));
      }
    });
  });
}
