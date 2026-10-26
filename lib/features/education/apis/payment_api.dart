import 'package:dio/dio.dart';
import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
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

  /// 获取校园卡离线支付码原文（二维码由客户端渲染）。
  ///
  /// 支付码有时效，必须绕过请求缓存：缓存拦截器给 `/payment.*` 的默认策略是
  /// 一分钟，直接读缓存会拿到已经失效的码。
  static Future<String> getPaymentQrCodePayload(
    String id, [
    String? password,
  ]) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Payment/$id/qrcode',
        queryParameters: _passwordQueryParameters(password),
        bypassCache: true,
        options: Options(
          // 支付码在服务端要连续访问两次校园卡上游（可能还要登录），
          // 默认 10 秒经常不够，与 EduApi 侧 30 秒的超时对齐。
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Old 端点直接返回 { payload }；同时兼容 V1 的 { data, code, message } 信封。
      final apiResponse = ApiResponse<dynamic>.parsed(
        rawResponse,
        (data) => data,
      );
      final data = apiResponse.data;
      final payload = data is Map
          ? (data['payload']?.toString().trim() ?? '')
          : (data?.toString().trim() ?? '');

      if (!apiResponse.isSuccess || payload.isEmpty) {
        throw NetworkException(apiResponse.message ?? '支付码获取失败', -1);
      }
      return payload;
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
