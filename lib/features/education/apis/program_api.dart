import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Program相关API — v1.yaml tag: ProgramV1
class ProgramApi {
  /// GET /v1/program → ApiResponseOfListOfPlanCourse
  static Future<List<PlanCourse>> getProgram(
    String studentId, {
    String? name,
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Program',
        queryParameters: {'id': studentId, 'name': name},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<PlanCourse>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => PlanCourse.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '培养方案请求失败', -1);
      }
      return apiResponse.data ?? <PlanCourse>[];
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// GET /v1/program/GetDic → ApiResponseOfDictionaryOfstringAndListOfPlanCourse
  static Future<Map<String, List<PlanCourse>>> getProgramDic(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Program/GetDic',
        queryParameters: {'id': studentId},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<Map<String, List<PlanCourse>>>.parsed(
        rawResponse,
        (data) {
          final map = Map<String, dynamic>.from(data as Map);
          return map.map((key, value) {
            final courses = (value as List<dynamic>)
                .map((e) => PlanCourse.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            return MapEntry(key, courses);
          });
        },
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '培养方案字典请求失败', -1);
      }
      return apiResponse.data ?? <String, List<PlanCourse>>{};
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
