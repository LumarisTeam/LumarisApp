// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_time_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleTimeModel _$ScheduleTimeModelFromJson(Map<String, dynamic> json) =>
    ScheduleTimeModel(
      campusName: _readEitherCase(json, 'campusName') == null
          ? ''
          : parseSchemaString(_readEitherCase(json, 'campusName')),
      time: _readEitherCase(json, 'time') == null
          ? ''
          : parseSchemaString(_readEitherCase(json, 'time')),
      start: _readEitherCase(json, 'start') == null
          ? const <String>[]
          : parseSchemaStringList(_readEitherCase(json, 'start')),
      end: _readEitherCase(json, 'end') == null
          ? const <String>[]
          : parseSchemaStringList(_readEitherCase(json, 'end')),
    );

Map<String, dynamic> _$ScheduleTimeModelToJson(ScheduleTimeModel instance) =>
    <String, dynamic>{
      'campusName': instance.campusName,
      'time': instance.time,
      'start': instance.start,
      'end': instance.end,
    };
