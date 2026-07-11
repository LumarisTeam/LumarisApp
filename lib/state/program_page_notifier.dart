import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/state/app_states.dart';

typedef ProgramsFetcher = Future<List<PlanCourseList>> Function(
    {bool forceRefresh});

final programAutoLoadProvider = Provider<bool>((ref) => true);
final programsFetcherProvider = Provider<ProgramsFetcher>((ref) {
  return ({bool forceRefresh = false}) async {
    final result = await ref
        .read(programRepositoryProvider)
        .getPrograms(forceRefresh: forceRefresh);
    if (!result.isSuccess) throw result.error;
    return result.data;
  };
});

final programControllerProvider =
    NotifierProvider<ProgramPageNotifier, ProgramState>(
        ProgramPageNotifier.new);

class ProgramPageNotifier extends Notifier<ProgramState> {
  int _loadCount = 0;
  final List<String> semesterNames = const [
    '大一上',
    '大一下',
    '大二上',
    '大二下',
    '大三上',
    '大三下',
    '大四上',
    '大四下',
    '大五上',
    '大五下',
    '特殊分组',
  ];

  @override
  ProgramState build() {
    if (ref.read(programAutoLoadProvider)) {
      Future<void>.microtask(loadPrograms);
    }
    return const ProgramState();
  }

  List<PlanCourseList> get programs => List.unmodifiable(state.programs);
  bool get isLoading => state.isLoading;
  bool get isError => state.isError;
  String get errorMessage => state.errorMessage;

  Future<void> loadPrograms({bool forceRefresh = false}) async {
    final currentLoadId = ++_loadCount;
    final previousPrograms = state.programs;
    try {
      state = state.copyWith(isLoading: true, isError: false);
      final result = await ref.read(programsFetcherProvider)(
        forceRefresh: forceRefresh,
      );

      if (currentLoadId != _loadCount) return;

      state = state.copyWith(
        programs: result,
        isError: false,
        errorMessage: '',
      );
    } catch (e) {
      if (currentLoadId != _loadCount) return;
      if (previousPrograms.isNotEmpty) {
        state = state.copyWith(
          programs: previousPrograms,
          isError: false,
          errorMessage: e.toString(),
        );
      } else {
        state = state.copyWith(isError: true, errorMessage: e.toString());
      }
    } finally {
      if (currentLoadId == _loadCount) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> refreshPrograms() async {
    await loadPrograms(forceRefresh: true);
  }

  void clean() {
    state = state.copyWith(programs: const []);
  }
}
