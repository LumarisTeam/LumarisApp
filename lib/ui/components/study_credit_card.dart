import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';

class StudyCreditCard extends StatelessWidget {
  final InfoModel data;

  const StudyCreditCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        shape: McSmoothCorners.shape(McRadii.cardBorder),
      ),
      child: McCard.elevated(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题部分
              _buildHeader(context),
              const SizedBox(height: 12),

              // 总学分部分
              _buildMainCreditCard(context),

              const SizedBox(height: 16),

              // 分项标题
              _buildSubtitle(context),
              const SizedBox(height: 8),

              // 分项学分列表
              ...data.other.asMap().entries.map((entry) {
                return _buildCreditItem(
                  context: context,
                  title: entry.value.name,
                  actual: entry.value.actual,
                  full: entry.value.full,
                  delay: entry.key * 100,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: McSmoothCorners.shape(McRadii.navigationBorder),
          ),
          child: Icon(
            CupertinoIcons.book_fill,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.type,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.creditOverview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCreditCard(BuildContext context) {
    final theme = Theme.of(context);
    final progress = data.total.full > 0
        ? data.total.actual / data.total.full
        : 0.0;

    return Container(
      padding: const EdgeInsets.only(left: 0, right: 20, top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: ShapeDecoration(
                      color: theme.colorScheme.error,
                      shape: McSmoothCorners.shape(McRadii.indicatorBorder),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    data.total.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                "${data.total.actual.toStringAsFixed(1)} / ${data.total.full.toStringAsFixed(1)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress, theme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 进度条
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildProgressBar(context, progress),
          ),

          const SizedBox(height: 8),

          // 进度文字
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '${context.l10n.completionRate}: ${(progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: ShapeDecoration(
            color: theme.colorScheme.primary,
            shape: McSmoothCorners.shape(McRadii.indicatorBorder),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.itemizedCredits,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditItem({
    required BuildContext context,
    required String title,
    required double actual,
    required double full,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final progress = full > 0 ? actual / full : 0.0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "${actual.toStringAsFixed(1)} / ${full.toStringAsFixed(1)}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(progress, theme),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(context, progress * value),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: 6,
      decoration: ShapeDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        shape: McSmoothCorners.shape(McRadii.xsBorder),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            decoration: ShapeDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              shape: McSmoothCorners.shape(McRadii.xsBorder),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: clampedProgress,
              child: Container(
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getProgressColor(clampedProgress, theme),
                      _getProgressColor(
                        clampedProgress,
                        theme,
                      ).withValues(alpha: 0.8),
                    ],
                  ),
                  shape: McSmoothCorners.shape(McRadii.xsBorder),
                  shadows: clampedProgress > 0
                      ? [
                          BoxShadow(
                            color: _getProgressColor(
                              clampedProgress,
                              theme,
                            ).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    final colors =
        theme.extension<McColors>() ??
        (theme.brightness == Brightness.dark ? McColors.dark : McColors.light);
    if (progress >= 1.0) {
      return colors.success;
    } else if (progress >= 0.8) {
      return colors.primary;
    } else if (progress >= 0.5) {
      return colors.warning;
    } else {
      return colors.danger;
    }
  }
}
