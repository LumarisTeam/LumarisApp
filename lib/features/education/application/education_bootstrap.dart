import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/auth_state_notifier.dart';
import '../../../state/course_store.dart';
import '../../basic/models/school.dart';
import '../services/auth_service.dart';
import '../services/edu_http_client.dart';
import '../services/edu_http_client_manager.dart';
import '../services/education_refresh_service.dart';

/// Transitional composition boundary for legacy static education services.
/// Only this application-layer adapter may initialize their compatibility
/// facades while repositories are moved to constructor injection.
class EducationBootstrap {
  const EducationBootstrap(this._ref);

  final Ref _ref;

  void initialize(School? school) {
    final auth = _ref.read(authStateNotifierProvider.notifier);
    final courses = _ref.read(courseStoreProvider.notifier);
    EduHttpClientManager.initialize(
      school: school,
      authStateCallbacks: AuthStateCallbacks(
        onRelogging: auth.startRelogging,
        onRelogSuccess: auth.relogSuccess,
        onRelogFailed: auth.relogFailed,
      ),
    );
    EducationRefreshService.setCourseRefreshCallback(courses.loadCourses);
  }

  Future<void> migrateCredentials() => AuthService.migrateCredentials();
}
