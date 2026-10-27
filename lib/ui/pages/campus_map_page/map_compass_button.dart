import 'dart:math' as math;
import 'dart:ui';

import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Normalizes a map rotation, in degrees, into the interval `(-180, 180]`.
///
/// flutter_map reports the rotation of the camera, which can be any multiple of
/// a full turn after repeated gestures. Normalizing it keeps the compass needle
/// and the "is the map facing north" check stable.
double normalizeMapRotation(double degrees) {
  if (!degrees.isFinite) return 0;
  final normalized = (degrees + 180) % 360 - 180;
  return normalized == -180 ? 180 : normalized;
}

/// Smallest signed rotation, in degrees, that turns [from] back to north (0°).
///
/// The value always lies in `(-180, 180]`, so the map never spins the long way
/// round when the user asks for north.
double shortestRotationToNorth(double from) => -normalizeMapRotation(from);

/// A compass control that shows where north currently is and restores north-up
/// when pressed.
///
/// The needle follows the map rotation: positive [rotation] values rotate the
/// map clockwise, so the needle (which points at true north) follows the same
/// direction.
class MapCompassButton extends StatelessWidget {
  const MapCompassButton({
    super.key,
    required this.rotation,
    required this.onResetNorth,
    required this.tooltip,
    this.size = 44,
  });

  /// Current map rotation in degrees, where `0` means north is up.
  final double rotation;

  /// Called when the user asks to align the map back to north.
  final VoidCallback onResetNorth;

  /// Tooltip/semantics label, usually "reset to north".
  final String tooltip;

  /// Width and height of the control. Matches the other map controls.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    final radius = BorderRadius.circular(12);
    final normalized = normalizeMapRotation(rotation);
    final isNorthUp = normalized.abs() < 0.5;

    return McSmoothCorners.clip(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            color: colors.cardOverlay,
            shape: McSmoothCorners.shape(
              radius,
              side: BorderSide(
                color: colors.separator.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('map-compass-button'),
              onTap: onResetNorth,
              child: Tooltip(
                message: tooltip,
                child: Center(
                  child: Transform.rotate(
                    angle: normalized * math.pi / 180,
                    child: Icon(
                      Icons.navigation_rounded,
                      size: 22,
                      color: isNorthUp ? colors.secondaryLabel : colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
