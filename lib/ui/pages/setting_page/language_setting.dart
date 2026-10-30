import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/state/settings_store.dart';

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
    final colors = context.mc.colors;
    final brightness = colors.brightness;

    final selected = await showCupertinoModalPopup<AppLocaleCode>(
      context: context,
      builder: (popupContext) => MediaQuery(
        data: MediaQuery.of(
          popupContext,
        ).copyWith(platformBrightness: brightness),
        child: CupertinoActionSheet(
          title: Text(l10n.language),
          actions: [
            for (final option in AppLocaleService.options)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(popupContext).pop(option.code),
                child: _languageLabel(
                  label: option.labelBuilder(l10n),
                  isSelected: option.code == currentCode,
                  colors: colors,
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
      await onChanged(selected);
    }
  }

  Widget _languageLabel({
    required String label,
    required bool isSelected,
    required McColors colors,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.primary : colors.label,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (isSelected) ...[
          const SizedBox(width: 8),
          Icon(CupertinoIcons.check_mark, size: 18, color: colors.primary),
        ],
      ],
    );
  }
}
