import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';

import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

import '../../../routes/router.dart';
import '../../../state/user_store.dart';
import '../../components/loading_state_view.dart';
import '../../components/schedule/schedule_import_empty_state.dart';

class ScheduleWidget extends ConsumerStatefulWidget {
  const ScheduleWidget({super.key});

  @override
  ConsumerState<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends ConsumerState<ScheduleWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scheduleState = ref.watch(scheduleStoreProvider);
    final isLogin = ref.watch(userStoreProvider.select((user) => user.isLogin));
    final showTomorrow = ref.watch(
      settingsStoreProvider.select((settings) => settings.isShowTomorrow),
    );
    final scheduleStore = ref.read(scheduleStoreProvider.notifier);
    ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final isDark = settingsStore.scheduleIsDark(
      systemIsDark: Theme.of(context).brightness == Brightness.dark,
    );
    final style = ref.watch(scheduleStyleStoreProvider);
    final homeCourses = scheduleStore.getHomeCourses(
      showTomorrow: showTomorrow,
    );
    final isTablet = screenWidth > 600;
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  homeCourses.showTomorrow
                      ? l10n.tomorrowSchedule
                      : l10n.todayScheduleLabel,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.gear_solid),
                onPressed: () {
                  showMcDialog(
                    context: context,
                    title: l10n.settings,
                    content: Consumer(
                      builder: (context, ref, child) {
                        final settings = ref.watch(settingsStoreProvider);
                        final settingsStore = ref.read(
                          settingsStoreProvider.notifier,
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            McListTile(
                              title: Text(l10n.showTomorrowSchedule),
                              trailing: CupertinoSwitch(
                                value: settings.isShowTomorrow,
                                onChanged: (value) async {
                                  await settingsStore.setIsShowTomorrow(value);
                                },
                              ),
                            ),
                            if ((PlatformUtils.isIOS ||
                                PlatformUtils.isAndroid))
                              McListTile(
                                title: Text(l10n.courseReminder),
                                trailing: CupertinoSwitch(
                                  value: settings.isRemind,
                                  onChanged: (bool value) async {
                                    await settingsStore.setIsRemind(value);
                                    if (value && context.mounted) {
                                      await NotificationService.set(context);
                                    }
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: McAnimatedCard(
            child: McCard.elevated(
              padding: EdgeInsets.zero,
              child: Builder(
                builder: (context) {
                  final todayCourses = homeCourses.courses;

                  if (!isLogin &&
                      scheduleState.allCourses.isEmpty &&
                      todayCourses.isEmpty) {
                    return scheduleState.isLoading
                        ? LoadingStateView(
                            title: l10n.loadingSchedule,
                            subtitle: l10n.loadingScheduleSubtitle,
                            compact: true,
                          )
                        : ScheduleImportEmptyState(
                            onImport: () =>
                                context.push<bool>(AppRoutes.htmlImport),
                          );
                  }

                  return todayCourses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: EmptyWidget(
                            title: l10n.noCourseToday,
                            icon: CupertinoIcons.book_fill,
                            subtitle: l10n.noCourseTodaySubtitle,
                          ),
                        )
                      : Column(
                          children: todayCourses.asMap().entries.map((entry) {
                            final index = entry.key;
                            final course = entry.value;
                            final weekdayNames = _getWeekdayNames(context);
                            final time = TimeService.getStartAndEnd(course);
                            final item = ScheduleItem(
                              title: course.courseName,
                              time:
                                  '${l10n.periodRange(course.startUnit, course.endUnit)} ${time.start}-${time.end}',
                              location: course.room,
                              teacher: course.teachers.join(','),
                              description: l10n.scheduleCourseTime(
                                CourseModel.formatWeekRanges(
                                  course.weekIndexes,
                                ),
                                weekdayNames[course.weekday],
                                course.startUnit,
                                course.endUnit,
                              ),
                            );
                            return McAnimatedListItem(
                              index: index,
                              child: _buildScheduleItem(
                                course,
                                item,
                                isTablet,
                                isDark,
                                ScheduleColorResolver.colorForCourse(
                                  course,
                                  isDark
                                      ? style.darkColorPool
                                      : style.lightColorPool,
                                  style.courseColorOverrides,
                                  themeId: isDark
                                      ? style.darkColorPoolThemeId
                                      : style.lightColorPoolThemeId,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
    CourseModel course,
    ScheduleItem item,
    bool isTablet,
    bool isDark,
    Color courseColor,
  ) {
    final colors = context.mc.colors;
    return Material(
      shape: McSmoothCorners.shape(McRadii.cardBorder),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: McRadii.cardBorder,
        customBorder: McSmoothCorners.shape(McRadii.cardBorder),
        onTap: () {
          CourseDetailSheet.show(context, course, isDark: isDark);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Container(
                key: const ValueKey('homeCourseColorBar'),
                width: 5,
                height: 52,
                decoration: ShapeDecoration(
                  color: courseColor,
                  shape: McSmoothCorners.shape(McRadii.xsBorder),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 18,
                          color: colors.secondaryLabel,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: colors.secondaryLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.placemark_fill,
                          size: 18,
                          color: colors.secondaryLabel,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.secondaryLabel,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCourse(ScheduleItem course, bool isTablet) {
    final colors = context.mc.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.title,
          style: TextStyle(
            fontSize: isTablet ? 24 : 22,
            fontWeight: FontWeight.w600,
            color: colors.label,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          children: [
            Icon(
              CupertinoIcons.placemark_fill,
              color: colors.primary,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                course.location,
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          children: [
            Icon(
              CupertinoIcons.person_2_fill,
              color: colors.danger,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                course.teacher,
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: colors.success,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                course.description,
                style: TextStyle(fontSize: isTablet ? 19 : 17),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

List<String> _getWeekdayNames(BuildContext context) {
  final l10n = context.l10n;
  return [
    l10n.sunday,
    l10n.monday,
    l10n.tuesday,
    l10n.wednesday,
    l10n.thursday,
    l10n.friday,
    l10n.saturday,
    l10n.sunday,
  ];
}
