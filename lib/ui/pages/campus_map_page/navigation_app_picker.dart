import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../core/services/external_navigation_service.dart';
import '../../../l10n/app_localizations.dart';

class NavigationAppPicker extends StatelessWidget {
  const NavigationAppPicker({super.key, required this.maps});

  final List<ExternalMap> maps;

  String _label(BuildContext context, ExternalMap map) {
    final l10n = context.l10n;
    return switch (map) {
      ExternalMap.apple => l10n.navigationAppleMaps,
      ExternalMap.google => l10n.navigationGoogleMaps,
      ExternalMap.amap => l10n.navigationAmap,
      ExternalMap.baidu => l10n.navigationBaiduMaps,
    };
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      shrinkWrap: true,
      children: [
        ListTile(title: Text(context.l10n.chooseNavigationApp)),
        for (final ExternalMap map in maps)
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: Text(_label(context, map)),
            onTap: () => Navigator.of(context).pop(map),
          ),
      ],
    ),
  );
}

@Preview(name: 'Navigation apps', size: Size(390, 360))
Widget navigationAppPickerPreview() => const MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: Locale('zh'),
  home: Scaffold(body: NavigationAppPicker(maps: ExternalMap.values)),
);
