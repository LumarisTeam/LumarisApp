import 'package:ios_club_app/features/education/models/exam_model.dart';

/// 考试数据获取结果
/// 用于区分不同的获取状态：成功、失败、无数据
class ExamResult {
  /// 获取是否成功
  final bool isSuccess;

  /// 考试列表数据
  final List<ExamItem> exams;

  /// 错误消息（仅在失败时有值）
  final String? errorMessage;

  /// 是否为网络错误
  final bool isNetworkError;

  ExamResult._({
    required this.isSuccess,
    required this.exams,
    this.errorMessage,
    this.isNetworkError = false,
  });

  /// 成功状态 - 有考试数据
  factory ExamResult.success(List<ExamItem> exams) {
    return ExamResult._(isSuccess: true, exams: exams);
  }

  /// 成功状态 - 无考试数据（正常情况，不是错误）
  factory ExamResult.empty() {
    return ExamResult._(isSuccess: true, exams: []);
  }

  /// 失败状态 - 网络错误
  factory ExamResult.networkError([String? message]) {
    return ExamResult._(
      isSuccess: false,
      exams: [],
      errorMessage: message ?? 'network_error',
      isNetworkError: true,
    );
  }

  /// 失败状态 - 其他错误
  factory ExamResult.error(String message) {
    return ExamResult._(
      isSuccess: false,
      exams: [],
      errorMessage: message,
      isNetworkError: false,
    );
  }

  /// 是否有数据
  bool get hasData => exams.isNotEmpty;

  /// 是否为空数据（成功但无考试）
  bool get isEmpty => isSuccess && exams.isEmpty;

  /// 是否为错误状态
  bool get isError => !isSuccess;
}
