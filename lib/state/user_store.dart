import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/application/education_dependencies.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';

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
        final userDataMap =
            Map<String, dynamic>.from(jsonDecode(userDataString) as Map);
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
    state = state.copyWith(userData: null, isLogin: false);

    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;

    await prefs.remove(PrefsKeys.USER_DATA);
    await prefs.remove(PrefsKeys.USERNAME);
    await prefs.remove(PrefsKeys.PASSWORD);
    await prefs.remove(PrefsKeys.COURSE_LAST_FETCH_TIME);
    await prefs.remove(PrefsKeys.EXAM_DATA);
    await prefs.remove(PrefsKeys.INFO_DATA);
    await prefs.remove(PrefsKeys.COURSE_DATA);

    await secureStorage.delete(key: PrefsKeys.USERNAME);
    await secureStorage.delete(key: PrefsKeys.PASSWORD);

    await ref.read(educationCacheClearerProvider)();

    ref.read(courseStoreProvider.notifier).clearCourseData();
    ref.read(scheduleStoreProvider.notifier).clean();
    ref.read(programControllerProvider.notifier).clean();
  }

  Future<void> logout() async {
    await _clearUserData();
  }
}
