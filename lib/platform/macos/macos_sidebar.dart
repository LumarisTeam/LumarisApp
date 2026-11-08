import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';

/// 应用侧 macOS 侧边栏适配：负责窗口焦点和用户状态，界面由 luamris_ui 提供。
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
    return McSidebar(
      items: [
        for (final item in widget.items)
          McSidebarDestination(
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            label: item.label,
            badge: item.badge,
          ),
      ],
      selectedIndex: widget.selectedIndex,
      onItemSelected: widget.onItemSelected,
      isWindowFocused: _isWindowFocused,
      bottom: const _UserTile(),
    );
  }
}

/// 侧边栏底部的用户信息卡片，对应原 `Sidebar.bottom`。
class _UserTile extends ConsumerWidget {
  const _UserTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStoreProvider);
    final colors = context.mc.colors;
    return FutureBuilder<String>(
      future: _getUsername(userState.isLogin),
      builder: (context, snapshot) => McSidebarUserTile(
        title: snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : context.l10n.notLoggedIn,
        subtitle: userState.isLogin
            ? context.l10n.eduSystem
            : context.l10n.clickToLogin,
        onTap: () {
          if (userState.isLogin) {
            AppRouter.go(AppRoutes.profile);
          } else {
            AppRouter.push(AppRoutes.login);
          }
        },
        leading: Container(
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
