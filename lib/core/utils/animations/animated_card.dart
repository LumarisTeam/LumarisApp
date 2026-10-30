import 'package:material_ui/material_ui.dart';
import 'app_animations.dart';
import 'animated_button.dart';
import 'motion_entrance.dart';

/// 带有进入动画的卡片
///
/// 苹果风格：12 px 轻移 + 淡入
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
    return MotionEntrance(
      duration: duration ?? AppAnimations.standard,
      delay: delay ?? Duration.zero,
      curve: curve ?? AppAnimations.easeOut,
      offset: const Offset(0, AppAnimations.cardSlideOffset),
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
class InteractiveCard extends StatelessWidget {
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
  Widget build(BuildContext context) => AnimatedButton(
    onTap: onTap,
    onLongPress: onLongPress,
    enableFeedback: enableFeedback,
    child: child,
  );
}

/// 带有悬停效果的卡片（桌面端）
///
/// 鼠标悬停时轻微上浮，不放大内容
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

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final bool reduced = AppAnimations.reduceMotionOf(context);
    return MouseRegion(
      onEnter: widget.enableHover
          ? (_) => setState(() => _hovered = true)
          : null,
      onExit: widget.enableHover
          ? (_) => setState(() => _hovered = false)
          : null,
      child: AnimatedSlide(
        offset: _hovered && widget.enableHover && !reduced
            ? const Offset(0, -0.005)
            : Offset.zero,
        duration: reduced ? Duration.zero : AppAnimations.fast,
        curve: AppAnimations.easeOut,
        child: AnimatedButton(onTap: widget.onTap, child: widget.child),
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
