import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../core/utils/app_logger.dart';

typedef ScreenCaptureProtection = Future<bool> Function(bool enabled);

final screenCaptureProtectionProvider = Provider<ScreenCaptureProtection>((
  ref,
) {
  return ScreenCaptureProtectionService().setEnabled;
});

class ScreenCaptureProtectionService {
  Future<bool> _pending = Future<bool>.value(true);

  /// 串行执行，避免快速退出、重新进入页面时，旧页面的关闭覆盖新页面的开启。
  Future<bool> setEnabled(bool enabled) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return Future<bool>.value(true);
    }

    _pending = _pending.then((_) async {
      try {
        if (enabled) {
          await ScreenProtector.preventScreenshotOn();
        } else {
          await ScreenProtector.preventScreenshotOff();
        }
        return true;
      } catch (error, stackTrace) {
        AppLogger.error(
          '支付码页面截图保护切换失败（enabled: $enabled）',
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      }
    });
    return _pending;
  }
}
