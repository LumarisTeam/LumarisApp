import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../core/utils/error_message_resolver.dart';
import '../../../routes/router.dart';
import '../../../state/payment_store.dart';
import '../loading_state_view.dart';

class PaymentTile extends ConsumerWidget {
  const PaymentTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final payment = ref.watch(paymentStoreProvider);
    final colors = context.mc.colors;

    return McCard.elevated(
      radius: McRadii.tile,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: McRadii.tileBorder,
          customBorder: McSmoothCorners.shape(McRadii.tileBorder),
          onTap: () => ref
              .read(appRouterProvider)
              .push(
                payment.openQrCodeFromTile
                    ? '${AppRoutes.paymentQrCode}?from=tile'
                    : AppRoutes.payment,
              ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                // Loading state
                if (payment.isLoading) {
                  return Center(
                    child: LoadingStateView(
                      title: l10n.readingPaymentCard,
                      subtitle: '',
                      compact: true,
                      padding: EdgeInsets.zero,
                    ),
                  );
                }

                // Has Data state
                if (!payment.isLoading && payment.hasData) {
                  final amount = payment.totalRecharge;
                  final isLow = amount <= 10;
                  final primaryColor = isLow ? colors.danger : colors.warning;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.monetization_on_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        l10n.currentBalance,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '¥${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isLow ? colors.danger : colors.label,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }

                // Unsubscribed / Unbound state
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.monetization_on_rounded,
                        color: colors.secondaryLabel,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.campusCardBalance,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.errorMessage.isNotEmpty
                          ? resolveErrorMessage(payment.errorMessage, l10n)
                          : l10n.tapToView,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: payment.errorMessage.isNotEmpty
                            ? colors.danger
                            : colors.secondaryLabel,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
