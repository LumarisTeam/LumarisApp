import 'package:json_annotation/json_annotation.dart';

import 'edu_api_models.dart';

part 'time_info.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TimeInfo {
  final String? startTime;
  final String? endTime;
  final String? semester;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, String>? extra;

  TimeInfo({this.startTime, this.endTime, this.semester, this.extra});

  factory TimeInfo.fromJson(Map<String, dynamic> json) {
    final generated = _$TimeInfoFromJson(json);
    final timeModel = TimeModel.fromJson(json);
    final extra = <String, String>{};
    for (final entry in json.entries) {
      if (entry.key == 'startTime' ||
          entry.key == 'endTime' ||
          entry.key == 'semester') {
        continue;
      }
      final value = entry.value;
      if (value is String) {
        extra[entry.key] = value;
      }
    }

    return TimeInfo(
      startTime: timeModel.startTime ?? generated.startTime,
      endTime: timeModel.endTime ?? generated.endTime,
      semester: generated.semester,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$TimeInfoToJson(this);

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }

  String? operator [](String key) {
    switch (key) {
      case 'startTime':
        return startTime;
      case 'endTime':
        return endTime;
      case 'semester':
        return semester;
      default:
        return extra?[key];
    }
  }
}
