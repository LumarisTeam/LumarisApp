import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

class LoadingStateView extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool compact;
  final bool showCard;
  final EdgeInsetsGeometry padding;

  const LoadingStateView({
    super.key,
    this.title,
    this.subtitle,
    this.compact = false,
    this.showCard = false,
    this.padding = const EdgeInsets.all(24),
  });

  String _resolveTitle(BuildContext context) =>
      title ?? context.l10n.loadingDefaultTitle;
  String _resolveSubtitle(BuildContext context) =>
      subtitle ?? context.l10n.loadingDefaultSubtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    Widget content = AnimatedSwitcher(
      duration: McMotion.standard,
      child: compact ? _buildCompact(context) : _buildFull(context),
    );

    if (showCard) {
      content = _GlassContainer(
        compact: compact,
        backgroundColor: colors.cardOverlay,
        borderColor: colors.separator.withValues(alpha: 0.35),
        child: content,
      );
    }

    return Padding(
      padding: padding,
      child: Center(child: content),
    );
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('loading_full'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const CupertinoActivityIndicator(radius: 16),
        const SizedBox(height: 24),
        Text(
          _resolveTitle(context),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        if (_resolveSubtitle(context).isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _resolveSubtitle(context),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6), // 提升文字对比度
              height: 1.4,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      key: const ValueKey('loading_compact'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const CupertinoActivityIndicator(radius: 10),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _resolveTitle(context),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              if (_resolveSubtitle(context).isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _resolveSubtitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool compact;
  final Color backgroundColor;
  final Color borderColor;

  const _GlassContainer({
    required this.child,
    required this.compact,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // 现代毛玻璃效果：大幅增加模糊半径（VisionOS 风格），优化边框和背景
    final radius = BorderRadius.circular(compact ? 100 : 28);
    return McSmoothCorners.clip(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // 深度模糊
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 36,
            vertical: compact ? 12 : 36,
          ),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: McSmoothCorners.shape(
              radius,
              side: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
