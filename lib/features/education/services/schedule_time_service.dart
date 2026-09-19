import 'dart:convert';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import '../apis/course_api.dart';
import '../models/schedule_time_model.dart';

/// 作息表（各校区、各季节的节次时间）取数服务。
///
/// 权威数据在服务端 `GET /v1/course/ScheduleTime`，本地只做缓存：
/// 启动和后台任务先用缓存装载（[loadFromCache]），登录/手动刷新时再拉一次
/// 远端（[fetchFromRemote]）。任何一步失败都保留当前生效的表——远端缓存或
/// `TimeService.builtInTables`——不会让课表时间变空。
class ScheduleTimeService {
  /// 用本地缓存装载作息表。
  ///
  /// 没有缓存或解析失败时保持当前表（首次启动即内置兜底表）。
  static Future<void> loadFromCache() async {
    try {
      if (!PrefsService.isInitialized) {
        return;
      }

      final raw = PrefsService.instance.getString(PrefsKeys.SCHEDULE_TIME_DATA);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final tables = _decode(raw);
      if (tables.isNotEmpty) {
        TimeService.installTables(tables);
      }
    } catch (e, stackTrace) {
      AppLogger.error('读取作息表缓存失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 拉取远端作息表并写入缓存。
  ///
  /// 返回是否成功装载；失败只记日志，调用方不需要处理异常。
  static Future<bool> fetchFromRemote({bool forceRefresh = false}) async {
    try {
      final models =
          await CourseApi.getScheduleTime(forceRefresh: forceRefresh);
      final tables =
          models.map(ScheduleTable.fromModel).toList(growable: false);
      if (tables.isEmpty) {
        return false;
      }

      if (PrefsService.isInitialized) {
        await PrefsService.instance.setString(
          PrefsKeys.SCHEDULE_TIME_DATA,
          jsonEncode(models.map((model) => model.toJson()).toList()),
        );
      }

      TimeService.installTables(tables);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('获取作息表失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 确保作息表已装载（后台 isolate 里没有共享内存，需要各自装载一次）。
  static Future<void> ensureLoaded() async {
    if (TimeService.isUsingRemoteTables) {
      return;
    }
    await loadFromCache();
  }

  static List<ScheduleTable> _decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <ScheduleTable>[];
    }

    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => ScheduleTable.fromModel(
            ScheduleTimeModel.fromJson(Map<String, dynamic>.from(item)),
          ),
        )
        .toList();
  }
}
