import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/schedule_time_model.dart';

void main() {
  group('ScheduleTimeModel', () {
    test('should parse camelCase payload served by the API', () {
      final model = ScheduleTimeModel.fromJson(<String, dynamic>{
        'campusName': '草堂校区',
        'start': <String>['8:00', '8:30'],
        'end': <String>['8:20', '9:15'],
      });

      expect(model.campusName, '草堂校区');
      // 草堂不分季节，服务端不下发 time 字段
      expect(model.time, '');
      expect(model.start, <String>['8:00', '8:30']);
      expect(model.end, <String>['8:20', '9:15']);
    });

    test('should parse PascalCase payload with season range', () {
      final model = ScheduleTimeModel.fromJson(<String, dynamic>{
        'CampusName': '雁塔校区',
        'Time': '05/01~09/30',
        'Start': <String>['', '8:00'],
        'End': <String>['', '8:50'],
      });

      expect(model.campusName, '雁塔校区');
      expect(model.time, '05/01~09/30');
      expect(model.start, <String>['', '8:00']);
      expect(model.end, <String>['', '8:50']);
    });

    test('should fall back to defaults when fields are missing or null', () {
      final missing = ScheduleTimeModel.fromJson(<String, dynamic>{});
      final nulls = ScheduleTimeModel.fromJson(<String, dynamic>{
        'campusName': null,
        'time': null,
        'start': null,
        'end': null,
      });

      expect(missing.campusName, '');
      expect(missing.time, '');
      expect(missing.start, isEmpty);
      expect(missing.end, isEmpty);
      expect(nulls.campusName, '');
      expect(nulls.start, isEmpty);
      expect(nulls.end, isEmpty);
    });

    test('should round-trip through json', () {
      const model = ScheduleTimeModel(
        campusName: '雁塔校区',
        time: '10/01~04/30',
        start: <String>['', '8:00'],
        end: <String>['', '8:50'],
      );

      final decoded = ScheduleTimeModel.fromJson(model.toJson());

      expect(decoded.campusName, '雁塔校区');
      expect(decoded.time, '10/01~04/30');
      expect(decoded.start, <String>['', '8:00']);
      expect(decoded.end, <String>['', '8:50']);
    });
  });
}
