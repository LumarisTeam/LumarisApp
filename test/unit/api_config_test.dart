import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/models/school.dart';

void main() {
  group('School fallback', () {
    test('should have default school', () {
      final defaultSchool = School.fallbackList.first;
      expect(defaultSchool, isNotNull);
      expect(defaultSchool.code, equals(School.defaultCode));
      expect(defaultSchool.name, equals('西安建筑科技大学'));
      expect(defaultSchool.website, equals('https://xauatapi.xauat.site'));
    });

    test('should find school by code', () {
      final school = School.findByCode(
        School.fallbackList,
        School.defaultCode,
      );
      expect(school, isNotNull);
      expect(school!.code, equals(School.defaultCode));
    });

    test('should find school code case-insensitively', () {
      final school = School.findByCode(
        School.fallbackList,
        School.defaultCode.toLowerCase(),
      );
      expect(school?.code, School.defaultCode);
    });

    test('should return null for invalid school code', () {
      final school = School.findByCode(
        School.fallbackList,
        'invalid_code',
      );
      expect(school, isNull);
    });

    test('should get fallback schools', () {
      final schools = School.fallbackList;
      expect(schools, isNotEmpty);
      expect(schools.length, greaterThanOrEqualTo(1));
    });

    test('default school code should be valid', () {
      final school = School.findByCode(
        School.fallbackList,
        School.defaultCode,
      );
      expect(school, isNotNull);
    });
  });

  group('School', () {
    test('should create from json', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'week_start_day': DateTime.monday,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.code, equals('test'));
      expect(school.name, equals('测试大学'));
      expect(school.website, equals('https://api.test.edu.cn'));
      expect(school.features, equals([Feature.timetable]));
      expect(school.weekStartDay, equals(DateTime.monday));
    });

    test('should default missing week start day to Sunday', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.weekStartDay, equals(DateTime.sunday));
    });

    test('should default invalid week start day to Sunday', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'week_start_day': DateTime.wednesday,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.weekStartDay, equals(DateTime.sunday));
    });

    test('should default non integer week start day to Sunday', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'week_start_day': '1',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.weekStartDay, equals(DateTime.sunday));
    });

    test('should convert to json', () {
      final school = School(
        code: 'test',
        name: '测试大学',
        website: 'https://api.test.edu.cn',
        features: [Feature.timetable],
        weekStartDay: DateTime.monday,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = school.toJson();
      expect(json['code'], equals('test'));
      expect(json['name'], equals('测试大学'));
      expect(json['website'], equals('https://api.test.edu.cn'));
      expect(json['features'], equals(['timetable']));
      expect(json['week_start_day'], equals(DateTime.monday));
      expect(json['edu_system_url'], equals(''));
    });
  });

  group('School.eduSystemUrl', () {
    Map<String, dynamic> jsonWith(Object? eduSystemUrl) => {
          'code': 'test',
          'name': '测试大学',
          'website': 'https://api.test.edu.cn',
          'features': <String>['timetable'],
          'enabled': true,
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
          'edu_system_url': ?eduSystemUrl,
        };

    test('should read edu system url from json', () {
      final json = jsonWith('https://jwc.test.edu.cn');
      final school = School.fromJson(json);
      expect(school.eduSystemUrl, equals('https://jwc.test.edu.cn'));
    });

    // 旧缓存与老版本接口都不含该字段。这里必须容错而不是抛异常，否则
    // SchoolConfigCache.read() 的 catch 会把用户静默降级到 fallbackList。
    test('should default missing edu system url to empty', () {
      final school = School.fromJson(jsonWith(null));
      expect(school.eduSystemUrl, equals(''));
    });

    test('should default non string edu system url to empty', () {
      final school = School.fromJson(jsonWith(123));
      expect(school.eduSystemUrl, equals(''));
    });

    test('should convert edu system url to json', () {
      final school = School.fromJson(jsonWith('https://jwc.test.edu.cn'));
      expect(school.toJson()['edu_system_url'],
          equals('https://jwc.test.edu.cn'));
    });

    test('htmlImportUrl should prefer edu system url', () {
      final json = jsonWith('https://jwc.test.edu.cn');
      final school = School.fromJson(json);
      expect(school.htmlImportUrl, equals('https://jwc.test.edu.cn'));
    });

    // 未登记教务系统地址的学校必须保持改动前的导入行为。
    test('htmlImportUrl should fall back to website when unset', () {
      final school = School.fromJson(jsonWith(null));
      expect(school.htmlImportUrl, equals('https://api.test.edu.cn'));
    });

    test('htmlImportUrl should fall back to website when blank', () {
      final school = School.fromJson(jsonWith('   '));
      expect(school.htmlImportUrl, equals('https://api.test.edu.cn'));
    });

    test('fallback school should keep falling back to website', () {
      final school = School.fallbackList.first;
      expect(school.eduSystemUrl, isEmpty);
      expect(school.htmlImportUrl, equals(school.website));
    });
  });
}
