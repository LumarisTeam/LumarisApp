import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';

/// 带有瀑布流进入动画的列表项
///
/// 使用苹果风格的动画：从下往上滑入 + 淡入效果
///
/// 示例：
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return AnimatedListItem(
///       index: index,
///       child: YourListTile(),
///     );
///   },
/// )
/// ```
class AnimatedListItem extends StatelessWidget {
  /// 列表项索引，用于计算延迟时间
  final int index;

  /// 子组件
  final Widget child;

  /// 自定义动画时长（可选）
  final Duration? duration;

  /// 自定义延迟（可选，如果不提供则自动根据index计算）
  final Duration? delay;

  /// 自定义动画曲线（可选）
  final Curve? curve;

  /// 滑入偏移量（可选）
  final double? slideOffset;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
    this.slideOffset,
  });

  @override
  Widget build(BuildContext context) {
    final animDuration = duration ?? AppAnimations.listItemDuration;
    final animDelay = delay ?? AppAnimations.getListItemDelay(index);
    final animCurve = curve ?? AppAnimations.easeOut;
    final offset = slideOffset ?? AppAnimations.slideOffset;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: animDuration + animDelay,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: animCurve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: child,
      ),
    );
  }
}

/// 带有从左滑入动画的列表项
class AnimatedListItemSlideLeft extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const AnimatedListItemSlideLeft({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    final animDuration = duration ?? AppAnimations.listItemDuration;
    final animDelay = delay ?? AppAnimations.getListItemDelay(index);
    final animCurve = curve ?? AppAnimations.easeOut;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: animDuration + animDelay,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: animCurve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-30 * (1 - value), 0),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: child,
      ),
    );
  }
}

/// 带有缩放进入动画的列表项
class AnimatedListItemScale extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const AnimatedListItemScale({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    final animDuration = duration ?? AppAnimations.listItemDuration;
    final animDelay = delay ?? AppAnimations.getListItemDelay(index);
    final animCurve = curve ?? AppAnimations.easeOut;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: animDuration + animDelay,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: animCurve,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: child,
      ),
    );
  }
}
