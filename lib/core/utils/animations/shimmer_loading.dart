import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'app_animations.dart';

/// Shimmer闪光加载效果
///
/// 仿照苹果风格的骨架屏加载动画
///
/// 示例：
/// ```dart
/// ShimmerLoading(
///   isLoading: true,
///   child: YourActualContent(),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  /// 是否处于加载状态
  final bool isLoading;

  /// 加载时显示的骨架屏，不提供则使用默认骨架
  final Widget? skeleton;

  /// 实际内容
  final Widget child;

  /// 动画时长
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.skeleton,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  void _syncAnimation() {
    if (widget.isLoading &&
        !AppAnimations.reduceMotionOf(context) &&
        TickerMode.valuesOf(context).enabled) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.stop();
      _controller.duration = widget.duration;
    }
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = AppAnimations.reduceMotionOf(context);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : AppAnimations.standard,
      switchInCurve: AppAnimations.easeOut,
      switchOutCurve: AppAnimations.easeIn,
      child: KeyedSubtree(
        key: ValueKey<bool>(widget.isLoading),
        child: !widget.isLoading
            ? widget.child
            : reduced
            ? widget.skeleton ?? _buildDefaultSkeleton(context)
            : AnimatedBuilder(
                animation: _controller,
                child: widget.skeleton ?? _buildDefaultSkeleton(context),
                builder: (context, child) {
                  final colors = context.mc.colors;
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-2 + _controller.value * 4, 0),
                      end: Alignment(-1 + _controller.value * 4, 0),
                      colors: [
                        colors.skeletonBase,
                        colors.skeletonHighlight,
                        colors.skeletonBase,
                      ],
                      stops: const [0, 0.5, 1],
                    ).createShader(bounds),
                    child: child,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDefaultSkeleton(BuildContext context) {
    return Container(color: context.mc.colors.cardBackground);
  }
}

/// 骨架屏组件 - 用于创建各种形状的占位符
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// 骨架屏圆形组件
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({super.key, required this.size, this.margin});

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 骨架屏文本行
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonLine({super.key, this.width, this.height = 12, this.margin});

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// 预设的列表项骨架屏
class ListItemSkeleton extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int lines;

  const ListItemSkeleton({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading)
            const SkeletonCircle(size: 48, margin: EdgeInsets.only(right: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(
                  width: double.infinity,
                  height: 14,
                  margin: EdgeInsets.only(bottom: 8),
                ),
                if (lines > 1)
                  SkeletonLine(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 12,
                  ),
              ],
            ),
          ),
          if (hasTrailing)
            const SkeletonBox(
              width: 60,
              height: 30,
              margin: EdgeInsets.only(left: 12),
            ),
        ],
      ),
    );
  }
}

/// 预设的卡片骨架屏
class CardSkeleton extends StatelessWidget {
  final double? height;

  const CardSkeleton({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Container(
      height: height ?? 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(
                size: 40,
                margin: EdgeInsets.only(right: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    SkeletonLine(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const SkeletonLine(
            width: double.infinity,
            height: 14,
            margin: EdgeInsets.only(bottom: 8),
          ),
          SkeletonLine(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 14,
          ),
        ],
      ),
    );
  }
}
