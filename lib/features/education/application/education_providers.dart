import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/bus_remote_data_source.dart';
import '../data/repositories/bus_repository_impl.dart';
import '../data/repositories/service_repository_adapters.dart';
import '../domain/repositories/bus_repository.dart';
import '../domain/repositories/education_feature_repositories.dart';
import 'education_dependencies.dart';
import 'education_session_coordinator.dart';
import 'education_bootstrap.dart';

export 'education_dependencies.dart';

/// Transitional composition root for education dependencies.
///
/// Legacy static APIs and new repositories resolve the same client during the
/// migration, so a school switch cannot leave login and feature requests on
/// different base URLs.
final busRemoteDataSourceProvider = Provider<BusRemoteDataSource>((ref) {
  return BusRemoteDataSource(ref.watch(eduApiClientProvider));
});

final busRepositoryProvider = Provider<BusRepository>((ref) {
  return BusRepositoryImpl(ref.watch(busRemoteDataSourceProvider));
});

final electricityRepositoryProvider = Provider<ElectricityRepository>((ref) {
  return ElectricityRepositoryAdapter(ref.watch(electricityServiceProvider));
});
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return const PaymentRepositoryAdapter();
});
final programRepositoryProvider = Provider<ProgramRepository>((ref) {
  return const ProgramRepositoryAdapter();
});
final scoreRepositoryProvider = Provider<ScoreFeatureRepository>((ref) {
  return const ScoreRepositoryAdapter();
});
final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return const ExamRepositoryAdapter();
});
final infoRepositoryProvider = Provider<InfoRepository>((ref) {
  return const InfoRepositoryAdapter();
});
final linkRepositoryProvider = Provider<LinkRepository>((ref) {
  return const LinkRepositoryAdapter();
});
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return const MapRepositoryAdapter();
});
final courseFeatureRepositoryProvider =
    Provider<CourseFeatureRepository>((ref) {
  return const CourseRepositoryAdapter();
});
final educationTimeRepositoryProvider =
    Provider<EducationTimeRepository>((ref) {
  return const EducationTimeRepositoryAdapter();
});

final educationSessionCoordinatorProvider =
    Provider<EducationSessionCoordinator>((ref) {
  return EducationSessionCoordinator(ref);
});

final educationBootstrapProvider = Provider<EducationBootstrap>((ref) {
  return EducationBootstrap(ref);
});
