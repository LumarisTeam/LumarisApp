import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';

import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/app_action_sheet.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/user_store.dart';

enum _ElectricityAction { refresh, changeRoom }

class ElectricityPage extends ConsumerStatefulWidget {
  const ElectricityPage({super.key});

  @override
  ConsumerState<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends ConsumerState<ElectricityPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _subscriptionEmailController =
      TextEditingController();
  final TextEditingController _subscriptionThresholdController =
      TextEditingController(text: '10');
  bool _isSubscriptionLoading = false;
  bool _hasLoadedSubscriptions = false;
  String _subscriptionEmail = '';
  bool _hasActiveSubscription = false;
  String _subscriptionId = '';
  double? _subscriptionThreshold;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_restoreSubscriptionPreferences);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _subscriptionEmailController.dispose();
    _subscriptionThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasElectricityData = ref.watch(
      electricityStoreProvider.select((state) => state.hasData),
    );
    final hasConfiguredSource = ref.watch(
      electricityStoreProvider.select((state) => state.hasConfiguredSource),
    );
    final l10n = context.l10n;
    final isLogin = ref.watch(
      userStoreProvider.select((state) => state.isLogin),
    );
    final school = ref.watch(
      schoolStoreProvider.select((state) => state.school),
    );
    final canElectricity = school?.supports(Feature.electricity) ?? true;

    if (school != null && !canElectricity) {
      return Scaffold(
        appBar: McAppBar(title: l10n.electricityManagement),
        body: Center(child: Text(l10n.schoolNotSupported)),
      );
    }

    if (!isLogin) {
      return Scaffold(
        appBar: McAppBar(title: l10n.electricityManagement),
        body: EmptyWidget(
          title: l10n.guestMode,
          subtitle: l10n.guestModeSubtitle,
          icon: Icons.lock_outline,
        ),
      );
    }

    if (hasElectricityData &&
        !_hasLoadedSubscriptions &&
        !_isSubscriptionLoading) {
      Future<void>.microtask(_loadSubscriptions);
    }
    if (kIsWeb) {
      return Scaffold(
        appBar: McAppBar(title: l10n.electricityManagement),
        body: EmptyWidget(
          title: l10n.webNotSupported,
          subtitle: l10n.webNotSupportedSubtitle,
          icon: Icons.error,
        ),
      );
    }
    return Scaffold(
      appBar: McAppBar(
        title: l10n.electricityManagement,
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _handleElectricityAction,
            child: Icon(
              hasElectricityData
                  ? CupertinoIcons.arrow_2_circlepath
                  : hasConfiguredSource
                  ? CupertinoIcons.arrow_2_circlepath
                  : CupertinoIcons.add,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handlePullToRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 当前电费头部
              _buildCurrentElectricityHeader(),

              const SizedBox(height: 32),

              // 电费图表卡片
              if (hasElectricityData) _buildChartCard(),

              if (hasElectricityData) const SizedBox(height: 24),

              // 设置选项
              if (hasElectricityData) _buildSettingsSection(),

              const SizedBox(height: 24),

              if (hasElectricityData)
                _buildSubscriptionSection(
                  hasElectricityData: hasElectricityData,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePullToRefresh() async {
    final controller = ref.read(electricityStoreProvider.notifier);
    final electricityState = ref.read(electricityStoreProvider);
    if (electricityState.hasData) {
      await controller.refreshElectricityData();
      await _loadSubscriptions(force: true);
      return;
    }
    await controller.loadElectricityData();
    if (!mounted) {
      return;
    }
    if (ref.read(electricityStoreProvider).hasData) {
      await _loadSubscriptions(force: true);
    }
  }

  Widget _buildCurrentElectricityHeader() {
    return Consumer(
      builder: (context, ref, child) {
        final electricityState = ref.watch(
          electricityStoreProvider.select(
            (state) => (
              hasData: state.hasData,
              hasConfiguredSource: state.hasConfiguredSource,
              electricity: state.electricity,
            ),
          ),
        );
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = context.l10n;
        final statusColor = electricityState.electricity <= 10
            ? colorScheme.error
            : _successColor(context);

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.currentBalance,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (electricityState.hasData)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                      child: Text(
                        '¥',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      electricityState.electricity.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  l10n.electricityNoData,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: ShapeDecoration(
                  color: electricityState.hasData
                      ? statusColor.withValues(alpha: 0.1)
                      : colorScheme.surfaceContainerHighest,
                  shape: McSmoothCorners.shape(BorderRadius.circular(20)),
                ),
                child: Text(
                  electricityState.hasData
                      ? (electricityState.electricity <= 10
                            ? l10n.electricityLowBalance
                            : l10n.electricitySufficient)
                      : electricityState.hasConfiguredSource
                      ? l10n.fetchFailed
                      : l10n.electricityAddTip,
                  style: TextStyle(
                    fontSize: 13,
                    color: electricityState.hasData
                        ? statusColor
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCard() {
    return Consumer(
      builder: (context, ref, child) {
        final electricityState = ref.watch(
          electricityStoreProvider.select(
            (state) =>
                (isLoading: state.isLoading, weeklyData: state.weeklyData),
          ),
        );
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = context.l10n;
        return AnimatedCard(
          delay: const Duration(milliseconds: 150),
          child: McCard.elevated(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Builder(
                builder: (context) {
                  if (electricityState.isLoading) {
                    return SizedBox(
                      height: 240,
                      child: Center(
                        child: LoadingStateView(
                          title: l10n.electricityLoading,
                          subtitle: l10n.electricityLoadingSubtitle,
                          compact: true,
                          showCard: false,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  }

                  final data = electricityState.weeklyData;
                  if (data.isEmpty) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: EmptyWidget(
                          title: l10n.noUsageDetails,
                          subtitle: l10n.noUsageDetailsSubtitle,
                          icon: CupertinoIcons.chart_bar_alt_fill,
                        ),
                      ),
                    );
                  }

                  final dailySummaries = _buildDailySummaries(data);
                  final totalCost = data.fold<double>(
                    0,
                    (previousValue, item) => previousValue + item.value,
                  );
                  final todayCost = data
                      .where(
                        (item) => _isSameDay(item.timestamp, DateTime.now()),
                      )
                      .fold<double>(
                        0,
                        (previousValue, item) => previousValue + item.value,
                      );
                  final averageDailyCost = dailySummaries.isEmpty
                      ? 0.0
                      : totalCost / dailySummaries.length;
                  final peakData = data.reduce(
                    (currentPeak, item) =>
                        item.value > currentPeak.value ? item : currentPeak,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.electricityCost,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: ShapeDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: McSmoothCorners.shape(
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.lastNDays(dailySummaries.length),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildCostOverview(
                        totalCost: totalCost,
                        todayCost: todayCost,
                        averageDailyCost: averageDailyCost,
                        peakData: peakData,
                      ),
                      const SizedBox(height: 32),
                      _buildHourlyCostScroller(data),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCostOverview({
    required double totalCost,
    required double todayCost,
    required double averageDailyCost,
    required ElectricData peakData,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMinimalMetric(
                label: l10n.totalCost,
                value: '¥${totalCost.toStringAsFixed(2)}',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _buildMinimalMetric(
                label: l10n.todayCost,
                value: '¥${todayCost.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildMinimalMetric(
                label: l10n.avgDailyCost,
                value: '¥${averageDailyCost.toStringAsFixed(2)}',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _buildMinimalMetric(
                label: l10n.peakHours,
                value: _formatHourCost(peakData),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimalMetric({required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyCostScroller(List<ElectricData> data) {
    final recentData = data.length > 24 ? data.sublist(data.length - 24) : data;
    final maxValue = recentData.map((item) => item.value).reduce(max);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.hourlyDetails,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: recentData.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildHourlyCostTile(data: item, maxValue: maxValue),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyCostTile({
    required ElectricData data,
    required double maxValue,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillRatio = maxValue <= 0 ? 0.0 : data.value / maxValue;

    return SizedBox(
      width: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            data.value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillRatio.clamp(0.05, 1.0).toDouble(),
                child: Container(
                  width: 12,
                  decoration: ShapeDecoration(
                    color: colorScheme.primary,
                    shape: McSmoothCorners.shape(BorderRadius.circular(6)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${data.timestamp.hour}:00',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  List<_ElectricityDailySummary> _buildDailySummaries(List<ElectricData> data) {
    final dailyCosts = <DateTime, double>{};
    for (final item in data) {
      final date = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      dailyCosts.update(
        date,
        (value) => value + item.value,
        ifAbsent: () => item.value,
      );
    }

    return dailyCosts.entries
        .map(
          (entry) =>
              _ElectricityDailySummary(date: entry.key, cost: entry.value),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatHourCost(ElectricData data) {
    return '${data.timestamp.hour}:00 / ¥${data.value.toStringAsFixed(1)}';
  }

  Color _successColor(BuildContext context) {
    return context.mc.colors.success;
  }

  Widget _buildSettingsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final tiles = ref.watch(
          electricityStoreProvider.select((state) => state.tiles),
        );
        final controller = ref.read(electricityStoreProvider.notifier);
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = context.l10n;

        return AnimatedCard(
          delay: const Duration(milliseconds: 300),
          child: McCard.elevated(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                McListTile(
                  leading: Icon(
                    CupertinoIcons.square_grid_2x2,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    l10n.addToHome,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(l10n.showElectricityTile),
                  trailing: CupertinoSwitch(
                    value: tiles.contains('电费'),
                    onChanged: (value) async {
                      await controller.toggleTile('电费', value);
                    },
                  ),
                ),
                McListTile(
                  leading: Icon(
                    CupertinoIcons.money_yen_circle,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    l10n.electricityRecharge,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(l10n.electricityRechargeSubtitle),
                  trailing: Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTap: () async {
                    await ref
                        .read(electricityServiceProvider)
                        .openRechargePage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionSection({required bool hasElectricityData}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AnimatedCard(
      delay: const Duration(milliseconds: 360),
      child: McCard.elevated(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lowBalanceSub,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasElectricityData
                              ? l10n.lowBalanceSubDesc
                              : l10n.addElectricityFirst,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasElectricityData)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: _isSubscriptionLoading
                          ? null
                          : () => _loadSubscriptions(force: true),
                      child: Icon(
                        Icons.refresh,
                        size: 20,
                        color: _isSubscriptionLoading
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            if (!hasElectricityData)
              _buildSubscriptionEmptyState(
                icon: CupertinoIcons.link,
                title: l10n.noElectricityData,
                subtitle: l10n.noElectricityDataSubtitle,
              )
            else ...[
              McListTile(
                leading: Icon(
                  _hasActiveSubscription
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.bell,
                  color: colorScheme.primary,
                ),
                title: Text(
                  _hasActiveSubscription
                      ? l10n.lowBalanceEnabled
                      : l10n.addLowBalanceAlert,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(_buildSubscriptionSummary()),
                trailing: Icon(
                  _hasActiveSubscription
                      ? CupertinoIcons.chevron_right
                      : CupertinoIcons.add_circled,
                  size: 18,
                  color: _hasActiveSubscription
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                ),
                onTap: _hasActiveSubscription
                    ? _showSubscriptionDetailDialog
                    : _showCreateSubscriptionDialog,
              ),
              if (_hasActiveSubscription)
                McListTile(
                  leading: Icon(
                    CupertinoIcons.delete,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    l10n.deleteSubscription,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(l10n.deleteSubDesc),
                  trailing: Icon(
                    CupertinoIcons.chevron_right,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTap: _showDeleteSubscriptionDialog,
                ),
              if (_isSubscriptionLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleElectricityAction() {
    final electricityState = ref.read(electricityStoreProvider);
    if (electricityState.hasData || electricityState.hasConfiguredSource) {
      _showRefreshDialog();
    } else {
      _showInputDialog();
    }
  }

  Future<void> _showRefreshDialog() async {
    final l10n = context.l10n;
    final action = await showAppActionSheet<_ElectricityAction>(
      context: context,
      title: l10n.electricityManagement,
      message: l10n.chooseAction,
      cancelLabel: l10n.cancel,
      items: [
        AppActionSheetItem(
          value: _ElectricityAction.refresh,
          label: l10n.refreshData,
        ),
        AppActionSheetItem(
          value: _ElectricityAction.changeRoom,
          label: l10n.changeRoom,
        ),
      ],
    );
    if (!mounted) return;

    switch (action) {
      case _ElectricityAction.refresh:
        await ref
            .read(electricityStoreProvider.notifier)
            .refreshElectricityData();
        await _loadSubscriptions(force: true);
      case _ElectricityAction.changeRoom:
        _showInputDialog();
      case null:
        break;
    }
  }

  void _showInputDialog() {
    final l10n = context.l10n;
    showMcDialog(
      context: context,
      title: l10n.getElectricity,
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.electricityUrlPrompt,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            McField.text(
              controller: _urlController,
              placeholder: l10n.urlPlaceholder,
            ),
          ],
        ),
      ),
      actions: [
        McDialogAction<void>(
          label: l10n.cancel,
          isDestructiveAction: true,
          onPressed: _urlController.clear,
        ),
        McDialogAction<void>(
          label: l10n.confirm,
          isDefaultAction: true,
          onPressed: () async {
            final sourceUrl = _urlController.text;
            final value = await ref
                .read(electricityServiceProvider)
                .fetchCurrentBalance(url: sourceUrl);
            if (!mounted) {
              return;
            }
            final controller = ref.read(electricityStoreProvider.notifier);
            controller.setSourceConfigured(sourceUrl.trim().isNotEmpty);
            if (value != null) {
              _urlController.clear();
              await controller.setElectricityValue(value);
              await controller.loadElectricityData();
              await _loadSubscriptions(force: true);
            } else {
              _urlController.clear();
            }
          },
        ),
      ],
    );
  }

  Future<void> _restoreSubscriptionPreferences() async {
    final email = await ref
        .read(electricityServiceProvider)
        .getSavedSubscriptionEmail();
    if (!mounted) {
      return;
    }

    setState(() {
      _subscriptionEmail = email;
    });
  }

  Future<void> _loadSubscriptions({bool force = false}) async {
    if (_isSubscriptionLoading) {
      return;
    }
    if (!force && _hasLoadedSubscriptions) {
      return;
    }

    setState(() {
      _isSubscriptionLoading = true;
    });

    try {
      final service = ref.read(electricityServiceProvider);
      final email = await service.getSavedSubscriptionEmail();
      var hasActiveSubscription = false;
      var subscriptionId = '';
      double? subscriptionThreshold;
      var resolvedEmail = email;

      if (email.isNotEmpty) {
        final query = await service.getSubscription(email: email);
        hasActiveSubscription = query.hasSubscription;
        subscriptionId = query.subscriptionId;
        subscriptionThreshold = query.threshold.toDouble();
        resolvedEmail = query.email;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _subscriptionEmail = resolvedEmail;
        _hasActiveSubscription = hasActiveSubscription;
        _subscriptionId = subscriptionId;
        _subscriptionThreshold = subscriptionThreshold;
        _hasLoadedSubscriptions = true;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      final l10n = context.l10n;
      McFeedback.showMessage(
        context,
        message: '${l10n.electricitySubLoadFailed}: $e',
      );
      setState(() {
        _hasLoadedSubscriptions = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubscriptionLoading = false;
        });
      }
    }
  }

  void _showCreateSubscriptionDialog() {
    final l10n = context.l10n;
    _subscriptionEmailController.text = _subscriptionEmail;
    if (_subscriptionThresholdController.text.trim().isEmpty) {
      _subscriptionThresholdController.text = '10';
    }

    showMcDialog(
      context: context,
      title: l10n.createLowBalanceAlert,
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.lowBalanceAlertDesc,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            McField.text(
              controller: _subscriptionEmailController,
              placeholder: l10n.remindEmailPlaceholder,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            McField.text(
              controller: _subscriptionThresholdController,
              placeholder: l10n.remindThresholdPlaceholder,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        McDialogAction<void>(label: l10n.cancel, isDestructiveAction: true),
        McDialogAction<void>(
          label: l10n.create,
          isDefaultAction: true,
          onPressed: _createSubscription,
        ),
      ],
    );
  }

  Future<void> _createSubscription() async {
    final email = _subscriptionEmailController.text.trim();
    final thresholdText = _subscriptionThresholdController.text.trim();
    final threshold = double.tryParse(thresholdText);

    final l10nSB = context.l10n;
    if (email.isEmpty) {
      McFeedback.showMessage(context, message: l10nSB.pleaseEnterEmail);
      return;
    }
    if (!_isValidEmail(email)) {
      McFeedback.showMessage(context, message: l10nSB.pleaseEnterValidEmail);
      return;
    }
    if (threshold == null || threshold <= 0) {
      McFeedback.showMessage(context, message: l10nSB.pleaseEnterThreshold);
      return;
    }

    setState(() {
      _isSubscriptionLoading = true;
    });

    try {
      await ref
          .read(electricityServiceProvider)
          .createSubscription(email: email, threshold: threshold);

      if (!mounted) {
        return;
      }

      setState(() {
        _subscriptionEmail = email;
        _hasActiveSubscription = true;
        _subscriptionThreshold = threshold;
        _isSubscriptionLoading = false;
        _hasLoadedSubscriptions = false;
      });
      await _loadSubscriptions(force: true);
      if (!mounted) {
        return;
      }
      McFeedback.showMessage(context, message: l10nSB.lowBalanceAlertCreated);
    } catch (e) {
      if (!mounted) {
        return;
      }
      McFeedback.showMessage(context, message: '${l10nSB.createSubFailed}: $e');
      setState(() {
        _isSubscriptionLoading = false;
      });
    }
  }

  String _buildSubscriptionSummary() {
    final l10n = context.l10n;
    if (_hasActiveSubscription && _subscriptionEmail.isNotEmpty) {
      return l10n.currentSubInfo(
        _subscriptionEmail,
        _formatThreshold(_subscriptionThreshold),
      );
    }
    return l10n.subSetupHint;
  }

  void _showSubscriptionDetailDialog() {
    final l10n = context.l10n;
    showMcDialog(
      context: context,
      title: l10n.lowBalanceSub,
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSubscriptionDetailLine(
              label: l10n.remindEmailLabel,
              value: _subscriptionEmail.isEmpty
                  ? l10n.notSet
                  : _subscriptionEmail,
            ),
            const SizedBox(height: 10),
            _buildSubscriptionDetailLine(
              label: l10n.remindThresholdLabel,
              value: '${_formatThreshold(_subscriptionThreshold)} 元',
            ),
          ],
        ),
      ),
      actions: [McDialogAction<void>(label: l10n.gotIt, isDefaultAction: true)],
    );
  }

  Widget _buildSubscriptionDetailLine({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteSubscriptionDialog() async {
    final l10n = context.l10n;
    if (_subscriptionId.isEmpty) {
      McFeedback.showMessage(context, message: l10n.noSubToDelete);
      return;
    }

    final confirmed = await showMcConfirmDialog(
      context: context,
      title: l10n.deleteSubTitle,
      message: l10n.deleteSubConfirmContent,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
    );

    if (confirmed == true) {
      await _deleteSubscription();
    }
  }

  Future<void> _deleteSubscription() async {
    final l10n = context.l10n;
    if (_subscriptionId.isEmpty) {
      McFeedback.showMessage(context, message: l10n.noSubToDelete);
      return;
    }

    setState(() {
      _isSubscriptionLoading = true;
    });

    try {
      await ref
          .read(electricityServiceProvider)
          .deleteSubscription(_subscriptionId);

      if (!mounted) {
        return;
      }

      setState(() {
        _hasActiveSubscription = false;
        _subscriptionId = '';
        _subscriptionThreshold = null;
        _isSubscriptionLoading = false;
        _hasLoadedSubscriptions = false;
      });
      await _loadSubscriptions(force: true);
      if (!mounted) {
        return;
      }
      McFeedback.showMessage(context, message: l10n.lowBalanceAlertDeleted);
    } catch (e) {
      if (!mounted) {
        return;
      }
      McFeedback.showMessage(context, message: '${l10n.deleteSubFailed}: $e');
      setState(() {
        _isSubscriptionLoading = false;
      });
    }
  }

  bool _isValidEmail(String value) {
    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegExp.hasMatch(value);
  }

  String _formatThreshold(double? threshold) {
    if (threshold == null) {
      return '--';
    }
    if (threshold == threshold.roundToDouble()) {
      return threshold.toStringAsFixed(0);
    }
    return threshold.toStringAsFixed(2);
  }
}

class _ElectricityDailySummary {
  const _ElectricityDailySummary({required this.date, required this.cost});

  final DateTime date;
  final double cost;
}
