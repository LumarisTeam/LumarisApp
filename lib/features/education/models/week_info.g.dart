// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeekInfo _$WeekInfoFromJson(Map<String, dynamic> json) => WeekInfo(
  week: parseSchemaInt(json['week']),
  maxWeek: parseSchemaInt(json['maxWeek']),
);

Map<String, dynamic> _$WeekInfoToJson(WeekInfo instance) => <String, dynamic>{
  'week': instance.week,
  'maxWeek': instance.maxWeek,
};
