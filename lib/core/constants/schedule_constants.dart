/// 课表布局和样式相关的常量。
abstract final class ScheduleConstants {
  /// 格子高度范围（单位：逻辑像素）
  static const double minGridHeight = 40.0;
  static const double maxGridHeight = 120.0;
  static const double defaultGridHeight = 55.0;

  /// 表头高度范围（单位：逻辑像素）
  static const double minHeaderHeight = 30.0;
  static const double maxHeaderHeight = 80.0;
  static const double defaultHeaderHeight = 45.0;

  /// 时间列宽度范围（单位：逻辑像素）
  static const double minTimeColumnWidth = 30.0;
  static const double maxTimeColumnWidth = 80.0;
  static const double defaultTimeColumnWidth = 45.0;

  /// 字体缩放比例范围
  static const double minFontScale = 0.5;
  static const double maxFontScale = 2.0;
  static const double defaultFontScale = 1.0;

  /// 圆角半径范围（单位：逻辑像素）
  static const double minCornerRadius = 0.0;
  static const double maxCornerRadius = 20.0;
  static const double defaultCornerRadius = 8.0;

  /// 内部填充范围（单位：逻辑像素）
  static const double minInnerPadding = 0.0;
  static const double maxInnerPadding = 16.0;
  static const double defaultInnerPadding = 4.0;

  /// 外部间距范围（单位：逻辑像素）
  static const double minOuterPadding = 0.0;
  static const double maxOuterPadding = 8.0;
  static const double defaultOuterPadding = 2.0;

  /// 不透明度范围
  static const double minOpacity = 0.1;
  static const double maxOpacity = 1.0;
  static const double defaultOpacity = 1.0;

  /// 课程卡片基础字号增量
  static const double courseCardFontSizeAdd = 0.9;

  /// 颜色主题相关
  static const int maxColorThemeColors = 32;
  static const int maxColorThemeNameLength = 40;
}
