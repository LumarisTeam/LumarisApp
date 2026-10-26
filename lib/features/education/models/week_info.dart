import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'week_info.g.dart';

@JsonSerializable(explicitToJson: true)
class WeekInfo {
  @JsonKey(fromJson: parseSchemaInt)
  final int week;
  @JsonKey(fromJson: parseSchemaInt)
  final int maxWeek;

  WeekInfo({required this.week, required this.maxWeek});

  factory WeekInfo.fromJson(Map<String, dynamic> json) =>
      _$WeekInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WeekInfoToJson(this);
}
