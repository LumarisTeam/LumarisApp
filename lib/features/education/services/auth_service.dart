import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/apis/login_api.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/services/auth_session_guard.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

class AuthService {
  static Future<void> migrateCredentials() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    final epoch = AuthSessionGuard.epoch;

    final username = prefs.getString(PrefsKeys.USERNAME);
    final password = prefs.getString(PrefsKeys.PASSWORD);

    if (username != null && username.isNotEmpty) {
      await _migrateCredential(
        key: PrefsKeys.USERNAME,
        value: username,
        storage: secureStorage,
        epoch: epoch,
      );
    }

    if (password != null && password.isNotEmpty) {
      await _migrateCredential(
        key: PrefsKeys.PASSWORD,
        value: password,
        storage: secureStorage,
        epoch: epoch,
      );
    }

    final paymentNum = prefs.getString(PrefsKeys.PAYMENT_NUM);
    if (paymentNum != null && paymentNum.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.PAYMENT_NUM, value: paymentNum);
      await prefs.remove(PrefsKeys.PAYMENT_NUM);
    }
  }

  /// 迁移单个凭证，并防止迁移期间用户登出后凭证被写回。
  static Future<void> _migrateCredential({
    required String key,
    required String value,
    required SecureStorageService storage,
    required int epoch,
  }) async {
    if (!AuthSessionGuard.isCurrent(epoch)) {
      return;
    }

    await storage.write(key: key, value: value);

    if (!AuthSessionGuard.isCurrent(epoch)) {
      // 迁移期间会话已被清空，撤销刚写入的凭证。
      await storage.delete(key: key);
      return;
    }

    await PrefsService.instance.remove(key);
  }

  static Future<bool> loginFromData(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    final epoch = AuthSessionGuard.epoch;
    final response = await LoginApi.login(username, password);
    if (response.success != true) {
      return false;
    }

    return _persistUserData(jsonEncode(response.toJson()), epoch);
  }

  static Future<bool> login() async {
    final epoch = AuthSessionGuard.epoch;
    try {
      final secureStorage = SecureStorageService.instance;

      await migrateCredentials();
      if (!AuthSessionGuard.isCurrent(epoch)) {
        return false;
      }

      final String? username = await secureStorage.read(
        key: PrefsKeys.USERNAME,
      );
      final String? password = await secureStorage.read(
        key: PrefsKeys.PASSWORD,
      );

      if (username == null || password == null) {
        return false;
      }
      if (username.isEmpty || password.isEmpty) {
        return false;
      }
      if (!AuthSessionGuard.isCurrent(epoch)) {
        return false;
      }

      final response = await LoginApi.login(username, password);
      if (response.success != true) {
        return false;
      }
      if (!await _credentialsStillMatch(
        secureStorage: secureStorage,
        username: username,
        password: password,
        epoch: epoch,
      )) {
        return false;
      }

      return await _persistUserData(jsonEncode(response.toJson()), epoch);
    } catch (e, stackTrace) {
      AppLogger.error('登录失败', error: e, stackTrace: stackTrace);
    }

    return false;
  }

  /// 校验登录期间凭证是否仍存在。
  ///
  /// 后台任务运行在独立 isolate 中，静态代际号不共享；登出会删除
  /// SecureStorage 凭证，因此读取 Keychain 可以跨 isolate 识别登出。
  static Future<bool> _credentialsStillMatch({
    required SecureStorageService secureStorage,
    required String username,
    required String password,
    required int epoch,
  }) async {
    if (!AuthSessionGuard.isCurrent(epoch)) {
      return false;
    }

    final currentUsername = await secureStorage.read(key: PrefsKeys.USERNAME);
    final currentPassword = await secureStorage.read(key: PrefsKeys.PASSWORD);

    if (currentUsername == username && currentPassword == password) {
      return true;
    }

    AppLogger.info('登录期间凭证已被清除，丢弃过期的登录结果');
    return false;
  }

  /// 写入登录态。
  ///
  /// 写入前后都校验代际：登出发生在网络请求期间时丢弃结果；发生在写入
  /// 期间时回滚刚写入的 key。
  static Future<bool> _persistUserData(String json, int epoch) async {
    if (!AuthSessionGuard.isCurrent(epoch)) {
      AppLogger.info('登录会话已失效，丢弃过期的登录结果');
      return false;
    }

    final prefs = PrefsService.instance;
    await prefs.setString(PrefsKeys.USER_DATA, json);
    await prefs.setInt(
      PrefsKeys.LAST_FETCH_TIME,
      DateTime.now().millisecondsSinceEpoch,
    );

    if (!AuthSessionGuard.isCurrent(epoch)) {
      await prefs.remove(PrefsKeys.USER_DATA);
      await prefs.remove(PrefsKeys.LAST_FETCH_TIME);
      AppLogger.info('登录会话在写入期间失效，已回滚登录态');
      return false;
    }

    return true;
  }

  static Future<UserData?> getUserData() async {
    final cachedData = await getCookie();
    if (cachedData is UserData) {
      return cachedData;
    }

    final loginSuccess = await login();
    if (!loginSuccess) {
      return null;
    }

    final freshData = await getCookie();
    if (freshData is UserData) {
      return freshData;
    }

    throw const FormatException(
      'Cookie data is invalid after successful login',
    );
  }

  static Future<UserData?> getCookie() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final prefs = PrefsService.instance;
      final lastFetchTime = prefs.getInt(PrefsKeys.LAST_FETCH_TIME);
      if (lastFetchTime == null || now - lastFetchTime > 1000 * 60 * 20) {
        return null;
      }

      final String? jsonString = prefs.getString(PrefsKeys.USER_DATA);
      if (jsonString != null) {
        return UserData.fromJson(jsonDecode(jsonString));
      }
    } catch (e, stackTrace) {
      AppLogger.error('读取本地数据失败', error: e, stackTrace: stackTrace);
    }

    return null;
  }
}
