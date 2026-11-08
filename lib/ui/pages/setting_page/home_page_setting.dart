import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../state/settings_store.dart';

class HomePageSetting extends ConsumerWidget {
  const HomePageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final pageNames = [
      l10n.home,
      l10n.schedulePage,
      l10n.scorePage,
      l10n.profilePage,
    ];

    return McListTile(
      leading: Icon(Icons.pageview, size: 20, color: colors.primary),
      title: Text(l10n.firstPageOnLaunch),
      trailing: Text(pageNames[settings.pageIndex]),
      onTap: () async {
        final selected = await showCupertinoModalPopup<int>(
          context: context,
          builder: (popupContext) => MediaQuery(
            data: MediaQuery.of(
              popupContext,
            ).copyWith(platformBrightness: colors.brightness),
            child: CupertinoActionSheet(
              title: Text(l10n.firstPageOnLaunch),
              actions: [
                for (var index = 0; index < pageNames.length; index++)
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(popupContext).pop(index),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pageNames[index],
                          style: TextStyle(
                            color: index == settings.pageIndex
                                ? colors.primary
                                : colors.label,
                            fontWeight: index == settings.pageIndex
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (index == settings.pageIndex) ...[
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.check_mark,
                            size: 18,
                            color: colors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(popupContext).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ),
        );
        if (selected != null) {
          await settingsStore.setPageIndex(selected);
        }
      },
    );
  }
}
