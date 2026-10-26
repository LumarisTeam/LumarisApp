import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

void main() {
  group('AppLogger 测试', () {
    test('应该能够输出 debug 日志', () {
      expect(() => AppLogger.debug('这是一条调试日志'), returnsNormally);
    });

    test('应该能够输出 info 日志', () {
      expect(() => AppLogger.info('这是一条信息日志'), returnsNormally);
    });

    test('应该能够输出 warning 日志', () {
      expect(() => AppLogger.warning('这是一条警告日志'), returnsNormally);
    });

    test('应该能够输出 error 日志', () {
      expect(() => AppLogger.error('这是一条错误日志'), returnsNormally);
    });

    test('应该能够输出带异常的 error 日志', () {
      final exception = Exception('测试异常');
      expect(() => AppLogger.error('发生错误', error: exception), returnsNormally);
    });

    test('应该能够输出 trace 日志', () {
      expect(() => AppLogger.trace('这是一条追踪日志'), returnsNormally);
    });

    test('应该能够输出 fatal 日志', () {
      expect(() => AppLogger.fatal('这是一条致命错误日志'), returnsNormally);
    });
  });
}
