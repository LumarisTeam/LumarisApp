// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusModel _$BusModelFromJson(Map<String, dynamic> json) => BusModel(
  records: _busItemsFromJson(json['records']),
  total: parseSchemaInt(json['total']),
);

Map<String, dynamic> _$BusModelToJson(BusModel instance) => <String, dynamic>{
  'records': instance.records.map((e) => e.toJson()).toList(),
  'total': instance.total,
};

BusItem _$BusItemFromJson(Map<String, dynamic> json) => BusItem(
  lineName: parseSchemaString(json['lineName']),
  description: parseSchemaString(json['description']),
  departureStation: parseSchemaString(json['departureStation']),
  arrivalStation: parseSchemaString(json['arrivalStation']),
  runTime: parseSchemaString(json['runTime']),
  arrivalStationTime: parseSchemaString(json['arrivalStationTime']),
);

Map<String, dynamic> _$BusItemToJson(BusItem instance) => <String, dynamic>{
  'lineName': instance.lineName,
  'description': instance.description,
  'departureStation': instance.departureStation,
  'arrivalStation': instance.arrivalStation,
  'runTime': instance.runTime,
  'arrivalStationTime': instance.arrivalStationTime,
};
