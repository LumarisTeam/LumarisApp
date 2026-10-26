// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edu_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(error: parseSchemaString(json['error']));

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{'error': instance.error};

ErrorWithMessageResponse _$ErrorWithMessageResponseFromJson(
  Map<String, dynamic> json,
) => ErrorWithMessageResponse(
  message: parseSchemaString(json['message']),
  error: parseSchemaString(json['error']),
);

Map<String, dynamic> _$ErrorWithMessageResponseToJson(
  ErrorWithMessageResponse instance,
) => <String, dynamic>{'message': instance.message, 'error': instance.error};

CreateElectricitySubscriptionRequest
_$CreateElectricitySubscriptionRequestFromJson(Map<String, dynamic> json) =>
    CreateElectricitySubscriptionRequest(
      url: parseSchemaString(json['url']),
      email: parseSchemaString(json['email']),
      threshold: parseSchemaNullableDouble(json['threshold']),
    );

Map<String, dynamic> _$CreateElectricitySubscriptionRequestToJson(
  CreateElectricitySubscriptionRequest instance,
) {
  final val = <String, dynamic>{'url': instance.url, 'email': instance.email};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('threshold', instance.threshold);
  return val;
}

ElectricitySubscriptionQueryResponse
_$ElectricitySubscriptionQueryResponseFromJson(Map<String, dynamic> json) =>
    ElectricitySubscriptionQueryResponse(
      email: parseSchemaString(json['email']),
      hasSubscription: parseSchemaBool(json['hasSubscription']),
      subscriptionId: parseSchemaString(json['subscriptionId']),
      threshold: parseSchemaDouble(json['threshold']),
    );

Map<String, dynamic> _$ElectricitySubscriptionQueryResponseToJson(
  ElectricitySubscriptionQueryResponse instance,
) => <String, dynamic>{
  'email': instance.email,
  'hasSubscription': instance.hasSubscription,
  'subscriptionId': instance.subscriptionId,
  'threshold': instance.threshold,
};

ElectricitySubscriptionResponse _$ElectricitySubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => ElectricitySubscriptionResponse(
  id: parseSchemaString(json['id']),
  url: parseSchemaString(json['url']),
  email: parseSchemaString(json['email']),
  threshold: parseSchemaDouble(json['threshold']),
  isActive: parseSchemaBool(json['isActive']),
  createdAt: parseSchemaDateTime(json['createdAt']),
  updatedAt: parseSchemaDateTime(json['updatedAt']),
  nextCheckAt: parseSchemaDateTime(json['nextCheckAt']),
  lastCheckedAt: parseSchemaNullableDateTime(json['lastCheckedAt']),
  lastKnownBalance: parseSchemaNullableDouble(json['lastKnownBalance']),
  lastAlertedAt: parseSchemaNullableDateTime(json['lastAlertedAt']),
  lastAlertedBalance: parseSchemaNullableDouble(json['lastAlertedBalance']),
  lastErrorMessage: parseSchemaString(json['lastErrorMessage']),
);

Map<String, dynamic> _$ElectricitySubscriptionResponseToJson(
  ElectricitySubscriptionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'email': instance.email,
  'threshold': instance.threshold,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'nextCheckAt': instance.nextCheckAt.toIso8601String(),
  'lastCheckedAt': instance.lastCheckedAt?.toIso8601String(),
  'lastKnownBalance': instance.lastKnownBalance,
  'lastAlertedAt': instance.lastAlertedAt?.toIso8601String(),
  'lastAlertedBalance': instance.lastAlertedBalance,
  'lastErrorMessage': instance.lastErrorMessage,
};

ExamResponse _$ExamResponseFromJson(Map<String, dynamic> json) => ExamResponse(
  exams: _examListFromJson(json['exams']),
  canClick: parseSchemaBool(json['canClick']),
  error: json['error'] as String?,
);

Map<String, dynamic> _$ExamResponseToJson(ExamResponse instance) =>
    <String, dynamic>{
      'exams': instance.exams.map((e) => e.toJson()).toList(),
      'canClick': instance.canClick,
      'error': instance.error,
    };

SemesterResult _$SemesterResultFromJson(Map<String, dynamic> json) =>
    SemesterResult(data: _semesterListFromJson(json['data']));

Map<String, dynamic> _$SemesterResultToJson(SemesterResult instance) =>
    <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};

TimeModel _$TimeModelFromJson(Map<String, dynamic> json) => TimeModel(
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
);

Map<String, dynamic> _$TimeModelToJson(TimeModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('startTime', instance.startTime);
  writeNotNull('endTime', instance.endTime);
  return val;
}
