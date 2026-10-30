import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/core/utils/error_message_resolver.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart'
    show BusItem;
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';

class SchoolBusPage extends ConsumerWidget {
  const SchoolBusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busState = ref.watch(busControllerProvider);
    final busController = ref.read(busControllerProvider.notifier);
    final colors = context.mc.colors;
    final isLogin = ref.watch(userStoreProvider).isLogin;
    final school = ref.watch(schoolStoreProvider).school;
    final canBusSchedule = school?.supports(Feature.busSchedule) ?? true;

    if (school != null && !canBusSchedule) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.schoolBus)),
        body: Center(child: Text(context.l10n.schoolNotSupported)),
      );
    }

    if (!isLogin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.schoolBus)),
        body: EmptyWidget(
          title: context.l10n.guestMode,
          subtitle: context.l10n.guestModeSubtitle,
          icon: Icons.lock_outline,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildCampusSwitcher(context, busState, busController, colors),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: busController.refreshData,
            tooltip: context.l10n.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsModalBottomSheet(context),
            tooltip: context.l10n.settings,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(busState, busController, colors),
          Expanded(child: _buildContent(context, ref, busState, colors)),
        ],
      ),
    );
  }

  Widget _buildCampusSwitcher(
    BuildContext context,
    BusPageState busState,
    BusPageNotifier busController,
    McColors colors,
  ) {
    final campusOptions = busState.campusOptions;
    if (campusOptions.isEmpty) {
      return Text(context.l10n.schoolBus);
    }

    if (campusOptions.length == 1) {
      return Text(
        _displayCampusName(campusOptions.first),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );
    }

    if (campusOptions.length >= 3) {
      return _buildDropdownSelector(
        context,
        busState,
        busController,
        campusOptions,
      );
    }

    return CupertinoSlidingSegmentedControl<String>(
      groupValue: busState.selectedCampus,
      children: {
        for (final campus in campusOptions)
          campus: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _displayCampusName(campus),
              style: TextStyle(
                fontSize: 14,
                fontWeight: busState.selectedCampus == campus
                    ? FontWeight.w600
                    : null,
              ),
            ),
          ),
      },
      onValueChanged: (val) {
        if (val != null) {
          busController.selectCampus(val);
        }
      },
    );
  }

  Widget _buildDropdownSelector(
    BuildContext context,
    BusPageState busState,
    BusPageNotifier busController,
    List<String> campusOptions,
  ) {
    final colors = context.mc.colors;
    final selectedCampus = busState.selectedCampus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: McPopoverMenu<String>(
        items: List.generate(campusOptions.length, (index) {
          return McPopoverMenuItem<String>(
            value: campusOptions[index],
            label: _displayCampusName(campusOptions[index]),
          );
        }),
        selectedValue: selectedCampus,
        matchTriggerWidth: true,
        onSelected: (val) {
          busController.selectCampus(val);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: ShapeDecoration(
            color: colors.cardBackground,
            shape: McSmoothCorners.shape(McRadii.navigationBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _displayCampusName(selectedCampus),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: colors.secondaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayCampusName(String campus) {
    return campus.endsWith('校区')
        ? campus.substring(0, campus.length - 2)
        : campus;
  }

  Widget _buildDateSelector(
    BusPageState busState,
    BusPageNotifier busController,
    McColors colors,
  ) {
    final dates = busController.availableDates.entries.toList();
    final selectedIndex = dates.indexWhere(
      (e) => e.key == busState.selectedDate,
    );

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final entry = dates[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => busController.selectDateByIndex(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: ShapeDecoration(
                  color: isSelected
                      ? colors.primary
                      : colors.primary.withValues(alpha: 0.05),
                  shape: McSmoothCorners.shape(BorderRadius.circular(24)),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? colors.onAccent : colors.secondaryLabel,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BusPageState busState,
    McColors colors,
  ) {
    final busController = ref.read(busControllerProvider.notifier);

    if (busState.isLoading) {
      return _buildRefreshPlaceholder(
        onRefresh: busController.refreshData,
        child: LoadingStateView(
          title: context.l10n.busLoading,
          subtitle: context.l10n.busLoadingSubtitle,
          showCard: false,
        ),
      );
    }

    final hasBusData = busState.busData.isNotEmpty;
    if (busState.errorMessage.isNotEmpty && !hasBusData) {
      return _buildRefreshPlaceholder(
        onRefresh: busController.refreshData,
        child: McCard.elevated(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.danger),
              const SizedBox(height: 16),
              Text(
                resolveErrorMessage(busState.errorMessage, context.l10n),
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.label, fontSize: 16),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                onPressed: busController.refreshData,
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasBusData) {
      return _buildRefreshPlaceholder(
        onRefresh: busController.refreshData,
        child: EmptyWidget(
          title: context.l10n.noBusToday,
          subtitle: context.l10n.noBusTodaySubtitle,
          icon: Icons.directions_bus_filled_rounded,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: busController.refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            busState.busData.length +
            (busState.errorMessage.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (busState.errorMessage.isNotEmpty && index == 0) {
            return McCard.elevated(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      resolveErrorMessage(busState.errorMessage, context.l10n),
                      style: TextStyle(color: colors.secondaryLabel),
                    ),
                  ),
                ],
              ),
            );
          }
          final busIndex = busState.errorMessage.isNotEmpty ? index - 1 : index;
          final bus = busState.busData[busIndex];
          return BusTimelineTile(
            bus: bus,
            onTap: () => _showBusDetails(context, bus),
          );
        },
      ),
    );
  }

  Widget _buildRefreshPlaceholder({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSettingsModalBottomSheet(BuildContext context) async {
    await showMcBottomSheet(
      context: context,
      builder: (_) => Consumer(
        builder: (context, ref, child) {
          final busState = ref.watch(busControllerProvider);
          final busController = ref.read(busControllerProvider.notifier);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.pageSettings,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              McListTile(
                title: Text(context.l10n.showBusTile),
                subtitle: Text(context.l10n.showBusTileSubtitle),
                trailing: CupertinoSwitch(
                  value: busState.isShowBus,
                  onChanged: busController.toggleShowBus,
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
    );
  }

  Future<void> _showBusDetails(BuildContext context, BusItem bus) {
    final colors = context.mc.colors;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ModalHeader(title: bus.lineName),
        const SizedBox(height: 12),
        _buildInfoRow(
          context: context,
          icon: Icons.access_time_filled_rounded,
          label: context.l10n.departureTime,
          content: bus.runTime,
          color: colors.primary,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.location_on_rounded,
          label: context.l10n.destination,
          content: bus.arrivalStation,
          color: colors.danger,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.schedule_rounded,
          label: context.l10n.estimatedArrival,
          content: bus.arrivalTime,
          color: colors.success,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.info_outline_rounded,
          label: context.l10n.busInfo,
          content: bus.description,
          color: colors.warning,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
      ],
    );

    return showMcBottomSheet(
      context: context,
      builder: (_) => content,
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String content,
    required Color color,
    int maxLines = 1,
  }) {
    final colors = context.mc.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: color.withValues(alpha: 0.1),
              shape: McSmoothCorners.shape(BorderRadius.circular(8)),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BusTimelineTile extends StatelessWidget {
  const BusTimelineTile({super.key, required this.bus, required this.onTap});

  final BusItem bus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: McCard.elevated(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTimeDisplay(
                    bus.runTime,
                    context.l10n.departure,
                    colors,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: colors.tertiaryLabel,
                    ),
                  ),
                  _buildTimeDisplay(
                    bus.arrivalTime,
                    context.l10n.arrival,
                    colors,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: ShapeDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: McSmoothCorners.shape(BorderRadius.circular(6)),
                    ),
                    child: Text(
                      _arrivalStationTimeInL10n(
                        bus.arrivalStationTime,
                        context,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bus.departureStation} → ${bus.arrivalStation}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (bus.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            bus.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.secondaryLabel,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.quaternaryLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(String time, String label, McColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.label,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colors.tertiaryLabel,
          ),
        ),
      ],
    );
  }

  String _arrivalStationTimeInL10n(
    String arrivalStationTime,
    BuildContext context,
  ) {
    var s = arrivalStationTime.split(':');
    if (s.length >= 2) {
      return context.l10n.arrivalStationTime(s[0], s[1]);
    }

    return arrivalStationTime;
  }
}
