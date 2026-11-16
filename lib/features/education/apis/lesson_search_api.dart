import '../models/api_response.dart';
import '../models/lesson_search_item.dart';
import '../services/edu_http_client_manager.dart';

class LessonSearchApi {
  const LessonSearchApi._();

  static Future<List<LessonSearchItem>> getLessons(String studentId) async {
    final Object? rawResponse = await EduHttpClientManager.instance.get(
      '/lesson-search',
      queryParameters: {'studentId': studentId},
      bypassCache: true,
    );
    final ApiResponse<List<LessonSearchItem>> response =
        ApiResponse<List<LessonSearchItem>>.parsed(
          rawResponse,
          (data) => (data as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(LessonSearchItem.fromJson)
              .toList(growable: false),
        );
    return response.data ?? const [];
  }
}
