import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/error_message_resolver.dart';
import '../../../features/basic/models/school.dart';
import '../../../features/education/apis/lesson_search_api.dart';
import '../../../features/education/models/lesson_search_item.dart';
import '../../../features/education/models/login_mode.dart';
import '../../../features/education/models/user_data.dart';
import '../../../features/education/services/login_mode_service.dart';
import '../../../routes/router.dart';
import '../../../state/school_store.dart';
import '../../../state/user_store.dart';
import '../../components/empty_widget.dart';
import '../../components/loading_state_view.dart';
import '../../components/page_app_bar.dart';
import 'lesson_search_view.dart';

final _lessonsProvider = FutureProvider.autoDispose
    .family<List<LessonSearchItem>, UserData>((ref, user) async {
      try {
        return await LessonSearchApi.getLessons(user.studentId);
      } catch (error, stackTrace) {
        AppLogger.error('获取全校教学班失败', error: error, stackTrace: stackTrace);
        rethrow;
      }
    });

class LessonSearchPage extends ConsumerWidget {
  const LessonSearchPage({super.key});

  static bool supports(School? school) =>
      (school?.code ?? School.defaultCode).toUpperCase() ==
          School.defaultCode &&
      LoginModeService.current == LoginMode.undergraduate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final School? school = ref.watch(
      schoolStoreProvider.select((state) => state.school),
    );
    final UserData? user = ref.watch(
      userStoreProvider.select((state) => state.userData),
    );

    Widget body;
    if (user == null) {
      body = _status(
        EmptyWidget(
          title: l10n.lessonSearchTitle,
          subtitle: l10n.pleaseLoginEduAccount,
          icon: CupertinoIcons.lock,
          action: TextButton(
            onPressed: () => AppRouter.push<bool>(
              AppRoutes.login,
              extra: {'isOnlyLoginMember': false},
            ),
            child: Text(l10n.loginEduSystem),
          ),
        ),
      );
    } else if (!supports(school)) {
      body = _status(
        EmptyWidget(
          title: l10n.lessonSearchTitle,
          subtitle: l10n.lessonUnsupported,
          icon: CupertinoIcons.info_circle,
        ),
      );
    } else {
      body = ref
          .watch(_lessonsProvider(user))
          .when(
            skipError: true,
            data: (lessons) => LessonSearchView(
              key: ObjectKey(user),
              lessons: lessons,
              onRefresh: () async {
                try {
                  ref.invalidate(_lessonsProvider(user));
                  await ref.read(_lessonsProvider(user).future);
                } catch (error) {
                  if (!context.mounted) return;
                  await McFeedback.showMessage(
                    context,
                    message: resolveEduErrorMessage(
                      error,
                      l10n,
                      fallback: l10n.fetchFailed,
                    ),
                  );
                }
              },
            ),
            error: (error, stackTrace) {
              final String message = resolveEduErrorMessage(
                error,
                l10n,
                fallback: l10n.fetchFailed,
              );
              return _status(
                EmptyWidget(
                  title: l10n.fetchFailed,
                  subtitle: message == l10n.fetchFailed ? '' : message,
                  icon: CupertinoIcons.exclamationmark_triangle,
                  action: TextButton(
                    onPressed: () => ref.invalidate(_lessonsProvider(user)),
                    child: Text(l10n.retry),
                  ),
                ),
              );
            },
            loading: () => const LoadingStateView(),
          );
    }

    return Scaffold(
      backgroundColor: context.mc.colors.groupedBackground,
      appBar: const PageAppBar(),
      body: SafeArea(child: body),
    );
  }

  Widget _status(EmptyWidget status) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(child: status),
      ),
    );
  }
}
