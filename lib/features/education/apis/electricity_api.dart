import '../models/api_response.dart';
import '../models/electric_data.dart';
import '../models/edu_api_models.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Electricity 相关 API
class ElectricityApi {
  /// 获取当前电费余额
  static Future<double?> getCurrentBalance({String? url}) async {
    try {
      final trimmedUrl = url?.trim();
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Electricity',
        queryParameters: trimmedUrl == null || trimmedUrl.isEmpty
            ? null
            : <String, dynamic>{'url': trimmedUrl},
      );

      final apiResponse = ApiResponse<double>.parsed(rawResponse, (data) {
        if (data is num) return data.toDouble();
        if (data is String) return double.parse(data);
        throw NetworkException('电费余额格式错误: ${data.runtimeType}', -1);
      });

      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '电费余额请求失败', -1);
      }
      return apiResponse.data;
    } on NotFoundException {
      return null;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取按小时聚合的周用电明细
  static Future<List<ElectricData>> getWeeklyData({String? url}) async {
    try {
      final trimmedUrl = url?.trim();

      final rawResponse = await EduHttpClientManager.instance.get(
        '/Electricity/WeeklyData',
        queryParameters: trimmedUrl == null || trimmedUrl.isEmpty
            ? null
            : <String, dynamic>{'url': trimmedUrl},
      );

      final apiResponse = ApiResponse<List<ElectricData>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map(
              (item) => ElectricData.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );

      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '电费周明细请求失败', -1);
      }
      return apiResponse.data ?? [];
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取电费充值页面地址
  static Future<String?> getRechargeUrl({String? url}) async {
    try {
      final trimmedUrl = url?.trim();

      final rawResponse = await EduHttpClientManager.instance.get(
        '/Electricity/RechargeUrl',
        queryParameters: trimmedUrl == null || trimmedUrl.isEmpty
            ? null
            : <String, dynamic>{'url': trimmedUrl},
      );

      final apiResponse = ApiResponse<String>.parsed(
        rawResponse,
        (data) => data as String,
      );

      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '电费充值地址请求失败', -1);
      }
      return apiResponse.data;
    } on NotFoundException {
      return null;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 创建电费订阅
  static Future<ElectricitySubscriptionResponse> createSubscription(
    CreateElectricitySubscriptionRequest request,
  ) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.post(
        '/Electricity/Subscriptions',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<ElectricitySubscriptionResponse>.parsed(
        rawResponse,
        (data) => ElectricitySubscriptionResponse.fromJson(
          Map<String, dynamic>.from(data as Map),
        ),
      );

      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '电费订阅创建失败', -1);
      }
      return apiResponse.data!;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 查询电费订阅状态
  static Future<ElectricitySubscriptionQueryResponse> getSubscription(
    String email,
  ) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Electricity/Subscriptions',
        queryParameters: <String, dynamic>{'email': email.trim()},
        bypassCache: true,
      );

      final apiResponse =
          ApiResponse<ElectricitySubscriptionQueryResponse>.parsed(
            rawResponse,
            (data) => ElectricitySubscriptionQueryResponse.fromJson(
              Map<String, dynamic>.from(data as Map),
            ),
          );

      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '电费订阅查询失败', -1);
      }
      return apiResponse.data!;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 删除电费订阅
  static Future<void> deleteSubscription(String id) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.delete(
        '/Electricity/Subscriptions/${id.trim()}',
      );

      final apiResponse = ApiResponse.parsed(rawResponse, (data) => data);

      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '电费订阅删除失败', -1);
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
