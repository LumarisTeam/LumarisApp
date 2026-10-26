import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'info_model.g.dart';

/// Maps to v1.yaml schema: CreditInfo
@JsonSerializable(explicitToJson: true)
class TotalData {
  @JsonKey(fromJson: parseSchemaString)
  final String name;
  @JsonKey(fromJson: parseSchemaDouble)
  final double actual;
  @JsonKey(fromJson: parseSchemaDouble)
  final double full;

  TotalData({required this.name, required this.actual, required this.full});

  factory TotalData.fromJson(Map<String, dynamic> json) =>
      _$TotalDataFromJson(json);

  Map<String, dynamic> toJson() => _$TotalDataToJson(this);
}

/// Maps to v1.yaml schema: StudyModule
// 主数据模型类
@JsonSerializable(explicitToJson: true)
class InfoModel {
  @JsonKey(fromJson: parseSchemaString)
  final String type;
  final TotalData total;
  @JsonKey(fromJson: _totalDataListFromJson)
  final List<TotalData> other;

  InfoModel({required this.type, required this.total, required this.other});

  factory InfoModel.fromJson(Map<String, dynamic> json) =>
      _$InfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$InfoModelToJson(this);
}

List<TotalData> _totalDataListFromJson(dynamic value) {
  return (value as List<dynamic>)
      .map((item) => TotalData.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
