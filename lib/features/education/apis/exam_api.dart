import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/exam_model.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Exam相关API — v1.yaml tag: ExamV1
class ExamApi {
  /// GET /v1/exam → ApiResponseOfListOfExamInfo
  static Future<ExamResponse> getExam(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Exam',
        queryParameters: {'studentId': studentId},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<ExamItem>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => ExamItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '考试请求失败', -1);
      }
      return ExamResponse(exams: apiResponse.data ?? [], canClick: true);
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
