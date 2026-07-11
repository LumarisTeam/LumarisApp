import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'bus_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BusModel {
  @JsonKey(fromJson: _busItemsFromJson)
  List<BusItem> records;
  @JsonKey(fromJson: parseSchemaInt)
  final int total;

  BusModel({
    required this.records,
    required this.total,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) =>
      _$BusModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BusItem {
  /// 线路名称
  @JsonKey(fromJson: parseSchemaString)
  final String lineName;

  /// 描述
  @JsonKey(fromJson: parseSchemaString)
  final String description;

  /// 出发站
  @JsonKey(fromJson: parseSchemaString)
  final String departureStation;

  /// 到达站
  @JsonKey(fromJson: parseSchemaString)
  final String arrivalStation;
  @JsonKey(fromJson: parseSchemaString)
  String runTime;

  /// 到达终点所需时间
  @JsonKey(fromJson: parseSchemaString)
  String arrivalStationTime;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String arrivalTime = '';

  BusItem({
    required this.lineName,
    required this.description,
    required this.departureStation,
    required this.arrivalStation,
    required this.runTime,
    required this.arrivalStationTime,
  }) {
    if (runTime.isNotEmpty) {
      // 确保字符串包含 ':' 字符再执行 substring 操作
      if (runTime.contains(':') && runTime.length > 5) {
        runTime = runTime.substring(0, runTime.lastIndexOf(':'));
      }
    }
    if (arrivalStationTime.isNotEmpty) {
      // 确保字符串长度大于1再执行 substring 操作
      if (arrivalStationTime.length > 1) {
        arrivalStationTime = arrivalStationTime.substring(1);
      }
      var s = arrivalStationTime.split(':');
      // 确保分割后的数组至少有2个元素
      if (s.length >= 2) {
        int h = int.parse(s[0]);
        int m = int.parse(s[1]);
        arrivalStationTime = '${h.toString().padLeft(2, '0')}小时 '
            '${m.toString().padLeft(2, '0')}分钟';
        if (runTime.isNotEmpty && runTime.contains(':')) {
          var runTimeSplit = runTime.split(':');
          if (runTimeSplit.length >= 2) {
            h += int.parse(runTimeSplit[0]);
            m += int.parse(runTimeSplit[1]);
            if (m >= 60) {
              m -= 60;
              h++;
            }
            arrivalTime = '$h:${m < 10 ? '0$m' : m}';
          }
        }
      }
    }
  }

  factory BusItem.fromJson(Map<String, dynamic> json) =>
      _$BusItemFromJson(json);

  Map<String, dynamic> toJson() => _$BusItemToJson(this);
}

List<BusItem> _busItemsFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((item) => BusItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  return <BusItem>[];
}
