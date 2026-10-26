import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';

/// 带有按压反馈动画的按钮包装器
///
/// 苹果风格：按下时轻微缩小，松开恢复
///
/// 示例：
/// ```dart
/// AnimatedButton(
///   onTap: () => AppLogger.debug('Tapped'),
///   child: YourButtonWidget(),
/// )
/// ```
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scaleOnPress;
  final Duration duration;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scaleOnPress = AppAnimations.pressScale,
    this.duration = AppAnimations.fast,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleOnPress)
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
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.enabled ? 1.0 : AppAnimations.disabledOpacity,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 带有弹性效果的按钮
///
/// 点击后有轻微的弹跳效果
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const BounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.standard,
      vsync: this,
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.95),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.95, end: 1.05),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.05, end: 1.0),
            weight: 25,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.spring),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enabled) {
      _controller.forward(from: 0);
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.enabled ? 1.0 : AppAnimations.disabledOpacity,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 带有淡入淡出效果的按钮
///
/// 点击时轻微变透明
class FadeButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double opacityOnPress;

  const FadeButton({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.opacityOnPress = 0.6,
  });

  @override
  State<FadeButton> createState() => _FadeButtonState();
}

class _FadeButtonState extends State<FadeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: widget.opacityOnPress)
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
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: widget.enabled
                ? _opacityAnimation.value
                : AppAnimations.disabledOpacity,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// iOS风格的可缩放容器
///
/// 类似于iOS按钮的交互反馈
class ScaleTapContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final bool enabled;

  const ScaleTapContainer({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.decoration,
    this.enabled = true,
  });

  @override
  State<ScaleTapContainer> createState() => _ScaleTapContainerState();
}

class _ScaleTapContainerState extends State<ScaleTapContainer>
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.pressScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _controller.forward() : null,
      onTapUp: widget.enabled ? (_) => _controller.reverse() : null,
      onTapCancel: widget.enabled ? () => _controller.reverse() : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: widget.decoration,
              child: Opacity(
                opacity: widget.enabled ? 1.0 : AppAnimations.disabledOpacity,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
