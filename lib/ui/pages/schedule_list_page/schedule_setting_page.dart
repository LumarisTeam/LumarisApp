import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_background_picker.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

class ScheduleSettingPage extends ConsumerStatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  ConsumerState<ScheduleSettingPage> createState() =>
      _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends ConsumerState<ScheduleSettingPage>
    with AutomaticKeepAliveClientMixin {
  late CourseStore courseStore;
  late SettingsStore settingsStore;
  late List<CourseIgnore> _ignores = [];
  String? _calendarSubscriptionUrl;
  final ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  String? get _httpsCalendarSubscriptionUrl => _calendarSubscriptionUrl;

  String? get _webcalCalendarSubscriptionUrl {
    final httpsUrl = _httpsCalendarSubscriptionUrl;
    if (httpsUrl == null || httpsUrl.isEmpty) {
      return null;
    }
    final uri = Uri.parse(httpsUrl);
    return uri.replace(scheme: 'webcal').toString();
  }

  /// 日历订阅地址。
  ///
  /// 原先指向 `schedule.xauat.site/class`（Flask / LoginApi 那一侧）。ICS 生成已迁到
  /// EduApi 的 `v1/course/Calendar`——它本来就在解析同一套课表与考试数据，
  /// 没必要两边各解析一遍。
  ///
  /// 基址取学校记录里的 website（XAUAT 是 https://xauatapi.xauat.site），
  /// 拿不到时回落到内置的学校配置。原来的 `school=xauat` 参数不需要了：
  /// EduApi 只服务本校，多余参数会被忽略。
  String _buildCalendarSubscriptionUrl({
    required String username,
    required String password,
  }) {
    final website =
        SchoolConfigCache.read()?.website ?? School.fallbackList.first.website;

    return Uri.parse(website)
        .replace(
          path: '/v1/course/Calendar',
          queryParameters: <String, String>{
            'username': username,
            'password': password,
          },
        )
        .toString();
  }

  @override
  void initState() {
    super.initState();
    courseStore = ref.read(courseStoreProvider.notifier);
    settingsStore = ref.read(settingsStoreProvider.notifier);
    _initData();
  }

  Future<void> _initData() async {
    await _loadCredentials();
    await _loadCourseData();
  }

  Future<void> _loadCredentials() async {
    try {
      final secureStorage = SecureStorageService.instance;
      final username = await secureStorage.read(key: PrefsKeys.USERNAME);
      final password = await secureStorage.read(key: PrefsKeys.PASSWORD);

      if (username != null && password != null) {
        setState(() {
          _calendarSubscriptionUrl = _buildCalendarSubscriptionUrl(
            username: username,
            password: password,
          );
        });
      }
    } catch (e) {
      AppLogger.debug('Failed to load credentials: $e');
    }
  }

  Future<void> _loadCourseData() async {
    try {
      await courseStore.loadIgnoreCourses();
      final courseNames = await CourseService.getCourseName();
      final ignoredNames = courseStore.ignoreCourses;

      final ignores = courseNames
          .map(
            (i) =>
                CourseIgnore(title: i, isCompleted: ignoredNames.contains(i)),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _ignores = ignores;
      });
    } catch (e) {
      AppLogger.debug('Failed to load course data: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final isDesktop = PlatformUtils.isDesktop;

    final colors = context.mc.colors;

    final schoolState = ref.watch(schoolStoreProvider);
    final school = schoolState.school;
    // The current subscription service is XAUAT-specific. Other schools must
    // provide their own endpoint before this entry can be enabled.
    final canSyncCalendar =
        school?.code.toUpperCase() == School.defaultCode &&
        (school?.supports(Feature.timetable) ?? false);
    final canEdit = school?.supports(Feature.timetable) ?? false;

    return Scaffold(
      appBar: McAppBar(title: l10n.scheduleSettingsTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop && canSyncCalendar) ...[
              _buildSectionTitle(l10n.calendarSubscription),
              const SizedBox(height: 12),
              _buildCalendarSection(context, colors),
              const SizedBox(height: 24),
            ],
            if (canEdit) ...[
              _buildSectionTitle(l10n.scheduleManagement),
              const SizedBox(height: 12),
              _buildManagementSection(context, colors),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle(l10n.scheduleBackground),
            const SizedBox(height: 12),
            _buildBackgroundSection(context, colors),
            if (_ignores.isNotEmpty) const SizedBox(height: 24),
            if (_ignores.isNotEmpty) _buildSectionTitle(l10n.ignoreCourses),
            if (_ignores.isNotEmpty) const SizedBox(height: 12),
            if (_ignores.isNotEmpty) _buildIgnoreCourseSection(context, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context, McColors colors) {
    final l10n = context.l10n;
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          McListTile(
            leading: Icon(Icons.calendar_today_outlined, color: colors.primary),
            title: Text(
              l10n.scheduleWidgetTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () => _launchCalendar(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionLink,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryLabel,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: colors.surfaceRaised,
                    shape: McSmoothCorners.shape(McRadii.controlBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _httpsCalendarSubscriptionUrl ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.secondaryLabel,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          final webcalUrl = _webcalCalendarSubscriptionUrl;
                          if (webcalUrl == null || webcalUrl.isEmpty) {
                            return;
                          }
                          Clipboard.setData(ClipboardData(text: webcalUrl));
                          if (context.mounted) {
                            McFeedback.showMessage(
                              context,
                              message: l10n.copiedSuccess,
                            );
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => showCalendarGuidanceDialog(context),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: Text(l10n.howToImport),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context, McColors colors) {
    final l10n = context.l10n;
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            shape: McSmoothCorners.shape(McRadii.cardBorder),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: McRadii.cardBorder,
              customBorder: McSmoothCorners.shape(McRadii.cardBorder),
              onTap: () => AppRouter.push(AppRoutes.customCourseManage),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_calendar_outlined,
                          color: colors.secondaryLabel,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.customCourseManage,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward_ios, size: 16),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: ShapeDecoration(
              shape: McSmoothCorners.shape(McRadii.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_on_outlined, color: colors.secondaryLabel),
                    const SizedBox(width: 12),
                    Text(
                      l10n.showCourseGrid,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CupertinoSwitch(
                      value: settingsStore.showCourseGrid,
                      onChanged: (value) {
                        setState(() {
                          settingsStore.setShowCourseGrid(value);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundSection(BuildContext context, McColors colors) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePath = settingsStore.backgroundImageFor(isDark: isDark);
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildBackgroundOption(
            context,
            l10n.noBackground,
            '',
            onTap: () async {
              await clearScheduleBackgroundImage(ref, isDark: isDark);
              if (mounted) setState(() {});
            },
          ),
          _buildBackgroundOption(context, l10n.customImage, 'custom'),
          if (settingsStore.scheduleBackground == 'custom') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      activePath.isEmpty ? l10n.noImageSelected : activePath,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.secondaryLabel,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_outlined, size: 20),
                    onPressed: _pickCustomBackgroundImage,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(
    BuildContext context,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    final colors = context.mc.colors;
    final isSelected = settingsStore.scheduleBackground == value;
    return Material(
      shape: McSmoothCorners.shape(McRadii.cardBorder),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: McRadii.cardBorder,
        customBorder: McSmoothCorners.shape(McRadii.cardBorder),
        onTap:
            onTap ??
            () {
              setState(() {
                settingsStore.setScheduleBackground(value);
              });
            },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            shape: McSmoothCorners.shape(McRadii.navigationBorder),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : colors.tertiaryLabel,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIgnoreCourseSection(BuildContext context, McColors colors) {
    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _ignores.length,
        itemBuilder: (context, index) {
          final ignore = _ignores[index];
          return CourseIgnoreItem(
            ignore: ignore,
            onChanged: _handleIgnoreChange,
          );
        },
      ),
    );
  }

  Future<void> _launchCalendar(BuildContext context) async {
    final webcalUrl = _webcalCalendarSubscriptionUrl;
    if (webcalUrl == null || webcalUrl.isEmpty) {
      return;
    }

    if (PlatformUtils.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: webcalUrl,
        type: 'text/calendar',
      );
      var result = await intent.canResolveActivity();
      if (result != null && result) {
        await intent.launch();
      } else {
        if (context.mounted) {
          McFeedback.showMessage(context, message: context.l10n.noCalendarApp);
        }
      }
      return;
    }

    final Uri uri = Uri.parse(webcalUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        McFeedback.showMessage(
          context,
          message: context.l10n.cannotOpenCalendar,
        );
      }
    }
  }

  Future<void> _pickCustomBackgroundImage() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await pickScheduleBackgroundImage(
      context,
      ref,
      isDark: isDark,
    );
    if (picked && mounted) setState(() {});
  }

  Future<void> _handleIgnoreChange(CourseIgnore ignore, bool value) async {
    setState(() => ignore.isCompleted = value);

    try {
      // 交给 CourseStore 一并改状态与落盘：它一变，appStateCoordinator 就会让
      // 课表按新的忽略名单重新过滤。不要直接改 ignoreCourses 返回的列表，
      // 那是 unmodifiable 的副本。
      if (value) {
        await courseStore.addIgnoreCourse(ignore.title);
      } else {
        await courseStore.removeIgnoreCourse(ignore.title);
      }
    } catch (e, stackTrace) {
      AppLogger.error('切换忽略课程失败', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => ignore.isCompleted = !value);
      if (!mounted) return;
      McFeedback.showMessage(context, message: context.l10n.saveFailedRetry);
    }
  }

  void showCalendarGuidanceDialog(BuildContext context) {
    final httpsUrl = _webcalCalendarSubscriptionUrl ?? '';
    final l10n = context.l10n;

    showMcDialog(
      context: context,
      title: l10n.addCalendarSub,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.calendarGuidanceIntro),
            const SizedBox(height: 16),
            Text(l10n.calendarGuidanceStep1),
            Text(l10n.calendarGuidanceStep2),
            Text(l10n.calendarGuidanceStep3),
            Text(l10n.calendarGuidanceStep4),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: context.mc.colors.surfaceRaised,
                shape: McSmoothCorners.shape(McRadii.xsBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      httpsUrl,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: httpsUrl));
                      if (context.mounted) {
                        McFeedback.showMessage(
                          context,
                          message: l10n.linkCopiedToClipboard,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.calendarGuidanceNote),
          ],
        ),
      ),
      actions: [
        McDialogAction<void>(label: l10n.understand, isDefaultAction: true),
      ],
    );
  }
}

class CourseIgnoreItem extends StatelessWidget {
  final CourseIgnore ignore;
  final Function(CourseIgnore, bool) onChanged;

  const CourseIgnoreItem({
    super.key,
    required this.ignore,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    return Material(
      color: Colors.transparent,
      shape: McSmoothCorners.shape(McRadii.cardBorder),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: McRadii.cardBorder,
        customBorder: McSmoothCorners.shape(McRadii.cardBorder),
        onTap: () => onChanged(ignore, !ignore.isCompleted),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                ignore.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: ignore.isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : colors.tertiaryLabel,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ignore.title,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseIgnore {
  String title;
  bool isCompleted;

  CourseIgnore({required this.title, this.isCompleted = false});
}
