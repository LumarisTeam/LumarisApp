import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Info相关API — v1.yaml tag: InfoV1
class InfoApi {
  /// GET /v1/info/Completion → ApiResponseOfListOfStudyModule
  static Future<List<InfoModel>> getInfoCompletion({
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Info/Completion',
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<InfoModel>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => InfoModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '信息完成度请求失败', -1);
      }
      return apiResponse.data ?? <InfoModel>[];
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// GET /v1/info/Time → ApiResponseOfTimeModel
  static Future<TimeInfo> getTime({bool forceRefresh = false}) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Info/Time',
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<TimeInfo>.parsed(
        rawResponse,
        (data) => TimeInfo.fromJson(Map<String, dynamic>.from(data as Map)),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '时间请求失败', -1);
      }
      return apiResponse.data ?? TimeInfo();
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
