import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'course_model.g.dart';

/// 课程模型类 — v1.yaml schema: CourseActivity
///
/// 用于表示课程的详细信息，包括课程名称、上课时间、地点、教师等。
/// 是应用中核心的数据结构之一，用于课程表展示、查询和管理。
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class CourseModel {
  /// 课程周次索引列表，例如：[1, 2, 3, 5, 6] 表示第1-3周和第5-6周上课
  @JsonKey(fromJson: parseSchemaIntList)
  @HiveField(0)
  List<int> weekIndexes = [];

  /// 授课教师列表
  @JsonKey(fromJson: parseSchemaStringList)
  @HiveField(1)
  List<String> teachers = [];

  /// 上课地点
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(2)
  String room = '';

  /// 课程名称
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(3)
  String courseName = '';

  /// 课程代码
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(4)
  String courseCode = '';

  /// 星期几上课（1-7，1表示周一，7表示周日，与 DateTime.weekday 一致）
  @JsonKey(fromJson: parseSchemaInt)
  @HiveField(5)
  int weekday = 0;

  /// 开始上课的节次（例如：1表示第1节课）
  @JsonKey(fromJson: parseSchemaInt)
  @HiveField(6)
  int startUnit = 0;

  /// 结束上课的节次（例如：2表示第2节课结束）
  @JsonKey(fromJson: parseSchemaInt)
  @HiveField(7)
  int endUnit = 0;

  /// 课程学分
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(8)
  String credits = '';

  /// 课程ID
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(9)
  String lessonId = '';

  /// 上课校区
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(10)
  String campus = '';

  /// 是否为自定义课程
  @JsonKey(fromJson: parseSchemaBool)
  @HiveField(11)
  bool isCustom = false;

  /// 是否使用自定义上下课时间，而不是节次。
  ///
  /// 适配仓库里少数课程没有节次，只给 `HH:mm` 起止时间。渲染时仍会映射到
  /// 最近的节次格，但提醒和详情展示应优先使用 [customStartTime] /
  /// [customEndTime]。
  @JsonKey(fromJson: parseSchemaBool)
  @HiveField(12)
  bool isCustomTime = false;

  /// 自定义开始时间，`HH:mm`；[isCustomTime] 为 false 时为空串。
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(13)
  String customStartTime = '';

  /// 自定义结束时间，`HH:mm`；[isCustomTime] 为 false 时为空串。
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(14)
  String customEndTime = '';

  /// 创建一个新的课程实例
  ///
  /// @param weekIndexes 课程周次索引列表
  /// @param teachers 授课教师列表
  /// @param room 上课地点
  /// @param courseName 课程名称
  /// @param courseCode 课程代码
  /// @param weekday 星期几上课（1-7）
  /// @param startUnit 开始上课的节次
  /// @param endUnit 结束上课的节次
  /// @param credits 课程学分
  /// @param lessonId 课程ID
  /// @param campus 上课校区
  CourseModel({
    List<int>? weekIndexes,
    List<String>? teachers,
    String? room,
    String? courseName,
    String? courseCode,
    int? weekday,
    int? startUnit,
    int? endUnit,
    String? credits,
    String? lessonId,
    String? campus,
    bool? isCustom,
    bool? isCustomTime,
    String? customStartTime,
    String? customEndTime,
  }) {
    this.weekIndexes = weekIndexes ?? [];
    this.teachers = teachers ?? [];
    this.room = room ?? '';
    this.courseName = courseName ?? '';
    this.courseCode = courseCode ?? '';
    this.weekday = weekday ?? 0;
    this.startUnit = startUnit ?? 0;
    this.endUnit = endUnit ?? 0;
    this.credits = credits ?? '';
    this.lessonId = lessonId ?? '';
    this.campus = campus ?? '';
    this.isCustom = isCustom ?? false;
    this.isCustomTime = isCustomTime ?? false;
    this.customStartTime = customStartTime ?? '';
    this.customEndTime = customEndTime ?? '';
  }

  /// 从JSON数据创建课程实例
  ///
  /// @param json JSON格式的课程数据
  /// @return 课程实例
  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  /// 将课程实例转换为JSON数据
  ///
  /// @return JSON格式的课程数据
  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  /// 合并课程名和节次相同的课程，并去重授课教师。
  ///
  /// 课程表和首页都使用这条规则，其他课程字段沿用每组中的第一条课程。
  static List<CourseModel> mergeSameNameCourses(List<CourseModel> courses) {
    final result = <CourseModel>[];
    final used = List<bool>.filled(courses.length, false);

    for (int i = 0; i < courses.length; i++) {
      if (used[i]) continue;

      final current = courses[i];
      final teachersToMerge = <String>[...current.teachers];
      used[i] = true;

      for (int j = i + 1; j < courses.length; j++) {
        if (used[j]) continue;

        final other = courses[j];
        if (current.courseName == other.courseName &&
            current.startUnit == other.startUnit &&
            current.endUnit == other.endUnit) {
          for (final teacher in other.teachers) {
            if (!teachersToMerge.contains(teacher)) {
              teachersToMerge.add(teacher);
            }
          }
          used[j] = true;
        }
      }

      result.add(
        CourseModel(
          weekIndexes: current.weekIndexes,
          teachers: teachersToMerge,
          room: current.room,
          courseName: current.courseName,
          courseCode: current.courseCode,
          weekday: current.weekday,
          startUnit: current.startUnit,
          endUnit: current.endUnit,
          credits: current.credits,
          lessonId: current.lessonId,
          campus: current.campus,
          isCustom: current.isCustom,
          isCustomTime: current.isCustomTime,
          customStartTime: current.customStartTime,
          customEndTime: current.customEndTime,
        ),
      );
    }

    return result;
  }

  /// 格式化周次范围
  ///
  /// 将周次列表转换为易读的范围字符串，例如：[1, 2, 3, 5, 6] 转换为 "1-3,5-6"
  ///
  /// @param weeks 周次列表
  /// @return 格式化后的周次范围字符串
  static String formatWeekRanges(List<int> weeks) {
    if (weeks.isEmpty) return '';
    if (weeks.length == 1) return weeks.first.toString();

    List<String> ranges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        // 连续的周数
        end = weeks[i];
      } else {
        // 不连续，保存当前段
        if (start == end) {
          ranges.add(start.toString());
        } else {
          ranges.add('$start-$end');
        }
        // 开始新的段
        start = weeks[i];
        end = weeks[i];
      }
    }

    // 添加最后一段
    if (start == end) {
      ranges.add(start.toString());
    } else {
      ranges.add('$start-$end');
    }

    return ranges.join(',');
  }
}
