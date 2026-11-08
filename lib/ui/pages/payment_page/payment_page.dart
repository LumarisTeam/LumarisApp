import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../features/basic/models/school.dart';
import '../../../features/education/models/payment_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes/router.dart';
import '../../../state/app_states.dart';
import '../../../state/payment_store.dart';
import '../../../state/school_store.dart';
import '../../components/loading_state_view.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  Future<void> _savePasswordAndReload(
    PaymentStore controller,
    String password,
  ) async {
    final l10n = context.l10n;
    final saveSuccess = await controller.savePassword(password);

    if (!mounted) {
      return;
    }

    if (!saveSuccess) {
      McFeedback.showMessage(context, message: l10n.saveFailedRetry);
      return;
    }

    McFeedback.showMessage(context, message: l10n.save);
    await controller.loadData();
  }

  Future<void> _showPasswordDialog(
    PaymentStore controller,
    PaymentState payment,
  ) async {
    final l10n = context.l10n;
    final result = await showMcInputDialog(
      context: context,
      title: l10n.paymentPasswordTitle,
      message: l10n.paymentPasswordSubtitle,
      hintText: l10n.password,
      confirmText: l10n.paymentSaveAndRefresh,
      initialValue: payment.password,
      obscureText: true,
      cancelText: context.l10n.cancel,
    );

    if (result == null) {
      return;
    }

    await _savePasswordAndReload(controller, result);
  }

  @override
  Widget build(BuildContext context) {
    final payment = ref.watch(paymentStoreProvider);
    final controller = ref.read(paymentStoreProvider.notifier);
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final school = ref.watch(schoolStoreProvider).school;
    final canPayment = school?.supports(Feature.payment) ?? true;

    if (school != null && !canPayment) {
      return Scaffold(
        appBar: McAppBar(title: l10n.payment),
        body: Center(child: Text(l10n.schoolNotSupported)),
      );
    }

    return Scaffold(
      appBar: McAppBar(
        title: l10n.payment,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadData,
            tooltip: l10n.refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadData,
        child: _buildContent(context, payment, controller, colors, l10n),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PaymentState payment,
    PaymentStore controller,
    McColors colors,
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        _buildBalanceCard(payment, colors, l10n),
        if (payment.hasData) ...[
          const SizedBox(height: 16),
          _buildQrCodeEntry(colors, l10n),
        ],
        const SizedBox(height: 24),
        if (payment.isLoading)
          LoadingStateView(
            title: l10n.paymentLoading,
            subtitle: l10n.paymentLoadingSubtitle,
            showCard: true,
          )
        else if (payment.errorMessage.isNotEmpty)
          _buildLoginPrompt(colors, l10n)
        else
          _buildRecentTransactionsSection(payment, colors, l10n),
        const SizedBox(height: 24),
        _buildSettingsSection(payment, controller, colors, l10n),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBalanceCard(
    PaymentState payment,
    McColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
        ),
        shape: McSmoothCorners.shape(BorderRadius.circular(20)),
        shadows: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.campusCard,
                style: TextStyle(
                  color: colors.onAccent.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.contactless_outlined,
                color: colors.onAccent.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            l10n.currentBalance,
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payment.hasData
                ? '¥${payment.totalRecharge.toStringAsFixed(2)}'
                : '¥ ---',
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildQrCodeEntry(McColors colors, AppLocalizations l10n) {
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: McListTile(
        leading: Icon(Icons.qr_code_2_rounded, color: colors.primary),
        title: Text(l10n.paymentQrCode),
        subtitle: Text(l10n.paymentQrCodeSubtitle),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          size: 18,
          color: colors.tertiaryLabel,
        ),
        onTap: () => AppRouter.push(AppRoutes.paymentQrCode),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(
    PaymentState payment,
    McColors colors,
    AppLocalizations l10n,
  ) {
    final recentRecords = payment.records
        .where(
          (r) =>
              r.turnoverType.contains('支付') ||
              r.turnoverType.contains('消费') ||
              r.turnoverType.contains('充值'),
        )
        .toList();

    if (recentRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.recentTransactions,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        McCard.elevated(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(recentRecords.length.clamp(0, 10), (index) {
              final record = recentRecords[index];
              final isLast = index == recentRecords.length.clamp(0, 10) - 1;
              return Column(
                children: [
                  _buildTransactionItem(record, colors),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colors.separator.withValues(alpha: 0.05),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(PaymentModel record, McColors colors) {
    final isRecharge = record.turnoverType.contains('充值');
    final amount = record.amount;
    final date = record.datetimeStr;
    final description = record.resume;

    return McListTile(
      title: Text(description.trim()),
      subtitle: Text(date),
      trailing: Text(
        '${isRecharge ? '+' : '-'}${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isRecharge ? colors.success : colors.label,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(McColors colors, AppLocalizations l10n) {
    return McCard.elevated(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.tertiaryLabel.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: colors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noCardData,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noCardDataSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: colors.secondaryLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    PaymentState payment,
    PaymentStore controller,
    McColors colors,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.settings,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        McCard.elevated(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              McListTile(
                leading: Icon(
                  Icons.lock_outline_rounded,
                  color: colors.primary,
                ),
                title: Text(l10n.paymentPasswordTitle),
                subtitle: Text(
                  payment.password.isEmpty
                      ? l10n.paymentPasswordSubtitle
                      : '••••••••',
                ),
                trailing: Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: colors.tertiaryLabel,
                ),
                onTap: payment.isLoading
                    ? null
                    : () => _showPasswordDialog(controller, payment),
              ),
              McListTile(
                leading: Icon(Icons.apps_rounded, color: colors.primary),
                title: Text(l10n.showPaymentTile),
                subtitle: Text(l10n.showPaymentTileSubtitle),
                trailing: CupertinoSwitch(
                  value: payment.isShowTile,
                  onChanged: (value) => controller.toggleTileShow(value),
                ),
              ),
              if (payment.isShowTile)
                McListTile(
                  leading: Icon(Icons.qr_code_2_rounded, color: colors.primary),
                  title: Text(l10n.paymentTileOpenQrCode),
                  subtitle: Text(l10n.paymentTileOpenQrCodeSubtitle),
                  trailing: CupertinoSwitch(
                    value: payment.openQrCodeFromTile,
                    onChanged: controller.setOpenQrCodeFromTile,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
