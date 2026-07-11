import '../../../../core/models/result.dart';
import '../../apis/link_api.dart';
import '../../apis/map_api.dart';
import '../../domain/repositories/education_feature_repositories.dart';
import '../../models/edu_fetch_models.dart';
import '../../models/electric_data.dart';
import '../../models/exam_result.dart';
import '../../models/info_model.dart';
import '../../models/link_model.dart';
import '../../models/map_model.dart';
import '../../models/payment_model.dart';
import '../../models/plan_course.dart';
import '../../models/score_model.dart';
import '../../services/electricity_service.dart';
import '../../services/exam_service.dart';
import '../../services/info_service.dart';
import '../../services/payment_service.dart';
import '../../services/program_service.dart';
import '../../services/score_service.dart';
import '../../services/course_service.dart';
import '../../services/edu_time_service.dart';
import '../../models/course_model.dart';
import '../../models/week_info.dart';
import '../../models/time_info.dart';
import '../../../basic/models/school.dart';

AppError _mapRepositoryError(Object error) {
  if (error is FormatException || error is TypeError) {
    return AppError.parsing('数据格式错误', originalError: error);
  }
  return AppError.unknown(error.toString(), originalError: error);
}

class ElectricityRepositoryAdapter implements ElectricityRepository {
  const ElectricityRepositoryAdapter(this._service);
  final ElectricityService _service;

  @override
  Future<Result<double?>> getBalance({String? url}) => Result.fromAsync(
        () => _service.fetchCurrentBalance(url: url),
        errorMapper: _mapRepositoryError,
      );

  @override
  Future<Result<List<ElectricData>>> getWeeklyData() => Result.fromAsync(
        _service.fetchWeeklyData,
        errorMapper: _mapRepositoryError,
      );
}

class PaymentRepositoryAdapter implements PaymentRepository {
  const PaymentRepositoryAdapter();

  @override
  Future<Result<PaymentData>> getPayment(String cardId, String? password) =>
      Result.fromAsync(
        () => PaymentService.fetchData(cardId, password),
        errorMapper: _mapRepositoryError,
      );
}

class ProgramRepositoryAdapter implements ProgramRepository {
  const ProgramRepositoryAdapter();

  @override
  Future<Result<List<PlanCourseList>>> getPrograms(
          {bool forceRefresh = false}) =>
      Result.fromAsync(
        () => ProgramService.getPrograms(forceRefresh: forceRefresh),
        errorMapper: _mapRepositoryError,
      );
}

class ScoreRepositoryAdapter implements ScoreFeatureRepository {
  const ScoreRepositoryAdapter();

  @override
  Future<Result<FetchSnapshot<List<ScoreList>>>> getScores(
          {FetchPolicy policy = FetchPolicy.localFirst}) =>
      Result.fromAsync(
        () => ScoreService.getScores(policy: policy),
        errorMapper: _mapRepositoryError,
      );
}

class ExamRepositoryAdapter implements ExamRepository {
  const ExamRepositoryAdapter();

  @override
  Future<Result<ExamResult>> getExams({bool forceRefresh = false}) =>
      Result.fromAsync(
        () => ExamService.getExamResult(isRefresh: forceRefresh),
        errorMapper: _mapRepositoryError,
      );
}

class InfoRepositoryAdapter implements InfoRepository {
  const InfoRepositoryAdapter();

  @override
  Future<Result<List<InfoModel>>> getInfo({bool forceRefresh = false}) =>
      Result.fromAsync(
        () => InfoService.getInfoList(forceRefresh: forceRefresh),
        errorMapper: _mapRepositoryError,
      );
}

class LinkRepositoryAdapter implements LinkRepository {
  const LinkRepositoryAdapter();

  @override
  Future<Result<List<CategoryModel>>> getLinks() => Result.fromAsync(
        LinkApi.getLinks,
        errorMapper: _mapRepositoryError,
      );
}

class MapRepositoryAdapter implements MapRepository {
  const MapRepositoryAdapter();

  @override
  Future<Result<List<MapModel>>> getMap() => Result.fromAsync(
        MapApi.getMap,
        errorMapper: _mapRepositoryError,
      );
}

class CourseRepositoryAdapter implements CourseFeatureRepository {
  const CourseRepositoryAdapter();

  @override
  Future<Result<List<CourseModel>>> getAllCourses({bool applyIgnore = true}) =>
      Result.fromAsync(
        () => CourseService.getAllCourse(isNeedIgnore: applyIgnore),
        errorMapper: _mapRepositoryError,
      );

  @override
  Future<Result<List<String>>> getCourseNames() => Result.fromAsync(
        CourseService.getCourseName,
        errorMapper: _mapRepositoryError,
      );

  @override
  Future<Result<void>> refreshCourses() => Result.fromAsync(
        () async => CourseService.getCourse(isRefresh: true),
        errorMapper: _mapRepositoryError,
      );

  @override
  Future<Result<void>> saveIgnoredCourses(List<String> courses) =>
      Result.fromAsync(
        () => CourseService.setIgnore(courses),
        errorMapper: _mapRepositoryError,
      );

  @override
  Future<Result<(bool, List<CourseModel>)>> getTodayOrTomorrowCourses({
    bool tomorrow = false,
  }) =>
      Result.fromAsync(
        () => CourseService.getTodayOrTomorrowCourse(isTomorrow: tomorrow),
        errorMapper: _mapRepositoryError,
      );
}

class EducationTimeRepositoryAdapter implements EducationTimeRepository {
  const EducationTimeRepositoryAdapter();

  @override
  Future<Result<TimeInfo>> getTime({bool forceRefresh = false}) =>
      Result.fromAsync(
        () => EduTimeService.getTime(isRefresh: forceRefresh),
        errorMapper: _mapRepositoryError,
      );

  @override
  Future<Result<WeekInfo>> getWeek({
    bool forceRefresh = false,
    int? weekStartDay,
  }) =>
      Result.fromAsync(
        () => EduTimeService.getWeek(
          isRefresh: forceRefresh,
          weekStartDay: weekStartDay ?? School.defaultWeekStartDay,
        ),
        errorMapper: _mapRepositoryError,
      );
}
