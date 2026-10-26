// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  studentId: parseSchemaString(json['studentId']),
  cookie: parseSchemaString(json['cookie']),
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'studentId': instance.studentId,
  'cookie': instance.cookie,
};
