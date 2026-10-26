import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';

void main() {
  group('SemesterModel', () {
    test('should create instance with provided values', () {
      const testSemester = '2023-2024-1';
      const testName = '2023-2024学年第一学期';

      final semester = SemesterModel(semester: testSemester, name: testName);

      expect(semester.semester, testSemester);
      expect(semester.name, testName);
    });

    test('should create instance from JSON', () {
      final json = {'value': '2023-2024-2', 'text': '2023-2024学年第二学期'};

      final semester = SemesterModel.fromJson(json);

      expect(semester.semester, '2023-2024-2');
      expect(semester.name, '2023-2024学年第二学期');
    });

    test('should convert to JSON correctly', () {
      const testSemester = '2022-2023-1';
      const testName = '2022-2023学年第一学期';

      final semester = SemesterModel(semester: testSemester, name: testName);

      final json = semester.toJson();

      expect(json, isA<Map<String, String>>());
      expect(json['value'], testSemester);
      expect(json['text'], testName);
    });

    test('should handle empty strings', () {
      const emptyString = '';

      final semester = SemesterModel(semester: emptyString, name: emptyString);

      expect(semester.semester, emptyString);
      expect(semester.name, emptyString);

      // Test JSON conversion with empty strings
      final json = semester.toJson();
      expect(json['value'], emptyString);
      expect(json['text'], emptyString);
    });

    test('should handle special characters', () {
      const specialSemester = '2023-2024-1#special';
      const specialName = '2023-2024学年第一学期（特殊）';

      final semester = SemesterModel(
        semester: specialSemester,
        name: specialName,
      );

      expect(semester.semester, specialSemester);
      expect(semester.name, specialName);

      // Test JSON conversion with special characters
      final json = semester.toJson();
      expect(json['value'], specialSemester);
      expect(json['text'], specialName);
    });

    test('should handle very long strings', () {
      final longSemester = '2023-2024-1'.padRight(1000, 'x');
      final longName = '2023-2024学年第一学期'.padRight(1000, 'x');

      final semester = SemesterModel(semester: longSemester, name: longName);

      expect(semester.semester, longSemester);
      expect(semester.name, longName);
      expect(semester.semester.length, 1000);
      expect(semester.name.length, 1000);

      // Test JSON conversion with long strings
      final json = semester.toJson();
      expect(json['value'], longSemester);
      expect(json['text'], longName);
    });

    test('should have consistent JSON serialization and deserialization', () {
      const originalSemester = '2023-2024-1';
      const originalName = '2023-2024学年第一学期';

      // Create original instance
      final original = SemesterModel(
        semester: originalSemester,
        name: originalName,
      );

      // Convert to JSON
      final json = original.toJson();

      // Convert back to instance
      final fromJson = SemesterModel.fromJson(json);

      // Verify the instances are equivalent
      expect(fromJson.semester, originalSemester);
      expect(fromJson.name, originalName);

      // Verify JSON conversion is consistent
      expect(fromJson.toJson(), equals(json));
    });

    test('should handle different JSON key names', () {
      // This test verifies that fromJson only uses the expected keys
      final jsonWithExtraKeys = {
        'value': '2023-2024-1',
        'text': '2023-2024学年第一学期',
        'extraKey1': 'extraValue1',
        'extraKey2': 'extraValue2',
      };

      final semester = SemesterModel.fromJson(jsonWithExtraKeys);

      // Should ignore extra keys and only use the expected ones
      expect(semester.semester, '2023-2024-1');
      expect(semester.name, '2023-2024学年第一学期');
    });

    test('should handle missing JSON keys by fallback to empty string', () {
      // Test with missing value key
      final jsonMissingValue = {'text': '2023-2024学年第一学期'};

      // Test with missing text key
      final jsonMissingText = {'value': '2023-2024-1'};

      final missingValue = SemesterModel.fromJson(jsonMissingValue);
      final missingText = SemesterModel.fromJson(jsonMissingText);

      expect(missingValue.semester, '');
      expect(missingValue.name, '2023-2024学年第一学期');
      expect(missingText.semester, '2023-2024-1');
      expect(missingText.name, '');
    });
  });
}
