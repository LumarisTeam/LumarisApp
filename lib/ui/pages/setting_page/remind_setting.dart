import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:numberpicker/numberpicker.dart';

class RemindSetting extends ConsumerWidget {
  const RemindSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.mc.colors;
    final l10n = context.l10n;

    return Column(
      children: [
        McListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: Icon(
            CupertinoIcons.clock_fill,
            size: 20,
            color: colors.success,
          ),
          title: Text(l10n.courseReminder),
          subtitle: Text(l10n.courseReminderSubtitle),
          trailing: CupertinoSwitch(
            value: settings.isRemind,
            onChanged: (bool value) async {
              if (!value) {
                await settingsStore.setIsRemind(false);
                return;
              }

              if (!context.mounted) {
                return;
              }

              final granted =
                  await NotificationService.ensureReminderPermission(context);
              if (granted) {
                await settingsStore.setIsRemind(true);
              }
            },
          ),
        ),
        settings.isRemind
            ? McListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                leading: const SizedBox(width: 24),
                title: Text(l10n.remindMinutesBefore),
                trailing: Text(l10n.remindMinutes(settings.remindTime)),
                onTap: () {
                  _show(context, ref);
                },
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _show(BuildContext context, WidgetRef ref) async {
    await showMcBottomSheet<void>(
      context: context,
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(settingsStoreProvider);
            final settingsStore = ref.read(settingsStoreProvider.notifier);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberPicker(
                    value: settings.remindTime,
                    minValue: 10,
                    maxValue: 120,
                    step: 1,
                    onChanged: (value) async {
                      await settingsStore.setRemindTime(value);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // 提前量修改后立即按新设置重排：否则系统里已经排好的闹钟
    // 还会按旧时间响，看起来就像“通知时间错乱”。
    if (!context.mounted) {
      return;
    }
    if (!ref.read(settingsStoreProvider).isRemind) {
      return;
    }
    await TaskExecutor.checkAndSendCourseReminder(force: true);
  }
}
