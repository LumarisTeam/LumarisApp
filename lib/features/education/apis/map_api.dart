import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/map_model.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';

class MapApi {
  static Future<List<MapModel>> getMap() async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get('/Map');
      final apiResponse = ApiResponse<List<MapModel>>.parsed(
        rawResponse,
        (data) => (data as List<dynamic>)
            .map((item) => MapModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
      return apiResponse.data ?? [];
    } catch (e) {
      AppLogger.error('获取地图数据失败: $e');
      rethrow;
    }
  }
}
