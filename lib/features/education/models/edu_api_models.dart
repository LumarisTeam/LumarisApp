import 'package:json_annotation/json_annotation.dart';

import 'exam_model.dart';
import 'semester_model.dart';
import 'schema_parsers.dart';

part 'edu_api_models.g.dart';

@JsonSerializable(explicitToJson: true)
class ErrorResponse {
  @JsonKey(fromJson: parseSchemaString)
  final String error;

  const ErrorResponse({required this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ErrorWithMessageResponse {
  @JsonKey(fromJson: parseSchemaString)
  final String message;
  @JsonKey(fromJson: parseSchemaString)
  final String error;

  const ErrorWithMessageResponse({required this.message, required this.error});

  factory ErrorWithMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorWithMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorWithMessageResponseToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CreateElectricitySubscriptionRequest {
  @JsonKey(fromJson: parseSchemaString)
  final String url;
  @JsonKey(fromJson: parseSchemaString)
  final String email;
  @JsonKey(fromJson: parseSchemaNullableDouble)
  final double? threshold;

  const CreateElectricitySubscriptionRequest({
    required this.url,
    required this.email,
    this.threshold,
  });

  factory CreateElectricitySubscriptionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateElectricitySubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateElectricitySubscriptionRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ElectricitySubscriptionQueryResponse {
  @JsonKey(fromJson: parseSchemaString)
  final String email;
  @JsonKey(fromJson: parseSchemaBool)
  final bool hasSubscription;
  @JsonKey(fromJson: parseSchemaString)
  final String subscriptionId;
  @JsonKey(fromJson: parseSchemaDouble)
  final num threshold;

  const ElectricitySubscriptionQueryResponse({
    required this.email,
    required this.hasSubscription,
    required this.subscriptionId,
    required this.threshold,
  });

  factory ElectricitySubscriptionQueryResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ElectricitySubscriptionQueryResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ElectricitySubscriptionQueryResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ElectricitySubscriptionResponse {
  @JsonKey(fromJson: parseSchemaString)
  final String id;
  @JsonKey(fromJson: parseSchemaString)
  final String url;
  @JsonKey(fromJson: parseSchemaString)
  final String email;
  @JsonKey(fromJson: parseSchemaDouble)
  final double threshold;
  @JsonKey(fromJson: parseSchemaBool)
  final bool isActive;
  @JsonKey(fromJson: parseSchemaDateTime)
  final DateTime createdAt;
  @JsonKey(fromJson: parseSchemaDateTime)
  final DateTime updatedAt;
  @JsonKey(fromJson: parseSchemaDateTime)
  final DateTime nextCheckAt;
  @JsonKey(fromJson: parseSchemaNullableDateTime)
  final DateTime? lastCheckedAt;
  @JsonKey(fromJson: parseSchemaNullableDouble)
  final double? lastKnownBalance;
  @JsonKey(fromJson: parseSchemaNullableDateTime)
  final DateTime? lastAlertedAt;
  @JsonKey(fromJson: parseSchemaNullableDouble)
  final double? lastAlertedBalance;
  @JsonKey(fromJson: parseSchemaString)
  final String lastErrorMessage;

  const ElectricitySubscriptionResponse({
    required this.id,
    required this.url,
    required this.email,
    required this.threshold,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.nextCheckAt,
    this.lastCheckedAt,
    this.lastKnownBalance,
    this.lastAlertedAt,
    this.lastAlertedBalance,
    required this.lastErrorMessage,
  });

  factory ElectricitySubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$ElectricitySubscriptionResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ElectricitySubscriptionResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExamResponse {
  @JsonKey(fromJson: _examListFromJson)
  final List<ExamItem> exams;
  @JsonKey(fromJson: parseSchemaBool)
  final bool canClick;
  final String? error;

  const ExamResponse({required this.exams, required this.canClick, this.error});

  factory ExamResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SemesterResult {
  @JsonKey(fromJson: _semesterListFromJson)
  final List<SemesterModel> data;

  const SemesterResult({required this.data});

  factory SemesterResult.fromJson(Map<String, dynamic> json) =>
      _$SemesterResultFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterResultToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TimeModel {
  final String? startTime;
  final String? endTime;

  const TimeModel({this.startTime, this.endTime});

  factory TimeModel.fromJson(Map<String, dynamic> json) =>
      _$TimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimeModelToJson(this);
}

List<ExamItem> _examListFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((item) => ExamItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  return <ExamItem>[];
}

List<SemesterModel> _semesterListFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((item) => SemesterModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  return <SemesterModel>[];
}
