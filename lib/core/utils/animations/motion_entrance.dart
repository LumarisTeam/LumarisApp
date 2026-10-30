import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app_animations.dart';

/// 一次性轻入场。延迟独立计时，嵌套内容由最外层统一编排。
class MotionEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset;
  final double initialScale;

  const MotionEntrance({
    super.key,
    required this.child,
    this.duration = AppAnimations.standard,
    this.delay = Duration.zero,
    this.curve = AppAnimations.easeOut,
    this.offset = const Offset(0, AppAnimations.slideOffset),
    this.initialScale = 1,
  });

  @override
  State<MotionEntrance> createState() => _MotionEntranceState();
}

class _MotionEntranceState extends State<MotionEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    assert(!widget.duration.isNegative && !widget.delay.isNegative);
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppAnimations.reduceMotionOf(context) ||
        context.dependOnInheritedWidgetOfExactType<_EntranceScope>() != null) {
      _delayTimer?.cancel();
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        _delayTimer = Timer(widget.delay, () => _controller.forward());
      }
    }
  }

  @override
  void didUpdateWidget(MotionEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EntranceScope(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final double value = widget.curve.transform(_controller.value);
          return IgnorePointer(
            ignoring: _controller.value == 0,
            child: Transform.translate(
              offset: widget.offset * (1 - value),
              child: Transform.scale(
                scale: widget.initialScale + (1 - widget.initialScale) * value,
                child: Opacity(opacity: value.clamp(0, 1), child: child),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EntranceScope extends InheritedWidget {
  const _EntranceScope({required super.child});

  @override
  bool updateShouldNotify(_EntranceScope oldWidget) => false;
}
