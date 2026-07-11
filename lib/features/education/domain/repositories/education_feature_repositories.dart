import '../../../../core/models/result.dart';
import '../../models/edu_fetch_models.dart';
import '../../models/electric_data.dart';
import '../../models/exam_result.dart';
import '../../models/info_model.dart';
import '../../models/link_model.dart';
import '../../models/map_model.dart';
import '../../models/payment_model.dart';
import '../../models/plan_course.dart';
import '../../models/score_model.dart';
import '../../models/course_model.dart';
import '../../models/week_info.dart';
import '../../models/time_info.dart';

abstract interface class ElectricityRepository {
  Future<Result<double?>> getBalance({String? url});
  Future<Result<List<ElectricData>>> getWeeklyData();
}

abstract interface class PaymentRepository {
  Future<Result<PaymentData>> getPayment(String cardId, String? password);
}

abstract interface class ProgramRepository {
  Future<Result<List<PlanCourseList>>> getPrograms({bool forceRefresh = false});
}

abstract interface class ScoreFeatureRepository {
  Future<Result<FetchSnapshot<List<ScoreList>>>> getScores({
    FetchPolicy policy = FetchPolicy.localFirst,
  });
}

abstract interface class ExamRepository {
  Future<Result<ExamResult>> getExams({bool forceRefresh = false});
}

abstract interface class InfoRepository {
  Future<Result<List<InfoModel>>> getInfo({bool forceRefresh = false});
}

abstract interface class LinkRepository {
  Future<Result<List<CategoryModel>>> getLinks();
}

abstract interface class MapRepository {
  Future<Result<List<MapModel>>> getMap();
}

abstract interface class CourseFeatureRepository {
  Future<Result<List<CourseModel>>> getAllCourses({bool applyIgnore = true});
  Future<Result<List<String>>> getCourseNames();
  Future<Result<void>> refreshCourses();
  Future<Result<void>> saveIgnoredCourses(List<String> courses);
  Future<Result<(bool, List<CourseModel>)>> getTodayOrTomorrowCourses({
    bool tomorrow = false,
  });
}

abstract interface class EducationTimeRepository {
  Future<Result<TimeInfo>> getTime({bool forceRefresh = false});
  Future<Result<WeekInfo>> getWeek({
    bool forceRefresh = false,
    int? weekStartDay,
  });
}
