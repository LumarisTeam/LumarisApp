import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: context.mc.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}
