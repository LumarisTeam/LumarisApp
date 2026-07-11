import 'package:flutter/cupertino.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/image_brightness.dart';

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
  List<String> totalList = [];
  List<String> ignoreList = [];
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

  String _buildCalendarSubscriptionUrl({
    required String username,
    required String password,
  }) {
    return Uri.https(
      'schedule.xauat.site',
      '/class',
      <String, dynamic>{
        'school': 'xauat',
        'username': username,
        'password': password,
      },
    ).toString();
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
      final courseResult =
          await ref.read(courseFeatureRepositoryProvider).getCourseNames();
      if (!courseResult.isSuccess) throw courseResult.error;
      final courseNames = courseResult.data;

      final ignores = courseNames
          .map((i) => CourseIgnore(
                title: i,
                isCompleted: courseStore.ignoreCourses.isNotEmpty &&
                    courseStore.ignoreCourses.any((x) => x == i),
              ))
          .toList();

      setState(() {
        ignoreList = courseStore.ignoreCourses;
        totalList = courseNames;
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

    final colors = context.clubColors;

    final schoolState = ref.watch(schoolStoreProvider);
    final school = schoolState.school;
    final canSyncCalendar = school?.supports(Feature.timetable) ?? false;
    final canEdit = school?.supports(Feature.timetable) ?? false;

    return Scaffold(
        appBar: ClubAppBar(
          title: l10n.scheduleSettingsTitle,
        ),
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
              if (_ignores.isNotEmpty)
                _buildIgnoreCourseSection(context, colors),
            ],
          ),
        ));
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

  Widget _buildCalendarSection(BuildContext context, ClubColors colors) {
    final l10n = context.l10n;
    return ClubCard(
      child: Column(
        children: [
          ClubListTile(
            leading: Icon(
              Icons.calendar_today_outlined,
              color: colors.primary,
            ),
            title: Text(
              l10n.scheduleWidgetTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
                    shape: ClubSmoothCorners.shape(ClubRadii.control),
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
                            showClubSnackBar(context, Text(l10n.copiedSuccess));
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
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context, ClubColors colors) {
    final l10n = context.l10n;
    return ClubCard(
      child: Column(
        children: [
          Material(
              color: Colors.transparent,
              shape: ClubSmoothCorners.shape(ClubRadii.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  borderRadius: ClubRadii.card,
                  customBorder: ClubSmoothCorners.shape(ClubRadii.card),
                  onTap: () => AppRouter.push(AppRoutes.customCourseManage),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
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
                          )
                        ],
                      )))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: ShapeDecoration(
                shape: ClubSmoothCorners.shape(ClubRadii.card),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.grid_on_outlined,
                        color: colors.secondaryLabel,
                      ),
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
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildBackgroundSection(BuildContext context, ClubColors colors) {
    final l10n = context.l10n;
    return ClubCard(
      child: Column(
        children: [
          _buildBackgroundOption(context, l10n.noBackground, ''),
          _buildBackgroundOption(context, l10n.customImage, 'custom'),
          if (settingsStore.scheduleBackground == 'custom') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      settingsStore.customBackgroundImage.isEmpty
                          ? l10n.noImageSelected
                          : settingsStore.customBackgroundImage,
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
    String value,
  ) {
    final colors = context.clubColors;
    final isSelected = settingsStore.scheduleBackground == value;
    return Material(
      shape: ClubSmoothCorners.shape(ClubRadii.card),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: ClubRadii.card,
        customBorder: ClubSmoothCorners.shape(ClubRadii.card),
        onTap: () {
          setState(() {
            settingsStore.setScheduleBackground(value);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            shape: ClubSmoothCorners.shape(ClubRadii.navigation),
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

  Widget _buildIgnoreCourseSection(BuildContext context, ClubColors colors) {
    return ClubCard(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
          showClubSnackBar(
            context,
            Text(context.l10n.noCalendarApp),
          );
        }
      }
      return;
    }

    final Uri uri = Uri.parse(webcalUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showClubSnackBar(
          context,
          Text(context.l10n.cannotOpenCalendar),
        );
      }
    }
  }

  Future<void> _pickCustomBackgroundImage() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: false,
      );

      if (result != null) {
        String filePath = result.files.single.path ?? result.files.single.name;
        await settingsStore.setCustomBackgroundImage(filePath);

        // 异步计算图片亮暗，完成后更新 store
        computeImageIsDark(filePath).then((isDark) {
          settingsStore.setCustomBackgroundIsDark(isDark);
        });

        if (mounted) {
          showClubSnackBar(
            context,
            Text(context.l10n.bgImageSetSuccess),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showClubSnackBar(
          context,
          Text(context.l10n.selectImageFailed),
        );
      }
      AppLogger.debug('选择背景图片失败: $e');
    }
  }

  void _handleIgnoreChange(CourseIgnore ignore, bool value) async {
    setState(() => ignore.isCompleted = value);
    await Future.microtask(() {
      if (value) {
        ignoreList.add(ignore.title);
      } else {
        ignoreList.remove(ignore.title);
      }

      courseStore.setIgnoreCourses(ignoreList);
      return ref
          .read(courseFeatureRepositoryProvider)
          .saveIgnoredCourses(ignoreList);
    });
  }

  void showCalendarGuidanceDialog(BuildContext context) {
    final httpsUrl = _webcalCalendarSubscriptionUrl ?? '';
    final l10n = context.l10n;

    PlatformDialog.showCustomDialog<void>(
      context,
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
                color: context.clubColors.surfaceRaised,
                shape: ClubSmoothCorners.shape(ClubRadii.xsBorder),
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
                        showClubSnackBar(
                          context,
                          Text(l10n.linkCopiedToClipboard),
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
        PlatformDialogAction<void>(
          label: l10n.understand,
          isDefaultAction: true,
        ),
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
    final colors = context.clubColors;
    return Material(
        color: Colors.transparent,
        shape: ClubSmoothCorners.shape(ClubRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            borderRadius: ClubRadii.card,
            customBorder: ClubSmoothCorners.shape(ClubRadii.card),
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
            )));
  }
}

class CourseIgnore {
  String title;
  bool isCompleted;

  CourseIgnore({required this.title, this.isCompleted = false});
}
