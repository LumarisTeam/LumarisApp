// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeInfo _$TimeInfoFromJson(Map<String, dynamic> json) => TimeInfo(
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  semester: json['semester'] as String?,
);

Map<String, dynamic> _$TimeInfoToJson(TimeInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('startTime', instance.startTime);
  writeNotNull('endTime', instance.endTime);
  writeNotNull('semester', instance.semester);
  return val;
}
