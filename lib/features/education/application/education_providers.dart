import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/edu_api_client.dart';
import '../services/edu_http_client_manager.dart';
import 'education_session_coordinator.dart';

/// Transitional composition root for education dependencies.
///
/// Legacy static APIs and new repositories resolve the same client during the
/// migration, so a school switch cannot leave login and feature requests on
/// different base URLs.
final eduApiClientProvider = Provider<EduApiClient>((ref) {
  return EduHttpClientManager.instance;
});

final educationSessionCoordinatorProvider =
    Provider<EducationSessionCoordinator>((ref) {
  return EducationSessionCoordinator(ref);
});
