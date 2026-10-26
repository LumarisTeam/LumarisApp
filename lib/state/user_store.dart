import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/services/auth_session_guard.dart';
import 'package:ios_club_app/features/education/services/education_cache_service.dart';
import 'package:ios_club_app/features/education/services/education_logout_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

final userStoreProvider = NotifierProvider<UserStore, UserState>(UserStore.new);

class UserStore extends Notifier<UserState> {
  @override
  UserState build() {
    Future<void>.microtask(_loadUserData);
    return const UserState();
  }

  bool get isLogin => state.isLogin;
  UserData? get userData => state.userData;

  Future<void> _loadUserData() async {
    final prefs = PrefsService.instance;
    final String? userDataString = prefs.getString(PrefsKeys.USER_DATA);

    if (userDataString != null) {
      try {
        final userDataMap = Map<String, dynamic>.from(
          jsonDecode(userDataString) as Map,
        );
        final userData = UserData.fromJson(userDataMap);
        if (userData.studentId.isEmpty ||
            userData.studentId == '/student/login') {
          await prefs.remove(PrefsKeys.USER_DATA);
        } else {
          state = state.copyWith(userData: userData, isLogin: true);
        }
      } catch (_) {
        await _clearUserData();
      }
    }
  }

  Future<void> setUserData(UserData userData) async {
    state = state.copyWith(userData: userData, isLogin: true);
  }

  Future<void> _clearUserData() async {
    // 先让所有在途登录结果失效，再删除本地数据，避免竞态下被重新写回。
    AuthSessionGuard.invalidate();
    state = state.copyWith(userData: null, isLogin: false);

    final prefs = PrefsService.instance;

    await prefs.remove(PrefsKeys.USER_DATA);
    await prefs.remove(PrefsKeys.USERNAME);
    await prefs.remove(PrefsKeys.PASSWORD);
    await prefs.remove(PrefsKeys.COURSE_LAST_FETCH_TIME);
    await prefs.remove(PrefsKeys.EXAM_DATA);
    await prefs.remove(PrefsKeys.INFO_DATA);
    await prefs.remove(PrefsKeys.COURSE_DATA);

    await _deleteCredential(PrefsKeys.USERNAME);
    await _deleteCredential(PrefsKeys.PASSWORD);

    await EducationCacheService.clearEduCache();
    await EducationLogoutService.clearAccountArtifacts();
  }

  /// 删除安全存储凭证。
  ///
  /// 失败时重试一次并明确记录，避免登出后残留凭证让后台任务静默重登。
  Future<void> _deleteCredential(String key) async {
    final storage = SecureStorageService.instance;

    if (await storage.delete(key: key)) {
      return;
    }
    if (await storage.delete(key: key)) {
      return;
    }

    AppLogger.warning('登出时删除安全存储凭证失败: $key');
  }

  Future<void> logout() async {
    await _clearUserData();
  }
}
