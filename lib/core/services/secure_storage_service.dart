import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 安全存储服务
///
/// 使用 flutter_secure_storage 存储敏感信息（如密码、Token等）
class SecureStorageService {
  SecureStorageService._();

  static const String _macOsFallbackPrefix = 'secure_storage_fallback.';

  static final SecureStorageService _instance = SecureStorageService._();

  static SecureStorageService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
      // Debug/Profile 在 Xcode 中禁用了签名，无法使用要求 entitlement 的
      // Data Protection Keychain；这两种构建使用 macOS 登录钥匙串。
      usesDataProtectionKeychain: kReleaseMode,
    ),
  );

  bool get _shouldUseMacOsFallback => !kIsWeb && Platform.isMacOS;

  String _fallbackKey(String key) => '$_macOsFallbackPrefix$key';

  Future<bool> _writeFallback({
    required String key,
    required String? value,
  }) async {
    try {
      final prefs = PrefsService.instance;
      final fallbackKey = _fallbackKey(key);

      if (value == null) {
        await prefs.remove(fallbackKey);
      } else {
        await prefs.setString(fallbackKey, value);
      }

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage macOS fallback write error',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<String?> _readFallback({required String key}) async {
    try {
      final prefs = PrefsService.instance;
      return prefs.getString(_fallbackKey(key));
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage macOS fallback read error',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> _deleteFallback({required String key}) async {
    try {
      final prefs = PrefsService.instance;
      await prefs.remove(_fallbackKey(key));
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage macOS fallback delete error',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _deleteAllFallback() async {
    try {
      final prefs = PrefsService.instance;
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith(_macOsFallbackPrefix))
          .toList();

      for (final key in keys) {
        await prefs.remove(key);
      }

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage macOS fallback deleteAll error',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 保存字符串
  Future<bool> write({required String key, required String? value}) async {
    try {
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
      if (_shouldUseMacOsFallback) {
        await _deleteFallback(key: key);
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage write error',
        error: e,
        stackTrace: stackTrace,
      );
      if (_shouldUseMacOsFallback) {
        AppLogger.warning(
          'SecureStorage write fallback to SharedPreferences on macOS',
        );
        return _writeFallback(key: key, value: value);
      }
      return false;
    }
  }

  /// 读取字符串
  Future<String?> read({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null || !_shouldUseMacOsFallback) {
        return value;
      }

      // 权限配置修复后，仍需接回旧版本降级保存的凭据。只有写入
      // Keychain 成功后才能移除旧副本，避免迁移失败时丢失数据。
      final fallbackValue = await _readFallback(key: key);
      if (fallbackValue != null) {
        await write(key: key, value: fallbackValue);
      }
      return fallbackValue;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage read error',
        error: e,
        stackTrace: stackTrace,
      );
      if (_shouldUseMacOsFallback) {
        AppLogger.warning(
          'SecureStorage read fallback to SharedPreferences on macOS',
        );
        return _readFallback(key: key);
      }
      return null;
    }
  }

  /// 删除
  Future<bool> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      if (_shouldUseMacOsFallback) {
        return await _deleteFallback(key: key);
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage delete error',
        error: e,
        stackTrace: stackTrace,
      );
      if (_shouldUseMacOsFallback) {
        AppLogger.warning(
          'SecureStorage delete fallback to SharedPreferences on macOS',
        );
        return _deleteFallback(key: key);
      }
      return false;
    }
  }

  /// 清除所有
  Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll();
      if (_shouldUseMacOsFallback) {
        return await _deleteAllFallback();
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorage deleteAll error',
        error: e,
        stackTrace: stackTrace,
      );
      if (_shouldUseMacOsFallback) {
        AppLogger.warning(
          'SecureStorage deleteAll fallback to SharedPreferences on macOS',
        );
        return _deleteAllFallback();
      }
      return false;
    }
  }
}
