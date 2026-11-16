import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoIcons, CupertinoSearchTextField;
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../features/education/models/lesson_search_item.dart';
import '../../components/empty_widget.dart';
import '../../components/modal_components.dart';

class LessonSearchView extends StatefulWidget {
  const LessonSearchView({super.key, required this.lessons, this.onRefresh});

  final List<LessonSearchItem> lessons;
  final RefreshCallback? onRefresh;

  @override
  State<LessonSearchView> createState() => _LessonSearchViewState();
}

class _LessonSearchViewState extends State<LessonSearchView> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _onlyAvailable = false;
  static final RegExp _whitespace = RegExp(r'\s+');

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _searchChanged() {
    setState(() {});
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _showFilters() async {
    FocusScope.of(context).unfocus();
    bool draft = _onlyAvailable;
    final bool? result = await showMcBottomSheet<bool>(
      context: context,
      scrollable: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          final l10n = context.l10n;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalHeader(
                title: l10n.lessonFilterTitle,
                actions: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.lessonOnlyAvailable),
                  value: draft,
                  onChanged: (value) => update(() => draft = value),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => update(() => draft = false),
                    child: Text(l10n.lessonReset),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(draft),
                    child: Text(l10n.lessonApplyFilter),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    if (!mounted || result == null || result == _onlyAvailable) return;
    _onlyAvailable = result;
    _searchChanged();
  }

  Future<void> _showDetails(LessonSearchItem lesson) async {
    FocusScope.of(context).unfocus();
    await showMcBottomSheet<void>(
      context: context,
      scrollable: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      builder: (context) {
        final l10n = context.l10n;
        final String fallback = l10n.lessonMissingValue;
        final Map<String, String> values = {
          l10n.teacherLabel: lesson.teacher.isEmpty ? fallback : lesson.teacher,
          l10n.classTime: lesson.timeText.isEmpty ? fallback : lesson.timeText,
          l10n.classroom: lesson.location.isEmpty ? fallback : lesson.location,
          l10n.lessonCapacity: l10n.lessonPeople(lesson.capacity),
          l10n.lessonSelected: l10n.lessonPeople(lesson.selectedCount),
          l10n.lessonRemaining: l10n.lessonPeople(lesson.remaining),
        };
        final String subtitle = [
          lesson.courseCode,
          lesson.sectionCode,
          if (lesson.sectionName != lesson.title &&
              lesson.sectionName != lesson.sectionCode)
            lesson.sectionName,
        ].where((value) => value.isNotEmpty).join(' · ');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalHeader(
              title: lesson.title.isEmpty ? fallback : lesson.title,
              subtitle: subtitle.isEmpty ? null : subtitle,
              actions: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              child: Column(
                children: [
                  for (final MapEntry<String, String> entry in values.entries)
                    ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final colors = context.mc.colors;
    final List<String> terms = _search.text
        .toLowerCase()
        .split(_whitespace)
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
    final bool hasConditions = terms.isNotEmpty || _onlyAvailable;
    final List<LessonSearchItem> matches = hasConditions
        ? widget.lessons
              .where(
                (lesson) =>
                    lesson.matches(terms, onlyAvailable: _onlyAvailable),
              )
              .toList(growable: false)
        : widget.lessons;
    final String semester = widget.lessons
        .map((lesson) => lesson.semesterName)
        .firstWhere(
          (name) => name.isNotEmpty,
          orElse: () => l10n.lessonCurrentTerm,
        );
    final BorderRadius groupRadius = BorderRadius.circular(18);

    final Widget scrollView = CustomScrollView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.lessonSearchTitle,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(semester, style: TextStyle(color: colors.secondaryLabel)),
              ],
            ),
          ),
        ),
        PinnedHeaderSliver(
          child: ColoredBox(
            color: colors.groupedBackground,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CupertinoSearchTextField(
                      controller: _search,
                      placeholder: l10n.lessonSearchHint,
                      onChanged: (_) => _searchChanged(),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      style: TextStyle(color: colors.label),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Tooltip(
                      message: l10n.lessonFilterTitle,
                      child: FilterChip(
                        label: Text(
                          _onlyAvailable
                              ? l10n.lessonAvailable
                              : l10n.lessonFilter,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        avatar: const Icon(
                          CupertinoIcons.line_horizontal_3_decrease,
                        ),
                        showCheckmark: false,
                        selected: _onlyAvailable,
                        onSelected: (_) => _showFilters(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.lessonResultCount(matches.length),
                style: TextStyle(color: colors.secondaryLabel),
              ),
            ),
          ),
        ),
        if (matches.isEmpty)
          SliverToBoxAdapter(
            child: EmptyWidget(
              title: hasConditions ? l10n.lessonNoMatches : l10n.lessonNoData,
              subtitle: '',
              icon: hasConditions ? CupertinoIcons.search : CupertinoIcons.book,
              action: hasConditions
                  ? TextButton(
                      onPressed: () {
                        _search.clear();
                        _onlyAvailable = false;
                        _searchChanged();
                      },
                      child: Text(l10n.lessonClearConditions),
                    )
                  : null,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final LessonSearchItem lesson = matches[index];
                final String metadata = [
                  lesson.courseCode,
                  lesson.sectionCode,
                  lesson.teacher,
                ].where((value) => value.isNotEmpty).join(' · ');
                return Material(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? groupRadius.topLeft : Radius.zero,
                    bottom: index == matches.length - 1
                        ? groupRadius.bottomLeft
                        : Radius.zero,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      if (index > 0)
                        Divider(height: 1, indent: 16, color: colors.separator),
                      ListTile(
                        onTap: () => _showDetails(lesson),
                        title: Text(
                          lesson.title.isEmpty
                              ? l10n.lessonMissingValue
                              : lesson.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          [
                            metadata,
                            lesson.timeText,
                          ].where((value) => value.isNotEmpty).join('\n'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              lesson.remaining > 0
                                  ? l10n.lessonSeatsLeft(lesson.remaining)
                                  : l10n.lessonFull,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 12,
                              color: colors.secondaryLabel,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: widget.onRefresh == null
              ? scrollView
              : RefreshIndicator(
                  onRefresh: widget.onRefresh!,
                  child: scrollView,
                ),
        ),
      ),
    );
  }
}
