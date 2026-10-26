import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LoginResponse {
  final bool? success;
  final String? studentId;
  final String? cookie;

  LoginResponse({this.success, this.studentId, this.cookie});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  bool get isSuccess => success ?? true;
}
