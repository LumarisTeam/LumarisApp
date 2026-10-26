import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';

/// 带有进入动画的卡片
///
/// 苹果风格：从下往上滑入 + 轻微缩放 + 淡入
///
/// 示例：
/// ```dart
/// AnimatedCard(
///   child: YourCardContent(),
/// )
/// ```
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final Curve? curve;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay,
    this.duration,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    final animDuration = duration ?? AppAnimations.medium;
    final animDelay = delay ?? Duration.zero;
    final animCurve = curve ?? AppAnimations.easeOut;

    return TweenAnimationBuilder<double>(
      duration: animDuration + animDelay,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: animCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, AppAnimations.cardSlideOffset * (1 - value)),
          child: Transform.scale(
            scale: AppAnimations.cardInitialScale + (0.1 * value),
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

/// 带有按压反馈的可交互卡片
///
/// 点击时会有轻微的缩放效果，松开恢复
///
/// 示例：
/// ```dart
/// InteractiveCard(
///   onTap: () => AppLogger.debug('Tapped'),
///   child: YourCardContent(),
/// )
/// ```
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableFeedback;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableFeedback = true,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: AppAnimations.pressScale)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppAnimations.defaultCurve,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enableFeedback ? _handleTapDown : null,
      onTapUp: widget.enableFeedback ? _handleTapUp : null,
      onTapCancel: widget.enableFeedback ? _handleTapCancel : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 带有悬停效果的卡片（桌面端）
///
/// 鼠标悬停时轻微上浮和阴影增强
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHover;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.enableHover = true,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: AppAnimations.hoverScale)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppAnimations.defaultCurve,
          ),
        );
    _elevationAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enableHover ? (_) => _controller.forward() : null,
      onExit: widget.enableHover ? (_) => _controller.reverse() : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _elevationAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 组合动画卡片：进入动画 + 交互反馈
///
/// 最佳选择 - 结合了进入动画和点击反馈
///
/// 示例：
/// ```dart
/// AnimatedInteractiveCard(
///   delay: Duration(milliseconds: 100),
///   onTap: () => AppLogger.debug('Tapped'),
///   child: YourCardContent(),
/// )
/// ```
class AnimatedInteractiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration? delay;
  final Duration? duration;
  final bool enableFeedback;

  const AnimatedInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.delay,
    this.duration,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      delay: delay,
      duration: duration,
      child: InteractiveCard(
        onTap: onTap,
        onLongPress: onLongPress,
        enableFeedback: enableFeedback,
        child: child,
      ),
    );
  }
}
