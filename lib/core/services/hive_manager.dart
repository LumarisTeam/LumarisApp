import 'package:hive_flutter/hive_flutter.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';

/// Hive 数据库管理类
///
/// 负责 Hive 的初始化、Box 管理和通用操作。
/// 采用单例模式，确保全局只有一个实例。
class HiveManager {
  HiveManager._();

  static final HiveManager _instance = HiveManager._();
  static HiveManager get instance => _instance;
  static bool _initialized = false;
  static Future<void>? _initializing;

  // Box 名称常量
  static const String requestCacheBoxName = 'request_cache';
  static const String courseBoxName = 'courses';
  static const String scoreBoxName = 'scores';

  /// 初始化 Hive
  ///
  /// 在 main.dart 中调用
  static Future<void> init() async {
    if (_initialized) return;
    if (_initializing != null) return _initializing;

    _initializing = _init();
    await _initializing;
  }

  static Future<void> _init() async {
    try {
      await Hive.initFlutter();

      // 注册 Adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CourseModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ScoreModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ScoreListAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(SemesterModelAdapter());
      }

      _initialized = true;
      AppLogger.info('Hive initialized successfully with adapters');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Hive',
          error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      _initializing = null;
    }
  }

  /// 打开指定的 Box
  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }

    if (_initializing != null) {
      await _initializing;
    }

    try {
      return await Hive.openBox<T>(boxName);
    } on HiveError catch (e, stackTrace) {
      if (!_shouldRetryAfterInit(e)) {
        rethrow;
      }

      AppLogger.warning(
        'Hive box "$boxName" opened before initialization, retrying after init',
        error: e,
        stackTrace: stackTrace,
      );

      await init();
      return await Hive.openBox<T>(boxName);
    }
  }

  /// 获取已打开的 Box
  ///
  /// 注意：调用此方法前必须确保 Box 已打开，否则会抛出异常
  Box<T> box<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// 关闭所有 Box
  Future<void> closeAll() async {
    await Hive.close();
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }

  bool _shouldRetryAfterInit(HiveError error) {
    final message = error.toString();
    return message.contains('initialize Hive') ||
        message.contains('provide a path to store the box');
  }
}
