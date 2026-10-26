import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'score_model.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 1)
/// Maps to v1.yaml schema: ScoreResponse
class ScoreModel {
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(0)
  String name;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(1)
  String lessonCode;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(2)
  String lessonName;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(3)
  String grade;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(4)
  String gpa;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(5)
  String gradeDetail;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(6)
  String credit;
  @JsonKey(fromJson: parseSchemaBool)
  @HiveField(7)
  bool isMinor;

  ScoreModel({
    this.name = '',
    this.lessonCode = '',
    this.lessonName = '',
    this.grade = '',
    this.gpa = '',
    this.gradeDetail = '',
    this.credit = '',
    this.isMinor = false,
  });

  // 如果需要从 JSON 创建对象
  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 2)
class ScoreList {
  @HiveField(0)
  List<ScoreModel> list;
  @HiveField(1)
  SemesterModel semester;

  Map<String, dynamic> toJson() => _$ScoreListToJson(this);

  factory ScoreList.fromJson(Map<String, dynamic> json) =>
      _$ScoreListFromJson(json);

  ScoreList({required this.semester, required this.list});

  static double? _tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  static double _calculateGpaFromCourses(List<ScoreModel> courses) {
    double totalCredits = 0;
    double weightedPoints = 0;

    final courseDic = <String, ScoreModel>{};

    for (final item in courses) {
      if (item.lessonCode.isEmpty) continue;
      if (!courseDic.containsKey(item.lessonCode)) {
        courseDic[item.lessonCode] = item;
      } else {
        final existing = courseDic[item.lessonCode]!;
        final existingGpa = _tryParse(existing.gpa);
        final newGpa = _tryParse(item.gpa);
        if (existingGpa == null || newGpa == null) continue;
        if (newGpa > existingGpa) {
          courseDic[item.lessonCode] = item;
        }
      }
    }

    for (final item in courseDic.values) {
      final gpaVal = _tryParse(item.gpa);
      final credVal = _tryParse(item.credit);
      if (gpaVal == null || credVal == null || credVal == 0) continue;

      totalCredits += credVal;
      weightedPoints += credVal * gpaVal;
    }

    for (final item in courses) {
      if (item.isMinor) continue;

      final gpaVal = _tryParse(item.gpa);
      final credVal = _tryParse(item.credit);
      if (gpaVal == null || credVal == null || credVal == 0) continue;

      totalCredits += credVal;
      weightedPoints += credVal * gpaVal;
    }

    return totalCredits > 0 ? weightedPoints / totalCredits : 0.0;
  }

  /// 总学分
  double get totalCredit {
    double credit = 0;
    for (var item in list) {
      final gpa = _tryParse(item.gpa);
      final cred = _tryParse(item.credit);
      if (gpa == null || cred == null || cred == 0) continue;
      if (gpa == 0) continue;
      credit += cred;
    }
    return credit;
  }

  /// 总绩点
  double get totalGpa {
    return _calculateGpaFromCourses(list);
  }

  /// 总课程数
  int get totalCourse {
    return list.where((x) {
      final gpa = _tryParse(x.gpa);
      if (gpa == null) return false;
      if (gpa == 0) return false;
      if (_tryParse(x.credit) == null || _tryParse(x.credit) == 0) return false;
      return true;
    }).length;
  }

  static double getTotalGpa(List<ScoreList> scoreList) {
    if (scoreList.isEmpty) return 0.0;
    final courses = <ScoreModel>[];
    for (final item in scoreList) {
      courses.addAll(item.list);
    }
    return _calculateGpaFromCourses(courses);
  }

  static double getTotalCredit(List<ScoreList> scoreList) {
    double total = 0;
    for (var item in scoreList) {
      total += item.totalCredit;
    }
    return total;
  }

  static int getTotalCourse(List<ScoreList> scoreList) {
    int total = 0;
    for (var item in scoreList) {
      total += item.totalCourse;
    }
    return total;
  }
}
