// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkModel _$LinkModelFromJson(Map<String, dynamic> json) => LinkModel(
  key: json['key'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String?,
  url: json['url'] as String,
  description: json['description'] as String?,
  index: (json['index'] as num).toInt(),
);

Map<String, dynamic> _$LinkModelToJson(LinkModel instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'icon': instance.icon,
  'url': instance.url,
  'description': instance.description,
  'index': instance.index,
};

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
      index: (json['index'] as num).toInt(),
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => LinkModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LinkModel>[],
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'index': instance.index,
      'links': instance.links.map((e) => e.toJson()).toList(),
    };
