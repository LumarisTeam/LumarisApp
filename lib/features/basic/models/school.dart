enum Feature {
  /// 日历显示
  timetable('timetable'),

  /// 成绩查询
  gradeQuery('grade_query'),

  /// gpa 计算
  gpaCalculation('gpa_calculation'),

  /// 课程信息
  courseSelection('course_schedule'),

  /// 考试安排
  examSchedule('exam_schedule'),

  /// 登录，必须要有的
  login('login'),

  /// 校车时刻表
  busSchedule('bus_schedule'),

  /// 培养计划
  program('program'),

  /// 学习进度
  studyProgress('study_progress'),

  /// 电费查询
  electricity('electricity'),

  /// 校园卡查询
  payment('payment'),

  /// 校园地图
  map('map');

  /// 其他功能

  const Feature(this.value);
  final String value;

  static Feature fromValue(String value) {
    return Feature.values.firstWhere(
      (f) => f.value == value,
      orElse: () => throw ArgumentError('Invalid feature: $value'),
    );
  }
}

class School {
  static const String defaultCode = 'XAUAT';
  static const int defaultWeekStartDay = DateTime.sunday;

  static List<School> get fallbackList => [
        School(
          code: 'XAUAT',
          name: '西安建筑科技大学',
          website: 'https://xauatapi.xauat.site',
          features: [
            Feature.timetable,
            Feature.gradeQuery,
            Feature.gpaCalculation,
            Feature.courseSelection,
            Feature.examSchedule,
            Feature.login,
            Feature.busSchedule,
            Feature.program,
            Feature.studyProgress,
            Feature.electricity,
            Feature.payment,
            Feature.map,
          ],
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

  final String code;
  final String name;
  final String website;

  /// 学生登录教务系统的地址，用于指引与 HTML 课表导入。
  ///
  /// 与 [website]（后端 API 基址）不同，该字段可以为空——学校尚未登记时
  /// 消费方应回退到 [website]，见 [htmlImportUrl]。
  final String eduSystemUrl;
  final List<Feature> features;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int weekStartDay;

  School({
    required this.code,
    required this.name,
    required this.website,
    this.eduSystemUrl = '',
    required this.features,
    this.enabled = true,
    int? weekStartDay,
    required this.createdAt,
    required this.updatedAt,
  }) : weekStartDay = _normalizeWeekStartDay(weekStartDay);

  bool supports(Feature feature) => features.contains(feature);

  /// HTML 导入时应打开的地址：优先学校登记的教务系统地址，未登记时回退到
  /// [website]（历史行为——这些学校此前就是拿 [website] 导入的）。
  String get htmlImportUrl =>
      eduSystemUrl.trim().isNotEmpty ? eduSystemUrl : website;

  static School? findByCode(List<School> schools, String code) {
    final normalizedCode = code.toUpperCase();
    try {
      return schools.firstWhere((s) => s.code.toUpperCase() == normalizedCode);
    } catch (_) {
      return null;
    }
  }

  static List<School> searchLocally(List<School> schools, String query) {
    if (query.isEmpty) return schools;
    final lower = query.toLowerCase();
    return schools
        .where((s) =>
            s.name.toLowerCase().contains(lower) ||
            s.code.toLowerCase().contains(lower))
        .toList();
  }

  static int _normalizeWeekStartDay(int? weekStartDay) {
    return switch (weekStartDay) {
      DateTime.monday => DateTime.monday,
      DateTime.sunday => DateTime.sunday,
      _ => defaultWeekStartDay,
    };
  }

  static int? _readWeekStartDay(Map<String, dynamic> json) {
    final value = json['week_start_day'];
    return value is int ? value : null;
  }

  /// 容错读取：旧缓存与老版本接口都不含该字段，缺失或类型不符时按空处理。
  static String _readEduSystemUrl(Map<String, dynamic> json) {
    final value = json['edu_system_url'];
    return value is String ? value : '';
  }

  factory School.fromJson(Map<String, dynamic> json) => School(
        code: json['code'] as String,
        name: json['name'] as String,
        website: json['website'] as String,
        eduSystemUrl: _readEduSystemUrl(json),
        features: (json['features'] as List<dynamic>)
            .map((f) => Feature.fromValue(f as String))
            .toList(),
        enabled: json['enabled'] as bool? ?? true,
        weekStartDay: _readWeekStartDay(json),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'website': website,
        'edu_system_url': eduSystemUrl,
        'features': features.map((f) => f.value).toList(),
        'enabled': enabled,
        'week_start_day': weekStartDay,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class SchoolListData {
  final int total;
  final List<School> items;

  SchoolListData({required this.total, required this.items});

  factory SchoolListData.fromJson(Map<String, dynamic> json) => SchoolListData(
        total: json['total'] as int,
        items: (json['items'] as List<dynamic>)
            .map((e) => School.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
