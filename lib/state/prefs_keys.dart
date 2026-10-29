/// SharedPreferences 键统一管理
class PrefsKeys {
  /// 用户相关
  static const String USERNAME = 'username';
  static const String PASSWORD = 'password';
  static const String USER_DATA = 'user_data';
  static const String LAST_FETCH_TIME = 'last_fetch_time';

  /// 教务系统类型（0 = 本科生，1 = 研究生），登录成功后记录，
  /// 后续请求通过 `x-loginMode` 头带上。
  static const String LOGIN_MODE = 'login_mode';

  /// 课程相关
  /// @deprecated 已迁移到 Hive (CourseRepository)，保留此 Key 仅用于迁移逻辑，禁止新代码写入
  @Deprecated(
    'Migrated to Hive via CourseRepository. Do not write new data to this key.',
  )
  static const String COURSE_DATA = 'course_data';
  static const String IGNORE_DATA = 'ignore_data';
  static const String COURSE_LAST_FETCH_TIME = 'course_last_fetch_time';

  /// 学期相关
  static const String SEMESTER_DATA = 'semester_data';
  static const String SEMESTER_TIME = 'semester_time';

  /// 成绩相关
  /// @deprecated 已迁移到 Hive (ScoreRepository)，保留此 Key 仅用于迁移逻辑，禁止新代码写入
  @Deprecated(
    'Migrated to Hive via ScoreRepository. Do not write new data to this key.',
  )
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

  /// 课程通知排期记录（通知 id -> 计划触发时刻），用于识别并撤销排歪的旧闹钟
  static const String COURSE_REMINDER_PLAN = 'course_reminder_plan';

  /// 课程通知排期规则版本，用于升级后清空旧版本排出来的闹钟
  static const String COURSE_REMINDER_SCHEMA = 'course_reminder_schema';

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
  static const String THEME_MODE = 'theme_mode';
  static const String SCHEDULE_BACKGROUND = 'schedule_background';
  static const String CUSTOM_BACKGROUND_IMAGE = 'custom_background_image';
  static const String CUSTOM_BACKGROUND_IS_DARK = 'custom_background_is_dark';

  /// 课表个性化样式相关
  /// 格子高度沿用旧键名，保证已设置过的用户升级后不丢配置。
  static const String COURSE_SIZE = 'course_size';
  static const String SCHEDULE_HEADER_HEIGHT = 'schedule_header_height';
  static const String SCHEDULE_HIDE_SECTION_TIME = 'schedule_hide_section_time';
  static const String SCHEDULE_HIDE_DATE_UNDER_DAY =
      'schedule_hide_date_under_day';
  static const String SCHEDULE_TIME_COLUMN_WIDTH = 'schedule_time_column_width';
  static const String SCHEDULE_SHOW_START_TIME = 'schedule_show_start_time';
  static const String SCHEDULE_HIDE_LOCATION = 'schedule_hide_location';
  static const String SCHEDULE_PAGE_TEXT_COLOR = 'schedule_page_text_color';
  static const String SCHEDULE_COURSE_TEXT_COLOR = 'schedule_course_text_color';
  static const String SCHEDULE_HIDE_TEACHER = 'schedule_hide_teacher';
  static const String SCHEDULE_TEXT_CENTER_H = 'schedule_text_center_h';
  static const String SCHEDULE_TEXT_CENTER_V = 'schedule_text_center_v';
  static const String SCHEDULE_BORDER_STYLE = 'schedule_border_style';
  static const String SCHEDULE_FONT_SCALE = 'schedule_font_scale';
  static const String SCHEDULE_CORNER_RADIUS = 'schedule_corner_radius';
  static const String SCHEDULE_INNER_PADDING = 'schedule_inner_padding';
  static const String SCHEDULE_OUTER_PADDING = 'schedule_outer_padding';
  static const String SCHEDULE_OPACITY = 'schedule_opacity';

  /// 旧版直接存储的颜色池；仅用于 schema 2 迁移清理，不再读取。
  static const String SCHEDULE_LIGHT_COLOR_POOL = 'schedule_light_color_pool';
  static const String SCHEDULE_DARK_COLOR_POOL = 'schedule_dark_color_pool';

  /// 当前颜色池使用的具名主题 ID（内置 flavor ID 或 custom: 前缀）。
  static const String SCHEDULE_LIGHT_COLOR_POOL_THEME_ID =
      'schedule_light_color_pool_theme_id';
  static const String SCHEDULE_DARK_COLOR_POOL_THEME_ID =
      'schedule_dark_color_pool_theme_id';

  /// 用户命名的自定义颜色主题（JSON：id -> {name, colors}）。
  static const String SCHEDULE_CUSTOM_COLOR_POOL_THEMES =
      'schedule_custom_color_pool_themes';

  static const String SCHEDULE_COURSE_COLOR_OVERRIDES =
      'schedule_course_color_overrides';

  /// 颜色池默认值版本；旧版本升级时一次性重置活动主题为 Macchiato。
  static const String SCHEDULE_COLOR_POOL_SCHEMA = 'schedule_color_pool_schema';

  /// 课表布局尺寸版本；旧版本升级时一次性重置为 55/45/45。
  static const String SCHEDULE_LAYOUT_SCHEMA = 'schedule_layout_schema';

  /// 浅色/深色独立壁纸
  static const String CUSTOM_BACKGROUND_IMAGE_LIGHT =
      'custom_background_image_light';
  static const String CUSTOM_BACKGROUND_IMAGE_DARK =
      'custom_background_image_dark';
  static const String CUSTOM_BACKGROUND_IS_DARK_LIGHT =
      'custom_background_is_dark_light';
  static const String CUSTOM_BACKGROUND_IS_DARK_DARK =
      'custom_background_is_dark_dark';

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
