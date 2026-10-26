import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client_manager.dart';

class SchoolApi {
  /// 需求1：返回学校列表
  static Future<SchoolListData> listSchools() async {
    final response = await BasicHttpClientManager.instance.get(
      '/api/v1/schools',
    );
    return SchoolListData.fromJson(Map<String, dynamic>.from(response['data']));
  }

  /// 需求2：根据代号返回学校详情及支持功能
  /// GET /api/v1/schools/:code
  static Future<School> getSchool(String code) async {
    code = code.toUpperCase();
    final response = await BasicHttpClientManager.instance.get(
      '/api/v1/schools/$code',
    );
    return School.fromJson(Map<String, dynamic>.from(response['data']));
  }
}
