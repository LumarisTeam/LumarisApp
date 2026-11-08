import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({super.key, this.title, this.titleWidget, this.actions});

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final canPop =
        navigator.canPop() || (ModalRoute.of(context)?.canPop ?? false);

    return AppBar(
      title:
          titleWidget ??
          Text(
            title ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
      actions: actions,
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              icon: const Icon(CupertinoIcons.chevron_back),
              onPressed: () => navigator.maybePop(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    );
  }
}
