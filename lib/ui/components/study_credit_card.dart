import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/education/models/info_model.dart';

class StudyCreditCard extends StatelessWidget {
  final InfoModel data;

  const StudyCreditCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final McTheme tokens = context.mc;

    return McCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.book_fill, size: 19, color: tokens.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    data.type,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _CreditRow(credit: data.total, isTotal: true),
          for (final TotalData credit in data.other) _CreditRow(credit: credit),
        ],
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.credit, this.isTotal = false});

  final TotalData credit;
  final bool isTotal;

  String _displayName(String name) => switch (name) {
    '通识教育教学模块' => '通识教育',
    '专业教育教学模块' => '专业教育',
    '创新创业教育及课外素质教育模块' => '创新创业与课外素质',
    '集中实践教育教学模块' => '集中实践',
    _ => name,
  };

  String _formatCredits(double credits) =>
      credits.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final McTheme tokens = context.mc;
    final double progress = credit.full > 0
        ? (credit.actual / credit.full).clamp(0.0, 1.0)
        : 0;
    final TextStyle? rowStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: isTotal ? 16 : 15,
      letterSpacing: 0,
    );

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _displayName(credit.name),
                    semanticsLabel: credit.name,
                    style: isTotal
                        ? rowStyle?.copyWith(fontWeight: FontWeight.w600)
                        : rowStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${_formatCredits(credit.actual)} / ${_formatCredits(credit.full)}',
                    textAlign: TextAlign.end,
                    style: rowStyle?.copyWith(
                      color: isTotal
                          ? tokens.foreground
                          : tokens.foreground.withValues(alpha: 0.72),
                      fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: progress,
              minHeight: isTotal ? 4 : 3,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              backgroundColor: tokens.surfaceSunken,
              color: tokens.primary,
              trackGap: 0,
              stopIndicatorRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
