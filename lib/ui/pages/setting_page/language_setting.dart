import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/app_action_sheet.dart';

class LanguageSetting extends ConsumerWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return McListTile(
      leading: Icon(CupertinoIcons.globe, size: 20, color: colors.primary),
      title: Text(l10n.language),
      subtitle: Text(AppLocaleService.labelOf(l10n, settings.localeCode)),
      showChevron: true,
      onTap: () => _showLanguagePicker(
        context: context,
        currentCode: settings.localeCode,
        onChanged: settingsStore.setLocaleCode,
      ),
    );
  }

  Future<void> _showLanguagePicker({
    required BuildContext context,
    required AppLocaleCode currentCode,
    required Future<void> Function(AppLocaleCode code) onChanged,
  }) async {
    final l10n = context.l10n;

    final selected = await showAppActionSheet<AppLocaleCode>(
      context: context,
      title: l10n.language,
      cancelLabel: l10n.cancel,
      items: [
        for (final option in AppLocaleService.options)
          AppActionSheetItem(
            value: option.code,
            label: option.labelBuilder(l10n),
            isSelected: option.code == currentCode,
          ),
      ],
    );

    if (selected != null) {
      await onChanged(selected);
    }
  }
}
