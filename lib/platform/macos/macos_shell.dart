import 'package:flutter/material.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/platform/macos/macos_sidebar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// macOS 窗口外壳：左侧侧边栏 + 右侧内容区。
///
/// 取代 macos_ui 的 `MacosWindow`。标题栏交还系统原生绘制，因此这里只负责
/// 内容区布局和侧边栏宽度。
class MacosShell extends StatefulWidget {
  const MacosShell({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.initialWidth = 220,
    this.minWidth = 180,
    this.maxWidth = 280,
  });

  final Widget child;
  final List<SidebarDestination> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

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
  /// 拖到比 [MacosShell.minWidth] 再窄这么多的位置时收起侧边栏，
  /// 对应 macos_ui 的 `Sidebar.dragClosedBuffer`。
  static const double _dragClosedBuffer = 90;

  late double _width = widget.initialWidth;
  bool _visible = true;
  double _dragStartWidth = 0;
  double _dragStartX = 0;
  MouseCursor _cursor = SystemMouseCursors.resizeColumn;

  double get _visibleWidth => _visible ? _width : 0;

  void _handleDragStart(DragStartDetails details) {
    _dragStartWidth = _width;
    _dragStartX = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final newWidth = _dragStartWidth + details.globalPosition.dx - _dragStartX;
    final clampedWidth = newWidth.clamp(widget.minWidth, widget.maxWidth);

    setState(() {
      _visible = newWidth >= widget.minWidth - _dragClosedBuffer;
      _width = clampedWidth;
      if (_width == widget.minWidth) {
        _cursor = SystemMouseCursors.resizeRight;
      } else if (_width == widget.maxWidth) {
        _cursor = SystemMouseCursors.resizeLeft;
      } else {
        _cursor = SystemMouseCursors.resizeColumn;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // macos_ui 的 MacosWindow 会把 canvasColor（即 groupedBackground）铺满窗口，
    // 这里补上同样的底色，避免内容区之外出现透明区域。
    return ColoredBox(
      color: context.clubColors.groupedBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Row(
            children: [
              SizedBox(
                width: _visibleWidth,
                child: _visible
                    ? MacosSidebar(
                        items: widget.items,
                        selectedIndex: widget.selectedIndex,
                        onItemSelected: widget.onItemSelected,
                      )
                    : null,
              ),
              Expanded(child: widget.child),
            ],
          ),
          // 拖拽热区骑在侧边栏右边缘上，与 macos_ui 一样向内容区探出 3px。
          Positioned(
            top: 0,
            bottom: 0,
            left: _visibleWidth - 4,
            width: 7,
            child: MouseRegion(
              cursor: _cursor,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _handleDragStart,
                onHorizontalDragUpdate: _handleDragUpdate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
