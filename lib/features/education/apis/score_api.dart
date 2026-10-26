import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Score相关API — v1.yaml tag: ScoreV1
class ScoreApi {
  /// GET /v1/score/Semester → ApiResponseOfSemesterResult
  static Future<SemesterResult> getSemester(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Score/Semester',
        queryParameters: {'studentId': studentId},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<SemesterModel>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => SemesterModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '学期请求失败', -1);
      }
      return SemesterResult(data: apiResponse.data ?? []);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// GET /v1/score → ApiResponseOfListOfScoreResponse
  static Future<List<ScoreModel>> getScore(
    String studentId,
    String semester, {
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Score',
        queryParameters: {'studentId': studentId, 'semester': semester},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<ScoreModel>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => ScoreModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '成绩请求失败', -1);
      }
      return apiResponse.data ?? <ScoreModel>[];
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// GET /v1/score/ThisSemester → ApiResponseOfSemesterItem
  static Future<SemesterModel> getThisSemester({
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Score/ThisSemester',
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<SemesterModel>.parsed(
        rawResponse,
        (data) =>
            SemesterModel.fromJson(Map<String, dynamic>.from(data as Map)),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '当前学期请求失败', -1);
      }
      return apiResponse.data ?? SemesterModel(semester: '', name: '');
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
