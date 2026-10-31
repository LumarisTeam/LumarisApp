import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/error_message_resolver.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/features/education/models/exam_result.dart';
import 'package:ios_club_app/features/education/services/exam_service.dart';

import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';

class ExamCard extends StatefulWidget {
  const ExamCard({super.key});

  @override
  State<StatefulWidget> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  List<ExamData> examItems = [];
  bool isLoading = true;
  String? errorMessage;
  bool isNetworkError = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    ExamService.getExamResult().then((result) {
      if (!mounted) {
        return;
      }
      setExam(result);
    });
  }

  void setExam(ExamResult result) {
    if (!mounted) {
      return;
    }
    setState(() {
      if (result.isSuccess) {
        examItems = result.exams
            .map(
              (course) => ExamData(
                title: course.name,
                time: course.examTime,
                location: course.room,
                color: CourseColorManager.generateSoftColor(course),
                seat: course.seatNo,
              ),
            )
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
    final result = await ExamService.getExamResult(isRefresh: true);
    if (!mounted) {
      return;
    }
    setExam(result);
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
                icon: const Icon(CupertinoIcons.refresh, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          examCard(),
        ],
      ),
    );
  }

  Widget examWrap(ExamData exam) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.clock, size: 16, color: colors.secondaryLabel),
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
      return McAnimatedCard(
        child: McCard.elevated(
          padding: EdgeInsets.zero,
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
      return McAnimatedCard(
        child: McCard.elevated(
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
        ? McAnimatedCard(
            child: McCard.elevated(
              padding: const EdgeInsets.all(20),
              child: EmptyWidget(
                title: l10n.empty,
                subtitle: l10n.noExamsSubtitle,
                icon: CupertinoIcons.hourglass,
              ),
            ),
          )
        : McAnimatedCard(
            child: McCard.elevated(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: math.min(
                  examItems.length * (isTablet ? 72.0 : 84.0),
                  isTablet ? 420.0 : 360.0,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: examItems.length,
                  itemBuilder: (context, index) {
                    final exam = examItems[index];

                    return McAnimatedListItem(
                      index: index,
                      child: Material(
                        color: Colors.transparent,
                        shape: McSmoothCorners.shape(McRadii.cardBorder),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            if (isTablet) {
                              showMcDialog(
                                context: context,
                                content: _buildExamTip(exam),
                              );
                            } else {
                              showMcBottomSheet(
                                context: context,
                                builder: (_) => _buildExamTip(exam),
                                showHandle: true,
                                contentPadding: const EdgeInsets.all(24),
                                scrollable: true,
                                maxHeight:
                                    MediaQuery.sizeOf(context).height * 0.6,
                              );
                            }
                          },
                          borderRadius: McRadii.cardBorder,
                          customBorder: McSmoothCorners.shape(
                            McRadii.cardBorder,
                          ),
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
                                    shape: McSmoothCorners.shape(
                                      McRadii.xsBorder,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
            ),
          );
  }

  Widget _buildExamTip(ExamData exam) {
    final l10n = context.l10n;
    final colors = context.mc.colors;
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
