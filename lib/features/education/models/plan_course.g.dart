// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanCourse _$PlanCourseFromJson(Map<String, dynamic> json) => PlanCourse(
  name: _readName(json, 'name') == null
      ? ""
      : parseSchemaString(_readName(json, 'name')),
  lessonType: _readLessonType(json, 'lessonType') == null
      ? ""
      : parseSchemaString(_readLessonType(json, 'lessonType')),
  examMode: _readExamMode(json, 'examMode') == null
      ? ""
      : parseSchemaString(_readExamMode(json, 'examMode')),
  courseTypeName: _readCourseTypeName(json, 'courseTypeName') == null
      ? ""
      : parseSchemaString(_readCourseTypeName(json, 'courseTypeName')),
  credits: _readCredits(json, 'credits') == null
      ? 0.0
      : parseSchemaDouble(_readCredits(json, 'credits')),
  termStr: _readTermStr(json, 'termStr') == null
      ? ""
      : parseSchemaString(_readTermStr(json, 'termStr')),
);

Map<String, dynamic> _$PlanCourseToJson(PlanCourse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'lessonType': instance.lessonType,
      'examMode': instance.examMode,
      'courseTypeName': instance.courseTypeName,
      'credits': instance.credits,
      'termStr': instance.termStr,
    };
