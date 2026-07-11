import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/basic/services/school_api.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/application/education_dependencies.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

final schoolStoreProvider =
    NotifierProvider<SchoolStore, SchoolStoreState>(SchoolStore.new);

class SchoolStore extends Notifier<SchoolStoreState> {
  @override
  SchoolStoreState build() {
    final school =
        _hasLoginData() ? School.fallbackList.first : _fallbackSchool();
    return SchoolStoreState(isLoading: false, school: school);
  }

  bool _hasLoginData() {
    final userData = PrefsService.instance.getString(PrefsKeys.USER_DATA);
    return userData != null && userData.isNotEmpty;
  }

  Future<void> fetchSchool(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final school = await SchoolApi.getSchool(code);
      state = state.copyWith(isLoading: false, school: school);
      await SchoolConfigCache.save(school);

      try {
        ref.read(eduApiClientProvider).updateBaseUrl(school.website);
      } catch (_) {
        // Manager may not be initialized during early startup or tests.
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  School _fallbackSchool() {
    final schoolId = PrefsService.instance.getString(PrefsKeys.SCHOOL_ID) ??
        School.defaultCode;
    return School.findByCode(School.fallbackList, schoolId) ??
        School.fallbackList.first;
  }
}
