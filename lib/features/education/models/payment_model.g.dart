// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  turnoverType: json['turnoverType'] as String,
  datetimeStr: json['datetimeStr'] as String,
  resume: json['resume'] as String,
  amount: _amountFromJson(json['tranamt']),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'turnoverType': instance.turnoverType,
      'datetimeStr': instance.datetimeStr,
      'resume': instance.resume,
      'tranamt': instance.amount,
    };

PaymentData _$PaymentDataFromJson(Map<String, dynamic> json) => PaymentData(
  _paymentsFromJson(json['records']),
  _balanceFromJson(json['balance']),
);

Map<String, dynamic> _$PaymentDataToJson(PaymentData instance) =>
    <String, dynamic>{
      'records': instance.payments.map((e) => e.toJson()).toList(),
      'balance': instance.balance,
    };
