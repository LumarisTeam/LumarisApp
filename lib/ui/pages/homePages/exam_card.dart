import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/error_message_resolver.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/features/education/models/exam_result.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';

import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ExamCard extends ConsumerStatefulWidget {
  const ExamCard({super.key});

  @override
  ConsumerState<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends ConsumerState<ExamCard> {
  List<ExamData> examItems = [];
  bool isLoading = true;
  String? errorMessage;
  bool isNetworkError = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    ref.read(examRepositoryProvider).getExams().then((repositoryResult) {
      if (!mounted) {
        return;
      }
      if (repositoryResult.isSuccess) {
        setExam(repositoryResult.data);
      } else {
        setExam(ExamResult.error(repositoryResult.error.userMessage));
      }
    });
  }

  void setExam(ExamResult result) {
    if (!mounted) {
      return;
    }
    setState(() {
      if (result.isSuccess) {
        examItems = result.exams
            .map((course) => ExamData(
                  title: course.name,
                  time: course.examTime,
                  location: course.room,
                  color: CourseColorManager.generateSoftColor(course),
                  seat: course.seatNo,
                ))
            .toList();
        errorMessage = null;
        isNetworkError = false;
      } else {
        examItems = [];
        errorMessage = result.errorMessage;
        isNetworkError = result.isNetworkError;
      }
      isLoading = false;
    });
  }

  Future<void> getExam() async {
    if (!mounted) {
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final repositoryResult =
        await ref.read(examRepositoryProvider).getExams(forceRefresh: true);
    if (!mounted) {
      return;
    }
    setExam(repositoryResult.isSuccess
        ? repositoryResult.data
        : ExamResult.error(repositoryResult.error.userMessage));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.upcomingExams,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await getExam();
                  },
                  icon: const Icon(
                    CupertinoIcons.refresh,
                    size: 22,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            examCard()
          ],
        ));
  }

  Widget examWrap(ExamData exam) {
    final l10n = context.l10n;
    final colors = context.clubColors;

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 16,
              color: colors.secondaryLabel,
            ),
            const SizedBox(width: 6),
            Text(
              exam.time,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryLabel,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        if (exam.location.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.placemark,
                size: 16,
                color: colors.secondaryLabel,
              ),
              const SizedBox(width: 6),
              Text(
                exam.location,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.secondaryLabel,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        if (exam.seat.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: colors.secondaryLabel,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.seatNumberLabel(exam.seat),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.secondaryLabel,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget examCard() {
    final l10n = context.l10n;
    if (isLoading) {
      return AnimatedCard(
        child: ClubCard(
          child: LoadingStateView(
            title: l10n.fetchingScores,
            subtitle: l10n.loadingExamsSubtitle,
            compact: true,
            padding: const EdgeInsets.all(20),
          ),
        ),
      );
    }

    // 显示错误信息
    if (errorMessage != null) {
      return AnimatedCard(
        child: ClubCard(
          padding: const EdgeInsets.all(20),
          child: EmptyWidget(
            title: isNetworkError ? l10n.networkError : l10n.loadFailed,
            subtitle: resolveErrorMessage(errorMessage!, l10n),
            icon: isNetworkError
                ? CupertinoIcons.wifi_slash
                : CupertinoIcons.exclamationmark_triangle,
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return examItems.isEmpty
        ? AnimatedCard(
            child: ClubCard(
              padding: const EdgeInsets.all(20),
              child: EmptyWidget(
                title: l10n.empty,
                subtitle: l10n.noExamsSubtitle,
                icon: CupertinoIcons.hourglass,
              ),
            ),
          )
        : AnimatedCard(
            child: ClubCard(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: examItems.length,
                itemBuilder: (context, index) {
                  final exam = examItems[index];

                  return AnimatedListItem(
                    index: index,
                    child: Material(
                      color: Colors.transparent,
                      shape: ClubSmoothCorners.shape(ClubRadii.card),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          if (isTablet) {
                            PlatformDialog.showCustomDialog<void>(
                              context,
                              content: _buildExamTip(exam),
                            );
                          } else {
                            showClubModalBottomSheet(
                              context,
                              _buildExamTip(exam),
                            );
                          }
                        },
                        borderRadius: ClubRadii.card,
                        customBorder: ClubSmoothCorners.shape(ClubRadii.card),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              Container(
                                width: 5,
                                height: isTablet ? 42 : 52,
                                decoration: ShapeDecoration(
                                  color: exam.color,
                                  shape: ClubSmoothCorners.shape(
                                      ClubRadii.xsBorder),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: examWrap(exam),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Widget _buildExamTip(ExamData exam) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ModalHeader(title: exam.title),
        ModalInfoRow(
          icon: CupertinoIcons.clock,
          label: l10n.examTime,
          content: exam.time,
          color: colors.success,
        ),
        if (exam.location.isNotEmpty) ...[
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.placemark,
            label: l10n.examLocation,
            content: exam.location,
            color: colors.warning,
          ),
        ],
        if (exam.seat.isNotEmpty) ...[
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.calendar,
            label: l10n.seatNumber,
            content: exam.seat,
            color: colors.danger,
          ),
        ],
      ],
    );
  }
}

class ExamData {
  final String title;
  final String time;
  final String location;
  final Color color;
  final String seat;

  ExamData({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
    required this.seat,
  });
}
