// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotalData _$TotalDataFromJson(Map<String, dynamic> json) => TotalData(
  name: parseSchemaString(json['name']),
  actual: parseSchemaDouble(json['actual']),
  full: parseSchemaDouble(json['full']),
);

Map<String, dynamic> _$TotalDataToJson(TotalData instance) => <String, dynamic>{
  'name': instance.name,
  'actual': instance.actual,
  'full': instance.full,
};

InfoModel _$InfoModelFromJson(Map<String, dynamic> json) => InfoModel(
  type: parseSchemaString(json['type']),
  total: TotalData.fromJson(json['total'] as Map<String, dynamic>),
  other: _totalDataListFromJson(json['other']),
);

Map<String, dynamic> _$InfoModelToJson(InfoModel instance) => <String, dynamic>{
  'type': instance.type,
  'total': instance.total.toJson(),
  'other': instance.other.map((e) => e.toJson()).toList(),
};
