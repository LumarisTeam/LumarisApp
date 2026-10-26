// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapModel _$MapModelFromJson(Map<String, dynamic> json) => MapModel(
  id: parseSchemaString(json['id']),
  name: parseSchemaString(json['name']),
  category: parseSchemaString(json['category']),
  latitude: parseSchemaString(json['latitude']),
  longitude: parseSchemaString(json['longitude']),
  description: json['description'] as String?,
  address: json['address'] as String?,
  campus: json['campus'] as String?,
  icon: json['icon'] as String?,
  isActive: json['is_active'] as bool,
  sortOrder: parseSchemaString(json['sort_order']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MapModelToJson(MapModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'description': instance.description,
  'address': instance.address,
  'campus': instance.campus,
  'icon': instance.icon,
  'is_active': instance.isActive,
  'sort_order': instance.sortOrder,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
