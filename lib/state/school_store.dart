import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/basic/services/school_api.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

final schoolStoreProvider = NotifierProvider<SchoolStore, SchoolStoreState>(
  SchoolStore.new,
);

class SchoolStore extends Notifier<SchoolStoreState> {
  @override
  SchoolStoreState build() {
    final school = _cachedSchool() ?? _fallbackSchool();
    return SchoolStoreState(isLoading: false, school: school);
  }

  School? _cachedSchool() {
    final school = SchoolConfigCache.read();
    final schoolId = PrefsService.instance.getString(PrefsKeys.SCHOOL_ID);
    if (school == null || schoolId == null) {
      return null;
    }
    return school.code.toUpperCase() == schoolId.toUpperCase() ? school : null;
  }

  Future<void> fetchSchool(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final school = await SchoolApi.getSchool(code);
      state = state.copyWith(isLoading: false, school: school);
      await SchoolConfigCache.save(school);

      try {
        EduHttpClientManager.current.updateSchoolConfig(school);
      } catch (_) {
        // Manager may not be initialized during early startup or tests.
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  School _fallbackSchool() {
    final schoolId =
        PrefsService.instance.getString(PrefsKeys.SCHOOL_ID) ??
        School.defaultCode;
    return School.findByCode(School.fallbackList, schoolId) ??
        School.fallbackList.first;
  }
}
