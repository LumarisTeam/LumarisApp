import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/settings_store.dart';

// 添加触觉反馈设置组件
class HapticFeedbackSetting extends ConsumerWidget {
  const HapticFeedbackSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return McListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        CupertinoIcons.device_phone_portrait,
        size: 20,
        color: Colors.deepPurple,
      ),
      title: Text(context.l10n.hapticFeedback),
      subtitle: Text(context.l10n.hapticFeedbackSubtitle),
      trailing: CupertinoSwitch(
        value: settings.enableHapticFeedback,
        onChanged: (bool value) async {
          await settingsStore.setEnableHapticFeedback(value);
        },
      ),
    );
  }
}
