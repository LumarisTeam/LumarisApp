import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/extensions/localization_extensions.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/sidebar_destination.dart';
import 'macos_sidebar.dart';

/// macOS 窗口外壳：左侧侧边栏 + 右侧内容区。
///
/// 顶部工具栏与系统红黄绿按钮共用一行，替代标准窗口标题栏。
/// 原生侧将内容扩展到透明标题栏，并为 Flutter 工具栏转发鼠标事件。
class MacosShell extends StatefulWidget {
  const MacosShell({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.toolbar,
    this.controller,
    this.initialWidth = 220,
    this.minWidth = 180,
    this.maxWidth = 280,
  });

  final Widget child;
  final List<SidebarDestination> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final PreferredSizeWidget? toolbar;
  final McSidebarController? controller;

  /// 侧边栏初始宽度。
  final double initialWidth;

  /// 侧边栏可拖拽到的最小宽度。
  final double minWidth;

  /// 侧边栏可拖拽到的最大宽度。
  final double maxWidth;

  @override
  State<MacosShell> createState() => _MacosShellState();
}

class _MacosShellState extends State<MacosShell> {
  McSidebarController? _ownedController;
  bool _canPop = false;

  McSidebarController get _controller =>
      widget.controller ?? (_ownedController ??= McSidebarController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  Future<void> _startWindowDrag(DragStartDetails _) async {
    try {
      await windowManager.startDragging();
    } catch (error) {
      AppLogger.error('拖动 macOS 窗口失败', error: error);
    }
  }

  Future<void> _toggleWindowZoom() async {
    try {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (error) {
      AppLogger.error('切换 macOS 窗口缩放失败', error: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    final controller = _controller;
    final toolbar =
        widget.toolbar ??
        PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: ListenableBuilder(
            listenable: Listenable.merge([controller, ?router?.routerDelegate]),
            builder: (context, _) {
              final l10n = context.l10n;
              final appTitle = l10n.appName;
              final canPop =
                  router?.canPop() ?? (ModalRoute.of(context)?.canPop ?? false);
              return McToolBar(
                title: Text(appTitle),
                automaticallyImplyLeading: false,
                // 与 MainFlutterWindow.swift 的原生窗口按钮预留区域一致。
                leadingWidth: 160,
                onBackgroundPanStart: _startWindowDrag,
                onBackgroundDoubleTap: _toggleWindowZoom,
                leading: Row(
                  children: [
                    const SizedBox(width: 80),
                    SizedBox(
                      width: 40,
                      child: McToolBarIconButton(
                        label: controller.isVisible
                            ? l10n.collapseSidebar
                            : l10n.expandSidebar,
                        icon: const Icon(CupertinoIcons.sidebar_left),
                        onPressed: controller.toggle,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: McToolBarIconButton(
                        label: l10n.back,
                        icon: const Icon(CupertinoIcons.chevron_back),
                        onPressed: canPop
                            ? () {
                                if (router != null) {
                                  router.pop();
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: toolbar.preferredSize.height, child: toolbar),
        Expanded(
          child: McSidebarShell(
            controller: controller,
            initialWidth: widget.initialWidth,
            minWidth: widget.minWidth,
            maxWidth: widget.maxWidth,
            sidebar: MacosSidebar(
              items: widget.items,
              selectedIndex: widget.selectedIndex,
              onItemSelected: widget.onItemSelected,
            ),
            // GoRouter 通知时分支 Navigator 可能尚未挂载或更新完毕，
            // 在导航栈实际更新后再刷新返回按钮（也覆盖直接打开详情页）。
            child: NotificationListener<NavigationNotification>(
              onNotification: (_) {
                final canPop =
                    router?.canPop() ??
                    (ModalRoute.of(context)?.canPop ?? false);
                if (_canPop != canPop) {
                  setState(() => _canPop = canPop);
                }
                return false;
              },
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
