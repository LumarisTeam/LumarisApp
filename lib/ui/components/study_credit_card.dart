import 'dart:math' as math;

import 'package:flutter/widget_previews.dart';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/extensions/localization_extensions.dart';
import '../../features/education/models/info_model.dart';

const EdgeInsets _cardPadding = EdgeInsets.fromLTRB(16, 16, 16, 12);
const double _progressSize = 53;
const double _detailRowHeight = 36;

class StudyCreditCard extends StatelessWidget {
  final InfoModel data;

  const StudyCreditCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final McTheme tokens = context.mc;
    final TotalData total = data.total;
    final String module = data.type.trim();
    final String title = module.isEmpty
        ? context.l10n.totalCredits
        : context.l10n.studyCreditTitle(module);
    final double progress = total.full > 0
        ? (total.actual / total.full).clamp(0.0, 1.0)
        : 0;

    return McCard.elevated(
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.book,
                          size: 20,
                          color: tokens.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: textTheme.titleMedium?.copyWith(
                                color: tokens.foreground,
                                fontSize: 16,
                                height: 21 / 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _CreditAmount(credit: total, isTotal: true),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ExcludeSemantics(
                child: SizedBox.square(
                  dimension: _progressSize,
                  child: CircularProgressIndicator(
                    value: progress,
                    color: tokens.primary,
                    backgroundColor: tokens.surfaceSunken,
                    strokeWidth: 5,
                    strokeAlign: CircularProgressIndicator.strokeAlignInside,
                    strokeCap: StrokeCap.round,
                    trackGap: 0,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          if (data.other.isNotEmpty) const SizedBox(height: 12),
          for (final TotalData credit in data.other) _CreditRow(credit: credit),
        ],
      ),
    );
  }
}

class StudyCreditCardSkeleton extends StatelessWidget {
  const StudyCreditCardSkeleton({required this.loadingLabel, super.key});

  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    final McTheme tokens = context.mc;
    final Color fill = MediaQuery.highContrastOf(context)
        ? tokens.foreground.withValues(alpha: 0.25)
        : tokens.skeletonBase;
    final TextScaler scale = MediaQuery.textScalerOf(context);
    final double titleHeight = scale.scale(16) * 21 / 16;
    final double amountHeight = scale.scale(34) * 41 / 34;
    final double detailHeight = math.max(
      _detailRowHeight,
      scale.scale(15) * 20 / 15 + 16,
    );

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(5),
      ),
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: loadingLabel,
      excludeSemantics: true,
      child: McCard.elevated(
        padding: _cardPadding,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: titleHeight,
                        child: Row(
                          children: [
                            bar(20, 20),
                            const SizedBox(width: 8),
                            Flexible(child: bar(84, titleHeight * 0.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: amountHeight,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: bar(96, amountHeight * 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: _progressSize,
                  height: _progressSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: fill, width: 5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final double width in const [72.0, 64.0, 112.0, 64.0])
              SizedBox(
                height: detailHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: bar(width, scale.scale(15) * 0.72)),
                    const SizedBox(width: 12),
                    Flexible(child: bar(46, scale.scale(15) * 0.72)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

@Preview(
  name: 'Credit card loading · Light',
  brightness: Brightness.light,
  size: Size(360, 280),
)
@Preview(
  name: 'Credit card loading · Dark',
  brightness: Brightness.dark,
  size: Size(360, 280),
)
Widget studyCreditCardSkeletonPreview() {
  return const Align(
    alignment: Alignment.topCenter,
    child: StudyCreditCardSkeleton(loadingLabel: '正在同步学业信息'),
  );
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.credit});

  final TotalData credit;

  String _displayName(String name) => switch (name) {
    '通识教育教学模块' => '通识教育',
    '专业教育教学模块' => '专业教育',
    '创新创业教育及课外素质教育模块' => '创新创业与课外素质',
    '集中实践教育教学模块' => '集中实践',
    _ => name,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _detailRowHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            overflowSpacing: 4,
            children: [
              Text(
                _displayName(credit.name),
                semanticsLabel: credit.name,
                style: textTheme.bodyLarge?.copyWith(
                  color: context.mc.foreground,
                  fontSize: 15,
                  height: 20 / 15,
                  letterSpacing: 0,
                ),
              ),
              _CreditAmount(credit: credit),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditAmount extends StatelessWidget {
  const _CreditAmount({required this.credit, this.isTotal = false});

  final TotalData credit;
  final bool isTotal;

  String _formatCredits(double credits) =>
      credits.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground = context.mc.foreground;

    return Text.rich(
      TextSpan(
        text: _formatCredits(credit.actual),
        children: [
          TextSpan(
            text: ' / ${_formatCredits(credit.full)}',
            style: TextStyle(
              color: foreground.withValues(alpha: 0.65),
              fontSize: isTotal ? 17 : 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      style: textTheme.bodyLarge?.copyWith(
        color: foreground,
        fontSize: isTotal ? 34 : 15,
        fontWeight: FontWeight.w600,
        height: isTotal ? 41 / 34 : 20 / 15,
        letterSpacing: isTotal ? -0.5 : 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
