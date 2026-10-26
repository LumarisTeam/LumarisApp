import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Bus相关API
class BusApi {
  /// 获取校巴信息
  static Future<BusModel> getBus({
    String? dayDate,
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Bus/${dayDate ?? ''}',
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<BusItem>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => BusItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '校巴请求失败', -1);
      }
      return BusModel(
        records: apiResponse.data ?? [],
        total: apiResponse.total ?? (apiResponse.data?.length ?? 0),
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取新的校巴数据
  static Future<BusModel> getBusNewData(
    String time, {
    String loc = 'ALL',
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Bus/NewData/$time',
        queryParameters: {'loc': loc},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<BusItem>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => BusItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '新校巴请求失败', -1);
      }
      return BusModel(
        records: apiResponse.data ?? [],
        total: apiResponse.total ?? (apiResponse.data?.length ?? 0),
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取旧的校巴数据
  static Future<BusModel> getBusOldData(
    String time, {
    bool isShow = false,
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Bus/OldData/$time',
        queryParameters: {'isShow': isShow},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<BusItem>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => BusItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '旧校巴请求失败', -1);
      }
      return BusModel(
        records: apiResponse.data ?? [],
        total: apiResponse.total ?? (apiResponse.data?.length ?? 0),
      );
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
