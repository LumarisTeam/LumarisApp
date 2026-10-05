import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:window_manager/window_manager.dart';

// 以下规格取自 macos_ui 2.2.2 的 `SidebarItemSize.large` 与 `_SidebarItem`，
// 并代入了 macOS 上的 `VisualDensity.compact`（即 (-2.0, -2.0)）。
// 写成字面量是为了让移除依赖后的外观与移除前逐像素一致。

/// `SidebarItemSize.large.height(36) + visualDensity.vertical(-2)`
const double _itemHeight = 34;

/// `10 + visualDensity.horizontal(-2)`
const double _itemSpacing = 8;

/// `EdgeInsets.symmetric(vertical: 7 + visualDensity.horizontal(-2), horizontal: _itemSpacing)`
const EdgeInsets _itemPadding = EdgeInsets.symmetric(
  vertical: 5,
  horizontal: _itemSpacing,
);

/// `EdgeInsets.all(10 - visualDensity.horizontal(-2))`
const EdgeInsets _listPadding = EdgeInsets.all(12);

/// `_defaultShape` 的圆角。
const double _selectedRadius = 5;

/// 应用显式传给图标的尺寸，覆盖 `SidebarItemSize.large.iconSize`。
const double _iconSize = 20;

/// macos_ui `MacosTypography` 的 `_kDefaultFontFamily`。
const String _macosFontFamily = '.AppleSystemUIFont';

/// macos_ui `typography.title3` 的 `letterSpacing`。
const double _labelLetterSpacing = -0.23;

/// macos_ui `typography.headline` 的 `letterSpacing`。
const double _titleLetterSpacing = -0.08;

/// macos_ui `typography.subheadline` 的 `letterSpacing`。
const double _subtitleLetterSpacing = 0.06;

/// macos_ui `MacosColors.labelColor`。
const Color _labelColorLight = Color.fromRGBO(0, 0, 0, 0.85);
const Color _labelColorDark = Color.fromRGBO(255, 255, 255, 0.85);

/// macos_ui `MacosColors.white`。
const Color _selectedForeground = Color(0xFFFFFFFF);

// macos_ui `_ColorProvider.getSelectedColor`，其 accentColor 被 ClubTheme 固定为
// `AccentColor.blue`（`MacosThemeData.light()/dark()` 的默认值）。
const Color _selectionLight = Color.fromRGBO(9, 129, 255, 0.749);
const Color _selectionDark = Color.fromRGBO(22, 105, 229, 0.749);
const Color _selectionInactiveLight = Color.fromRGBO(213, 213, 208, 1.0);
const Color _selectionInactiveDark = Color.fromRGBO(76, 78, 65, 1.0);

/// 窗口失焦时的选中态底色，复刻 macOS 原生行为。
Color _selectionColor({required bool isDark, required bool isWindowFocused}) {
  if (!isWindowFocused) {
    return isDark ? _selectionInactiveDark : _selectionInactiveLight;
  }
  return isDark ? _selectionDark : _selectionLight;
}

/// macOS 侧边栏。
///
/// 复刻 macos_ui `Sidebar` 在本项目中的具体用法：纯色背景、导航项列表、
/// 底部用户卡片。宽度由 [MacosShell] 控制。
class MacosSidebar extends StatefulWidget {
  const MacosSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<SidebarDestination> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  State<MacosSidebar> createState() => _MacosSidebarState();
}

class _MacosSidebarState extends State<MacosSidebar> with WindowListener {
  bool _isWindowFocused = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncWindowFocus();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncWindowFocus() async {
    final bool isFocused;
    try {
      isFocused = await windowManager.isFocused();
    } catch (e) {
      AppLogger.error('读取窗口焦点状态失败', error: e);
      return;
    }
    if (!mounted || isFocused == _isWindowFocused) {
      return;
    }
    setState(() {
      _isWindowFocused = isFocused;
    });
  }

  @override
  void onWindowFocus() {
    if (_isWindowFocused) {
      return;
    }
    setState(() {
      _isWindowFocused = true;
    });
  }

  @override
  void onWindowBlur() {
    if (!_isWindowFocused) {
      return;
    }
    setState(() {
      _isWindowFocused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTextStyle(
      // macos_ui 的 MacosApp 会在整个 macOS 应用外包一层 DefaultTextStyle，
      // 换成 MaterialApp 后没有了，而 MaterialApp 的兜底样式带着黄色双下划线
      // （专门用来提醒文字缺少 Material 祖先）。侧边栏本身不含 Scaffold/Material，
      // 必须自己提供基础样式，否则只设置了字号/颜色的 Text 会把下划线漏进来。
      style: TextStyle(
        color: isDark ? _labelColorDark : _labelColorLight,
        decoration: TextDecoration.none,
      ),
      child: ColoredBox(
        color: context.clubColors.groupedBackground,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: _listPadding,
                children: [
                  for (var index = 0; index < widget.items.length; index++)
                    _MacosSidebarItem(
                      destination: widget.items[index],
                      selected: widget.selectedIndex == index,
                      isWindowFocused: _isWindowFocused,
                      onTap: () => widget.onItemSelected(index),
                    ),
                ],
              ),
            ),
            const _UserTile(),
          ],
        ),
      ),
    );
  }
}

class _MacosSidebarItem extends StatelessWidget {
  const _MacosSidebarItem({
    required this.destination,
    required this.selected,
    required this.isWindowFocused,
    required this.onTap,
  });

  final SidebarDestination destination;
  final bool selected;
  final bool isWindowFocused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = _selectionColor(
      isDark: isDark,
      isWindowFocused: isWindowFocused,
    );

    // macos_ui 的 textLuminance：按底色亮度在纯黑/纯白之间取反。
    final labelColor = selected
        ? (selectedColor.computeLuminance() >= 0.5
              ? const Color(0xFF000000)
              : _selectedForeground)
        : (isDark ? _labelColorDark : _labelColorLight);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: FocusableActionDetector(
          descendantsAreFocusable: false,
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => onTap(),
            ),
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (_) => onTap(),
            ),
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.basic,
            child: Container(
              height: _itemHeight,
              padding: _itemPadding,
              decoration: ShapeDecoration(
                color: selected ? selectedColor : Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(_selectedRadius),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: _itemSpacing),
                    child: Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      size: _iconSize,
                      color: selected ? _selectedForeground : colors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: _macosFontFamily,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        letterSpacing: _labelLetterSpacing,
                        color: labelColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 侧边栏底部的用户信息卡片，对应原 `Sidebar.bottom`。
class _UserTile extends ConsumerWidget {
  const _UserTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStoreProvider);
    final colors = context.clubColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleStyle = TextStyle(
      fontFamily: _macosFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: _titleLetterSpacing,
      color: isDark ? _labelColorDark : _labelColorLight,
    );

    return Padding(
      // macos_ui 的 MacosWindow 会为 `Sidebar.bottom` 套一层 EdgeInsets.all(16)。
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.separator, width: 0.5)),
        ),
        padding: const EdgeInsets.only(top: 8),
        child: GestureDetector(
          onTap: () {
            AppRouter.go(AppRoutes.profile);
          },
          child: MouseRegion(
            cursor: MouseCursor.defer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: 18,
                    color: colors.onAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getUsername(userState.isLogin),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Text(
                              snapshot.data!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            );
                          }
                          return Text(
                            context.l10n.notLoggedIn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          );
                        },
                      ),
                      Text(
                        userState.isLogin
                            ? context.l10n.eduSystem
                            : context.l10n.clickToLogin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _macosFontFamily,
                          fontSize: 11,
                          letterSpacing: _subtitleLetterSpacing,
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> _getUsername(bool isLogin) async {
  final prefs = PrefsService.instance;
  final secureStorage = SecureStorageService.instance;
  var name = '';

  if (isLogin) {
    final iosName =
        await secureStorage.read(key: PrefsKeys.USERNAME) ??
        prefs.getString(PrefsKeys.USERNAME);
    if (iosName != null) {
      name = iosName;
    }
  }
  return name;
}
