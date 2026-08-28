import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/app_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ios_club_app/features/system/update/check_update_manager.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

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
  int tapCount = 0;
  DateTime? lastTapTime;

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

  void _handleTap() {
    final now = DateTime.now();
    if (lastTapTime == null ||
        now.difference(lastTapTime!) > const Duration(seconds: 1)) {
      // 重置计数器
      tapCount = 0;
    }

    tapCount++;
    lastTapTime = now;

    if (tapCount >= 5) {
      // 显示彩蛋页面
      AppRouter.push(AppRoutes.egg);

      // 重置计数器
      tapCount = 0;
      lastTapTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;
    final l10n = context.l10n;

    return Column(
      children: [
        ClubListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: isNeedUpdate
              ? Badge(
                  backgroundColor: colors.danger,
                  child: Icon(
                    Icons.update,
                    size: 20,
                  ),
                )
              : Icon(Icons.verified, size: 20, color: colors.success),
          title: Text(l10n.version),
          subtitle: Text(
            buildNumber.isEmpty ? version : '$version.$buildNumber',
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13,
            color: colors.secondaryLabel,
          ),
          onTap: () async {
            _handleTap(); // 处理点击事件

            if (isNeedUpdate) {
              final result = await PlatformDialog.showConfirmDialog(
                context,
                title: l10n.confirmUpdateTitle(latestRelease?.name ?? ''),
                content: l10n.confirmUpdateContent,
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
                    showClubSnackBar(
                      context,
                      Text(l10n.updateOpened),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showClubSnackBar(
                      context,
                      Text('${l10n.openUpdateFailed}: $e'),
                    );
                  }
                }
              }
            }
          },
        ),
        if (CheckUpdateManager.shouldCheckForUpdates())
          ClubListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: Icon(
              Icons.update,
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
