import 'dart:async' show TimeoutException, unawaited;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/education/models/edu_fetch_models.dart';
import 'package:ios_club_app/features/education/services/score_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';

import '../../../core/utils/error_message_resolver.dart';

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
  int _scope = 0;
  bool _calendarLabels = false;
  bool _isRefreshing = false;

  late PageController pageController = PageController();
  late int _currentIndex = 0;
  bool _selectorMenuOpen = false;
  final List<String> _selectorList = [];

  @override
  void initState() {
    super.initState();
    _loadLabelPreference();
    refresh();
  }

  Future<void> _loadLabelPreference() async {
    final prefs = await PrefsService.getInstanceAsync();
    if (mounted) {
      setState(() {
        _calendarLabels = prefs.getBool(PrefsKeys.scoreCalendarLabels) ?? false;
        _updateSelectors();
      });
    }
  }

  Future<void> _setLabelPreference(bool value) async {
    setState(() {
      _calendarLabels = value;
      _updateSelectors();
    });
    final prefs = await PrefsService.getInstanceAsync();
    await prefs.setBool(PrefsKeys.scoreCalendarLabels, value);
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

    final localSnapshot = await ScoreService.getScores(
      policy: FetchPolicy.localFirst,
    );
    if (localSnapshot.data.isNotEmpty) {
      _applyScoreData(localSnapshot.data, isLoading: false);
      unawaited(
        _loadScores(
          policy: FetchPolicy.refresh,
          keepCurrentDataWhileLoading: true,
          showStaleMessage: false,
        ),
      );
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
        McFeedback.showMessage(context, message: l10n.refreshFailedFallback);
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        McFeedback.showMessage(context, message: l10n.fetchTimeout);
      }
      AppLogger.warning('[ScorePage] 获取数据超时: $e');
    } catch (e, stackTrace) {
      if (mounted) {
        McFeedback.showMessage(
          context,
          message: resolveEduErrorMessage(e, l10n, fallback: l10n.fetchFailed),
        );
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
      final groups = <String, ScoreList>{};
      for (final score in scores) {
        final text = '${score.semester.semester} ${score.semester.name}';
        final match = RegExp(r'(\d{4})\s*[-–—]\s*(\d{2,4})').firstMatch(text);
        final key = match == null ? score.semester.semester : match.group(1)!;
        final group = groups[key];
        if (group == null) {
          groups[key] = ScoreList(
            semester: score.semester,
            list: score.list.toList(),
          );
        } else {
          group.list.addAll(score.list);
        }
      }
      _yearList.addAll(groups.values);
      _isLoading = isLoading;
      _updateSelectors();
      if (pageController.hasClients && _scope != 0) {
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

  String _semesterLabel(int index) {
    final score = _scoreList[index];
    if (_calendarLabels) {
      return score.semester.name.isNotEmpty
          ? score.semester.name
          : score.semester.semester;
    }
    final years = _yearList.reversed.toList();
    final yearIndex = years.indexWhere(
      (year) => year.list.any(score.list.contains),
    );
    final text = '${score.semester.semester} ${score.semester.name}';
    final isSpring = RegExp(r'(?:[-_]2\b|第二学期|春)').hasMatch(text);
    return '${_yearLabel(yearIndex < 0 ? 0 : yearIndex)}${isSpring ? context.l10n.semesterSpringShort : context.l10n.semesterAutumnShort}';
  }

  void _updateSelectors() {
    _selectorList.clear();
    if (_scope == 1) {
      for (var i = 0; i < _scoreList.length; i++) {
        _selectorList.add(_semesterLabel(i));
      }
    } else if (_scope == 2) {
      for (var i = 0; i < _yearList.length; i++) {
        final semester = _yearList[i].semester;
        final match = RegExp(
          r'\d{4}\s*[-–—]\s*\d{2,4}',
        ).firstMatch('${semester.semester} ${semester.name}');
        _selectorList.add(
          _calendarLabels && match != null
              ? '${match.group(0)} ${context.l10n.scoreAcademicYear}'
              : _yearLabel(_yearList.length - i - 1),
        );
      }
    }
    if (_currentIndex >= _selectorList.length) _currentIndex = 0;
  }

  void _setScope(int? value) {
    if (value == null) return;
    setState(() {
      _scope = value;
      _isYear = value == 2;
      _currentIndex = 0;
      _updateSelectors();
    });
    if (pageController.hasClients && value != 0) pageController.jumpToPage(0);
  }

  Future<void> _showLabelSettings() async {
    final brightness = context.mc.colors.brightness;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => MediaQuery(
        data: MediaQuery.of(
          popupContext,
        ).copyWith(platformBrightness: brightness),
        child: CupertinoActionSheet(
          title: Text(context.l10n.scoreSemesterFormat),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                _setLabelPreference(false);
                Navigator.of(popupContext).pop();
              },
              child: _labelFormatOption(
                context.l10n.scoreFormatGrade,
                isSelected: !_calendarLabels,
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                _setLabelPreference(true);
                Navigator.of(popupContext).pop();
              },
              child: _labelFormatOption(
                context.l10n.scoreFormatCalendar,
                isSelected: _calendarLabels,
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: Text(context.l10n.cancel),
          ),
        ),
      ),
    );
  }

  Widget _labelFormatOption(String label, {required bool isSelected}) {
    final colors = context.mc.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.primary : colors.label,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (isSelected) ...[
          const SizedBox(width: 8),
          Icon(CupertinoIcons.check_mark, size: 18, color: colors.primary),
        ],
      ],
    );
  }

  void _handleFoolishMode() {
    setState(() {
      _isFool = true;
      for (final item in _scoreList) {
        for (final item2 in item.list) {
          item2.grade = '100';
          item2.gpa = '5';
          item2.gradeDetail = '666';
        }
      }
    });

    McFeedback.showMessage(context, message: context.l10n.foolishModeMessage);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
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
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 48,
                color: colors.secondaryLabel,
              ),
              SizedBox(height: 16),
              Text(
                context.l10n.notLoggedIn,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                context.l10n.pleaseLoginFirst,
                style: TextStyle(fontSize: 16, color: colors.secondaryLabel),
              ),
              SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () {
                  AppRouter.push(AppRoutes.login);
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
          if (_scoreList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _scope,
                  onValueChanged: _setScope,
                  children: {
                    0: Text(context.l10n.scoreCumulative),
                    1: Text(context.l10n.scoreBySemester),
                    2: Text(context.l10n.scoreByYear),
                  },
                ),
              ),
            ),
            if (_scope != 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDropdownSelector(),
              ),
          ],
          Expanded(child: _buildScoreList()),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (_scoreList.isNotEmpty)
                IconButton(
                  onPressed: _showLabelSettings,
                  tooltip: context.l10n.scoreSemesterFormat,
                  icon: const Icon(CupertinoIcons.gear),
                ),
              if (!_isFool)
                IconButton(
                  onPressed: _handleFoolishMode,
                  icon: const Icon(CupertinoIcons.smiley),
                ),
              IconButton(
                onPressed: () => refresh(isRefresh: true),
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_scoreList.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: McCard.elevated(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                _scope == 0
                    ? context.l10n.scoreCumulative
                    : _selectorList[_currentIndex],
                style: TextStyle(color: context.mc.colors.secondaryLabel),
              ),
            ),
            _buildStatsPadding(
              scoreList: _scope == 0
                  ? null
                  : (_isYear ? _yearList : _scoreList)[_currentIndex],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPadding({ScoreList? scoreList}) {
    final canGpa =
        ref
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
              icon: CupertinoIcons.checkmark_seal,
              value: scoreList == null
                  ? ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2)
                  : scoreList.totalGpa.toStringAsFixed(2),
              label: 'GPA',
              color: context.mc.colors.success,
            ),
          _buildStatItem(
            icon: CupertinoIcons.book,
            value: scoreList == null
                ? ScoreList.getTotalCourse(_scoreList).toString()
                : scoreList.totalCourse.toString(),
            label: context.l10n.passedCourses,
            color: context.mc.colors.primary,
          ),
          InkWell(
            onTap: _showCreditInfoDialog,
            child: _buildStatItem(
              icon: CupertinoIcons.chart_bar,
              value: scoreList == null
                  ? ScoreList.getTotalCredit(_scoreList).toStringAsFixed(1)
                  : scoreList.totalCredit.toStringAsFixed(1),
              label: context.l10n.totalCredits,
              withInfo: true,
              color: context.mc.colors.cyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool withInfo = false,
    Color? color,
  }) {
    final colors = context.mc.colors;
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withInfo)
              Icon(
                CupertinoIcons.info_circle,
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
    showMcDialog(
      context: context,
      title: context.l10n.creditInfoTitle,
      content: Text(context.l10n.creditInfoContent),
      actions: [
        McDialogAction<void>(label: context.l10n.ok, isDefaultAction: true),
      ],
    );
  }

  Widget _buildDropdownSelector() {
    final colors = context.mc.colors;
    return McPopoverMenu<int>(
      items: List.generate(_selectorList.length, (index) {
        return McPopoverMenuItem<int>(
          value: index,
          label: _selectorList[index],
        );
      }),
      selectedValue: _currentIndex,
      matchTriggerWidth: true,
      onOpenChanged: (open) {
        if (_selectorMenuOpen != open) {
          setState(() => _selectorMenuOpen = open);
        }
      },
      onSelected: _handleSelectorChanged,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: colors.cardBackground,
          shape: McSmoothCorners.shape(McRadii.navigationBorder),
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
            AnimatedRotation(
              turns: _selectorMenuOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: colors.secondaryLabel,
              ),
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
        : _scope == 0
        ? _buildCumulativeList()
        : _isYear
        ? _buildYearList()
        : _buildSemesterList();
  }

  Widget _buildCumulativeList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        for (var i = 0; i < _scoreList.length; i++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              _semesterLabel(i),
              style: TextStyle(color: context.mc.colors.secondaryLabel),
            ),
          ),
          _buildScoreGroup(_scoreList[i].list),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildScoreGroup(List<ScoreModel> scores) {
    final colors = context.mc.colors;
    return McCard.grouped(
      child: Column(
        children: [
          for (var i = 0; i < scores.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: 16,
                endIndent: 16,
                color: colors.separator,
              ),
            _buildScoreItem(scores[i]),
          ],
        ],
      ),
    );
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
      itemBuilder: (context, index) => _buildYearCard(_yearList[index]),
    );
  }

  Widget _buildYearCard(ScoreList score) => _buildSemesterCard(score);

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          EmptyWidget(
            title: context.l10n.noScores,
            subtitle: context.l10n.noScoresSubtitle,
            icon: CupertinoIcons.book_fill,
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
      sliver: SliverToBoxAdapter(child: _buildScoreGroup(scores)),
    );
  }

  Widget _buildScoreItem(ScoreModel item) {
    final colors = context.mc.colors;
    final canGpa =
        ref
            .read(schoolStoreProvider)
            .school
            ?.supports(Feature.gpaCalculation) ??
        true;
    return InkWell(
      onTap: () => _showScoreDetails(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.name}${item.isMinor ? ' (${context.l10n.minorCourse})' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      context.l10n.creditUnit(item.credit),
                      if (canGpa) context.l10n.gpaLabel(item.gpa),
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item.grade,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              size: 15,
              color: colors.secondaryLabel,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScoreDetails(ScoreModel score) async {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final content = _buildScoreDetailsContent(score, isTablet);

    if (isTablet) {
      final screenSize = MediaQuery.sizeOf(context);
      final dialogWidth = (screenSize.width * 0.36)
          .clamp(420.0, 560.0)
          .toDouble();
      final maxDialogHeight = screenSize.height * 0.78;

      await showMcDialog<void>(
        context: context,
        width: dialogWidth,
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxDialogHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: content,
          ),
        ),
      );
    } else {
      await showMcBottomSheet(
        context: context,
        builder: (_) => content,
        showHandle: true,
        contentPadding: const EdgeInsets.all(24),
        scrollable: true,
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      );
    }
  }

  Widget _buildScoreDetailsContent(ScoreModel score, bool isTablet) {
    final colors = context.mc.colors;
    final canGpa =
        ref
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
