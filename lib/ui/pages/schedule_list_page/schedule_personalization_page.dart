import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_components.dart';

/// 课表个性化配置页。
///
/// 顶部是固定示例课表的预览（只在设置提交后刷新一次，拖动时不重建），
/// 下方集中管理参考实现的全部样式项。
class SchedulePersonalizationPage extends ConsumerStatefulWidget {
  const SchedulePersonalizationPage({super.key});

  @override
  ConsumerState<SchedulePersonalizationPage> createState() =>
      _SchedulePersonalizationPageState();
}

class _SchedulePersonalizationPageState
    extends ConsumerState<SchedulePersonalizationPage> {
  static final List<CourseModel> _demoCourses = <CourseModel>[
    CourseModel(
      courseName: '高等数学',
      room: 'A101',
      teachers: const ['张老师'],
      weekday: 1,
      startUnit: 1,
      endUnit: 2,
      campus: TimeService.caoTangCampus,
    ),
    CourseModel(
      courseName: '大学物理',
      room: 'B202',
      teachers: const ['李老师'],
      weekday: 1,
      startUnit: 3,
      endUnit: 4,
      campus: TimeService.caoTangCampus,
    ),
    CourseModel(
      courseName: '大学英语',
      room: 'C303',
      teachers: const ['王老师'],
      weekday: 3,
      startUnit: 3,
      endUnit: 4,
      campus: TimeService.caoTangCampus,
    ),
    CourseModel(
      courseName: '程序设计',
      room: 'D404',
      teachers: const ['赵老师'],
      weekday: 5,
      startUnit: 7,
      endUnit: 8,
      campus: TimeService.caoTangCampus,
    ),
    CourseModel(
      courseName: '模拟电子技术',
      room: 'E505',
      teachers: const ['钱老师'],
      weekday: 2,
      startUnit: 5,
      endUnit: 6,
      campus: TimeService.caoTangCampus,
    ),
    CourseModel(
      courseName: '数字电子技术',
      room: 'F606',
      teachers: const ['孙老师'],
      weekday: 2,
      startUnit: 5,
      endUnit: 6,
      campus: TimeService.caoTangCampus,
    ),
  ];

  late double _gridHeight;

  @override
  void initState() {
    super.initState();
    // 只读一次，后续不再 watch schedule store，避免拖动时联动重建真实课表页。
    _gridHeight = ref.read(scheduleStoreProvider).height;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsStoreProvider);
    final styleState = ref.watch(scheduleStyleStoreProvider);
    final weekStartDay = ref.watch(
      schoolStoreProvider.select(
        (value) => value.school?.weekStartDay ?? School.defaultWeekStartDay,
      ),
    );

    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final styleStore = ref.read(scheduleStyleStoreProvider.notifier);
    final themeIsDark = Theme.of(context).brightness == Brightness.dark;
    final wallpaperPath = settings.scheduleBackground == 'custom'
        ? settingsStore.backgroundImageFor(isDark: themeIsDark)
        : '';
    final previewIsDark = wallpaperPath.isNotEmpty
        ? (settingsStore.backgroundIsDarkFor(isDark: themeIsDark) ??
              themeIsDark)
        : themeIsDark;

    final visualStyle = ScheduleVisualStyle.from(
      styleState: styleState,
      showGrid: settings.showCourseGrid,
      cellHeight: _gridHeight,
      isDark: previewIsDark,
    );

    final preview = SchedulePreview(
      style: visualStyle,
      courses: _demoCourses,
      weekStartDate: WeekStartUtils.getWeekStart(DateTime.now(), weekStartDay),
      isDark: previewIsDark,
      wallpaperPath: wallpaperPath.isEmpty ? null : wallpaperPath,
      weekStartDay: weekStartDay,
    );

    final panel = _buildSettingsPanel(
      settings: settings,
      styleState: styleState,
      settingsStore: settingsStore,
      styleStore: styleStore,
    );

    return Scaffold(
      appBar: McAppBar(title: l10n.schedulePersonalization),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide =
                constraints.maxWidth >= 700 ||
                (constraints.maxWidth >= 600 &&
                    constraints.maxWidth > constraints.maxHeight);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                      child: preview,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                      child: panel,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.45,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: preview,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: panel,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsPanel({
    required SettingsState settings,
    required ScheduleStyleState styleState,
    required SettingsStore settingsStore,
    required ScheduleStyleStore styleStore,
  }) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: Text(l10n.resetToDefaultStyle),
            ),
          ),
          const SizedBox(height: 20),

          // 界面显示
          _sectionTitle(l10n.sectionInterface),
          McCard.grouped(
            child: Column(
              children: [
                _wallpaperTile(isDark: false, settingsStore: settingsStore),
                _wallpaperTile(isDark: true, settingsStore: settingsStore),
                _switchTile(
                  label: l10n.hideSectionTime,
                  value: styleState.hideSectionTime,
                  onChanged: styleStore.setHideSectionTime,
                ),
                _switchTile(
                  label: l10n.hideDateUnderDay,
                  value: styleState.hideDateUnderDay,
                  onChanged: styleStore.setHideDateUnderDay,
                ),
                _switchTile(
                  label: l10n.hideGridLines,
                  value: !settings.showCourseGrid,
                  onChanged: (value) => settingsStore.setShowCourseGrid(!value),
                ),
                _colorTile(
                  label: l10n.schedulePageTextColor,
                  color: styleState.pageTextColor,
                  onTap: () => _pickPageTextColor(styleStore),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 网格尺寸
          _sectionTitle(l10n.sectionGridSize),
          McCard.grouped(
            child: Column(
              children: [
                _CommitSlider(
                  label: l10n.gridHeight,
                  value: _gridHeight,
                  min: 40,
                  max: 120,
                  step: 1,
                  onCommit: _setGridHeight,
                ),
                _CommitSlider(
                  label: l10n.timeColumnWidth,
                  value: styleState.timeColumnWidth,
                  min: ScheduleStyleStore.minTimeColumnWidth,
                  max: ScheduleStyleStore.maxTimeColumnWidth,
                  step: 1,
                  onCommit: styleStore.setTimeColumnWidth,
                ),
                _CommitSlider(
                  label: l10n.topHeaderHeight,
                  value: styleState.headerHeight,
                  min: ScheduleStyleStore.minHeaderHeight,
                  max: ScheduleStyleStore.maxHeaderHeight,
                  step: 1,
                  onCommit: styleStore.setHeaderHeight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 课程块配置
          _sectionTitle(l10n.sectionCourseBlock),
          McCard.grouped(
            child: Column(
              children: [
                _colorTile(
                  label: l10n.courseBlockTextColor,
                  color: styleState.courseTextColor,
                  onTap: () => _pickCourseTextColor(styleStore),
                ),
                _switchTile(
                  label: l10n.showStartTime,
                  value: styleState.showStartTime,
                  onChanged: styleStore.setShowStartTime,
                ),
                _switchTile(
                  label: l10n.hideLocation,
                  value: styleState.hideLocation,
                  onChanged: styleStore.setHideLocation,
                ),
                _switchTile(
                  label: l10n.hideTeacher,
                  value: styleState.hideTeacher,
                  onChanged: styleStore.setHideTeacher,
                ),
                _switchTile(
                  label: l10n.textAlignCenterH,
                  value: styleState.centerHorizontally,
                  onChanged: styleStore.setCenterHorizontally,
                ),
                _switchTile(
                  label: l10n.textAlignCenterV,
                  value: styleState.centerVertically,
                  onChanged: styleStore.setCenterVertically,
                ),
                _buildBorderStyleSelector(styleState.borderStyle, styleStore),
                _CommitSlider(
                  label: l10n.fontScale,
                  value: styleState.fontScale,
                  min: ScheduleStyleStore.minFontScale,
                  max: ScheduleStyleStore.maxFontScale,
                  step: 0.1,
                  decimals: 1,
                  onCommit: styleStore.setFontScale,
                ),
                _CommitSlider(
                  label: l10n.cornerRadius,
                  value: styleState.cornerRadius,
                  min: ScheduleStyleStore.minCornerRadius,
                  max: ScheduleStyleStore.maxCornerRadius,
                  step: 1,
                  onCommit: styleStore.setCornerRadius,
                ),
                _CommitSlider(
                  label: l10n.innerPadding,
                  value: styleState.innerPadding,
                  min: ScheduleStyleStore.minInnerPadding,
                  max: ScheduleStyleStore.maxInnerPadding,
                  step: 1,
                  onCommit: styleStore.setInnerPadding,
                ),
                _CommitSlider(
                  label: l10n.outerPadding,
                  value: styleState.outerPadding,
                  min: ScheduleStyleStore.minOuterPadding,
                  max: ScheduleStyleStore.maxOuterPadding,
                  step: 1,
                  onCommit: styleStore.setOuterPadding,
                ),
                _CommitSlider(
                  label: l10n.opacity,
                  value: styleState.opacity,
                  min: ScheduleStyleStore.minOpacity,
                  max: ScheduleStyleStore.maxOpacity,
                  step: 0.05,
                  decimals: 2,
                  onCommit: styleStore.setOpacity,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 颜色方案
          _sectionTitle(l10n.sectionColorScheme),
          ScheduleColorPoolCard(
            key: const ValueKey('schedule-color-pool-card-light'),
            isDarkPool: false,
            title: l10n.lightColorPool,
          ),
          const SizedBox(height: 12),
          ScheduleColorPoolCard(
            key: const ValueKey('schedule-color-pool-card-dark'),
            isDarkPool: true,
            title: l10n.darkColorPool,
          ),
        ],
      ),
    );
  }

  void _setGridHeight(double value) {
    setState(() => _gridHeight = value);
    unawaited(
      ref.read(scheduleStoreProvider.notifier).commitCourseHeight(value),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: context.mc.colors.primary,
        ),
      ),
    );
  }

  Widget _wallpaperTile({
    required bool isDark,
    required SettingsStore settingsStore,
  }) {
    final l10n = context.l10n;
    final colors = context.mc.colors;
    final path = settingsStore.backgroundImageFor(isDark: isDark);
    final hasWallpaper =
        settingsStore.hasBackgroundFor(isDark: isDark) && path.isNotEmpty;

    return McListTile(
      leading: Icon(Icons.image_outlined, color: colors.primary),
      title: Text(
        '${l10n.scheduleWallpaper} · '
        '${isDark ? l10n.wallpaperEditingDark : l10n.wallpaperEditingLight}',
      ),
      subtitle: Text(
        hasWallpaper ? l10n.wallpaperClearHint : l10n.wallpaperTapHint,
      ),
      trailing: Icon(
        hasWallpaper ? Icons.check_circle : Icons.circle_outlined,
        color: hasWallpaper ? colors.primary : colors.tertiaryLabel,
      ),
      onTap: () => pickScheduleBackgroundImage(context, ref, isDark: isDark),
      onLongPress: () => clearScheduleBackgroundImage(ref, isDark: isDark),
    );
  }

  Widget _switchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return McListTile(
      title: Text(label),
      trailing: CupertinoSwitch(value: value, onChanged: onChanged),
    );
  }

  Widget _colorTile({
    required String label,
    required Color? color,
    required VoidCallback onTap,
  }) {
    final colors = context.mc.colors;
    return McListTile(
      title: Text(label),
      trailing: color == null
          ? Text(
              context.l10n.notSet,
              style: TextStyle(fontSize: 13, color: colors.tertiaryLabel),
            )
          : Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: colors.separator, width: 0.5),
              ),
            ),
      onTap: onTap,
    );
  }

  Widget _buildBorderStyleSelector(
    ScheduleBorderStyle value,
    ScheduleStyleStore styleStore,
  ) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(l10n.borderStyle),
          ),
          CupertinoSlidingSegmentedControl<ScheduleBorderStyle>(
            groupValue: value,
            onValueChanged: (next) {
              if (next != null) styleStore.setBorderStyle(next);
            },
            children: {
              ScheduleBorderStyle.none: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(l10n.borderStyleNone),
              ),
              ScheduleBorderStyle.solid: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(l10n.borderStyleSolid),
              ),
              ScheduleBorderStyle.dashed: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(l10n.borderStyleDashed),
              ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final l10n = context.l10n;
    final confirmed = await showMcDialog<bool>(
      context: context,
      title: l10n.resetStyleConfirmTitle,
      content: Text(l10n.resetStyleConfirmMessage),
      actions: [
        McDialogAction<bool>(label: l10n.cancel, value: false),
        McDialogAction<bool>(
          label: l10n.confirm,
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    await ref.read(scheduleStyleStoreProvider.notifier).resetToDefaults();
    await ref.read(scheduleStoreProvider.notifier).setCourseHeight(55);
    await ref.read(settingsStoreProvider.notifier).setShowCourseGrid(false);

    if (mounted) {
      setState(() => _gridHeight = 55);
      McFeedback.showMessage(context, message: l10n.resetToDefaultStyle);
    }
  }

  void _pickPageTextColor(ScheduleStyleStore styleStore) {
    final current = ref.read(scheduleStyleStoreProvider).pageTextColor;
    showScheduleColorPicker(
      context: context,
      title: context.l10n.schedulePageTextColor,
      initialColor: current ?? Theme.of(context).colorScheme.primary,
      onChanged: styleStore.setPageTextColor,
      onReset: () => styleStore.setPageTextColor(null),
      resetLabel: context.l10n.useTheme,
    );
  }

  void _pickCourseTextColor(ScheduleStyleStore styleStore) {
    final current = ref.read(scheduleStyleStoreProvider).courseTextColor;
    showScheduleColorPicker(
      context: context,
      title: context.l10n.courseBlockTextColor,
      initialColor: current ?? Theme.of(context).colorScheme.primary,
      onChanged: styleStore.setCourseTextColor,
      onReset: () => styleStore.setCourseTextColor(null),
      resetLabel: context.l10n.useTheme,
    );
  }
}

class _CommitSlider extends StatefulWidget {
  const _CommitSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onCommit,
    this.decimals = 0,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final int decimals;
  final ValueChanged<double> onCommit;

  @override
  State<_CommitSlider> createState() => _CommitSliderState();
}

class _CommitSliderState extends State<_CommitSlider> {
  late double _value;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _CommitSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  String _format(double value) {
    if (widget.decimals <= 0) return value.round().toString();
    return value.toStringAsFixed(widget.decimals);
  }

  void _commit(double value) {
    final clamped = value.clamp(widget.min, widget.max).toDouble();
    final steps = ((clamped - widget.min) / widget.step).round();
    final snapped = (widget.min + steps * widget.step)
        .clamp(widget.min, widget.max)
        .toDouble();
    setState(() => _value = snapped);
    widget.onCommit(snapped);
  }

  Future<void> _showInputDialog() async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: _format(_value));
    final confirmed = await showMcDialog<bool>(
      context: context,
      title: widget.label,
      content: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_format(widget.min)} – ${_format(widget.max)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.mc.colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              placeholder: l10n.inputValue,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        McDialogAction<bool>(label: l10n.cancel, value: false),
        McDialogAction<bool>(label: l10n.confirm, value: true),
      ],
    );

    if (confirmed == true) {
      final parsed = double.tryParse(controller.text.trim());
      if (parsed != null) _commit(parsed);
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label),
              GestureDetector(
                onTap: _showInputDialog,
                child: Text(
                  _format(_value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _value.clamp(widget.min, widget.max).toDouble(),
            min: widget.min,
            max: widget.max,
            divisions: ((widget.max - widget.min) / widget.step)
                .round()
                .clamp(1, 1000)
                .toInt(),
            onChangeStart: (_) => _dragging = true,
            onChanged: (value) => setState(() => _value = value),
            onChangeEnd: (value) {
              _dragging = false;
              _commit(value);
            },
          ),
        ],
      ),
    );
  }
}
