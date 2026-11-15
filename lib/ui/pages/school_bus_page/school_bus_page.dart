import 'package:flutter/widget_previews.dart';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../core/utils/error_message_resolver.dart';
import '../../../features/basic/models/school.dart';
import '../../../features/education/models/bus_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/app_states.dart';
import '../../../state/bus_page_notifier.dart';
import '../../../state/school_store.dart';
import '../../../state/user_store.dart';
import '../../components/modal_components.dart';
import '../../components/page_app_bar.dart';

class SchoolBusPage extends ConsumerWidget {
  const SchoolBusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final School? school = ref.watch(schoolStoreProvider).school;
    final bool isLogin = ref.watch(userStoreProvider).isLogin;
    final AppLocalizations l10n = context.l10n;

    if (school != null && !school.supports(Feature.busSchedule)) {
      return Scaffold(
        appBar: PageAppBar(title: l10n.schoolBus),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(l10n.schoolNotSupported),
          ),
        ),
      );
    }
    if (!isLogin) {
      return Scaffold(
        appBar: PageAppBar(title: l10n.schoolBus),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            McEmpty.placeholder(
              icon: CupertinoIcons.lock,
              title: l10n.guestMode,
              description: l10n.guestModeSubtitle,
            ),
          ],
        ),
      );
    }

    final BusPageState state = ref.watch(busControllerProvider);
    final BusPageNotifier controller = ref.read(busControllerProvider.notifier);
    return _BusScheduleView(
      state: state,
      dates: controller.availableDates.keys.map(DateTime.parse).toList(),
      onDateSelected: controller.selectDateByIndex,
      onStationSelected: controller.selectCampus,
      onRefresh: controller.refreshData,
      onSettings: () => _showSettings(context),
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    await showMcBottomSheet<void>(
      context: context,
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final BusPageState state = ref.watch(busControllerProvider);
          final BusPageNotifier controller = ref.read(
            busControllerProvider.notifier,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalHeader(title: context.l10n.pageSettings),
              McListTile(
                title: Text(context.l10n.showBusTile),
                subtitle: Text(context.l10n.showBusTileSubtitle),
                trailing: CupertinoSwitch(
                  value: state.isShowBus,
                  onChanged: controller.toggleShowBus,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BusScheduleView extends StatelessWidget {
  const _BusScheduleView({
    required this.state,
    required this.dates,
    required this.onDateSelected,
    required this.onStationSelected,
    required this.onRefresh,
    this.onSettings,
  });

  final BusPageState state;
  final List<DateTime> dates;
  final ValueChanged<int> onDateSelected;
  final ValueChanged<String> onStationSelected;
  final Future<void> Function() onRefresh;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DateTime? selectedDate = DateTime.tryParse(state.selectedDate);

    return Scaffold(
      backgroundColor: context.mc.groupedBackground,
      appBar: PageAppBar(
        title: l10n.schoolBus,
        actions: [
          Tooltip(
            message: l10n.refreshData,
            child: McButton.ghost(
              padding: const EdgeInsets.all(12),
              onPressed: state.isLoading ? null : onRefresh,
              child: Icon(CupertinoIcons.arrow_clockwise, size: 24),
            ),
          ),
          if (onSettings != null)
            Tooltip(
              message: l10n.settings,
              child: McButton.ghost(
                padding: const EdgeInsets.all(12),
                onPressed: onSettings,
                child: Icon(CupertinoIcons.gear, size: 24),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.selectedCampus.isNotEmpty) ...[
                        _buildStation(context),
                        const SizedBox(height: 12),
                      ],
                      _BusDateStrip(
                        dates: dates,
                        selectedDate: selectedDate,
                        onSelected: onDateSelected,
                      ),
                      const SizedBox(height: 20),
                      _buildDepartures(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStation(BuildContext context) {
    final bool canSelect = state.campusOptions.length > 1;
    final Widget field = McCard.grouped(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 14, 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 24),
          child: OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            overflowSpacing: 6,
            overflowAlignment: OverflowBarAlignment.start,
            children: [
              Text(
                context.l10n.busDepartureStation,
                style: context.mc.textMuted,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      state.selectedCampus,
                      style: TextStyle(
                        color: context.mc.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (canSelect) ...[
                    const SizedBox(width: 6),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 14,
                      color: context.mc.secondaryLabel,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!canSelect) return field;

    return McPopoverMenu<String>(
      items: [
        for (final String station in state.campusOptions)
          McPopoverMenuItem(value: station, label: station),
      ],
      selectedValue: state.selectedCampus,
      onSelected: onStationSelected,
      matchTriggerWidth: true,
      child: field,
    );
  }

  Widget _buildDepartures(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<BusItem> trips = state.busData.toList()
      ..sort(_compareDepartures);
    final bool hasSchedule = state.todayBusData.isNotEmpty;
    final bool hasError = state.errorMessage.isNotEmpty;
    final String status = hasError
        ? resolveErrorMessage(state.errorMessage, l10n)
        : '';
    final bool showCount = trips.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          overflowAlignment: OverflowBarAlignment.start,
          spacing: 12,
          overflowSpacing: 4,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.busTimetable, style: context.mc.textSection),
            ),
            if (showCount)
              Text(
                l10n.busTripCount(trips.length),
                style: context.mc.textMuted,
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.isLoading && !hasSchedule)
          McCard.grouped(
            child: McListTile(
              leading: const CupertinoActivityIndicator(),
              title: Semantics(liveRegion: true, child: Text(l10n.busLoading)),
            ),
          )
        else if (hasError && !hasSchedule)
          McEmpty.retry(
            title: status,
            description: '',
            retryLabel: l10n.retry,
            onRetry: onRefresh,
          )
        else ...[
          if (hasError || state.isLoading) ...[
            McCard.grouped(
              child: McListTile(
                leading: hasError
                    ? Icon(
                        CupertinoIcons.info_circle,
                        color: context.mc.colors.warning,
                      )
                    : const CupertinoActivityIndicator(),
                title: Semantics(
                  liveRegion: true,
                  child: Text(hasError ? status : l10n.busLoading),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (!showCount)
            McEmpty.placeholder(
              icon: CupertinoIcons.bus,
              title: hasSchedule
                  ? l10n.busNoTripsFromStation
                  : l10n.busNoTripsOnDate,
              description: hasSchedule
                  ? l10n.busSwitchStationOrDateHint
                  : l10n.busSwitchDateHint,
            )
          else
            McCard.grouped(
              child: Column(
                children: [
                  for (final (int index, BusItem bus) in trips.indexed) ...[
                    if (index > 0)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 16,
                        endIndent: 16,
                        color: context.mc.colors.separator,
                      ),
                    _BusDepartureTile(bus: bus),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }

  static int _compareDepartures(BusItem a, BusItem b) =>
      _timeInMinutes(a.runTime).compareTo(_timeInMinutes(b.runTime));

  static int _timeInMinutes(String time) {
    final List<String> parts = time.split(':');
    if (parts.length < 2) return 1 << 30;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    return hour == null || minute == null ? 1 << 30 : hour * 60 + minute;
  }
}

class _BusDateStrip extends StatelessWidget {
  const _BusDateStrip({
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final DateTime? selectedDate;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String locale = Localizations.localeOf(context).toString();
    final DateFormat weekday = DateFormat.E(locale);
    final DateFormat monthDay = DateFormat.Md(locale);
    final DateFormat fullDate = DateFormat.yMMMMEEEEd(locale);
    final m = context.mc;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 4,
        children: [
          for (final (int index, DateTime date) in dates.indexed)
            Builder(
              builder: (context) {
                final bool selected = DateUtils.isSameDay(date, selectedDate);
                final String title = switch (index) {
                  0 => l10n.busDateToday,
                  1 => l10n.busDateTomorrow,
                  _ => weekday.format(date),
                };
                return Semantics(
                  label: fullDate.format(date),
                  selected: selected,
                  child: McButton.ghost(
                    onPressed: () => onSelected(index),
                    padding: EdgeInsets.zero,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: selected ? m.colors.primarySoft : null,
                        shape: McSmoothCorners.shape(McRadii.navigationBorder),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 62,
                          minHeight: 56,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: ExcludeSemantics(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 2,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: selected
                                        ? m.foreground
                                        : m.secondaryLabel,
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                Text(monthDay.format(date), style: m.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BusDepartureTile extends StatelessWidget {
  const _BusDepartureTile({required this.bus});

  final BusItem bus;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Widget time = Text(
      bus.runTime.isEmpty ? '—' : bus.runTime,
      semanticsLabel: bus.runTime.isEmpty
          ? null
          : '${l10n.departureTime} ${bus.runTime}',
      style: TextStyle(
        color: context.mc.foreground,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final Widget destination = Text(
      bus.arrivalStation.isEmpty ? bus.lineName : bus.arrivalStation,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double timeWidth = MediaQuery.textScalerOf(context).scale(70);
        final bool stackTime = constraints.maxWidth < timeWidth + 190;
        return McListTile(
          leading: stackTime ? null : SizedBox(width: timeWidth, child: time),
          title: stackTime
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [time, destination],
                )
              : destination,
          titleTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          subtitle: bus.arrivalTime.isEmpty
              ? null
              : Text('${l10n.estimatedArrival} ${bus.arrivalTime}'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          showChevron: true,
          onTap: () => _showDetails(context),
        );
      },
    );
  }

  Future<void> _showDetails(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    final List<String> duration = bus.arrivalStationTime.split(':');
    await showMcBottomSheet<void>(
      context: context,
      scrollable: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModalHeader(
            title: bus.lineName.isEmpty ? l10n.busInfo : bus.lineName,
          ),
          _BusStopTime(
            label: l10n.departureTime,
            station: bus.departureStation,
            time: bus.runTime,
          ),
          const SizedBox(height: 16),
          _BusStopTime(
            label: l10n.estimatedArrival,
            station: bus.arrivalStation,
            time: bus.arrivalTime,
          ),
          const SizedBox(height: 4),
          if (bus.arrivalStationTime.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              duration.length < 2
                  ? bus.arrivalStationTime
                  : l10n.arrivalStationTime(duration[0], duration[1]),
              style: context.mc.textMuted,
            ),
          ],
          if (bus.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(bus.description, style: context.mc.textMuted),
          ],
        ],
      ),
    );
  }
}

class _BusStopTime extends StatelessWidget {
  const _BusStopTime({
    required this.label,
    required this.station,
    required this.time,
  });

  final String label;
  final String station;
  final String time;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceBetween,
        overflowAlignment: OverflowBarAlignment.start,
        spacing: 16,
        overflowSpacing: 4,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Text(label, style: context.mc.textMuted),
              if (station.isNotEmpty)
                Text(
                  station,
                  style: context.mc.textBody.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Text(
            time.isEmpty ? '—' : time,
            style: TextStyle(
              color: context.mc.foreground,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'School bus timetable', size: Size(375, 812))
Widget schoolBusTimetablePreview() {
  final List<BusItem> trips = [
    for (final String time in ['08:00', '09:30', '12:10', '14:30', '17:20'])
      BusItem(
        lineName: '雁塔校区 → 长安校区',
        departureStation: '雁塔校区',
        arrivalStation: '长安校区',
        runTime: time,
        arrivalStationTime: '+00:45',
        description: '',
      ),
  ];
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _BusScheduleView(
      state: BusPageState(
        selectedDate: '2026-11-15',
        selectedCampus: '雁塔校区',
        campusOptions: const ['雁塔校区'],
        busData: trips,
        todayBusData: trips,
      ),
      dates: List.generate(7, (index) => DateTime(2026, 11, 15 + index)),
      onDateSelected: (_) {},
      onStationSelected: (_) {},
      onRefresh: () async {},
    ),
  );
}
