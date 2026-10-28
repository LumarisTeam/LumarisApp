import 'package:dio/dio.dart';
import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/payment_qr_code.dart';
import 'package:ios_club_app/features/education/models/raw_string_response.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Payment相关API
class PaymentApi {
  static Map<String, dynamic>? _passwordQueryParameters(String? password) {
    final normalizedPassword = password?.trim();
    if (normalizedPassword == null || normalizedPassword.isEmpty) {
      return null;
    }
    return {'password': normalizedPassword};
  }

  /// 获取缴费信息
  static Future<RawStringResponse> getPayment(
    String id, [
    String? password,
  ]) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Payment/$id',
        queryParameters: _passwordQueryParameters(password),
      );
      final apiResponse = ApiResponse<String>.parsed(
        rawResponse,
        (data) => data?.toString() ?? '',
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '缴费信息请求失败', -1);
      }
      return RawStringResponse(apiResponse.data ?? '');
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取缴费流水
  static Future<PaymentData> getPaymentTurnover(
    String id, [
    String? password,
  ]) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Payment/$id/turnover',
        queryParameters: _passwordQueryParameters(password),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.parsed(
        rawResponse,
        (data) => Map<String, dynamic>.from(data as Map),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw NetworkException(apiResponse.message ?? '缴费流水请求失败', -1);
      }

      final turnoverData = apiResponse.data!;
      final records = (turnoverData['records'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final balance =
          double.tryParse(turnoverData['balance']?.toString() ?? '0') ?? 0;
      return PaymentData(records, balance);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取校园卡支付码内容（Base64 载荷 + 离线/在线模式），二维码由客户端渲染。
  ///
  /// 支付码有时效，必须绕过请求缓存：缓存拦截器给 `/payment.*` 的默认策略是
  /// 一分钟，直接读缓存会拿到已经失效的码。
  static Future<PaymentQrCode> getPaymentQrCodePayload(
    String id, [
    String? password,
  ]) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Payment/$id/qrcode',
        queryParameters: _passwordQueryParameters(password),
        bypassCache: true,
        options: Options(
          // 支付码在服务端要连续访问多个校园卡上游接口（可能还要登录），
          // 默认 10 秒经常不够，与 EduApi 侧 30 秒的超时对齐。
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Old 端点直接返回 { payload, mode }；同时兼容 V1 的 { data, code, message } 信封。
      final apiResponse = ApiResponse<dynamic>.parsed(
        rawResponse,
        (data) => data,
      );
      final data = apiResponse.data;

      if (!apiResponse.isSuccess || data is! Map) {
        throw NetworkException(apiResponse.message ?? '支付码获取失败', -1);
      }

      try {
        return PaymentQrCode.fromJson(Map<String, dynamic>.from(data));
      } on FormatException {
        throw NetworkException('支付码格式错误', -1);
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static void _handleError(dynamic e) {
    if (e is! NetworkException) {
      throw NetworkException('未知错误', -1);
    }
  }
}
