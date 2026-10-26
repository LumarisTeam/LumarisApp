// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TileConfiguration _$TileConfigurationFromJson(Map<String, dynamic> json) =>
    TileConfiguration(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      isVisible: json['isVisible'] as bool,
    );

Map<String, dynamic> _$TileConfigurationToJson(TileConfiguration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'isVisible': instance.isVisible,
    };

TileConfigurationList _$TileConfigurationListFromJson(
  Map<String, dynamic> json,
) => TileConfigurationList(
  configurations: (json['configurations'] as List<dynamic>)
      .map((e) => TileConfiguration.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$TileConfigurationListToJson(
  TileConfigurationList instance,
) => <String, dynamic>{
  'configurations': instance.configurations.map((e) => e.toJson()).toList(),
  'lastModified': instance.lastModified.toIso8601String(),
};
