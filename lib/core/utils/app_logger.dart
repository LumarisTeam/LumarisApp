import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 应用统一日志工具类
///
/// 提供统一的日志输出接口，支持不同日志级别：
/// - debug: 调试信息（仅在 debug 模式下输出）
/// - info: 一般信息
/// - warning: 警告信息
/// - error: 错误信息
///
/// 使用示例：
/// ```dart
/// AppLogger.debug('调试信息');
/// AppLogger.info('一般信息');
/// AppLogger.warning('警告信息');
/// AppLogger.error('错误信息', error: e, stackTrace: stackTrace);
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // 显示的方法调用栈数量
      errorMethodCount: 8, // 错误时显示的方法调用栈数量
      lineLength: 120, // 每行的宽度
      colors: true, // 彩色输出
      printEmojis: true, // 打印表情符号
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 时间格式
    ),
    level: kDebugMode ? Level.debug : Level.info, // 根据运行模式设置日志级别
  );

  /// 调试日志（仅在 debug 模式下输出）
  static void debug(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// 信息日志
  static void info(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  static void warning(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  static void error(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 追踪日志（用于追踪代码执行流程）
  static void trace(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// 致命错误日志
  static void fatal(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
