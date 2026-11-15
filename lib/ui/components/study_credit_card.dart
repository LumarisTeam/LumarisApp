import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/extensions/localization_extensions.dart';
import '../../features/education/models/info_model.dart';

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

    return McCard.flat(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(22),
      radius: 24,
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
                        Icon(Icons.school, size: 19, color: tokens.foreground),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: textTheme.titleMedium?.copyWith(
                                color: tokens.foreground,
                                fontSize: 16,
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
                  dimension: 53,
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
          if (data.other.isNotEmpty) const SizedBox(height: 20),
          for (final TotalData credit in data.other) _CreditRow(credit: credit),
        ],
      ),
    );
  }
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
        constraints: const BoxConstraints(minHeight: 38),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
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
        height: isTotal ? 1.12 : null,
        letterSpacing: isTotal ? -0.5 : 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
