class LessonSearchItem {
  const LessonSearchItem({
    required this.courseCode,
    required this.courseName,
    required this.sectionCode,
    required this.sectionName,
    required this.teacher,
    required this.timeText,
    required this.location,
    required this.semesterName,
    required this.capacity,
    required this.selectedCount,
    required this.remaining,
  });

  factory LessonSearchItem.fromJson(Map<String, dynamic> json) {
    return LessonSearchItem(
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      sectionCode: json['sectionCode'] as String? ?? '',
      sectionName: json['sectionName'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      timeText: json['timeText'] as String? ?? '',
      location: json['location'] as String? ?? '',
      semesterName: json['semesterName'] as String? ?? '',
      capacity: json['capacity'] as int,
      selectedCount: json['selectedCount'] as int,
      remaining: json['remaining'] as int,
    );
  }

  final String courseCode;
  final String courseName;
  final String sectionCode;
  final String sectionName;
  final String teacher;
  final String timeText;
  final String location;
  final String semesterName;
  final int capacity;
  final int selectedCount;
  final int remaining;

  String get title => courseName.isEmpty ? sectionName : courseName;

  bool matches(List<String> terms, {required bool onlyAvailable}) {
    if (onlyAvailable && remaining <= 0) return false;
    final String searchable = '$title $courseCode $teacher'.toLowerCase();
    return terms.every(searchable.contains);
  }
}
