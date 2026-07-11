import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/edu_api_client.dart';
import '../services/edu_http_client_manager.dart';
import '../services/education_cache_service.dart';
import '../services/electricity_service.dart';

typedef EducationCacheClearer = Future<void> Function();

final eduApiClientProvider = Provider<EduApiClient>((ref) {
  return EduHttpClientManager.instance;
});

final educationCacheClearerProvider = Provider<EducationCacheClearer>((ref) {
  return EducationCacheService.clearEduCache;
});

final electricityServiceProvider = Provider<ElectricityService>((ref) {
  return ElectricityService();
});
