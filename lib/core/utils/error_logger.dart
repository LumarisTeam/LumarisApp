import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 统一的错误日志系统
///
/// 功能：
/// - 开发环境：输出到控制台
/// - 生产环境：写入本地日志文件
/// - 支持错误、警告、信息三个级别
class ErrorLogger {
  static const String _logFileName = 'app_errors.log';
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  static File? _logFile;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// 初始化日志系统
  static Future<void> initialize() async {
    if (kReleaseMode && !kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        _logFile = File('${directory.path}/$_logFileName');

        // 检查文件大小，如果超过限制则清空
        if (await _logFile!.exists()) {
          final fileSize = await _logFile!.length();
          if (fileSize > _maxLogFileSize) {
            await _logFile!.writeAsString('');
          }
        }
      } catch (e) {
        AppLogger.debug('Failed to initialize error logger: $e');
      }
    }
  }

  /// 记录错误
  static void logError(Object error, [StackTrace? stackTrace]) {
    _log('ERROR', error.toString(), stackTrace);
  }

  /// 记录警告
  static void logWarning(String message) {
    _log('WARNING', message, null);
  }

  /// 记录信息
  static void logInfo(String message) {
    _log('INFO', message, null);
  }

  /// 内部日志记录方法
  static void _log(String level, String message, StackTrace? stackTrace) {
    final timestamp = _dateFormat.format(DateTime.now());
    final logMessage = '[$timestamp] [$level] $message';

    // 开发环境：输出到控制台
    if (kDebugMode) {
      AppLogger.debug(logMessage);
      if (stackTrace != null) {
        AppLogger.debug('StackTrace: $stackTrace');
      }
    }

    // 生产环境：写入文件
    if (kReleaseMode && _logFile != null) {
      _writeToFile(logMessage, stackTrace);
    }
  }

  /// 写入日志文件
  static Future<void> _writeToFile(
    String message,
    StackTrace? stackTrace,
  ) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(message);
      if (stackTrace != null) {
        buffer.writeln('StackTrace: $stackTrace');
      }
      buffer.writeln('---');

      await _logFile!.writeAsString(buffer.toString(), mode: FileMode.append);
    } catch (e) {
      AppLogger.debug('Failed to write log: $e');
    }
  }

  /// 获取日志文件路径
  static Future<String?> getLogFilePath() async {
    if (_logFile != null && await _logFile!.exists()) {
      return _logFile!.path;
    }
    return null;
  }

  /// 读取日志内容
  static Future<String?> readLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      try {
        return await _logFile!.readAsString();
      } catch (e) {
        AppLogger.debug('Failed to read logs: $e');
        return null;
      }
    }
    return null;
  }

  /// 清空日志
  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      try {
        await _logFile!.writeAsString('');
        logInfo('Logs cleared');
      } catch (e) {
        AppLogger.debug('Failed to clear logs: $e');
      }
    }
  }
}
