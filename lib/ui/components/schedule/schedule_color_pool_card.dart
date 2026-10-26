import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/schedule_color_themes.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_color_picker.dart';

/// 单个课表颜色池卡片。
///
/// 一级交互是顶部主题选择行（内置 Catppuccin flavor / 自定义主题）；
/// 二级交互是卡片内展开的颜色编辑器。内置主题只读，需先复制为自定义主题。
class ScheduleColorPoolCard extends ConsumerStatefulWidget {
  const ScheduleColorPoolCard({
    super.key,
    required this.isDarkPool,
    required this.title,
  });

  final bool isDarkPool;
  final String title;

  @override
  ConsumerState<ScheduleColorPoolCard> createState() =>
      _ScheduleColorPoolCardState();
}

class _ScheduleColorPoolCardState extends ConsumerState<ScheduleColorPoolCard> {
  static const String _newThemeSentinel = '__new_custom_theme__';

  bool _expanded = false;

  bool get _isDark => widget.isDarkPool;
  String get _suffix => _isDark ? 'dark' : 'light';

  @override
  Widget build(BuildContext context) {
    final styleState = ref.watch(scheduleStyleStoreProvider);
    final themeId = _isDark
        ? styleState.darkColorPoolThemeId
        : styleState.lightColorPoolThemeId;
    final colors = _isDark
        ? styleState.darkColorPool
        : styleState.lightColorPool;
    final isBuiltIn = ScheduleColorThemeCatalog.isBuiltIn(themeId);
    final themeName = ScheduleColorThemeCatalog.nameFor(
      themeId,
      styleState.customColorPoolThemes,
    );
    final foreground = _isDark ? Colors.white : Colors.black;
    final background = _isDark ? McColors.dark.card : McColors.light.card;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: McRadii.cardBorder,
        border: Border.all(
          color: foreground.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
          const SizedBox(height: 10),
          _buildThemeSelector(themeName, foreground),
          const SizedBox(height: 12),
          _buildSwatchStrip(themeId, colors, isBuiltIn, foreground),
          const SizedBox(height: 10),
          _buildEditToggle(colors.length, foreground),
          if (_expanded) ...[
            const SizedBox(height: 6),
            if (isBuiltIn)
              _buildBuiltInEditor(foreground)
            else
              _buildCustomEditor(themeId, colors, themeName, foreground),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeSelector(String themeName, Color foreground) {
    return GestureDetector(
      key: ValueKey('schedule-color-theme-selector-$_suffix'),
      behavior: HitTestBehavior.opaque,
      onTap: _openThemePicker,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              context.l10n.colorTheme,
              style: TextStyle(
                fontSize: 12,
                color: foreground.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                themeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: foreground.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwatchStrip(
    String themeId,
    List<Color> colors,
    bool isBuiltIn,
    Color foreground,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(colors.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == colors.length - 1 ? 0 : 14,
            ),
            child: Column(
              children: [
                GestureDetector(
                  key: ValueKey('schedule-color-pool-$_suffix-$index'),
                  onTap: isBuiltIn
                      ? null
                      : () => _pickColor(themeId, index, colors[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: foreground.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: foreground.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEditToggle(int count, Color foreground) {
    final l10n = context.l10n;
    return GestureDetector(
      key: ValueKey('schedule-color-pool-edit-toggle-$_suffix'),
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    l10n.editColorPool,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: foreground.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.colorCount(count),
                  style: TextStyle(
                    fontSize: 11,
                    color: foreground.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: foreground.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuiltInEditor(Color foreground) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.builtInThemeReadOnly,
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: foreground.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        _buildActionRow(
          key: ValueKey('schedule-color-theme-copy-$_suffix'),
          icon: CupertinoIcons.square_on_square,
          label: l10n.copyAsCustomTheme,
          color: foreground,
          onTap: _copyAsCustom,
        ),
      ],
    );
  }

  Widget _buildCustomEditor(
    String themeId,
    List<Color> colors,
    String themeName,
    Color foreground,
  ) {
    final l10n = context.l10n;
    final danger = _isDark ? McColors.dark.danger : McColors.light.danger;
    final canRemove = colors.length > ScheduleStyleStore.minThemeColorCount;
    final canAdd = colors.length < ScheduleStyleStore.maxThemeColorCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(colors.length, (index) {
          return _buildColorRow(
            themeId: themeId,
            color: colors[index],
            index: index,
            foreground: foreground,
            danger: danger,
            canRemove: canRemove,
          );
        }),
        if (!canRemove)
          Padding(
            padding: const EdgeInsets.only(left: 38, bottom: 4),
            child: Text(
              l10n.minOneColorHint,
              style: TextStyle(
                fontSize: 11,
                color: foreground.withValues(alpha: 0.5),
              ),
            ),
          ),
        _buildActionRow(
          key: ValueKey('schedule-color-pool-$_suffix-add'),
          icon: CupertinoIcons.add,
          label: l10n.addColor,
          color: foreground,
          onTap: canAdd ? () => _addColor(themeId, colors.length) : null,
          hint: canAdd
              ? null
              : l10n.maxColorLimitHint(ScheduleStyleStore.maxThemeColorCount),
        ),
        _buildActionRow(
          key: ValueKey('schedule-color-theme-rename-$_suffix'),
          icon: CupertinoIcons.pencil,
          label: l10n.renameTheme,
          color: foreground,
          onTap: () => _renameTheme(themeId, themeName),
        ),
        _buildActionRow(
          key: ValueKey('schedule-color-theme-delete-$_suffix'),
          icon: CupertinoIcons.delete,
          label: l10n.deleteTheme,
          color: danger,
          onTap: () => _deleteTheme(themeId, themeName),
        ),
      ],
    );
  }

  Widget _buildColorRow({
    required String themeId,
    required Color color,
    required int index,
    required Color foreground,
    required Color danger,
    required bool canRemove,
  }) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: foreground.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hexLabel(color),
              style: TextStyle(
                fontSize: 13,
                color: foreground.withValues(alpha: 0.8),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _buildIconButton(
            key: ValueKey('schedule-color-pool-$_suffix-edit-$index'),
            icon: CupertinoIcons.pencil,
            label: l10n.editColor,
            color: foreground.withValues(alpha: 0.7),
            onTap: () => _pickColor(themeId, index, color),
          ),
          const SizedBox(width: 4),
          _buildIconButton(
            key: ValueKey('schedule-color-pool-$_suffix-delete-$index'),
            icon: CupertinoIcons.delete,
            label: l10n.deleteColor,
            color: canRemove ? danger : danger.withValues(alpha: 0.3),
            onTap: canRemove ? () => _removeColor(themeId, index) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required Key key,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    String? hint,
  }) {
    final enabledColor = onTap == null ? color.withValues(alpha: 0.3) : color;
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 18, color: enabledColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onTap == null ? color.withValues(alpha: 0.4) : color,
                ),
              ),
            ),
            if (hint != null)
              Text(
                hint,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required Key key,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Future<void> _openThemePicker() async {
    final styleState = ref.read(scheduleStyleStoreProvider);
    final activeId = _isDark
        ? styleState.darkColorPoolThemeId
        : styleState.lightColorPoolThemeId;
    final customThemes = styleState.customColorPoolThemes;

    final selected = await showMcBottomSheet<String>(
      context: context,
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return Column(
          key: const ValueKey('schedule-color-theme-picker'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.colorTheme,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _themeSectionTitle('Lumaris / Catppuccin'),
            ...ScheduleColorThemeCatalog.builtInIds.map((id) {
              return McListTile(
                key: ValueKey('schedule-color-theme-option-$id'),
                leading: _palettePreview(
                  ScheduleColorThemeCatalog.accentsById[id]!,
                ),
                title: Text(ScheduleColorThemeCatalog.displayNames[id]!),
                trailing: activeId == id
                    ? Icon(
                        CupertinoIcons.check_mark,
                        size: 18,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(id),
              );
            }),
            if (customThemes.isNotEmpty) ...[
              const SizedBox(height: 14),
              _themeSectionTitle(l10n.customThemes),
              ...customThemes.entries.map((entry) {
                return McListTile(
                  key: ValueKey('schedule-color-theme-option-${entry.key}'),
                  leading: _palettePreview(entry.value.colors),
                  title: Text(
                    entry.value.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(l10n.colorCount(entry.value.colors.length)),
                  trailing: activeId == entry.key
                      ? Icon(
                          CupertinoIcons.check_mark,
                          size: 18,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(entry.key),
                );
              }),
            ],
            const SizedBox(height: 12),
            McListTile(
              key: const ValueKey('schedule-color-theme-new'),
              leading: const Icon(CupertinoIcons.add),
              title: Text(l10n.newCustomTheme),
              onTap: () => Navigator.of(sheetContext).pop(_newThemeSentinel),
            ),
          ],
        );
      },
    );

    if (selected == null || !mounted) return;
    if (selected == _newThemeSentinel) {
      await _createCustomTheme();
      return;
    }

    await ref
        .read(scheduleStyleStoreProvider.notifier)
        .applyColorPoolTheme(isDark: _isDark, themeId: selected);
  }

  Widget _themeSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.mc.colors.secondaryLabel,
        ),
      ),
    );
  }

  Widget _palettePreview(List<Color> colors) {
    final previewColors = colors.take(4).toList();
    return SizedBox(
      width: 21,
      height: 21,
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: previewColors
            .map(
              (color) => Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _createCustomTheme() async {
    final styleState = ref.read(scheduleStyleStoreProvider);
    final activeId = _isDark
        ? styleState.darkColorPoolThemeId
        : styleState.lightColorPoolThemeId;
    final activeName = ScheduleColorThemeCatalog.nameFor(
      activeId,
      styleState.customColorPoolThemes,
    );

    final name = await _promptThemeName(
      title: context.l10n.newCustomTheme,
      initialValue: context.l10n.copyThemeName(activeName),
    );
    if (name == null || !mounted) return;

    final id = await ref
        .read(scheduleStyleStoreProvider.notifier)
        .copyActivePoolThemeAsCustom(isDark: _isDark, name: name);
    if (!mounted) return;

    if (id == null) {
      McFeedback.showMessage(
        context,
        message: context.l10n.colorThemeNameDuplicate,
      );
      return;
    }
    setState(() => _expanded = true);
  }

  Future<void> _copyAsCustom() async {
    final styleState = ref.read(scheduleStyleStoreProvider);
    final activeId = _isDark
        ? styleState.darkColorPoolThemeId
        : styleState.lightColorPoolThemeId;
    final activeName = ScheduleColorThemeCatalog.nameFor(
      activeId,
      styleState.customColorPoolThemes,
    );

    final name = await _promptThemeName(
      title: context.l10n.copyAsCustomTheme,
      initialValue: context.l10n.copyThemeName(activeName),
    );
    if (name == null || !mounted) return;

    final id = await ref
        .read(scheduleStyleStoreProvider.notifier)
        .copyActivePoolThemeAsCustom(isDark: _isDark, name: name);
    if (!mounted) return;

    if (id == null) {
      McFeedback.showMessage(
        context,
        message: context.l10n.colorThemeNameDuplicate,
      );
      return;
    }
    setState(() => _expanded = true);
  }

  Future<void> _renameTheme(String themeId, String currentName) async {
    final name = await _promptThemeName(
      title: context.l10n.renameTheme,
      initialValue: currentName,
      excludingId: themeId,
    );
    if (name == null || !mounted || name == currentName) return;

    final renamed = await ref
        .read(scheduleStyleStoreProvider.notifier)
        .renameCustomColorTheme(id: themeId, name: name);
    if (!mounted || renamed) return;

    McFeedback.showMessage(
      context,
      message: context.l10n.colorThemeNameDuplicate,
    );
  }

  Future<void> _deleteTheme(String themeId, String themeName) async {
    final l10n = context.l10n;
    final confirmed = await showMcDialog<bool>(
      context: context,
      title: l10n.deleteTheme,
      content: Text(l10n.deleteThemeConfirmMessage(themeName)),
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

    final deleted = await ref
        .read(scheduleStyleStoreProvider.notifier)
        .deleteCustomColorTheme(themeId);
    if (!mounted) return;
    if (deleted) setState(() => _expanded = false);
  }

  Future<String?> _promptThemeName({
    required String title,
    String? initialValue,
    String? excludingId,
  }) async {
    final l10n = context.l10n;
    var currentValue = initialValue;

    while (mounted) {
      final raw = await showMcInputDialog(
        context: context,
        title: title,
        hintText: l10n.colorThemeNameHint,
        initialValue: currentValue,
        cancelText: l10n.cancel,
        confirmText: l10n.confirm,
      );
      if (raw == null || !mounted) return null;

      final name = raw.trim();
      if (name.isEmpty) {
        McFeedback.showMessage(context, message: l10n.colorThemeNameRequired);
        currentValue = raw;
        continue;
      }
      if (name.length > ScheduleStyleStore.maxThemeNameLength) {
        McFeedback.showMessage(
          context,
          message: l10n.colorThemeNameTooLong(
            ScheduleStyleStore.maxThemeNameLength,
          ),
        );
        currentValue = raw;
        continue;
      }
      if (!ref
          .read(scheduleStyleStoreProvider.notifier)
          .isColorThemeNameAvailable(name, excludingId: excludingId)) {
        McFeedback.showMessage(context, message: l10n.colorThemeNameDuplicate);
        currentValue = raw;
        continue;
      }
      return name;
    }
    return null;
  }

  void _pickColor(String themeId, int index, Color color) {
    final store = ref.read(scheduleStyleStoreProvider.notifier);
    showScheduleColorPicker(
      context: context,
      title: '${widget.title} ${index + 1}',
      initialColor: color,
      onChanged: (value) => store.setCustomColorThemeColor(
        id: themeId,
        index: index,
        color: value,
      ),
    );
  }

  Future<void> _addColor(String themeId, int count) async {
    final defaultPool = ScheduleColorThemeCatalog.defaultColorPool;
    final seed = defaultPool[count % defaultPool.length];
    final index = await ref
        .read(scheduleStyleStoreProvider.notifier)
        .addCustomColorThemeColor(id: themeId, seedColor: seed);
    if (!mounted || index == null) return;

    final colors = ref
        .read(scheduleStyleStoreProvider)
        .customColorPoolThemes[themeId]
        ?.colors;
    if (colors == null || index >= colors.length) return;
    _pickColor(themeId, index, colors[index]);
  }

  Future<void> _removeColor(String themeId, int index) async {
    await ref
        .read(scheduleStyleStoreProvider.notifier)
        .removeCustomColorThemeColor(id: themeId, index: index);
  }

  static String _hexLabel(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
