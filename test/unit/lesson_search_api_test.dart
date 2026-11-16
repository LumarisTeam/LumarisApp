import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/apis/lesson_search_api.dart';
import 'package:ios_club_app/features/education/models/lesson_search_item.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'should send the edu session and parse the current term sections',
    () async {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.USER_DATA: jsonEncode({
          'studentId': '12345',
          'cookie': 'test',
        }),
      });
      await PrefsService.init();
      EduHttpClientManager.initialize();
      addTearDown(EduHttpClientManager.resetForTest);

      RequestOptions? request;
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'code': 0,
                  'total': 1,
                  'data': [
                    {
                      'sectionId': '741',
                      'courseCode': 'MATH1001',
                      'courseName': '高等数学',
                      'sectionCode': '01',
                      'semesterName': '第一学期',
                      'capacity': 64,
                      'selectedCount': 56,
                      'remaining': 3,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final List<LessonSearchItem> result = await LessonSearchApi.getLessons(
        '12345',
      );
      expect(request?.uri.path, '/v1/lesson-search');
      expect(request?.uri.queryParameters, {'studentId': '12345'});
      expect(request?.headers['Cookie'], 'test');
      expect(result.single.title, '高等数学');
      expect(result.single.semesterName, '第一学期');
      expect(result.single.remaining, 3);
      expect(result.single.timeText, isEmpty);
    },
  );
}
