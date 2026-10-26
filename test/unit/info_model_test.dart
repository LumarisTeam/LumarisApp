import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';

void main() {
  group('TotalData', () {
    test('should parse numeric values and fallback null values to zero', () {
      final data = TotalData.fromJson(<String, dynamic>{
        'name': '完成度',
        'actual': 35,
        'full': null,
      });

      expect(data.name, '完成度');
      expect(data.actual, 35.0);
      expect(data.full, 0.0);
      expect(data.toJson(), <String, dynamic>{
        'name': '完成度',
        'actual': 35.0,
        'full': 0.0,
      });
    });
  });

  group('InfoModel', () {
    test('should deserialize and serialize correctly', () {
      final json = <String, dynamic>{
        'type': 'completion',
        'total': <String, dynamic>{'name': '总计', 'actual': 80, 'full': 100},
        'other': <Map<String, dynamic>>[
          <String, dynamic>{'name': '课程', 'actual': 50, 'full': 60},
          <String, dynamic>{'name': '实验', 'actual': 30.5, 'full': 40},
        ],
      };

      final model = InfoModel.fromJson(json);
      expect(model.type, 'completion');
      expect(model.total.name, '总计');
      expect(model.total.actual, 80.0);
      expect(model.total.full, 100.0);
      expect(model.other.length, 2);
      expect(model.other[0].name, '课程');
      expect(model.other[1].actual, 30.5);

      final encoded = model.toJson();
      expect(encoded['type'], 'completion');
      expect((encoded['other'] as List).length, 2);
    });

    test('should throw when required fields are missing or wrong type', () {
      expect(
        () => InfoModel.fromJson(<String, dynamic>{
          'type': 'x',
          'total': <String, dynamic>{'name': 'x', 'actual': 1, 'full': 2},
          'other': 'invalid',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
