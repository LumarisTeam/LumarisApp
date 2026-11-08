import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';

class ProgramPage extends ConsumerStatefulWidget {
  const ProgramPage({super.key});

  @override
  ConsumerState<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends ConsumerState<ProgramPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late final PageController _pageController;
  int _tabLength = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _ensureTabController(int length) {
    if (length == 0 || _tabLength == length) {
      return;
    }
    _tabController?.dispose();
    _tabLength = length;
    _tabController = TabController(length: length, vsync: this);
    _tabController!.addListener(() {
      if (_tabController != null && !_tabController!.indexIsChanging) {
        _pageController.animateToPage(
          _tabController!.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final school = ref.watch(schoolStoreProvider).school;
    final canProgram = school?.supports(Feature.program) ?? true;

    if (school != null && !canProgram) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.programLabel)),
        body: Center(child: Text(l10n.schoolNotSupported)),
      );
    }

    final programState = ref.watch(programControllerProvider);
    final controller = ref.read(programControllerProvider.notifier);
    _ensureTabController(programState.programs.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.programLabel,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: programState.isLoading
                ? null
                : () => controller.refreshPrograms(),
            icon: const Icon(CupertinoIcons.arrow_clockwise),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child:
              programState.isLoading ||
                  programState.isError ||
                  programState.programs.isEmpty ||
                  _tabController == null
              ? const SizedBox.shrink()
              : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: programState.programs.asMap().entries.map((entry) {
                    final program = entry.value;
                    final term = program.term == '特殊分组'
                        ? controller.semesterNames.length - 1
                        : int.parse(program.term) - 1;

                    return Tab(child: Text(controller.semesterNames[term]));
                  }).toList(),
                ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final colors = context.mc.colors;

          if (programState.isLoading) {
            return Center(
              child: LoadingStateView(
                title: l10n.programLoading,
                subtitle: l10n.programLoadingSubtitle,
              ),
            );
          }

          if (programState.isError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: colors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadFailed,
                      style: TextStyle(
                        fontSize: 17,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          if (programState.programs.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: colors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noData,
                      style: TextStyle(
                        fontSize: 17,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: programState.programs.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final program = programState.programs[index];

              return ListView.builder(
                padding: const EdgeInsets.only(top: 16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    program.courses.length +
                    (programState.errorMessage.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (programState.errorMessage.isNotEmpty && index == 0) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: ShapeDecoration(
                        color: colors.warningSoft,
                        shape: McSmoothCorners.shape(McRadii.panelBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle,
                            color: colors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.programRefreshFailed,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.secondaryLabel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final courseIndex = programState.errorMessage.isNotEmpty
                      ? index - 1
                      : index;
                  final course = program.courses[courseIndex];
                  final courseColor = CourseColorManager.generateSoftColor(
                    course.courseTypeName,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: courseColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.label,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.courseTypeName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          decoration: ShapeDecoration(
                            color: courseColor.withValues(alpha: 0.15),
                            shape: McSmoothCorners.shape(McRadii.controlBorder),
                          ),
                          child: Text(
                            l10n.creditUnit(course.credits.toString()),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: courseColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
