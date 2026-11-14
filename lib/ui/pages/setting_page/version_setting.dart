import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/app_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ios_club_app/features/system/update/check_update_manager.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

import '../../../core/utils/app_logger.dart';

class VersionSetting extends ConsumerStatefulWidget {
  const VersionSetting({super.key});

  @override
  ConsumerState<VersionSetting> createState() => _VersionSettingState();
}

class _VersionSettingState extends ConsumerState<VersionSetting> {
  late bool isNeedUpdate = false;
  late String version = '';
  late String buildNumber = '';
  ReleaseModel? latestRelease;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
        if (PlatformUtils.isAndroid) {
          CheckUpdateManager.checkForUpdates().then((res) {
            isNeedUpdate = res.$1;
            if (res.$1) {
              latestRelease = res.$2;
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.mc.colors;
    final l10n = context.l10n;

    return Column(
      children: [
        McListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          leading: isNeedUpdate
              ? Badge(
                  backgroundColor: colors.danger,
                  child: Icon(CupertinoIcons.arrow_down_circle, size: 20),
                )
              : Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  size: 20,
                  color: colors.success,
                ),
          title: Text(l10n.version),
          subtitle: Text(
            buildNumber.isEmpty ? version : '$version.$buildNumber',
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13,
            color: colors.secondaryLabel,
          ),
          onTap: () async {
            if (isNeedUpdate) {
              final result = await showMcConfirmDialog(
                context: context,
                title: l10n.confirmUpdateTitle(latestRelease?.name ?? ''),
                message: l10n.confirmUpdateContent,
                confirmText: l10n.goToBrowser,
                cancelText: l10n.dontUpdate,
              );

              if (result == true) {
                final release = latestRelease;
                if (release == null) {
                  return;
                }
                try {
                  await AppService.updateApp(release);
                  if (context.mounted) {
                    McFeedback.showMessage(context, message: l10n.updateOpened);
                  }
                } catch (error, stackTrace) {
                  AppLogger.error(
                    '打开更新链接失败',
                    error: error,
                    stackTrace: stackTrace,
                  );
                  if (context.mounted) {
                    McFeedback.showMessage(
                      context,
                      message: l10n.openUpdateFailed,
                    );
                  }
                }
              }
            }
          },
        ),
        if (CheckUpdateManager.shouldCheckForUpdates())
          McListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            leading: Icon(
              CupertinoIcons.arrow_down_circle,
              size: 20,
              color: colors.warning,
            ),
            title: Text(l10n.updateLog),
            subtitle: Text(l10n.ignoreVersionUpdate),
            subtitleTextStyle: TextStyle(
              fontSize: 12,
              color: colors.secondaryLabel,
            ),
            trailing: CupertinoSwitch(
              value: settings.updateIgnored,
              onChanged: (bool value) async {
                await settingsStore.setUpdateIgnored(value);
              },
            ),
          ),
      ],
    );
  }
}
