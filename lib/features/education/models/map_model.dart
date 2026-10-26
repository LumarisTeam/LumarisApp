import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'map_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MapModel {
  @JsonKey(fromJson: parseSchemaString)
  String id;
  @JsonKey(fromJson: parseSchemaString)
  String name;
  @JsonKey(fromJson: parseSchemaString)
  String category;
  @JsonKey(fromJson: parseSchemaString)
  String latitude;
  @JsonKey(fromJson: parseSchemaString)
  String longitude;
  String? description;
  String? address;
  String? campus;
  String? icon;

  @JsonKey(name: 'is_active')
  bool isActive;

  @JsonKey(name: 'sort_order', fromJson: parseSchemaString)
  String sortOrder;
  DateTime createdAt;
  DateTime updatedAt;

  MapModel({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.description,
    this.address,
    this.campus,
    this.icon,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  static MapModel fromJson(Map<String, dynamic> map) {
    return _$MapModelFromJson(map);
  }

  static Map<String, dynamic> toJson(MapModel instance) {
    return _$MapModelToJson(instance);
  }
}
