import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

import '../../components/page_app_bar.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.mc.colors;
    return Scaffold(
      appBar: PageAppBar(title: l10n.easterEggTitle),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.hare_fill, size: 100, color: colors.warning),
              const SizedBox(height: 20),
              Text(
                l10n.easterEggFound,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.easterEggContent,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
