import 'dart:convert';

import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/exam_model.dart';
import 'package:ios_club_app/features/education/models/exam_result.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import '../apis/exam_api.dart';

class ExamService {
  static Future<void> getExam({
    UserData? userData,
    bool forceRefresh = false,
  }) async {
    final cookieData = userData ?? await AuthService.getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await ExamApi.getExam(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.EXAM_DATA, jsonEncode(response.toJson()));
    } catch (e, stackTrace) {
      AppLogger.error('获取考试信息失败', error: e, stackTrace: stackTrace);
    }
  }

  static Future<ExamResult> getExamResult({bool isRefresh = false}) async {
    final now = DateTime.now();
    final prefs = PrefsService.instance;

    final cacheResult = _checkCache(prefs, now, isRefresh);
    if (!cacheResult.$1 && cacheResult.$2.isNotEmpty) {
      final parsedExams = _parseExamItems(cacheResult.$2, now);
      if (parsedExams.isNotEmpty) {
        return ExamResult.success(parsedExams);
      }
    }

    final cookieData = await AuthService.getUserData();
    if (cookieData == null) {
      return ExamResult.error('exam_auth_required');
    }

    final result = await _fetchExamData(
      cookieData,
      now,
      forceRefresh: isRefresh,
    );
    if (result.$1 && result.$2 != null) {
      await _updateCache(prefs, result.$2!, now);
    }

    return result.$3;
  }

  static (bool needRefresh, String jsonString) _checkCache(
    SharedPreferences prefs,
    DateTime now,
    bool isRefresh,
  ) {
    final jsonString = prefs.getString(PrefsKeys.EXAM_DATA) ?? '';
    final examTime = prefs.getInt(PrefsKeys.EXAM_TIME);

    var hasUpcomingExams = false;
    if (jsonString.isNotEmpty) {
      final upcomingExams = _parseExamItems(jsonString, now);
      hasUpcomingExams = upcomingExams.isNotEmpty;
    }

    final cacheDuration =
        hasUpcomingExams ? const Duration(hours: 2) : const Duration(hours: 24);

    final isCached = examTime != null &&
        now.difference(DateTime.fromMicrosecondsSinceEpoch(examTime)) <
            cacheDuration &&
        jsonString.isNotEmpty;

    return (isRefresh || !isCached, jsonString);
  }

  static Future<(bool, ExamResponse?, ExamResult)> _fetchExamData(
    UserData cookieData,
    DateTime now, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await ExamApi.getExam(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      final prefs = PrefsService.instance;
      final existingData = prefs.getString(PrefsKeys.EXAM_DATA) ?? '';
      final mergedData = _mergeExamData(existingData, response, now);
      final parsedExams = _parseExamItemsFromResponse(mergedData, now);
      final result = parsedExams.isEmpty
          ? ExamResult.empty()
          : ExamResult.success(parsedExams);
      return (true, mergedData, result);
    } on AuthenticationException catch (e) {
      AppLogger.debug('认证失败: $e');
      return (false, null, ExamResult.error('auth_failed'));
    } on NetworkException catch (e) {
      AppLogger.debug('网络错误: $e');
      return (false, null, ExamResult.networkError(e.message));
    } catch (e) {
      AppLogger.debug('获取考试数据失败: $e');
      return (false, null, ExamResult.error('fetch_failed'));
    }
  }

  static Future<void> _updateCache(
    SharedPreferences prefs,
    ExamResponse response,
    DateTime now,
  ) async {
    final parsedExams = _parseExamItemsFromResponse(response, now);
    if (parsedExams.isNotEmpty) {
      await prefs.setString(PrefsKeys.EXAM_DATA, jsonEncode(response.toJson()));
      await prefs.setInt(PrefsKeys.EXAM_TIME, now.microsecondsSinceEpoch);
    } else {
      await prefs.remove(PrefsKeys.EXAM_DATA);
      await prefs.remove(PrefsKeys.EXAM_TIME);
    }
  }

  static List<ExamItem> _parseExamItems(String jsonString, DateTime now) {
    if (jsonString.isEmpty) {
      return <ExamItem>[];
    }

    try {
      return _parseExamItemsFromResponse(
        ExamResponse.fromJson(jsonDecode(jsonString) as Map<String, dynamic>),
        now,
      );
    } catch (e) {
      AppLogger.debug('JSON解析失败: $e');
      return <ExamItem>[];
    }
  }

  static List<ExamItem> _parseExamItemsFromResponse(
    ExamResponse response,
    DateTime now,
  ) {
    final list = <ExamItemAndEndTime>[];
    for (final item in response.exams) {
      try {
        final endTime = _parseExamTime(item.examTime, now);
        if (endTime != null && !now.isAfter(endTime)) {
          list.add(ExamItemAndEndTime(
              name: item.name,
              examTime: item.examTime,
              room: item.room,
              seatNo: item.seatNo,
              endTime: endTime));
        }
      } catch (e) {
        AppLogger.debug('时间解析失败: $e');
      }
    }
    AppLogger.debug('解析完成，找到${list.length}个有效考试');
    list.sort((a, b) => a.endTime.compareTo(b.endTime));
    return list;
  }

  static ExamResponse _mergeExamData(
    String existingExams,
    ExamResponse newExams,
    DateTime now,
  ) {
    if (existingExams.isEmpty) {
      return newExams;
    }

    try {
      final existingExamList = ExamResponse.fromJson(
        jsonDecode(existingExams) as Map<String, dynamic>,
      ).exams;
      final newExamList = newExams.exams;
      final examMap = <String, ExamItem>{};

      for (final exam in existingExamList) {
        examMap['${exam.name}_${exam.examTime}_${exam.room}'] = exam;
      }
      for (final exam in newExamList) {
        examMap['${exam.name}_${exam.examTime}_${exam.room}'] = exam;
      }

      final validExams = examMap.values.where((exam) {
        final endTime = _parseExamTime(exam.examTime, now);
        return endTime != null && !now.isAfter(endTime);
      }).toList();

      return ExamResponse(exams: validExams, canClick: newExams.canClick);
    } catch (e) {
      AppLogger.debug('合并考试数据失败: $e');
      return newExams;
    }
  }

  static DateTime? _parseExamTime(String examTime, DateTime now) {
    final match =
        RegExp(r'(\d{4})-(\d{2})-(\d{2}).*?(\d{2}):(\d{2})-(\d{2}):(\d{2})')
            .firstMatch(examTime);
    if (match == null) {
      final matchType2 =
          RegExp(r'(\d{4})-(\d{2})-(\d{2}).*?(\d{2}):(\d{2})~(\d{2}):(\d{2})')
              .firstMatch(examTime);
      if (matchType2 == null) {
        return null;
      }

      return DateTime(
        int.parse(matchType2.group(1)!),
        int.parse(matchType2.group(2)!),
        int.parse(matchType2.group(3)!),
        int.parse(matchType2.group(6)!),
        int.parse(matchType2.group(7)!),
      );
    }

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(6)!),
      int.parse(match.group(7)!),
    );
  }
}

class ExamItemAndEndTime extends ExamItem {
  DateTime endTime;

  ExamItemAndEndTime({
    required super.name,
    required super.examTime,
    required super.room,
    required super.seatNo,
    required this.endTime,
  });
}
