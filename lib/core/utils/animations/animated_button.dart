import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';

import 'app_animations.dart';

/// 统一按压反馈：轻压、平稳恢复，支持键盘及减少动态效果。
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scaleOnPress;
  final double opacityOnPress;
  final Duration duration;
  final bool enableFeedback;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scaleOnPress = AppAnimations.pressScale,
    this.opacityOnPress = 0.88,
    this.duration = AppAnimations.fast,
    this.enableFeedback = true,
  }) : assert(scaleOnPress > 0 && scaleOnPress <= 1),
       assert(opacityOnPress >= 0 && opacityOnPress <= 1);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _pressed = false;
  bool _focused = false;
  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_interactive || !widget.enableFeedback) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = AppAnimations.reduceMotionOf(context);
    final bool pressed = _pressed && _interactive && widget.enableFeedback;
    final Duration duration = reduced ? Duration.zero : widget.duration;
    return FocusableActionDetector(
      enabled: _interactive,
      mouseCursor: _interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (_interactive) widget.onTap?.call();
            return null;
          },
        ),
      },
      child: Semantics(
        button: _interactive,
        enabled: widget.enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _interactive && widget.enableFeedback
              ? (_) => _setPressed(true)
              : null,
          onTapUp: _interactive && widget.enableFeedback
              ? (_) => _setPressed(false)
              : null,
          onTapCancel: _interactive && widget.enableFeedback
              ? () => _setPressed(false)
              : null,
          onTap: _interactive ? widget.onTap : null,
          onLongPress: _interactive && widget.onLongPress != null
              ? () {
                  _setPressed(false);
                  widget.onLongPress?.call();
                }
              : null,
          child: AnimatedScale(
            scale: pressed && !reduced ? widget.scaleOnPress : 1,
            duration: duration,
            curve: AppAnimations.easeOut,
            child: AnimatedOpacity(
              opacity: !widget.enabled
                  ? AppAnimations.disabledOpacity
                  : pressed
                  ? widget.opacityOnPress
                  : 1,
              duration: duration,
              curve: AppAnimations.easeOut,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: _focused
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 兼容旧名称，统一使用无回弹的按压反馈。
class BounceButton extends StatelessWidget {
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
  Widget build(BuildContext context) =>
      AnimatedButton(onTap: onTap, enabled: enabled, child: child);
}

/// 文本操作只改变透明度。
class FadeButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double opacityOnPress;
  const FadeButton({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.opacityOnPress = 0.72,
  });
  @override
  Widget build(BuildContext context) => AnimatedButton(
    onTap: onTap,
    enabled: enabled,
    scaleOnPress: 1,
    opacityOnPress: opacityOnPress,
    child: child,
  );
}

class ScaleTapContainer extends StatelessWidget {
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
  Widget build(BuildContext context) => AnimatedButton(
    onTap: onTap,
    enabled: enabled,
    child: Container(padding: padding, decoration: decoration, child: child),
  );
}
