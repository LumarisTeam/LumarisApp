// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleItem _$ScheduleItemFromJson(Map<String, dynamic> json) => ScheduleItem(
  title: json['title'] as String,
  time: json['time'] as String,
  location: json['location'] as String,
  teacher: json['teacher'] as String,
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$ScheduleItemToJson(ScheduleItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'time': instance.time,
      'location': instance.location,
      'teacher': instance.teacher,
      'description': instance.description,
    };
