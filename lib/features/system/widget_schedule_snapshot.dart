import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

/// iOS 小组件的课表快照。
///
/// Widget Extension 读不到 App 的 Hive/SharedPreferences，也没法复用 Dart 侧的
/// 周次换算、校区作息表和季节判断。所以这里把「整学期课程 + 作息表 + 学期起点」
/// 一次性序列化进 App Group，由 WidgetKit 在设备上自行推算今日/明日课表。
///
/// 这样 App 不在前台、后台任务没被系统调度时，小组件也能按节次自动切换，
/// 不再依赖 App 反复写入当天的课程列表。
class WidgetScheduleSnapshot {
  const WidgetScheduleSnapshot._();

  /// 快照结构版本，字段有增减时同步递增，方便小组件侧做兼容。
  static const int version = 1;

  /// 构建写入 App Group 的快照 JSON。
  static Map<String, dynamic> build({
    required List<CourseModel> courses,
    required List<ScheduleTable> tables,
    required String? semesterStart,
    required String? semesterEnd,
    required int weekStartDay,
    DateTime? now,
  }) {
    return {
      'version': version,
      'updatedAt': (now ?? DateTime.now()).toIso8601String(),
      'semesterStart': _normalizeDate(semesterStart),
      'semesterEnd': _normalizeDate(semesterEnd),
      'weekStartDay': WeekStartUtils.normalizeWeekStartDay(weekStartDay),
      'defaultCampus': TimeService.defaultCampusName,
      'tables': _withDefaultCampusTable(tables).map(_tableToJson).toList(),
      'courses': courses.where(_isUsable).map(_courseToJson).toList(),
    };
  }

  /// 节次时间只对「有星期、有节次、有课名」的课程有意义，其余直接丢弃，
  /// 免得小组件侧还要再做一遍防御。
  static bool _isUsable(CourseModel course) {
    return course.courseName.isNotEmpty &&
        course.weekday >= DateTime.monday &&
        course.weekday <= DateTime.sunday &&
        course.startUnit > 0 &&
        course.endUnit >= course.startUnit;
  }

  static Map<String, dynamic> _courseToJson(CourseModel course) {
    return {
      'name': course.courseName,
      'room': course.room,
      'teachers': course.teachers,
      'weekday': course.weekday,
      'startUnit': course.startUnit,
      'endUnit': course.endUnit,
      'weeks': course.weekIndexes,
      'campus': TimeService.resolveCampusName(course),
      if (course.isCustomTime) ...<String, dynamic>{
        'isCustomTime': true,
        'customStartTime': course.customStartTime,
        'customEndTime': course.customEndTime,
      },
    };
  }

  static Map<String, dynamic> _tableToJson(ScheduleTable table) {
    return {
      'campus': table.campusName,
      'range': table.timeRange,
      'start': table.start,
      'end': table.end,
    };
  }

  /// 节次查不到校区时小组件会退回默认校区，快照里必须保证该表一定存在。
  static List<ScheduleTable> _withDefaultCampusTable(
    List<ScheduleTable> tables,
  ) {
    final defaultCampus = TimeService.defaultCampusName;
    final hasDefault = tables.any(
      (table) => table.campusName == defaultCampus,
    );
    if (hasDefault) {
      return tables;
    }

    return [
      ...tables,
      TimeService.builtInTables.firstWhere(
        (table) => table.campusName == TimeService.caoTangCampus,
      ),
    ];
  }

  /// 统一成 `yyyy-MM-dd`，小组件侧只需要一种日期格式。
  static String? _normalizeDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(raw);
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year.toString().padLeft(4, '0')}-$month-$day';
    } catch (_) {
      return null;
    }
  }
}
