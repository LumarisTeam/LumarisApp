import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = context.mc.colors;

    // 定义颜色
    final bgColor = backgroundColor ?? colors.cardOverlay;
    final selectedColor = selectedItemColor ?? colorScheme.primary;
    final unselectedColor = unselectedItemColor ?? colors.secondaryLabel;

    return Container(
      decoration: BoxDecoration(color: bgColor),
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          destinations.length,
          (index) => _NavigationItem(
            destination: destinations[index],
            isSelected: selectedIndex == index,
            onTap: () {
              // if (settingsStore.enableHapticFeedback) {
              //   Feedback.forLongPress(context);
              // }
              onDestinationSelected(index);
            },
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatefulWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void _releasePress() {
    _pressController.animateBack(0, curve: const Cubic(0.23, 1, 0.32, 1));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color itemColor = widget.isSelected
        ? widget.selectedColor
        : widget.unselectedColor;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _pressController.value = 1,
        onTapUp: (_) => _releasePress(),
        onTapCancel: _releasePress,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            final double press = _pressController.value;
            return reduceMotion
                ? Opacity(opacity: 1 - 0.12 * press, child: child)
                : Transform.scale(scale: 1 - 0.03 * press, child: child);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(color: itemColor, size: 24),
                  child: widget.isSelected
                      ? widget.destination.selectedIcon ??
                            widget.destination.icon
                      : widget.destination.icon,
                ),
                const SizedBox(height: 4),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 11,
                    color: itemColor,
                    letterSpacing: 0.2,
                  ),
                  child: Text(
                    widget.destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
