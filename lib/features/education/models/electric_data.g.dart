// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electric_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricData _$ElectricDataFromJson(Map<String, dynamic> json) => ElectricData(
  timestamp: _timestampFromJson(_readTimestamp(json, 'timestamp')),
  value: _valueFromJson(_readValue(json, 'value')),
);

Map<String, dynamic> _$ElectricDataToJson(ElectricData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
    };
