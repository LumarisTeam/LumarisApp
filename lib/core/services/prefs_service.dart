import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 单例服务
///
/// 在应用启动时初始化一次，之后所有地方都使用缓存的实例，
/// 避免重复调用 SharedPreferences.getInstance() 造成的性能浪费。
///
/// 使用方式：
/// ```dart
/// // 在 main.dart 中初始化
/// await PrefsService.init();
///
/// // 在其他地方使用
/// final prefs = PrefsService.instance;
/// final value = prefs.getString('key');
/// await prefs.setString('key', 'value');
/// ```
class PrefsService {
  static SharedPreferences? _instance;

  /// 获取 SharedPreferences 实例
  ///
  /// 如果尚未初始化，会自动初始化（但建议在 main.dart 中提前初始化）
  static SharedPreferences get instance {
    if (_instance == null) {
      throw StateError('PrefsService 尚未初始化，请先调用 PrefsService.init()');
    }
    return _instance!;
  }

  /// 初始化 SharedPreferences
  ///
  /// 应在应用启动时调用一次
  static Future<void> init() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  /// 检查是否已初始化
  static bool get isInitialized => _instance != null;

  /// 安全获取实例（如果未初始化则自动初始化）
  ///
  /// 用于兼容旧代码的迁移过程
  static Future<SharedPreferences> getInstanceAsync() async {
    if (_instance == null) {
      await init();
    }
    return _instance!;
  }
}
