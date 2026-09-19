/// SharedPreferences 键统一管理
class PrefsKeys {
  /// 用户相关
  static const String USERNAME = 'username';
  static const String PASSWORD = 'password';
  static const String USER_DATA = 'user_data';
  static const String LAST_FETCH_TIME = 'last_fetch_time';

  /// 课程相关
  /// @deprecated 已迁移到 Hive (CourseRepository)，保留此 Key 仅用于迁移逻辑，禁止新代码写入
  @Deprecated(
      'Migrated to Hive via CourseRepository. Do not write new data to this key.')
  static const String COURSE_DATA = 'course_data';
  static const String IGNORE_DATA = 'ignore_data';
  static const String COURSE_LAST_FETCH_TIME = 'course_last_fetch_time';

  /// 学期相关
  static const String SEMESTER_DATA = 'semester_data';
  static const String SEMESTER_TIME = 'semester_time';

  /// 成绩相关
  /// @deprecated 已迁移到 Hive (ScoreRepository)，保留此 Key 仅用于迁移逻辑，禁止新代码写入
  @Deprecated(
      'Migrated to Hive via ScoreRepository. Do not write new data to this key.')
  static const String ALL_SCORE_DATA = 'all_score_data';
  static const String LAST_SCORE_TIME = 'last_Score_time';
  static const String THIS_SEMESTER_DATA = 'this_semester_data';

  /// 考试相关
  static const String EXAM_DATA = 'exam_data';
  static const String EXAM_TIME = 'exam_time';

  /// 时间相关
  static const String TIME_DATA = 'time_data';
  static const String TIME_LAST_UPDATED = 'time_last_updated';

  /// 作息表（各校区/季节的节次时间，GET /v1/course/ScheduleTime）
  static const String SCHEDULE_TIME_DATA = 'schedule_time_data';

  /// 信息完成度相关
  static const String INFO_DATA = 'info_data';
  static const String INFO_DATA_TIME = 'info_data_time';

  /// 通知相关
  static const String NOTIFICATION_TIME = 'notification_time';
  static const String IS_REMIND = 'is_remind';
  static const String LAST_REMIND_DATE = 'last_remind_date';
  static const String IS_SHOW_TOMORROW = 'is_show_tomorrow';

  /// 待办事项相关
  /// @deprecated 已迁移到 Hive (TodoService)，保留此 Key 仅用于迁移逻辑，禁止新代码写入
  @Deprecated(
      'Migrated to Hive via TodoService. Do not write new data to this key.')
  static const String TODO_DATA = 'todo_data';

  /// 电费相关
  static const String ELECTRICITY_URL = 'electricity_url';
  static const String ELECTRICITY_SUBSCRIPTION_EMAIL =
      'electricity_subscription_email';
  static const String TILES = 'tiles';
  static const String TILE_CONFIGURATIONS = 'tile_configurations';

  /// 支付相关
  static const String PAYMENT_NUM = 'payment_num';
  static const String PAYMENT_PASSWORD = 'payment_password';

  /// 更新相关
  static const String UPDATE_IGNORED = 'update_ignored';

  /// 页面相关
  static const String PAGE_DATA = 'page_data';

  /// 触觉反馈相关
  static const String ENABLE_HAPTIC_FEEDBACK = 'enable_haptic_feedback';

  /// 字体设置相关
  static const String FONT_FAMILY = 'font_family';

  /// 多语言相关
  static const String LOCALE_CODE = 'locale_code';

  /// 课表网格线显示相关
  static const String SHOW_COURSE_GRID = 'show_course_grid';

  /// 待办事项提醒相关
  static const String TODO_REMIND_ENABLED = 'todo_remind_enabled';
  static const String THEME_MODE = 'theme_mode';
  static const String SCHEDULE_BACKGROUND = 'schedule_background';
  static const String CUSTOM_BACKGROUND_IMAGE = 'custom_background_image';
  static const String CUSTOM_BACKGROUND_IS_DARK = 'custom_background_is_dark';

  /// 学校配置相关
  static const String SCHOOL_ID = 'school_id';
  static const String SCHOOL_DATA = 'school_data';

  /// 游客课程数据（HTML 导入等）
  static const String GUEST_COURSE_DATA = 'guest_course_data';

  /// 自定义课程数据
  static const String CUSTOM_COURSE_DATA = 'custom_courses';

  /// 协议相关
  static const String AGREEMENT_ACCEPTED = 'agreement_accepted';
}
