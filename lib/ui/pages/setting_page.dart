import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/pages/settingPages/version_setting.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/widget_settings_service.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

import 'package:ios_club_app/ui/pages/settingPages/show_tomorrow_setting.dart';
import 'package:ios_club_app/ui/pages/settingPages/remind_setting.dart';

import 'package:ios_club_app/ui/pages/settingPages/home_page_setting.dart';
import 'package:ios_club_app/ui/pages/settingPages/font_family_setting.dart';
import 'package:ios_club_app/ui/pages/settingPages/language_setting.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.clubColors;
    final userState = ref.watch(userStoreProvider);
    final userStore = ref.read(userStoreProvider.notifier);
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return Scaffold(
      appBar: ClubAppBar(
        title: context.l10n.settings,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final horizontalPadding = isTablet ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildAppHeader(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, context.l10n.basicSettings),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildRefreshTile(context, ref),
                  _buildThemeModeTile(context, settings, settingsStore),
                  const LanguageSetting(),
                  const ShowTomorrowSetting(),
                  if (PlatformUtils.isMobile) const RemindSetting(),
                  // const TodoRemindSetting(),
                  const HomePageSetting(),
                  if (PlatformUtils.isDesktop && !PlatformUtils.isMacOS)
                    const FontFamilySetting(),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.version),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  const VersionSetting(),
                ]),
                const SizedBox(height: 24),
                if (PlatformUtils.isMobile)
                  _buildSectionTitle(context, context.l10n.widgets),
                if (PlatformUtils.isMobile) const SizedBox(height: 12),
                if (PlatformUtils.isMobile)
                  _buildSettingsGroup([
                    _buildWidgetTile(context),
                  ]),
                if (PlatformUtils.isMobile) const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.about),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildTeamTile(context),
                  _buildLicenseTile(context),
                  _buildPrivacyPolicyTile(context),
                  _buildUserAgreementTile(context),
                  _buildICPTile(context)
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.other),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildClearCacheTile(context, ref),
                  if (userState.isLogin) _buildLogoutTile(context, userStore),
                  ClubListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Icon(
                      CupertinoIcons.grid,
                      size: 20,
                      color: colors.tertiaryLabel,
                    ),
                    title: Text(context.l10n.showCourseGrid),
                    trailing: CupertinoSwitch(
                      value: settings.showCourseGrid,
                      onChanged: (value) {
                        settingsStore.setShowCourseGrid(value);
                      },
                    ),
                  ),
                  if (kDebugMode)
                    ClubListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Icon(
                        CupertinoIcons.checkmark_shield,
                        size: 20,
                        color: colors.warning,
                      ),
                      title: Text(context.l10n.agreementAuthDebug),
                      subtitle: Text(context.l10n.agreementAuthDebugSubtitle),
                      subtitleTextStyle: const TextStyle(fontSize: 12),
                      trailing: CupertinoSwitch(
                        value: settings.hasAcceptedAgreement,
                        onChanged: (value) {
                          settingsStore.setHasAcceptedAgreement(value);
                        },
                      ),
                    ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    final colors = context.clubColors;

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: ShapeDecoration(
            shape: ClubSmoothCorners.shape(ClubRadii.tile),
            shadows: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClubSmoothCorners.clip(
            borderRadius: ClubRadii.tile,
            child: const Image(
              image: AssetImage('assets/icon.webp'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.appName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colors.label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.appSlogan,
          style: TextStyle(
            fontSize: 14,
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.clubColors;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: colors.secondaryLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return ClubCard(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRefreshTile(BuildContext context, WidgetRef ref) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.refresh,
        size: 20,
        color: context.clubColors.primary,
      ),
      title: Text(context.l10n.refreshData),
      showChevron: true,
      onTap: () async {
        showClubSnackBar(context, Text(context.l10n.refreshingData));
        final refreshResult =
            await ref.read(educationSessionCoordinatorProvider).refresh();
        final refreshed = refreshResult.isSuccess;
        if (refreshed) {
          await _syncHomeWidget();
        }
        if (context.mounted) {
          showClubSnackBar(
            context,
            Text(
              refreshed
                  ? context.l10n.refreshDataSuccess
                  : context.l10n.refreshDataFailed,
            ),
          );
        }
      },
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    SettingsState settings,
    SettingsStore settingsStore,
  ) {
    final colors = context.clubColors;

    return ClubListTile(
      leading: Icon(
        CupertinoIcons.moon_stars,
        size: 20,
        color: colors.primary,
      ),
      title: Text(context.l10n.appearance),
      subtitle: Text(_themeModeLabel(context, settings.themeMode)),
      showChevron: true,
      onTap: () => _showThemeModePicker(context, settingsStore),
    );
  }

  Future<void> _syncHomeWidget() async {
    if (PlatformUtils.isAndroid) {
      await BackgroundService.updateWidget();
      return;
    }

    if (PlatformUtils.isIOS) {
      await IOSBackgroundService.updateWidget();
    }
  }

  Widget _buildTeamTile(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.person_2_fill,
        size: 20,
        color: context.clubColors.warning,
      ),
      title: Text(context.l10n.team),
      subtitle: Text(context.l10n.teamName),
      onTap: () {
        AppRouter.push(AppRoutes.author);
      },
    );
  }

  Widget _buildLicenseTile(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.doc_text_fill,
        size: 20,
        color: context.clubColors.success,
      ),
      title: Text(context.l10n.openSourceLicense),
      subtitle: Text(context.l10n.mitLicense),
      onTap: () {
        AppRouter.push(AppRoutes.license);
      },
    );
  }

  Widget _buildICPTile(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.checkmark_shield_fill,
        size: 20,
        color: context.clubColors.success,
      ),
      title: Text(context.l10n.icp),
      subtitle: Text("陕ICP备2024031872号-2A"),
      onTap: () async {
        final Uri url = Uri.parse('https://beian.miit.gov.cn/');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      },
    );
  }

  Widget _buildPrivacyPolicyTile(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.shield_fill,
        size: 20,
        color: context.clubColors.primary,
      ),
      title: Text(context.l10n.privacyPolicy),
      subtitle: Text(context.l10n.privacyPolicySubtitle),
      onTap: () {
        AppRouter.push(AppRoutes.privacyPolicy);
      },
    );
  }

  Widget _buildUserAgreementTile(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.doc_text_fill,
        size: 20,
        color: context.clubColors.purple,
      ),
      title: Text(context.l10n.userAgreement),
      subtitle: Text(context.l10n.userAgreementSubtitle),
      onTap: () {
        AppRouter.push(AppRoutes.userAgreement);
      },
    );
  }

  Widget _buildLogoutTile(
    BuildContext context,
    UserStore userStore,
  ) {
    return ClubListTile(
      leading: Icon(
        Icons.logout_outlined,
        size: 20,
        color: context.clubColors.tertiaryLabel,
      ),
      title: Text(context.l10n.logoutEduSystem),
      onTap: () async {
        final result = await PlatformDialog.showConfirmDialog(
          context,
          title: context.l10n.confirmLogoutTitle,
          content: context.l10n.confirmLogoutContent,
          confirmText: context.l10n.logout,
          cancelText: context.l10n.cancel,
        );

        if (result == true) {
          await userStore.logout();
          AppRouter.go(AppRoutes.profile);
        }
      },
    );
  }

  Widget _buildWidgetTile(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        Icons.widgets,
        size: 20,
        color: context.clubColors.primary,
      ),
      title: Text(context.l10n.addToDesktop),
      showChevron: true,
      onTap: () {
        _handleWidgetSetup(context);
      },
    );
  }

  Future<void> _handleWidgetSetup(BuildContext context) async {
    if (PlatformUtils.isAndroid) {
      final ready = await _ensureAndroidWidgetPrerequisites(context);
      if (!ready || !context.mounted) return;

      final type = await _showWidgetTypePicker(context);
      if (type == null || !context.mounted) return;
      await _openWidgetSettings(context, type: type);
      return;
    }

    await _openWidgetSettings(context);
  }

  Future<bool> _ensureAndroidWidgetPrerequisites(BuildContext context) async {
    final exactAlarmPlugin = NotificationService.instance.notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final canScheduleExact =
        await exactAlarmPlugin?.canScheduleExactNotifications() ?? false;
    final batteryOptimizationStatus =
        await permission_handler.Permission.ignoreBatteryOptimizations.status;

    final hasExactAlarm = canScheduleExact;
    final hasBackgroundPermission =
        _isPermissionGranted(batteryOptimizationStatus);

    if (hasExactAlarm && hasBackgroundPermission) {
      return true;
    }

    if (!context.mounted) return false;

    final shouldRequest = await PlatformDialog.showConfirmDialog(
      context,
      title: context.l10n.addToDesktop,
      content:
          '${context.l10n.allowScheduleAlarm}\n${context.l10n.allowScheduleAlarmContent}\n\n'
          '${context.l10n.allowBackgroundRun}\n${context.l10n.allowBackgroundRunContent}',
      confirmText: context.l10n.goAuthorize,
      cancelText: context.l10n.cancel,
    );

    if (shouldRequest != true || !context.mounted) {
      return false;
    }

    return NotificationService.ensureReminderPermission(context);
  }

  bool _isPermissionGranted(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited ||
        status == PermissionStatus.provisional;
  }

  Future<void> _openWidgetSettings(
    BuildContext context, {
    WidgetSetupType type = WidgetSetupType.today,
  }) async {
    final result = await WidgetSettingsService.openWidgetSetup(type: type);

    if (!context.mounted) return;

    if (result == WidgetSetupLaunchResult.unavailable ||
        result == WidgetSetupLaunchResult.failed) {
      _showWidgetInstructions(context);
    }
  }

  Future<WidgetSetupType?> _showWidgetTypePicker(BuildContext context) async {
    return showCupertinoModalPopup<WidgetSetupType>(
      context: context,
      builder: (popupContext) {
        return CupertinoActionSheet(
          title: Text(context.l10n.addToDesktop),
          message: Text(context.l10n.widgetSetupTitle),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(popupContext).pop(WidgetSetupType.today);
              },
              child: Text(context.l10n.todayScheduleLabel),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(popupContext).pop(WidgetSetupType.tomorrow);
              },
              child: Text(context.l10n.tomorrowSchedule),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: Text(context.l10n.cancel),
          ),
        );
      },
    );
  }

  Widget _buildClearCacheTile(BuildContext context, WidgetRef ref) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.trash_fill,
        size: 20,
        color: context.clubColors.danger,
      ),
      title: Text(context.l10n.clearCache),
      showChevron: true,
      onTap: () async {
        final result = await PlatformDialog.showConfirmDialog(
          context,
          title: context.l10n.confirmClearCacheTitle,
          content: context.l10n.confirmClearCacheContent,
          confirmText: context.l10n.clearCache,
          cancelText: context.l10n.cancel,
        );

        if (result == true) {
          if (context.mounted) {
            showClubSnackBar(context, Text(context.l10n.clearingCache));
          }

          await ref.read(educationCacheClearerProvider)();
          await RequestCache.instance.clear();

          if (context.mounted) {
            showClubSnackBar(context, Text(context.l10n.cacheCleared));
          }
        }
      },
    );
  }

  void _showWidgetInstructions(BuildContext context) {
    final colors = context.clubColors;

    showClubModalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.widgetSetupTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.label,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.widgetSetupIntro,
            style: TextStyle(
              fontSize: 16,
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            context,
            '1',
            context.l10n.widgetSetupStep1,
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            context,
            '2',
            context.l10n.widgetSetupStep2,
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            context,
            '3',
            context.l10n.widgetSetupStep3,
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            context,
            '4',
            context.l10n.widgetSetupStep4,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.widgetSetupTip,
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
    BuildContext context,
    String step,
    String description,
  ) {
    final colors = context.clubColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: colors.onAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: colors.label,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showThemeModePicker(
    BuildContext context,
    SettingsStore settingsStore,
  ) async {
    final colors = context.clubColors;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return CupertinoActionSheet(
          title: Text(context.l10n.appearance),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                await settingsStore.setThemeMode(ThemeMode.system);
                if (popupContext.mounted) {
                  Navigator.of(popupContext).pop();
                }
              },
              child: Text(context.l10n.followSystem),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                await settingsStore.setThemeMode(ThemeMode.light);
                if (popupContext.mounted) {
                  Navigator.of(popupContext).pop();
                }
              },
              child: Text(
                context.l10n.light,
                style: TextStyle(color: colors.label),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                await settingsStore.setThemeMode(ThemeMode.dark);
                if (popupContext.mounted) {
                  Navigator.of(popupContext).pop();
                }
              },
              child: Text(context.l10n.dark),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: Text(context.l10n.cancel),
          ),
        );
      },
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode themeMode) {
    final l10n = context.l10n;

    switch (themeMode) {
      case ThemeMode.system:
        return l10n.followSystem;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }
}
