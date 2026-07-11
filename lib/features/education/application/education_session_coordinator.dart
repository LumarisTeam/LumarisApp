import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/result.dart';
import '../../../core/utils/app_logger.dart';
import '../../../state/settings_store.dart';
import '../../basic/models/school.dart';
import '../services/auth_service.dart';
import '../services/education_cache_service.dart';
import '../services/education_refresh_service.dart';

/// Coordinates operations that must remain ordered across school, session and
/// cached education data.
class EducationSessionCoordinator {
  EducationSessionCoordinator(this._ref);

  final Ref _ref;
  Future<void> _serial = Future<void>.value();

  Future<Result<bool>> login({
    required School school,
    required String username,
    required String password,
  }) {
    return _serialized(() async {
      if (username.isEmpty || password.isEmpty) {
        return Result.failure(
          AppError.validation('用户名和密码不能为空', field: 'credentials'),
        );
      }

      try {
        // Applying the school first guarantees that /Login uses its base URL.
        await _ref
            .read(settingsStoreProvider.notifier)
            .setSchoolId(school.code);
        await EducationCacheService.clearEduCache();

        final loggedIn = await AuthService.loginFromData(username, password);
        if (!loggedIn) {
          return Result.failure(AppError.authentication('登录失败'));
        }

        final refreshed =
            await EducationRefreshService.refreshWithExistingSession();
        return Result.success(refreshed);
      } catch (error, stackTrace) {
        AppLogger.error(
          '教育会话登录失败',
          error: error,
          stackTrace: stackTrace,
        );
        return Result.failure(_mapError(error));
      }
    });
  }

  Future<Result<T>> _serialized<T>(Future<Result<T>> Function() operation) {
    final result = _serial.then((_) => operation());
    _serial = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  AppError _mapError(Object error) {
    if (error is FormatException) {
      return AppError.parsing(error.message, originalError: error);
    }
    return AppError.network(error.toString(), originalError: error);
  }
}
