import 'package:flutter/widget_previews.dart';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../empty_widget.dart';

class ScheduleImportEmptyState extends StatelessWidget {
  const ScheduleImportEmptyState({super.key, required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyWidget(
      icon: CupertinoIcons.calendar,
      title: l10n.scheduleNotImported,
      subtitle: l10n.scheduleNotImportedHint,
      action: McButton.primary(
        onPressed: onImport,
        child: Text(l10n.importSchedule),
      ),
    );
  }
}

@Preview(name: 'Schedule import empty state', size: Size(320, 420))
Widget scheduleImportEmptyStatePreview() => MaterialApp(
  locale: const Locale('zh'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  theme: McThemeData.materialTheme(McColors.light),
  home: Scaffold(
    body: Center(child: ScheduleImportEmptyState(onImport: () {})),
  ),
);
