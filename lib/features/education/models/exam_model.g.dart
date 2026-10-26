// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamItem _$ExamItemFromJson(Map<String, dynamic> json) => ExamItem(
  name: json['name'] == null ? '' : parseSchemaString(json['name']),
  examTime: json['time'] == null ? '' : parseSchemaString(json['time']),
  room: json['location'] == null ? '' : parseSchemaString(json['location']),
  seatNo: json['seat'] == null ? '' : parseSchemaString(json['seat']),
);

Map<String, dynamic> _$ExamItemToJson(ExamItem instance) => <String, dynamic>{
  'name': instance.name,
  'time': instance.examTime,
  'location': instance.room,
  'seat': instance.seatNo,
};
