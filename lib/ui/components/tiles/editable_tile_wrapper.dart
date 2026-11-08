import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';

/// Wrapper for tiles that adds edit mode functionality
class EditableTileWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String tileId;
  final int index;

  const EditableTileWrapper({
    super.key,
    required this.child,
    required this.tileId,
    required this.index,
  });

  @override
  ConsumerState<EditableTileWrapper> createState() =>
      _EditableTileWrapperState();
}

class _EditableTileWrapperState extends ConsumerState<EditableTileWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;
  Timer? _jiggleDelayTimer;

  @override
  void initState() {
    super.initState();

    _jiggleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    // Slight rotation back and forth
    _jiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.015), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.015, end: -0.015), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.015, end: 0.0), weight: 25),
    ]).animate(_jiggleController);
  }

  @override
  void dispose() {
    _jiggleDelayTimer?.cancel();
    _jiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileEditState = ref.watch(tileEditControllerProvider);
    final controller = ref.read(tileEditControllerProvider.notifier);
    final isEditMode = tileEditState.isEditMode;
    final reduceMotion = McMotion.reduceMotionOf(context);
    final shouldJiggle = isEditMode && !reduceMotion;

    if (shouldJiggle) {
      if (!_jiggleController.isAnimating &&
          !(_jiggleDelayTimer?.isActive ?? false)) {
        // Create a slightly random offset so they don't all jiggle exactly identical
        final delay = Duration(milliseconds: widget.index * 50);
        void startJiggle() {
          if (mounted && ref.read(tileEditControllerProvider).isEditMode) {
            _jiggleController.repeat();
          }
        }

        if (delay == Duration.zero) {
          startJiggle();
        } else {
          _jiggleDelayTimer = Timer(delay, startJiggle);
        }
      }
    } else {
      _jiggleDelayTimer?.cancel();
      _jiggleDelayTimer = null;
      _jiggleController.stop();
      _jiggleController.reset();
    }

    final colors = context.mc.colors;
    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        McSmoothCorners.clip(
          borderRadius: McRadii.tileBorder,
          child: widget.child,
        ),
        if (isEditMode) ...[
          Positioned.fill(
            child: ReorderableDragStartListener(
              index: widget.index,
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(8),
                child: reduceMotion
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.secondaryLabel.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.line_horizontal_3,
                          color: colors.onAccent,
                          size: 16,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Positioned(top: 8, left: 8, child: _buildHideButton(controller)),
        ],
      ],
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _jiggleAnimation,
        child: content,
        builder: (context, child) => Transform.rotate(
          angle: shouldJiggle ? _jiggleAnimation.value : 0,
          child: child,
        ),
      ),
    );
  }

  Widget _buildHideButton(TileEditNotifier controller) {
    final colors = context.mc.colors;

    return GestureDetector(
      onTap: () async {
        try {
          await controller.toggleVisibility(widget.tileId);
        } catch (e) {
          // Ignore error, or log it if needed
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.secondaryLabel.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.minus, // Simple minus
          color: colors.onAccent,
          size: 16,
        ),
      ),
    );
  }
}
