import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/schedule_time_model.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Course相关API — v1.yaml tag: CourseV1
class CourseApi {
  /// GET /v1/course → ApiResponseOfListOfCourseActivity
  static Future<List<CourseModel>> getCourse(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Course',
        queryParameters: {'studentId': studentId},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<CourseModel>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(
          apiResponse.message ?? '课程请求失败',
          -1,
        );
      }
      return apiResponse.data ?? <CourseModel>[];
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// GET /v1/course/ScheduleTime → ListOfScheduleTimeModel
  ///
  /// 获取各校区、各季节的作息时间表（草堂一份，雁塔冬季/夏季各一份）。
  /// 服务端返回的是裸数组，也兼容带 `data` 包装的响应；服务端不做校区判断，
  /// 由调用方按课程的校区字段和当前日期自行选择。
  static Future<List<ScheduleTimeModel>> getScheduleTime({
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/v1/course/ScheduleTime',
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<List<ScheduleTimeModel>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map(
              (e) => ScheduleTimeModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(
          apiResponse.message ?? '时间表请求失败',
          -1,
        );
      }
      return apiResponse.data ?? <ScheduleTimeModel>[];
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
