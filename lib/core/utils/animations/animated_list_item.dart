import 'package:material_ui/material_ui.dart';
import 'app_animations.dart';
import 'motion_entrance.dart';

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
    return RepaintBoundary(
      child: MotionEntrance(
        duration: duration ?? AppAnimations.listItemDuration,
        delay: delay ?? AppAnimations.getListItemDelay(index),
        curve: curve ?? AppAnimations.easeOut,
        offset: Offset(0, slideOffset ?? AppAnimations.slideOffset),
        initialScale: 1,
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
    return RepaintBoundary(
      child: MotionEntrance(
        duration: duration ?? AppAnimations.listItemDuration,
        delay: delay ?? AppAnimations.getListItemDelay(index),
        curve: curve ?? AppAnimations.easeOut,
        offset: Offset(
          (Directionality.of(context) == TextDirection.rtl ? 1 : -1) *
              AppAnimations.slideOffset,
          0,
        ),
        initialScale: 1,
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
    return RepaintBoundary(
      child: MotionEntrance(
        duration: duration ?? AppAnimations.listItemDuration,
        delay: delay ?? AppAnimations.getListItemDelay(index),
        curve: curve ?? AppAnimations.easeOut,
        offset: Offset.zero,
        initialScale: 0.98,
        child: child,
      ),
    );
  }
}
