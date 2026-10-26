import 'dart:convert';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'auth_service.dart';
import '../apis/info_api.dart';

class InfoService {
  static Future<void> getInfoCompletion({
    UserData? userData,
    bool forceRefresh = false,
  }) async {
    final cookieData = userData ?? await AuthService.getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await InfoApi.getInfoCompletion(
        forceRefresh: forceRefresh,
      );
      final prefs = PrefsService.instance;
      await prefs.setString(
        PrefsKeys.INFO_DATA,
        jsonEncode(response.map((item) => item.toJson()).toList()),
      );
    } catch (e, stackTrace) {
      AppLogger.error('获取学生信息完成度失败', error: e, stackTrace: stackTrace);
    }
  }

  static Future<List<InfoModel>> getInfoList({
    bool forceRefresh = false,
  }) async {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.INFO_DATA);
    final time = prefs.getInt(PrefsKeys.INFO_DATA_TIME);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (!forceRefresh &&
        jsonString != null &&
        time != null &&
        (time - now).abs() < 1000 * 60 * 60 * 3) {
      return _parseInfoList(jsonString);
    }

    await getInfoCompletion(forceRefresh: forceRefresh);
    final refreshed = prefs.getString(PrefsKeys.INFO_DATA);
    if (refreshed == null) {
      return [];
    }

    await prefs.setInt(PrefsKeys.INFO_DATA_TIME, now);
    return _parseInfoList(refreshed);
  }

  static List<InfoModel> _parseInfoList(String jsonString) {
    final list = <InfoModel>[];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      for (final item in jsonList) {
        list.add(InfoModel.fromJson(item as Map<String, dynamic>));
      }
    } catch (e) {
      AppLogger.debug('解析信息完成度数据失败: $e');
    }
    return list;
  }
}
