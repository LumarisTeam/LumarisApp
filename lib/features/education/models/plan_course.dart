import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'plan_course.g.dart';

@JsonSerializable(explicitToJson: true)
class PlanCourse {
  @JsonKey(readValue: _readName, fromJson: parseSchemaString)
  String name;
  @JsonKey(readValue: _readLessonType, fromJson: parseSchemaString)
  String lessonType;
  @JsonKey(readValue: _readExamMode, fromJson: parseSchemaString)
  String examMode;
  @JsonKey(readValue: _readCourseTypeName, fromJson: parseSchemaString)
  String courseTypeName;
  @JsonKey(readValue: _readCredits, fromJson: parseSchemaDouble)
  double credits;
  @JsonKey(readValue: _readTermStr, fromJson: parseSchemaString)
  String termStr;

  PlanCourse({
    this.name = "",
    this.lessonType = "",
    this.examMode = "",
    this.courseTypeName = "",
    this.credits = 0.0,
    this.termStr = "",
  });

  Map<String, dynamic> toJson() => _$PlanCourseToJson(this);

  factory PlanCourse.fromJson(Map<String, dynamic> json) =>
      _$PlanCourseFromJson(json);

  // 将对象序列化为JSON字符串
  String toJsonString() => json.encode(toJson());

  // 从JSON字符串创建PlanCourse对象
  factory PlanCourse.fromJsonString(String jsonString) =>
      PlanCourse.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}

Object? _readName(Map json, String key) => json[key] ?? json['Name'];

Object? _readLessonType(Map json, String key) =>
    json[key] ?? json['LessonType'];

Object? _readExamMode(Map json, String key) => json[key] ?? json['ExamMode'];

Object? _readCourseTypeName(Map json, String key) =>
    json[key] ?? json['CourseTypeName'];

Object? _readCredits(Map json, String key) => json[key] ?? json['Credits'];

Object? _readTermStr(Map json, String key) => json[key] ?? json['TermStr'];

class PlanCourseList {
  List<PlanCourse> courses;
  String term;

  PlanCourseList({this.courses = const [], this.term = ""});

  // 将对象转换为Map以便JSON编码
  Map<String, dynamic> toJson() => {
    term: courses.map((course) => course.toJson()).toList(),
  };

  // 从Map创建PlanCourseList对象
  factory PlanCourseList.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return PlanCourseList();
    }

    // 获取第一个键值对
    String term = json.keys.first;
    List<dynamic> courseData = json[term];

    return PlanCourseList(
      term: term,
      courses: courseData
          .map((courseJson) => PlanCourse.fromJson(courseJson))
          .toList(),
    );
  }

  factory PlanCourseList.fromMap(String term, List<dynamic> courses) =>
      PlanCourseList(
        term: term,
        courses: courses.map<PlanCourse>((e) {
          if (e is PlanCourse) {
            return e;
          }
          return PlanCourse.fromJson(e as Map<String, dynamic>);
        }).toList(),
      );
}
