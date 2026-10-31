import 'dart:convert';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';
import 'package:ios_club_app/features/education/services/warehouse_import_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import '../models/edu_fetch_models.dart';
import '../apis/info_api.dart';

class EduTimeService {
  static Future<void> syncTime() async {
    await fetchTimeInfoFromRemote();
  }

  static Future<TimeInfo?> fetchTimeInfoFromRemote({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await InfoApi.getTime(forceRefresh: forceRefresh);
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.TIME_DATA, jsonEncode(response.toJson()));
      return response;
    } catch (e, stackTrace) {
      AppLogger.error('获取时间信息失败', error: e, stackTrace: stackTrace);
    }

    return null;
  }

  static Future<TimeInfo> getTimeInfo({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) async {
    final snapshot = await getTimeSnapshot(policy: policy);
    return _withImportedFallback(snapshot.data);
  }

  static Future<TimeInfo> getTime({bool isRefresh = false}) async {
    return getTimeInfo(
      policy: isRefresh ? FetchPolicy.refresh : FetchPolicy.localFirst,
    );
  }

  static Future<FetchSnapshot<TimeInfo>> getTimeSnapshot({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) async {
    final localTime = readTimeInfoFromPrefs();

    switch (policy) {
      case FetchPolicy.localFirst:
        if (localTime.startTime != null || localTime.endTime != null) {
          return FetchSnapshot<TimeInfo>(
            data: localTime,
            isFromLocal: true,
            isStale: false,
          );
        }
        return _refreshTimeInfo(fallbackTime: localTime);
      case FetchPolicy.refresh:
      case FetchPolicy.fallbackToLocal:
        return _refreshTimeInfo(fallbackTime: localTime);
    }
  }

  static Future<WeekInfo> getWeek({
    bool isRefresh = false,
    int weekStartDay = School.defaultWeekStartDay,
  }) async {
    final time = await getTimeInfo(
      policy: isRefresh ? FetchPolicy.refresh : FetchPolicy.localFirst,
    );
    if (time.startTime == null || time.endTime == null) {
      return WeekInfo(week: 0, maxWeek: 0);
    }

    final startTime = DateTime.parse(time.startTime!);
    final endTime = DateTime.parse(time.endTime!);
    final now = DateTime.now();
    final effectiveWeekStartDay = time.extra?['imported'] == '1'
        ? (WarehouseImportStore.read()?.config?.firstDayOfWeek ?? weekStartDay)
        : weekStartDay;

    final startWeek = WeekStartUtils.getWeekStart(startTime, effectiveWeekStartDay);
    final currentWeek = WeekStartUtils.getWeekStart(now, effectiveWeekStartDay);
    final endWeek = WeekStartUtils.getWeekStart(endTime, effectiveWeekStartDay);

    final week = currentWeek.difference(startWeek).inDays ~/ 7 + 1;
    final maxWeek = endWeek.difference(startWeek).inDays ~/ 7 + 1;
    return WeekInfo(week: week, maxWeek: maxWeek);
  }

  /// 统一的周数计算工具方法
  static int getWeekIndexByStartTime(
    DateTime date,
    DateTime startTime, {
    int weekStartDay = School.defaultWeekStartDay,
  }) {
    return WeekStartUtils.getWeekIndexByStartTime(
      date,
      startTime,
      weekStartDay: weekStartDay,
    );
  }

  /// 没有学校服务端学期信息时，用适配仓库导入的开学日期兜底。
  ///
  /// 游客导入的课表没有 `/Time` 接口，若这里返回空值，当前周会停在 0，
  /// 提醒和小组件也无法按周筛选。仅在起点缺失时兜底，登录态仍以学校数据为准。
  static TimeInfo _withImportedFallback(TimeInfo time) {
    if (time.startTime != null && time.endTime != null) return time;

    final imported = WarehouseImportStore.read();
    final start = imported?.config?.semesterStartDate;
    final startDate = start == null ? null : DateTime.tryParse(start);
    if (startDate == null) return time;

    final totalWeeks = imported?.config?.semesterTotalWeeks ?? 20;
    final endDate = startDate.add(Duration(days: totalWeeks * 7 - 1));
    return TimeInfo(
      startTime: _formatDate(startDate),
      endTime: _formatDate(endDate),
      semester: time.semester,
      extra: <String, String>{...?time.extra, 'imported': '1'},
    );
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  static TimeInfo readTimeInfoFromPrefs() {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.TIME_DATA);
    if (jsonString == null || jsonString.isEmpty) {
      return TimeInfo();
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return TimeInfo.fromJson(decoded);
    } catch (e) {
      AppLogger.debug('解析时间数据失败: $e');
      return TimeInfo();
    }
  }

  static Future<FetchSnapshot<TimeInfo>> _refreshTimeInfo({
    required TimeInfo fallbackTime,
  }) async {
    try {
      final time = await fetchTimeInfoFromRemote(forceRefresh: true);
      if (time != null) {
        return FetchSnapshot<TimeInfo>(
          data: time,
          isFromLocal: false,
          isStale: false,
        );
      }
    } catch (e) {
      AppLogger.debug('刷新时间数据失败: $e');
    }

    final hasFallback =
        fallbackTime.startTime != null || fallbackTime.endTime != null;
    return FetchSnapshot<TimeInfo>(
      data: fallbackTime,
      isFromLocal: true,
      isStale: hasFallback,
    );
  }
}
