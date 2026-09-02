import 'dart:async' show TimeoutException, unawaited;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';
import 'package:ios_club_app/core/utils/animations/animated_list_item.dart';
import 'package:ios_club_app/features/education/models/edu_fetch_models.dart';
import 'package:ios_club_app/features/education/services/score_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_menu.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';

class ScorePage extends ConsumerStatefulWidget {
  const ScorePage({super.key});

  @override
  ConsumerState<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends ConsumerState<ScorePage>
    with SingleTickerProviderStateMixin {
  final List<ScoreList> _scoreList = [];
  bool _isLoading = true;
  bool _isFool = false;
  final List<ScoreList> _yearList = [];
  bool _isYear = false;
  bool _isRefreshing = false;

  late PageController pageController = PageController();
  late int _currentIndex = 0;
  final List<String> _selectorList = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> refresh({bool isRefresh = false}) async {
    if (_isRefreshing) return;
    if (isRefresh || _isFool) {
      await _loadScores(policy: FetchPolicy.refresh);
      return;
    }

    final localSnapshot =
        await ScoreService.getScores(policy: FetchPolicy.localFirst);
    if (localSnapshot.data.isNotEmpty) {
      _applyScoreData(localSnapshot.data, isLoading: false);
      unawaited(_loadScores(
        policy: FetchPolicy.refresh,
        keepCurrentDataWhileLoading: true,
        showStaleMessage: false,
      ));
      return;
    }

    await _loadScores(policy: FetchPolicy.refresh);
  }

  Future<void> _loadScores({
    required FetchPolicy policy,
    bool keepCurrentDataWhileLoading = false,
    bool showStaleMessage = true,
  }) async {
    if (!mounted) return;
    _isRefreshing = true;
    final l10n = context.l10n;

    setState(() {
      _isLoading = !keepCurrentDataWhileLoading;
    });

    try {
      final snapshot = await ScoreService.getScores(policy: policy).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(l10n.fetchTimeout);
        },
      );

      _applyScoreData(snapshot.data, isLoading: false);
      if (!mounted) return;
      if (snapshot.isStale && snapshot.data.isNotEmpty && showStaleMessage) {
        showClubSnackBar(context, Text(l10n.refreshFailedFallback));
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        showClubSnackBar(context, Text(l10n.fetchTimeout));
      }
      AppLogger.warning('[ScorePage] 获取数据超时: $e');
    } catch (e, stackTrace) {
      if (mounted) {
        showClubSnackBar(context, Text('${l10n.fetchFailed}: ${e.toString()}'));
      }
      AppLogger.error('[ScorePage] 获取数据失败', error: e, stackTrace: stackTrace);
    } finally {
      _isFool = false;
      _isRefreshing = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyScoreData(List<ScoreList> scores, {required bool isLoading}) {
    if (!mounted) return;
    setState(() {
      _scoreList
        ..clear()
        ..addAll(scores);
      _yearList.clear();
      _isYear = false;
      _isLoading = isLoading;
      _selectorList
        ..clear()
        ..addAll(_buildSelectorList(scores.length));
      if (_currentIndex >= _selectorList.length) {
        _currentIndex = _selectorList.isNotEmpty ? _selectorList.length - 1 : 0;
      }
      if (_selectorList.isNotEmpty && pageController.hasClients) {
        pageController.jumpToPage(_currentIndex);
      }
    });
  }

  String _yearLabel(int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.year1,
      1 => l10n.year2,
      2 => l10n.year3,
      3 => l10n.year4,
      4 => l10n.year5,
      5 => l10n.year6,
      6 => l10n.year7,
      7 => l10n.year8,
      8 => l10n.year9,
      9 => l10n.year10,
      _ => '${index + 1}',
    };
  }

  List<String> _buildSelectorList(int count) {
    final selectorList = <String>[];
    for (var i = 0; i < count; i++) {
      final y = count - i + 1;
      selectorList.add(
          '${_yearLabel(y ~/ 2 - 1)}${y % 2 == 1 ? context.l10n.semesterSpringShort : context.l10n.semesterAutumnShort}');
    }
    return selectorList;
  }

  void _handleFoolishMode() {
    final colors = context.clubColors;
    setState(() {
      _isFool = true;
      for (final item in _scoreList) {
        for (final item2 in item.list) {
          item2.grade = '100';
          item2.gpa = '5';
          item2.gradeDetail = '666';
        }
      }
      _yearList.clear();
      _isYear = false;
    });

    showClubSnackBar(
      context,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.foolishModeMessage),
          Icon(Icons.mood, color: colors.quaternaryLabel),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final school = ref.watch(schoolStoreProvider).school;
    final canGradeQuery = school?.supports(Feature.gradeQuery) ?? true;

    if (school != null && !canGradeQuery) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.scoresAndGpa)),
        body: Center(child: Text(context.l10n.schoolNotSupported)),
      );
    }

    // 检查是否为游客模式
    if (!ref.watch(userStoreProvider).isLogin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 48,
                color: colors.secondaryLabel,
              ),
              SizedBox(height: 16),
              Text(
                context.l10n.notLoggedIn,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                context.l10n.pleaseLoginFirst,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.secondaryLabel,
                ),
              ),
              SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () {
                  AppRouter.go(AppRoutes.profile);
                },
                child: Text(context.l10n.goToLogin),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingStateView(
            title: context.l10n.fetchingScores,
            subtitle: context.l10n.readingScoresSubtitle,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildStatsCard(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadowColor.withValues(alpha: 0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _changeScoreList,
                      icon: Icon(_isYear
                          ? Icons.calendar_today_rounded
                          : Icons.calendar_view_day_rounded),
                    )),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildSelector(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildScoreList(),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.scoresAndGpa,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (!_isFool)
                  IconButton(
                    onPressed: _handleFoolishMode,
                    icon: const Icon(Icons.mood),
                  ),
                IconButton(
                  onPressed: () => refresh(isRefresh: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ));
  }

  void _changeScoreList() {
    setState(() {
      _isYear = !_isYear;
      if (_isYear && _scoreList.isNotEmpty && _yearList.isEmpty) {
        for (var i = _scoreList.length - 1; i >= 0; i--) {
          var j = _scoreList.length - 1 - i;
          if (j % 2 == 0) {
            _yearList.add(ScoreList(
              semester: _scoreList[i].semester,
              list: _scoreList[i].list.toList(),
            ));
          } else {
            var a = _yearList.lastOrNull;
            if (a != null) {
              a.list.addAll(_scoreList[i].list.toList());
            }
          }
        }
      }

      if (_scoreList.isNotEmpty) {
        _selectorList.clear();
        if (_isYear) {
          for (var i = 0; i < _yearList.length; i++) {
            _selectorList.add(_yearLabel(i));
          }
        } else {
          for (var i = 0; i < _scoreList.length; i++) {
            var y = _scoreList.length - i + 1;
            _selectorList.add(
                '${_yearLabel(y ~/ 2 - 1)}${y % 2 == 1 ? context.l10n.semesterSpringShort : context.l10n.semesterAutumnShort}');
          }
        }

        if (_currentIndex >= _selectorList.length) {
          _currentIndex =
              _selectorList.isNotEmpty ? _selectorList.length - 1 : 0;
        }
        if (_selectorList.isNotEmpty && pageController.hasClients) {
          pageController.jumpToPage(_currentIndex);
        }
      }
    });
  }

  Widget _buildStatsCard() {
    if (_scoreList.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ClubCard(
        child: _buildStatsPadding(),
      ),
    );
  }

  Widget _buildStatsPadding({ScoreList? scoreList}) {
    final canGpa = ref
            .read(schoolStoreProvider)
            .school
            ?.supports(Feature.gpaCalculation) ??
        true;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canGpa)
            _buildStatItem(
              icon: Icons.credit_score,
              value: scoreList == null
                  ? ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2)
                  : scoreList.totalGpa.toStringAsFixed(2),
              label: 'GPA',
            ),
          _buildStatItem(
            icon: Icons.library_books,
            value: scoreList == null
                ? ScoreList.getTotalCourse(_scoreList).toString()
                : scoreList.totalCourse.toString(),
            label: context.l10n.passedCourses,
          ),
          InkWell(
            onTap: _showCreditInfoDialog,
            child: _buildStatItem(
              icon: Icons.equalizer,
              value: scoreList == null
                  ? ScoreList.getTotalCredit(_scoreList).toStringAsFixed(1)
                  : scoreList.totalCredit.toStringAsFixed(1),
              label: context.l10n.totalCredits,
              withInfo: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool withInfo = false,
  }) {
    final colors = context.clubColors;
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withInfo)
              Icon(
                Icons.info_outline,
                size: 9,
                color: colors.secondaryLabel,
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreditInfoDialog() {
    PlatformDialog.showCustomDialog<void>(
      context,
      title: context.l10n.creditInfoTitle,
      content: Text(context.l10n.creditInfoContent),
      actions: [
        PlatformDialogAction<void>(
          label: context.l10n.ok,
          isDefaultAction: true,
        ),
      ],
    );
  }

  Widget _buildSelector() {
    if (_selectorList.length < 2) {
      return Container();
    }

    if (_selectorList.length > 4) {
      return _buildDropdownSelector();
    }

    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<int>(
        proportionalWidth: true,
        groupValue: _currentIndex,
        onValueChanged: _handleSelectorChanged,
        children: _selectorList
            .map(
              (x) => Text(x),
            )
            .toList()
            .asMap(),
      ),
    );
  }

  Widget _buildDropdownSelector() {
    final colors = context.clubColors;
    return ClubMenu<int>(
      items: List.generate(_selectorList.length, (index) {
        return ClubMenuItem<int>(
          value: index,
          label: _selectorList[index],
        );
      }),
      onSelected: _handleSelectorChanged,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: colors.cardBackground,
          shape: ClubSmoothCorners.shape(
            ClubRadii.navigation,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectorList[_currentIndex],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: colors.secondaryLabel,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelectorChanged(int? value) {
    if (value == null || value >= _selectorList.length) {
      return;
    }

    setState(() {
      _currentIndex = value;
    });

    if (pageController.hasClients) {
      pageController.jumpToPage(value);
    }
  }

  Widget _buildScoreList() {
    return _scoreList.isEmpty
        ? _buildEmptyState()
        : _isYear
            ? _buildYearList()
            : _buildSemesterList();
  }

  Widget _buildSemesterList() {
    return PageView.builder(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: _scoreList.length,
      itemBuilder: (context, index) => _buildSemesterCard(_scoreList[index]),
    );
  }

  Widget _buildYearList() {
    return PageView.builder(
        controller: pageController,
        itemCount: _yearList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) => _buildYearCard(_yearList[index]));
  }

  Widget _buildYearCard(ScoreList score) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: ClubCard(
              borderRadius: ClubRadii.navigation,
              child: _buildStatsPadding(scoreList: score),
            ),
          ),
        ),
        _buildScoreSliverList(score.list),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          EmptyWidget(
            title: context.l10n.noScores,
            subtitle: context.l10n.noScoresSubtitle,
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: () => refresh(isRefresh: true),
            child: Text(context.l10n.refreshDataBtn),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(ScoreList score) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 16),
          sliver: _buildScoreSliverList(score.list),
        ),
      ],
    );
  }

  Widget _buildScoreSliverList(List<ScoreModel> scores) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverFixedExtentList.builder(
        itemExtent: 72,
        itemCount: scores.length,
        itemBuilder: (context, index) => AnimatedCard(
          delay: Duration(milliseconds: 50 * index),
          child: ClubCard(
            margin: const EdgeInsets.only(bottom: 8),
            borderRadius: ClubRadii.navigation,
            child: AnimatedListItem(
              index: index,
              child: _buildScoreItem(scores[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(ScoreModel item) {
    return Material(
      shape: ClubSmoothCorners.shape(ClubRadii.navigation),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: ClubRadii.navigation,
        customBorder: ClubSmoothCorners.shape(ClubRadii.navigation),
        onTap: () => _showScoreDetails(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: ShapeDecoration(
                  color: CourseColorManager.generateSoftColor(item.name),
                  shape: ClubSmoothCorners.shape(ClubRadii.indicatorBorder),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.name}${item.isMinor ? ' (${context.l10n.minorCourse})' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              _buildScoreMeta(item),
                            ]),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreMeta(ScoreModel item) {
    final colors = context.clubColors;
    final canGpa = ref
            .read(schoolStoreProvider)
            .school
            ?.supports(Feature.gpaCalculation) ??
        true;
    return Wrap(
      spacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.time, size: 16, color: colors.secondaryLabel),
            const SizedBox(width: 4),
            Text(context.l10n.creditUnit(item.credit),
                style: TextStyle(color: colors.secondaryLabel))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.location,
                size: 16, color: colors.secondaryLabel),
            const SizedBox(width: 4),
            Text(context.l10n.gradeLabel(item.grade),
                style: TextStyle(color: colors.secondaryLabel))
          ],
        ),
        if (canGpa)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.star, size: 16, color: colors.secondaryLabel),
              const SizedBox(width: 4),
              Text(context.l10n.gpaLabel(item.gpa),
                  style: TextStyle(color: colors.secondaryLabel))
            ],
          ),
      ],
    );
  }

  Future<void> _showScoreDetails(ScoreModel score) async {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final content = _buildScoreDetailsContent(score, isTablet);

    if (isTablet) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          final screenSize = MediaQuery.sizeOf(dialogContext);
          final dialogWidth =
              (screenSize.width * 0.36).clamp(420.0, 560.0).toDouble();
          final maxDialogHeight = screenSize.height * 0.78;

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: maxDialogHeight,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: content,
              ),
            ),
          );
        },
      );
    } else {
      await showClubModalBottomSheet(context, content);
    }
  }

  Widget _buildScoreDetailsContent(ScoreModel score, bool isTablet) {
    final colors = context.clubColors;
    final canGpa = ref
            .read(schoolStoreProvider)
            .school
            ?.supports(Feature.gpaCalculation) ??
        true;
    return SizedBox(
      width: isTablet ? 420 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalHeader(
              title: score.name,
              subtitle: score.isMinor ? context.l10n.minorCourse : null,
            ),
            ModalInfoRow(
              icon: CupertinoIcons.star_fill,
              label: context.l10n.courseCreditLabel,
              content: context.l10n.creditUnit(score.credit),
              color: colors.yellow,
            ),
            const ModalSpacing(),
            ModalInfoRow(
              icon: CupertinoIcons.chart_bar_fill,
              label: context.l10n.courseScoreLabel,
              content: score.grade,
              color: colors.danger,
            ),
            if (canGpa) ...[
              const ModalSpacing(),
              ModalInfoRow(
                icon: CupertinoIcons.star_circle_fill,
                label: context.l10n.courseGpaLabel,
                content: score.gpa,
                color: colors.success,
              ),
            ],
            const ModalSpacing(),
            ModalInfoRow(
              icon: CupertinoIcons.doc_text_fill,
              label: context.l10n.scoreDetail,
              content: score.gradeDetail,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
