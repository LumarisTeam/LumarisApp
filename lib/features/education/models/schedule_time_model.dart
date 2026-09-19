import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'schedule_time_model.g.dart';

/// 作息时间表模型 — v1.yaml schema: ScheduleTimeModel
///
/// 对应 `GET /v1/course/ScheduleTime` 返回数组中的一项：某个校区在某个季节的
/// 作息时间。`start` / `end` 的下标就是课表节次（0 起，草堂的第 0 节是早自习），
/// 空串表示该节次没课，与服务端 `ScheduleTimeService`、本地 `TimeService`
/// 的下标约定一致。
///
/// 服务端不做校区判断，同一个校区可能返回多项（雁塔按冬季/夏季分），
/// 由调用方结合课程的校区字段和当前日期自行选择。
@JsonSerializable(explicitToJson: true)
class ScheduleTimeModel {
  /// 校区名称，例如「草堂校区」「雁塔校区」
  @JsonKey(readValue: _readEitherCase, fromJson: parseSchemaString)
  final String campusName;

  /// 适用时间区间，例如「05/01~09/30」；不区分季节的校区为空串
  @JsonKey(readValue: _readEitherCase, fromJson: parseSchemaString)
  final String time;

  /// 各节次的开始时间
  @JsonKey(readValue: _readEitherCase, fromJson: parseSchemaStringList)
  final List<String> start;

  /// 各节次的结束时间
  @JsonKey(readValue: _readEitherCase, fromJson: parseSchemaStringList)
  final List<String> end;

  const ScheduleTimeModel({
    this.campusName = '',
    this.time = '',
    this.start = const <String>[],
    this.end = const <String>[],
  });

  factory ScheduleTimeModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleTimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleTimeModelToJson(this);
}

/// 兼容服务端可能返回的 PascalCase 字段名（`CampusName`、`Time`…）。
Object? _readEitherCase(Map json, String key) {
  if (json.containsKey(key)) {
    return json[key];
  }
  final pascal = key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
  return json[pascal];
}
