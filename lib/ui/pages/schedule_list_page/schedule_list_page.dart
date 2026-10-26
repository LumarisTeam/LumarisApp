import 'dart:async';
import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_background_image.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_visual_style.dart';
import 'package:ios_club_app/ui/components/schedule/weekday_header.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(scheduleStoreProvider).currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final styleState = ref.watch(scheduleStyleStoreProvider);
    final weekStartDay = ref.watch(
      schoolStoreProvider.select(
        (value) => value.school?.weekStartDay ?? School.defaultWeekStartDay,
      ),
    );
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    final backgroundPath = settingsStore.backgroundImageFor(
      isDark: systemIsDark,
    );
    final hasCustomBackground =
        settings.scheduleBackground == 'custom' && backgroundPath.isNotEmpty;
    // 有自定义背景时，根据背景亮暗决定文字/颜色池；未计算完成前回退系统主题。
    final isDark = hasCustomBackground
        ? (settingsStore.backgroundIsDarkFor(isDark: systemIsDark) ??
              systemIsDark)
        : systemIsDark;

    final visualStyle = ScheduleVisualStyle.from(
      styleState: styleState,
      showGrid: settings.showCourseGrid,
      cellHeight: scheduleState.height,
      isDark: isDark,
    );

    return Scaffold(
      body: Builder(
        builder: (context) {
          final content = Column(
            children: [
              // 顶部工具栏
              _buildTopBar(
                context,
                isDesktop,
                isDark,
                styleState.pageTextColor,
              ),
              // 课表内容
              Expanded(
                child: Builder(
                  builder: (context) {
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
                        return _WeekScheduleView(
                          weekIndex: index,
                          currentWeek: scheduleState.currentWeek,
                          courses: scheduleState.allCourses[index],
                          weekStartDay: weekStartDay,
                          isYanTa: scheduleState.isYanTa,
                          visualStyle: visualStyle,
                          onCourseTap: (course) =>
                              _showCourseDetail(course, visualStyle.isDark),
                          onCourseLongPress: (course) {
                            if (course.isCustom) {
                              _showCourseActions(course);
                            }
                          },
                          onConflictCourseTap: (courses) =>
                              _showConflictCourseSelector(courses, visualStyle),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );

          return hasCustomBackground
              ? Stack(
                  fit: StackFit.expand,
                  children: [_buildBackgroundImage(backgroundPath), content],
                )
              : content;
        },
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDesktop,
    bool isDark,
    Color? pageTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // 左侧：周次导航
              if (!isDesktop) _buildWeekInfo(context, isDark, pageTextColor),
              if (isDesktop) _buildDesktopWeekNav(context, pageTextColor),
              const Spacer(),
              // 右侧：操作按钮
              _buildActionButtons(context, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekInfo(
    BuildContext context,
    bool isDark,
    Color? pageTextColor,
  ) {
    final scheduleState = ref.watch(scheduleStoreProvider);
    final colors = context.mc.colors;
    final l10n = context.l10n;
    return Builder(
      builder: (context) {
        final weekText = scheduleState.currentWeek <= 0
            ? l10n.weeksUntilStart(-scheduleState.currentWeek + 1)
            : l10n.currentWeek(scheduleState.currentWeek);

        return InkWell(
          onLongPress: () => weekMenuPress(context),
          onDoubleTap: () => _jumpToPage(0),
          onTap: () => _jumpToPage(scheduleState.currentWeek),
          borderRadius: McRadii.controlBorder,
          customBorder: McSmoothCorners.shape(McRadii.controlBorder),
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
                    color: pageTextColor ?? colors.label,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weekText,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        pageTextColor?.withValues(alpha: 0.8) ??
                        Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> weekMenuPress(BuildContext context) async {
    final scheduleState = ref.read(scheduleStoreProvider);
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (renderBox == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
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
      shape: McSmoothCorners.shape(
        McRadii.cardBorder,
        side: BorderSide(
          color: colors.separator.withValues(alpha: 0.18),
          width: 0.75,
        ),
      ),
      menuPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      items: List<PopupMenuEntry<int>>.generate(scheduleState.maxWeek + 1, (
        index,
      ) {
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
              shape: McSmoothCorners.shape(McRadii.navigationBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
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
      }),
    );

    if (!mounted || selectedPage == null) return;
    _jumpToPage(selectedPage);
  }

  Widget _buildDesktopWeekNav(BuildContext context, Color? pageTextColor) {
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: pageTextColor,
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
        // 个性化配置
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          onPressed: () => AppRouter.push(AppRoutes.schedulePersonalization),
          tooltip: l10n.schedulePersonalization,
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

  /// 构建背景图片
  Widget _buildBackgroundImage(String imagePath) {
    return ScheduleBackgroundImage(imagePath: imagePath);
  }

  Future<void> _handleHtmlImport() async {
    final result = await AppRouter.push<bool>(AppRoutes.htmlImport);
    if (result == true) {
      ref.read(scheduleStoreProvider.notifier).loadGuestCourseData();
    }
  }

  Future<void> _handleRefresh() async {
    final l10n = context.l10n;
    McFeedback.showMessage(context, message: l10n.updatingSchedule);
    try {
      await ref.read(scheduleStoreProvider.notifier).refreshCourses();
      if (mounted) {
        McFeedback.showMessage(context, message: l10n.updateComplete);
      }
    } on TimeoutException {
      if (mounted) {
        McFeedback.showMessage(context, message: l10n.updateTimeout);
      }
    } catch (e) {
      if (mounted) {
        McFeedback.showMessage(
          context,
          message: l10n.updateFailed(e.toString()),
        );
      }
    }
  }

  void _showCourseDetail(CourseModel course, bool isDark) {
    CourseDetailSheet.show(
      context,
      course,
      isDark: isDark,
      onEdit: course.isCustom ? () => _editCustomCourse(course) : null,
      onDelete: course.isCustom ? () => _deleteCustomCourse(course) : null,
    );
  }

  /// 显示冲突课程选择列表
  void _showConflictCourseSelector(
    List<CourseModel> courses,
    ScheduleVisualStyle visualStyle,
  ) {
    final l10n = context.l10n;

    showMcBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectCourse,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...courses.map(
            (course) => McListTile(
              leading: Container(
                width: 8,
                height: 40,
                decoration: ShapeDecoration(
                  color: visualStyle.colorFor(course),
                  shape: McSmoothCorners.shape(McRadii.xsBorder),
                ),
              ),
              title: Text(
                course.courseName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${course.room} · ${l10n.periodRange(course.startUnit, course.endUnit)}',
              ),
              onTap: () {
                Navigator.pop(context);
                _showCourseDetail(course, visualStyle.isDark);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
    );
  }

  void _showCourseActions(CourseModel course) {
    final colors = context.mc.colors;
    final l10n = context.l10n;

    showMcBottomSheet(
      context: context,
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          McListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.editCourse),
            onTap: () {
              Navigator.pop(sheetContext);
              _editCustomCourse(course);
            },
          ),
          McListTile(
            leading: Icon(Icons.delete, color: colors.danger),
            title: Text(
              l10n.deleteCourse,
              style: TextStyle(color: colors.danger),
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              _deleteCustomCourse(course);
            },
          ),
        ],
      ),
    );
  }

  void _editCustomCourse(CourseModel course) {
    final screenHeight = MediaQuery.of(context).size.height;

    showMcBottomSheet(
      context: context,
      builder: (_) => AddEditCourseDialog(
        course: course,
        onSave: (updatedCourse) async {
          await _saveUpdatedCustomCourse(updatedCourse);
          if (mounted && context.mounted) {
            McFeedback.showMessage(
              context,
              message: context.l10n.courseModified,
            );
          }
        },
      ),
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: screenHeight * 0.7,
    );
  }

  Future<void> _deleteCustomCourse(CourseModel course) async {
    final l10n = context.l10n;
    final confirm = await showMcDialog(
      context: context,
      title: l10n.confirmDelete,
      content: Text(l10n.confirmDeleteCourseContent(course.courseName)),
      actions: [
        McDialogAction<bool>(label: l10n.cancel, value: false),
        McDialogAction<bool>(
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

          final updatedJsonString = jsonEncode(
            customCourses.map((c) => c.toJson()).toList(),
          );
          await prefs.setString(
            PrefsKeys.CUSTOM_COURSE_DATA,
            updatedJsonString,
          );
          await ref.read(scheduleStoreProvider.notifier).refreshLocalCourses();

          if (mounted) {
            McFeedback.showMessage(context, message: l10n.courseDeleted);
          }
        } catch (e) {
          if (mounted) {
            McFeedback.showMessage(context, message: l10n.deleteFailed);
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

        final index = customCourses.indexWhere(
          (c) => c.lessonId == updatedCourse.lessonId,
        );
        if (index != -1) {
          customCourses[index] = updatedCourse;
        }

        final updatedJsonString = jsonEncode(
          customCourses.map((c) => c.toJson()).toList(),
        );
        await prefs.setString(PrefsKeys.CUSTOM_COURSE_DATA, updatedJsonString);
        await ref.read(scheduleStoreProvider.notifier).refreshLocalCourses();
      } catch (e) {
        // 处理错误
      }
    }
  }
}

/// 单个周课表页。
///
/// 每个周页持有自己的 ScrollController，用于保留各自的滚动位置。
class _WeekScheduleView extends StatefulWidget {
  const _WeekScheduleView({
    required this.weekIndex,
    required this.currentWeek,
    required this.courses,
    required this.weekStartDay,
    required this.isYanTa,
    required this.visualStyle,
    required this.onCourseTap,
    required this.onCourseLongPress,
    required this.onConflictCourseTap,
  });

  final int weekIndex;
  final int currentWeek;
  final List<CourseModel> courses;
  final int weekStartDay;
  final bool isYanTa;
  final ScheduleVisualStyle visualStyle;
  final void Function(CourseModel) onCourseTap;
  final void Function(CourseModel) onCourseLongPress;
  final void Function(List<CourseModel>) onConflictCourseTap;

  @override
  State<_WeekScheduleView> createState() => _WeekScheduleViewState();
}

class _WeekScheduleViewState extends State<_WeekScheduleView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekStartDate = widget.weekIndex == 0
        ? WeekStartUtils.getWeekStart(DateTime.now(), widget.weekStartDay)
        : WeekStartUtils.getWeekStart(
            DateTime.now(),
            widget.weekStartDay,
          ).add(Duration(days: (widget.weekIndex - widget.currentWeek) * 7));

    return Column(
      children: [
        WeekdayHeader(
          weekStartDate: weekStartDate,
          currentWeek: widget.weekIndex == 0 ? null : widget.weekIndex,
          showDate: widget.weekIndex > 0,
          showGrid: widget.visualStyle.showGrid,
          highlightToday: widget.currentWeek != 0,
          height: widget.visualStyle.headerHeight,
          timeColumnWidth: widget.visualStyle.timeColumnWidth,
          hideDateUnderDay: widget.visualStyle.hideDateUnderDay,
          textColor: widget.visualStyle.pageTextColor,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: widget.visualStyle.gridHeight,
              child: ScheduleGrid(
                courses: widget.courses,
                cellHeight: widget.visualStyle.cellHeight,
                weekStartDay: widget.weekStartDay,
                isYanTa: widget.isYanTa,
                showGrid: widget.visualStyle.showGrid,
                visualStyle: widget.visualStyle,
                onCourseTap: widget.onCourseTap,
                onCourseLongPress: widget.onCourseLongPress,
                onConflictCourseTap: widget.onConflictCourseTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
