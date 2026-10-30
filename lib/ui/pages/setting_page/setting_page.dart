import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/pages/setting_page/version_setting.dart';
import 'package:ios_club_app/features/education/services/education_cache_service.dart';
import 'package:ios_club_app/features/education/services/education_refresh_service.dart';
import 'package:ios_club_app/features/system/permissions/course_feature_permissions.dart';
import 'package:ios_club_app/features/system/widget_settings_service.dart';
import 'package:ios_club_app/ui/components/permissions/course_feature_permission_tile.dart';
import 'package:ios_club_app/ui/components/app_action_sheet.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/user_store.dart';

import 'package:ios_club_app/ui/pages/setting_page/show_tomorrow_setting.dart';
import 'package:ios_club_app/ui/pages/setting_page/remind_setting.dart';

import 'package:ios_club_app/ui/pages/setting_page/home_page_setting.dart';
import 'package:ios_club_app/ui/pages/setting_page/font_family_setting.dart';
import 'package:ios_club_app/ui/pages/setting_page/language_setting.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.mc.colors;
    final userState = ref.watch(userStoreProvider);
    final userStore = ref.read(userStoreProvider.notifier);
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return Scaffold(
      appBar: McAppBar(title: context.l10n.settings),
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
                  _buildRefreshTile(context),
                  _buildThemeModeTile(context, settings, settingsStore),
                  const LanguageSetting(),
                  const ShowTomorrowSetting(),
                  if (PlatformUtils.isMobile) const RemindSetting(),
                  if (PlatformUtils.isAndroid)
                    const CourseFeaturePermissionTile(
                      feature: CourseFeaturePermission.reminder,
                    ),
                  const HomePageSetting(),
                  if (PlatformUtils.isMobile) _buildPermissionTile(context),
                  if (PlatformUtils.isDesktop && !PlatformUtils.isMacOS)
                    const FontFamilySetting(),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.version),
                const SizedBox(height: 12),
                _buildSettingsGroup([const VersionSetting()]),
                const SizedBox(height: 24),
                if (PlatformUtils.isMobile)
                  _buildSectionTitle(context, context.l10n.widgets),
                if (PlatformUtils.isMobile) const SizedBox(height: 12),
                if (PlatformUtils.isMobile)
                  _buildSettingsGroup([
                    _buildWidgetTile(context),
                    if (PlatformUtils.isAndroid)
                      const CourseFeaturePermissionTile(
                        feature: CourseFeaturePermission.widget,
                      ),
                  ]),
                if (PlatformUtils.isMobile) const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.about),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildFeedbackTile(context),
                  _buildTeamTile(context),
                  _buildLicenseTile(context),
                  _buildPrivacyPolicyTile(context),
                  _buildUserAgreementTile(context),
                  _buildICPTile(context),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.other),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildClearCacheTile(context),
                  McListTile(
                    leading: Icon(
                      CupertinoIcons.link,
                      size: 20,
                      color: colors.primary,
                    ),
                    title: Text(context.l10n.mcpTitle),
                    subtitle: Text(context.l10n.mcpSubtitle),
                    showChevron: true,
                    onTap: () => AppRouter.push(AppRoutes.mcp),
                  ),
                  if (userState.isLogin) _buildLogoutTile(context, userStore),
                  McListTile(
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
                    McListTile(
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
    final colors = context.mc.colors;

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: ShapeDecoration(
            shape: McSmoothCorners.shape(McRadii.tileBorder),
            shadows: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: McSmoothCorners.clip(
            borderRadius: McRadii.tileBorder,
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
          style: TextStyle(fontSize: 14, color: colors.secondaryLabel),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.mc.colors;

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
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildRefreshTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.refresh,
        size: 20,
        color: context.mc.colors.primary,
      ),
      title: Text(context.l10n.refreshData),
      showChevron: true,
      onTap: () async {
        McFeedback.showMessage(context, message: context.l10n.refreshingData);
        final re = await EducationRefreshService.refresh();
        if (re) {
          await _syncHomeWidget();
        }
        if (context.mounted) {
          McFeedback.showMessage(
            context,
            message: re
                ? context.l10n.refreshDataSuccess
                : context.l10n.refreshDataFailed,
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
    final colors = context.mc.colors;

    return McListTile(
      leading: Icon(CupertinoIcons.moon_stars, size: 20, color: colors.primary),
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

  Widget _buildPermissionTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.checkmark_shield_fill,
        size: 20,
        color: context.mc.colors.indigo,
      ),
      title: Text(context.l10n.permissionManagement),
      subtitle: Text(context.l10n.permissionManagementSubtitle),
      showChevron: true,
      onTap: () => AppRouter.push(AppRoutes.permissions),
    );
  }

  Widget _buildFeedbackTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        Icons.feedback_rounded,
        size: 20,
        color: context.mc.colors.primary,
      ),
      title: Text(context.l10n.feedback),
      subtitle: Text(context.l10n.feedbackSubtitle),
      onTap: () {
        AppRouter.push(AppRoutes.feedback);
      },
    );
  }

  Widget _buildTeamTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.person_2_fill,
        size: 20,
        color: context.mc.colors.warning,
      ),
      title: Text(context.l10n.team),
      subtitle: Text(context.l10n.teamName),
      onTap: () {
        AppRouter.push(AppRoutes.author);
      },
    );
  }

  Widget _buildLicenseTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.doc_text_fill,
        size: 20,
        color: context.mc.colors.success,
      ),
      title: Text(context.l10n.openSourceLicense),
      subtitle: Text(context.l10n.mitLicense),
      onTap: () {
        AppRouter.push(AppRoutes.license);
      },
    );
  }

  Widget _buildICPTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.checkmark_shield_fill,
        size: 20,
        color: context.mc.colors.success,
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
    return McListTile(
      leading: Icon(
        CupertinoIcons.shield_fill,
        size: 20,
        color: context.mc.colors.primary,
      ),
      title: Text(context.l10n.privacyPolicy),
      subtitle: Text(context.l10n.privacyPolicySubtitle),
      onTap: () {
        AppRouter.push(AppRoutes.privacyPolicy);
      },
    );
  }

  Widget _buildUserAgreementTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.doc_text_fill,
        size: 20,
        color: context.mc.colors.purple,
      ),
      title: Text(context.l10n.userAgreement),
      subtitle: Text(context.l10n.userAgreementSubtitle),
      onTap: () {
        AppRouter.push(AppRoutes.userAgreement);
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context, UserStore userStore) {
    return McListTile(
      leading: Icon(
        Icons.logout_outlined,
        size: 20,
        color: context.mc.colors.tertiaryLabel,
      ),
      title: Text(context.l10n.logoutEduSystem),
      onTap: () async {
        final result = await showMcConfirmDialog(
          context: context,
          title: context.l10n.confirmLogoutTitle,
          message: context.l10n.confirmLogoutContent,
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
    return McListTile(
      leading: Icon(Icons.widgets, size: 20, color: context.mc.colors.primary),
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
    final statuses = await CourseFeaturePermissions.load(
      CourseFeaturePermission.widget,
    );
    final hasBackgroundPermission = CourseFeaturePermissions.allGranted(
      statuses.values,
    );

    if (hasBackgroundPermission) {
      return true;
    }

    if (!context.mounted) return false;

    final shouldRequest = await showMcConfirmDialog(
      context: context,
      title: context.l10n.addToDesktop,
      message:
          '${context.l10n.allowBackgroundRun}\n${context.l10n.permissionBatteryDesc}',
      confirmText: context.l10n.goAuthorize,
      cancelText: context.l10n.cancel,
    );

    if (shouldRequest != true || !context.mounted) {
      return false;
    }

    return CourseFeaturePermissions.requestMissing(
      context,
      CourseFeaturePermission.widget,
    );
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

  Future<WidgetSetupType?> _showWidgetTypePicker(BuildContext context) {
    return showAppActionSheet<WidgetSetupType>(
      context: context,
      title: context.l10n.addToDesktop,
      message: context.l10n.widgetSetupTitle,
      cancelLabel: context.l10n.cancel,
      items: [
        AppActionSheetItem(
          value: WidgetSetupType.today,
          label: context.l10n.todayScheduleLabel,
        ),
        AppActionSheetItem(
          value: WidgetSetupType.tomorrow,
          label: context.l10n.tomorrowSchedule,
        ),
      ],
    );
  }

  Widget _buildClearCacheTile(BuildContext context) {
    return McListTile(
      leading: Icon(
        CupertinoIcons.trash_fill,
        size: 20,
        color: context.mc.colors.danger,
      ),
      title: Text(context.l10n.clearCache),
      showChevron: true,
      onTap: () async {
        final result = await showMcConfirmDialog(
          context: context,
          title: context.l10n.confirmClearCacheTitle,
          message: context.l10n.confirmClearCacheContent,
          confirmText: context.l10n.clearCache,
          cancelText: context.l10n.cancel,
        );

        if (result == true) {
          if (context.mounted) {
            McFeedback.showMessage(
              context,
              message: context.l10n.clearingCache,
            );
          }

          // "清除缓存"只清数据，保留登录态。
          await EducationCacheService.clearEduCache(clearSession: false);
          await RequestCache.instance.clear();

          if (context.mounted) {
            McFeedback.showMessage(context, message: context.l10n.cacheCleared);
          }
        }
      },
    );
  }

  void _showWidgetInstructions(BuildContext context) {
    final colors = context.mc.colors;

    showMcBottomSheet(
      context: context,
      builder: (_) => Column(
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
            style: TextStyle(fontSize: 16, color: colors.secondaryLabel),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(context, '1', context.l10n.widgetSetupStep1),
          const SizedBox(height: 8),
          _buildInstructionStep(context, '2', context.l10n.widgetSetupStep2),
          const SizedBox(height: 8),
          _buildInstructionStep(context, '3', context.l10n.widgetSetupStep3),
          const SizedBox(height: 8),
          _buildInstructionStep(context, '4', context.l10n.widgetSetupStep4),
          const SizedBox(height: 24),
          Text(
            context.l10n.widgetSetupTip,
            style: TextStyle(fontSize: 14, color: colors.secondaryLabel),
          ),
          const SizedBox(height: 24),
        ],
      ),
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
    );
  }

  Widget _buildInstructionStep(
    BuildContext context,
    String step,
    String description,
  ) {
    final colors = context.mc.colors;

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
            style: TextStyle(fontSize: 16, color: colors.label),
          ),
        ),
      ],
    );
  }

  Future<void> _showThemeModePicker(
    BuildContext context,
    SettingsStore settingsStore,
  ) async {
    final selected = await showAppActionSheet<ThemeMode>(
      context: context,
      title: context.l10n.appearance,
      cancelLabel: context.l10n.cancel,
      items: [
        for (final ThemeMode mode in ThemeMode.values)
          AppActionSheetItem(
            value: mode,
            label: _themeModeLabel(context, mode),
            isSelected: mode == settingsStore.themeMode,
          ),
      ],
    );

    if (selected != null) {
      await settingsStore.setThemeMode(selected);
    }
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
