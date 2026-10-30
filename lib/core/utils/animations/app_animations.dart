import 'package:flutter/widgets.dart';

/// 应用统一动画配置
/// 光序的克制动效参数；具体数值为产品设计选择。
class AppAnimations {
  AppAnimations._();

  /// 所有自定义动效统一读取系统设置，并在设置变化时重建。
  static bool reduceMotionOf(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  // ==================== 动画时长 ====================

  /// 快速动画 - 用于微交互（按钮按压、开关切换）
  static const Duration fast = Duration(milliseconds: 120);

  /// 标准动画 - 用于大多数UI转换（卡片展开、列表项出现）
  static const Duration standard = Duration(milliseconds: 240);

  /// 中等动画 - 用于复杂的过渡（页面内容切换）
  static const Duration medium = Duration(milliseconds: 320);

  /// 慢速动画 - 用于引人注目的效果（进度条、加载完成）
  static const Duration slow = Duration(milliseconds: 480);

  /// 超慢动画 - 用于数值变化等持续性动画
  static const Duration extraSlow = Duration(milliseconds: 1000);

  // ==================== 动画曲线 ====================

  /// 标准缓入缓出，用于状态变化
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// 缓出 - 用于进入动画（元素出现）
  static const Curve easeOut = Curves.easeOutCubic;

  /// 缓入 - 用于退出动画（元素消失）
  static const Curve easeIn = Curves.easeInCubic;

  /// 兼容旧调用：使用无过冲的收敛曲线
  static const Curve spring = Curves.easeOutCubic;

  /// 平滑 - 用于连续变化的动画
  static const Curve smooth = Curves.easeOutQuart;

  // ==================== 列表动画配置 ====================

  /// 列表项基础延迟（每项）
  static const Duration listItemDelay = Duration(milliseconds: 24);

  /// 列表项最大延迟时间
  static const Duration listItemMaxDelay = Duration(milliseconds: 120);

  /// 列表项动画时长
  static const Duration listItemDuration = standard;

  /// 计算列表项延迟（索引 * 延迟，但不超过最大延迟）
  static Duration getListItemDelay(int index) {
    final Duration delay = listItemDelay * (index < 0 ? 0 : index);
    return delay > listItemMaxDelay ? listItemMaxDelay : delay;
  }

  // ==================== 偏移量 ====================

  /// 列表项滑入的垂直偏移量
  static const double slideOffset = 8.0;

  /// 卡片滑入的垂直偏移量
  static const double cardSlideOffset = 12.0;

  // ==================== 缩放比例 ====================

  /// 按压时的缩放比例
  static const double pressScale = 0.98;

  /// 卡片初始缩放比例
  static const double cardInitialScale = 1.0;

  /// 悬停时的缩放比例
  static const double hoverScale = 1.0;

  // ==================== 不透明度 ====================

  /// 禁用状态不透明度
  static const double disabledOpacity = 0.4;

  /// 次要元素不透明度
  static const double secondaryOpacity = 0.6;
}
