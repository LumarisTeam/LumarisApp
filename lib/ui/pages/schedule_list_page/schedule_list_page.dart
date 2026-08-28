import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/image_helper.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid.dart';
import 'package:ios_club_app/ui/components/schedule/weekday_header.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page/custom_course_manage_page.dart';

// 条件导入 dart:io，仅在非 Web 环境中使用
// import 'dart:io' if (dart.library.html) 'dart:html' as io;

/// 课表列表页面
///
/// 简约的苹果风格设计，展示完整的课程表
class ScheduleListPage extends ConsumerStatefulWidget {
  const ScheduleListPage({super.key});

  @override
  ConsumerState<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends ConsumerState<ScheduleListPage> {
  late PageController _pageController;

  CourseCardStyle _cardStyle = CourseCardStyle.normal;
  bool _showStyleSelector = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(scheduleStoreProvider).currentPage,
    );
    _loadPreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = PrefsService.instance;
    final courseSize = prefs.getDouble('course_size') ?? 55;

    setState(() {
      _cardStyle = _determineCourseStyle(courseSize);
    });
  }

  CourseCardStyle _determineCourseStyle(double size) {
    if (size == 50) return CourseCardStyle.small;
    if (size == 60) return CourseCardStyle.large;
    return CourseCardStyle.normal;
  }

  void _jumpToPage(int page) {
    final scheduleStore = ref.read(scheduleStoreProvider.notifier);
    scheduleStore.jumpToPage(page);
    _pageController.jumpToPage(ref.read(scheduleStoreProvider).currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop;
    final school = ref.watch(schoolStoreProvider).school;
    final canCourseSchedule = school?.supports(Feature.courseSelection) ?? true;

    if (school != null && !canCourseSchedule) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.schedule)),
        body: Center(child: Text(context.l10n.schoolNotSupported)),
      );
    }

    final systemIsDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsStoreProvider);
    final scheduleState = ref.watch(scheduleStoreProvider);

    return Scaffold(
      body: Builder(builder: (context) {
        final hasCustomBackground = settings.scheduleBackground == 'custom' &&
            settings.customBackgroundImage.isNotEmpty;

        // 有自定义背景时，根据背景亮暗决定字体颜色（异步计算后自动更新）
        // 未计算完成前回退到系统主题
        final isDark = hasCustomBackground
            ? (settings.customBackgroundIsDark ?? systemIsDark)
            : systemIsDark;

        final content = Column(
          children: [
            // 顶部工具栏
            _buildTopBar(context, isDesktop, isDark),
            // 课表内容
            Expanded(
              child: Builder(builder: (context) {
                if (scheduleState.isLoading) {
                  return Center(
                    child: LoadingStateView(
                      title: context.l10n.loadingSchedule,
                      subtitle: context.l10n.loadingScheduleSubtitle,
                    ),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    ref
                        .read(scheduleStoreProvider.notifier)
                        .setCurrentPage(index);
                  },
                  itemCount: scheduleState.allCourses.length,
                  itemBuilder: (context, index) {
                    return _buildSchedulePage(context, index);
                  },
                );
              }),
            ),
          ],
        );

        return hasCustomBackground
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackgroundImage(settings.customBackgroundImage),
                  content,
                ],
              )
            : content;
      }),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // 左侧：周次导航
              if (!isDesktop) _buildWeekInfo(context, isDark),
              if (isDesktop) _buildDesktopWeekNav(context),
              const Spacer(),
              // 右侧：操作按钮
              _buildActionButtons(context, isDark),
            ],
          ),
          // 样式选择器
          if (_showStyleSelector) ...[
            const SizedBox(height: 12),
            _buildStyleSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekInfo(BuildContext context, bool isDark) {
    final scheduleState = ref.watch(scheduleStoreProvider);
    final colors = context.clubColors;
    final l10n = context.l10n;
    return Builder(builder: (context) {
      final weekText = scheduleState.currentWeek <= 0
          ? l10n.weeksUntilStart(-scheduleState.currentWeek + 1)
          : l10n.currentWeek(scheduleState.currentWeek);

      return InkWell(
        onLongPress: () => weekMenuPress(context),
        onDoubleTap: () => _jumpToPage(0),
        onTap: () => _jumpToPage(scheduleState.currentWeek),
        borderRadius: ClubRadii.control,
        customBorder: ClubSmoothCorners.shape(ClubRadii.control),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduleState.currentPage <= 0
                    ? l10n.allSchedules
                    : l10n.weekUnit(scheduleState.currentPage),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.label,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekText,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> weekMenuPress(BuildContext context) async {
    final scheduleState = ref.read(scheduleStoreProvider);
    final colors = context.clubColors;
    final l10n = context.l10n;
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (renderBox == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selectedPage = await showMenu<int>(
      context: context,
      position: position,
      color: colors.cardBackground.withValues(alpha: 0.96),
      surfaceTintColor: Colors.transparent,
      shadowColor: colors.shadowColor.withValues(alpha: 0.18),
      elevation: 10,
      constraints: const BoxConstraints(minWidth: 196, maxWidth: 240),
      shape: ClubSmoothCorners.shape(
        ClubRadii.card,
        side: BorderSide(
          color: colors.separator.withValues(alpha: 0.18),
          width: 0.75,
        ),
      ),
      menuPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      items: List<PopupMenuEntry<int>>.generate(
        scheduleState.maxWeek + 1,
        (index) {
          final isSelected = index == scheduleState.currentPage;
          final isCurrentWeek = index == scheduleState.currentWeek;
          final label = index == 0
              ? l10n.allSchedules
              : '${l10n.weekUnit(index)}'
                  '${isCurrentWeek ? " (${l10n.currentWeekLabel})" : ""}';

          return PopupMenuItem<int>(
            value: index,
            padding: EdgeInsets.zero,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: ShapeDecoration(
                shape: ClubSmoothCorners.shape(ClubRadii.navigation),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: colors.label,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (!mounted || selectedPage == null) return;
    _jumpToPage(selectedPage);
  }

  Widget _buildDesktopWeekNav(BuildContext context) {
    final scheduleState = ref.watch(scheduleStoreProvider);
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _jumpToPage((scheduleState.currentPage - 1).ceil()),
          tooltip: l10n.previousWeek,
        ),
        const SizedBox(width: 8),
        Text(
          scheduleState.currentPage <= 0
              ? l10n.allSchedules
              : '${l10n.weekUnit(scheduleState.currentPage)}'
                  '${scheduleState.currentPage == scheduleState.currentWeek ? " (${l10n.currentWeekLabel})" : ""}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _jumpToPage((_pageController.page! + 1).ceil()),
          tooltip: l10n.nextWeek,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    final l10n = context.l10n;
    final isLogin = ref.watch(userStoreProvider).isLogin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 样式切换
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          onPressed: () {
            setState(() {
              _showStyleSelector = !_showStyleSelector;
            });
          },
          tooltip: l10n.switchStyle,
        ),
        // 游客模式：HTML 导入
        if (!isLogin)
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: _handleHtmlImport,
            tooltip: l10n.htmlImport,
          ),
        // 刷新
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _handleRefresh,
          tooltip: l10n.refreshSchedule,
        ),
        // 设置
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => AppRouter.push(AppRoutes.scheduleSetting),
          tooltip: l10n.scheduleSettingsTitle,
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        shape: ClubSmoothCorners.shape(ClubRadii.navigation),
      ),
      child: CupertinoSlidingSegmentedControl<CourseCardStyle>(
        groupValue: _cardStyle,
        onValueChanged: (CourseCardStyle? value) async {
          if (value != null) {
            setState(() {
              _cardStyle = value;
            });

            double height = 55;
            if (value == CourseCardStyle.small) {
              height = 50;
            } else if (value == CourseCardStyle.large) {
              height = 60;
            }

            await ref
                .read(scheduleStoreProvider.notifier)
                .setCourseHeight(height);
          }
        },
        children: {
          CourseCardStyle.small: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.compact),
          ),
          CourseCardStyle.normal: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.standard),
          ),
          CourseCardStyle.large: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.relaxed),
          ),
        },
      ),
    );
  }

  Widget _buildSchedulePage(BuildContext context, int weekIndex) {
    final scheduleState = ref.watch(scheduleStoreProvider);
    final settings = ref.watch(settingsStoreProvider);
    final weekStartDay = ref.watch(
      schoolStoreProvider.select(
        (value) => value.school?.weekStartDay ?? School.defaultWeekStartDay,
      ),
    );
    final courses = scheduleState.allCourses[weekIndex];
    final currentWeek = scheduleState.currentWeek;
    final now = DateTime.now();

    final weekStartDate = weekIndex == 0
        ? WeekStartUtils.getWeekStart(now, weekStartDay)
        : WeekStartUtils.getWeekStart(now, weekStartDay).add(
            Duration(days: (weekIndex - currentWeek) * 7),
          );

    return Builder(builder: (context) {
      final scheduleContent = Column(
        children: [
          // 星期标题栏
          WeekdayHeader(
            weekStartDate: weekStartDate,
            currentWeek: weekIndex == 0 ? null : weekIndex,
            showDate: weekIndex > 0,
            showGrid: settings.showCourseGrid,
            highlightToday: currentWeek != 0,
          ),
          // 课表网格
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: scheduleState.height * 12,
                child: ScheduleGrid(
                  courses: courses,
                  cellHeight: scheduleState.height,
                  weekStartDay: weekStartDay,
                  isYanTa: scheduleState.isYanTa,
                  cardStyle: _cardStyle,
                  showGrid: settings.showCourseGrid,
                  onCourseTap: (course) => _showCourseDetail(course),
                  onCourseLongPress: (course) {
                    if (course.isCustom) {
                      _showCourseActions(course);
                    }
                  },
                  onConflictCourseTap: (courses) =>
                      _showConflictCourseSelector(courses),
                ),
              ),
            ),
          ),
        ],
      );

      return scheduleContent;
    });
  }

  /// 构建背景图片
  Widget _buildBackgroundImage(String imagePath) {
    // 检查是否为网络图片
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image(
        image: CachedNetworkImageProvider(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          );
        },
      );
    }

    // 本地文件图片（使用 image_helper 处理平台差异）
    return getLocalImage(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        );
      },
    );
  }

  Future<void> _handleHtmlImport() async {
    final result = await AppRouter.push<bool>(AppRoutes.htmlImport);
    if (result == true) {
      ref.read(scheduleStoreProvider.notifier).loadGuestCourseData();
    }
  }

  Future<void> _handleRefresh() async {
    final l10n = context.l10n;
    showClubSnackBar(context, Text(l10n.updatingSchedule));
    try {
      await ref.read(scheduleStoreProvider.notifier).refreshCourses();
      if (mounted) {
        showClubSnackBar(context, Text(l10n.updateComplete));
      }
    } on TimeoutException {
      if (mounted) {
        showClubSnackBar(
          context,
          Text(l10n.updateTimeout),
        );
      }
    } catch (e) {
      if (mounted) {
        showClubSnackBar(
          context,
          Text(l10n.updateFailed(e.toString())),
        );
      }
    }
  }

  void _showCourseDetail(CourseModel course) {
    CourseDetailSheet.show(
      context,
      course,
      onEdit: course.isCustom ? () => _editCustomCourse(course) : null,
      onDelete: course.isCustom ? () => _deleteCustomCourse(course) : null,
    );
  }

  /// 显示冲突课程选择列表
  void _showConflictCourseSelector(List<CourseModel> courses) {
    final l10n = context.l10n;
    showClubModalBottomSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectCourse,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...courses.map((course) => ClubListTile(
                leading: Container(
                  width: 8,
                  height: 40,
                  decoration: ShapeDecoration(
                    color:
                        CourseColorManager.generateSoftColor(course.courseName),
                    shape: ClubSmoothCorners.shape(ClubRadii.xsBorder),
                  ),
                ),
                title: Text(
                  course.courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${course.room} · ${l10n.periodRange(course.startUnit, course.endUnit)}',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCourseDetail(course);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showCourseActions(CourseModel course) {
    final colors = context.clubColors;
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClubListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.editCourse),
            onTap: () {
              Navigator.pop(context);
              _editCustomCourse(course);
            },
          ),
          ClubListTile(
            leading: Icon(Icons.delete, color: colors.danger),
            title:
                Text(l10n.deleteCourse, style: TextStyle(color: colors.danger)),
            onTap: () {
              Navigator.pop(context);
              _deleteCustomCourse(course);
            },
          ),
        ],
      ),
    );
  }

  void _editCustomCourse(CourseModel course) {
    final screenHeight = MediaQuery.of(context).size.height;

    showClubModalBottomSheet(
      context,
      AddEditCourseDialog(
        course: course,
        onSave: (updatedCourse) async {
          await _saveUpdatedCustomCourse(updatedCourse);
          if (mounted && context.mounted) {
            showClubSnackBar(context, Text(context.l10n.courseModified));
          }
        },
      ),
      maxHeight: screenHeight * 0.7,
    );
  }

  Future<void> _deleteCustomCourse(CourseModel course) async {
    final l10n = context.l10n;
    final confirm = await PlatformDialog.showCustomDialog<bool>(
      context,
      title: l10n.confirmDelete,
      content: Text(l10n.confirmDeleteCourseContent(course.courseName)),
      actions: [
        PlatformDialogAction<bool>(
          label: l10n.cancel,
          value: false,
        ),
        PlatformDialogAction<bool>(
          label: l10n.delete,
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (confirm == true) {
      final prefs = PrefsService.instance;
      final jsonString = prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA);

      if (jsonString != null) {
        try {
          final jsonList = jsonDecode(jsonString) as List<dynamic>;
          final customCourses = jsonList
              .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
              .where((c) => c.isCustom && c.lessonId != course.lessonId)
              .toList();

          final updatedJsonString =
              jsonEncode(customCourses.map((c) => c.toJson()).toList());
          await prefs.setString(
              PrefsKeys.CUSTOM_COURSE_DATA, updatedJsonString);
          await ref.read(scheduleStoreProvider.notifier).refreshLocalCourses();

          if (mounted) {
            showClubSnackBar(context, Text(l10n.courseDeleted));
          }
        } catch (e) {
          if (mounted) {
            showClubSnackBar(context, Text(l10n.deleteFailed));
          }
        }
      }
    }
  }

  Future<void> _saveUpdatedCustomCourse(CourseModel updatedCourse) async {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA);

    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        final customCourses = jsonList
            .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
            .where((c) => c.isCustom)
            .toList();

        final index = customCourses
            .indexWhere((c) => c.lessonId == updatedCourse.lessonId);
        if (index != -1) {
          customCourses[index] = updatedCourse;
        }

        final updatedJsonString =
            jsonEncode(customCourses.map((c) => c.toJson()).toList());
        await prefs.setString(PrefsKeys.CUSTOM_COURSE_DATA, updatedJsonString);
        await ref.read(scheduleStoreProvider.notifier).refreshLocalCourses();
      } catch (e) {
        // 处理错误
      }
    }
  }
}
