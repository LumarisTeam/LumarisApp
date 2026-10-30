import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

/// 底部操作菜单中的一项。
class AppActionSheetItem<T> {
  const AppActionSheetItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.isSelected = false,
  });

  /// 点击该项时由 [showAppActionSheet] 返回的值。
  final T value;

  final String label;

  final IconData? icon;

  /// 使用危险色显示（删除、退出等）。
  final bool isDestructive;

  /// 是否为当前选中项，选中项会高亮并显示勾选图标。
  final bool isSelected;
}

/// 基于 [showMcBottomSheet] 的 iOS 风格操作菜单。
///
/// 用它替代 `showCupertinoModalPopup` + `CupertinoActionSheet`，让全 app 的
/// 选择菜单共用同一套悬浮玻璃卡片、拖拽手柄，以及平板 / 桌面端的居中弹窗
/// 行为。
///
/// ```dart
/// final action = await showAppActionSheet<ThemeMode>(
///   context: context,
///   title: l10n.appearance,
///   cancelLabel: l10n.cancel,
///   items: [
///     AppActionSheetItem(value: ThemeMode.system, label: l10n.followSystem),
///     AppActionSheetItem(value: ThemeMode.light, label: l10n.light),
///   ],
/// );
/// ```
Future<T?> showAppActionSheet<T>({
  required BuildContext context,
  required List<AppActionSheetItem<T>> items,
  String? title,
  String? message,
  String? cancelLabel,
  double maxHeightFactor = 0.7,
}) {
  return showMcBottomSheet<T>(
    context: context,
    showHandle: true,
    contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
    maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
    scrollable: true,
    builder: (sheetContext) {
      final m = sheetContext.mc;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: m.foreground,
                      ),
                    ),
                  if (message != null) ...[
                    if (title != null) const SizedBox(height: 4),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: m.secondaryLabel),
                    ),
                  ],
                ],
              ),
            ),
          for (final item in items)
            McListTile(
              leading: item.icon == null
                  ? null
                  : Icon(item.icon, size: 20, color: _itemColor(m, item)),
              title: Text(item.label),
              titleTextStyle: TextStyle(
                color: _itemColor(m, item),
                fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              selected: item.isSelected,
              trailing: item.isSelected
                  ? Icon(CupertinoIcons.check_mark, size: 18, color: m.primary)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(item.value),
            ),
          if (cancelLabel != null) ...[
            const SizedBox(height: 8),
            McListTile(
              title: Text(cancelLabel, textAlign: TextAlign.center),
              titleTextStyle: TextStyle(
                color: m.primary,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ],
      );
    },
  );
}

Color _itemColor(McTheme m, AppActionSheetItem<Object?> item) {
  if (item.isDestructive) return m.destructive;
  if (item.isSelected) return m.primary;
  return m.foreground;
}
