import 'dart:convert';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

/// 自定义课程管理页面
///
/// 提供自定义课程的增删改查功能
class CustomCourseManagePage extends ConsumerStatefulWidget {
  const CustomCourseManagePage({super.key});

  @override
  ConsumerState<CustomCourseManagePage> createState() =>
      _CustomCourseManagePageState();
}

class _CustomCourseManagePageState
    extends ConsumerState<CustomCourseManagePage> {
  late List<CourseModel> customCourses;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomCourses();
  }

  Future<void> _loadCustomCourses() async {
    setState(() {
      isLoading = true;
    });

    final prefs = PrefsService.instance;
    final String? jsonString = prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        var migratedLegacySunday = false;
        customCourses = jsonList
            .map((json) => CourseModel.fromJson(json))
            .where((course) => course.isCustom)
            .map((course) {
              if (course.weekday == 0) {
                migratedLegacySunday = true;
                return _copyCourseWithWeekday(course, DateTime.sunday);
              }
              return course;
            })
            .toList();
        if (migratedLegacySunday) {
          await _saveCustomCourses();
        }
      } catch (e) {
        customCourses = [];
      }
    } else {
      customCourses = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveCustomCourses() async {
    final prefs = PrefsService.instance;
    final jsonString = jsonEncode(
      customCourses.map((course) => course.toJson()).toList(),
    );
    await prefs.setString(PrefsKeys.CUSTOM_COURSE_DATA, jsonString);
  }

  void _showAddCourseDialog() {
    final screenHeight = MediaQuery.of(context).size.height;

    showMcBottomSheet(
      context: context,
      builder: (_) => AddEditCourseDialog(
        onSave: (course) async {
          setState(() {
            customCourses.add(course);
          });
          await _saveCustomCourses();
          await _refreshCourseStore();
          if (mounted) {
            if (context.mounted) {
              McFeedback.showMessage(
                context,
                message: context.l10n.courseAdded,
              );
            }
          }
        },
      ),
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: screenHeight * 0.7,
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    final screenHeight = MediaQuery.of(context).size.height;
    showMcBottomSheet(
      context: context,
      builder: (_) => AddEditCourseDialog(
        course: course,
        onSave: (updatedCourse) async {
          setState(() {
            final index = customCourses.indexWhere(
              (c) => c.lessonId == course.lessonId,
            );
            if (index != -1) {
              customCourses[index] = updatedCourse;
            }
          });
          await _saveCustomCourses();
          await _refreshCourseStore();
          if (mounted) {
            if (context.mounted) {
              if (context.mounted) {
                McFeedback.showMessage(
                  context,
                  message: context.l10n.courseAdded,
                );
              }
            }
          }
        },
      ),
      showHandle: true,
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      maxHeight: screenHeight * 0.7,
    );
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirm = await showMcDialog(
      context: context,
      title: context.l10n.confirmDelete,
      content: Text(context.l10n.confirmDeleteCourseContent(course.courseName)),
      actions: [
        McDialogAction<bool>(label: context.l10n.cancel, value: false),
        McDialogAction<bool>(
          label: context.l10n.delete,
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (confirm == true) {
      setState(() {
        customCourses.removeWhere((c) => c.lessonId == course.lessonId);
      });
      await _saveCustomCourses();
      await _refreshCourseStore();
      if (mounted) {
        McFeedback.showMessage(context, message: context.l10n.courseDeleted);
      }
    }
  }

  Future<void> _refreshCourseStore() async {
    await ref.read(courseStoreProvider.notifier).loadCourses();
    await ref.read(scheduleStoreProvider.notifier).refreshLocalCourses();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.mc.colors;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: McAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.customCourses,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (customCourses.isNotEmpty)
              Center(
                child: Text(
                  l10n.customCoursesCount(customCourses.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryLabel,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCourseDialog,
            tooltip: l10n.addCourse,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingStateView(
                      title: l10n.readingCustomCourses,
                      subtitle: l10n.readingCustomCoursesSubtitle,
                    ),
                  )
                : customCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: McRadii.cardBorder,
                          ),
                          child: Icon(
                            Icons.event_available,
                            size: 48,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.noCustomCourses,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noCustomCoursesSubtitle,
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customCourses.length,
                    itemBuilder: (context, index) {
                      final course = customCourses[index];
                      return McCard.elevated(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.zero,
                        child: Material(
                          color: Colors.transparent,
                          shape: McSmoothCorners.shape(McRadii.cardBorder),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            borderRadius: McRadii.cardBorder,
                            customBorder: McSmoothCorners.shape(
                              McRadii.cardBorder,
                            ),
                            onTap: () {
                              _showEditCourseDialog(course);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.courseName,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _buildInfoChip(
                                              Icons.location_on_outlined,
                                              course.room.isEmpty
                                                  ? l10n.noLocation
                                                  : course.room,
                                              colors.primary,
                                            ),
                                            _buildInfoChip(
                                              Icons.schedule_outlined,
                                              _formatCourseTime(course),
                                              colors.success,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  McPopoverMenu<String>(
                                    showCheckmark: false,
                                    items: <McPopoverMenuItem<String>>[
                                      McPopoverMenuItem<String>(
                                        value: 'edit',
                                        label: l10n.editCourse,
                                        icon: Icons.edit_outlined,
                                      ),
                                      McPopoverMenuItem<String>(
                                        value: 'delete',
                                        label: l10n.deleteCourse,
                                        icon: Icons.delete_outline,
                                        isDestructive: true,
                                      ),
                                    ],
                                    onSelected: (String value) {
                                      if (value == 'edit') {
                                        _showEditCourseDialog(course);
                                      } else if (value == 'delete') {
                                        _deleteCourse(course);
                                      }
                                    },
                                    child: Tooltip(
                                      message: l10n.moreFunctions,
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          CupertinoIcons.ellipsis_circle,
                                          size: 19,
                                          color: colors.secondaryLabel,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.1),
        shape: McSmoothCorners.shape(McRadii.controlBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCourseTime(CourseModel course) {
    final l10n = context.l10n;
    return '${_getWeekdayName(l10n, course.weekday)} '
        '${l10n.periodRange(course.startUnit, course.endUnit)}';
  }
}

List<String> _getWeekdayNames(dynamic l10n) {
  return [
    l10n.sunday,
    l10n.monday,
    l10n.tuesday,
    l10n.wednesday,
    l10n.thursday,
    l10n.friday,
    l10n.saturday,
    l10n.sunday,
  ];
}

const List<int> _weekdayDropdownValues = [
  DateTime.sunday,
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
];

int _normalizeCourseWeekday(int weekday) {
  if (weekday == 0) {
    return DateTime.sunday;
  }
  if (weekday >= DateTime.monday && weekday <= DateTime.sunday) {
    return weekday;
  }
  return DateTime.monday;
}

String _getWeekdayName(dynamic l10n, int weekday) {
  return _getWeekdayNames(l10n)[_normalizeCourseWeekday(weekday)];
}

CourseModel _copyCourseWithWeekday(CourseModel course, int weekday) {
  return CourseModel(
    weekIndexes: course.weekIndexes,
    teachers: course.teachers,
    room: course.room,
    courseName: course.courseName,
    courseCode: course.courseCode,
    weekday: weekday,
    startUnit: course.startUnit,
    endUnit: course.endUnit,
    credits: course.credits,
    lessonId: course.lessonId,
    campus: course.campus,
    isCustom: course.isCustom,
  );
}

/// 添加/编辑课程对话框
class AddEditCourseDialog extends StatefulWidget {
  final CourseModel? course;
  final Function(CourseModel) onSave;

  const AddEditCourseDialog({super.key, this.course, required this.onSave});

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  late TextEditingController _courseNameController;
  late TextEditingController _roomController;
  late TextEditingController _teacherController;
  late TextEditingController _creditsController;
  late int _selectedWeekday;
  late int _startUnit;
  late int _endUnit;
  late List<int> _selectedWeeks;

  final List<int> _availableWeeks = List.generate(20, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(
      text: widget.course?.courseName ?? '',
    );
    _roomController = TextEditingController(text: widget.course?.room ?? '');
    _teacherController = TextEditingController(
      text: widget.course?.teachers.join(', ') ?? '',
    );
    _creditsController = TextEditingController(
      text: widget.course?.credits ?? '',
    );
    _selectedWeekday = _normalizeCourseWeekday(
      widget.course?.weekday ?? DateTime.monday,
    );
    _startUnit = widget.course?.startUnit ?? 1;
    _endUnit = widget.course?.endUnit ?? 2;
    _selectedWeeks =
        widget.course != null && widget.course!.weekIndexes.isNotEmpty
        ? List.from(widget.course!.weekIndexes)
        : [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
          ];
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _roomController.dispose();
    _teacherController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_courseNameController.text.trim().isEmpty) {
      McFeedback.showMessage(context, message: context.l10n.courseName);
      return;
    }

    final course = CourseModel(
      weekIndexes: _selectedWeeks,
      teachers: _teacherController.text
          .trim()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      room: _roomController.text.trim(),
      courseName: _courseNameController.text.trim(),
      courseCode: 'CUSTOM_${DateTime.now().millisecondsSinceEpoch}',
      weekday: _selectedWeekday,
      startUnit: _startUnit,
      endUnit: _endUnit,
      credits: _creditsController.text.trim(),
      lessonId:
          widget.course?.lessonId ??
          'CUSTOM_${DateTime.now().millisecondsSinceEpoch}',
      campus: '',
      isCustom: true,
    );

    widget.onSave(course);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weekdays = _getWeekdayNames(l10n);
    final colors = context.mc.colors;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.course == null ? l10n.addCourse : l10n.editCourse,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              l10n.courseName,
              _courseNameController,
              l10n.courseName,
              Icons.book_outlined,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.courseRoom,
              _roomController,
              l10n.courseRoom,
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.courseTeacher,
              _teacherController,
              l10n.courseTeacher,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.courseCredits,
              _creditsController,
              l10n.courseCredits,
              Icons.school_outlined,
            ),
            const SizedBox(height: 20),

            // Weekday selector
            Text(
              l10n.courseWeekday,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdownField<int>(
              label: weekdays[_selectedWeekday],
              value: _selectedWeekday,
              items: _weekdayDropdownValues
                  .map(
                    (weekday) => McPopoverMenuItem<int>(
                      value: weekday,
                      label: weekdays[weekday],
                    ),
                  )
                  .toList(growable: false),
              onSelected: (value) {
                setState(() {
                  _selectedWeekday = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Time selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.courseStartUnit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownField<int>(
                        label: l10n.periodUnit(_startUnit),
                        value: _startUnit,
                        items: List.generate(
                          12,
                          (index) => McPopoverMenuItem<int>(
                            value: index + 1,
                            label: l10n.periodUnit(index + 1),
                          ),
                        ),
                        onSelected: (value) {
                          setState(() {
                            _startUnit = value;
                            if (_startUnit > _endUnit) {
                              _endUnit = _startUnit;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.courseEndUnit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownField<int>(
                        label: l10n.periodUnit(_endUnit),
                        value: _endUnit,
                        items: List.generate(
                          12,
                          (index) => McPopoverMenuItem<int>(
                            value: index + 1,
                            label: l10n.periodUnit(index + 1),
                          ),
                        ),
                        onSelected: (value) {
                          if (value >= _startUnit) {
                            setState(() {
                              _endUnit = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Week selector
            Text(
              l10n.courseWeeks,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableWeeks.map((week) {
                final isSelected = _selectedWeeks.contains(week);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedWeeks.remove(week);
                      } else {
                        _selectedWeeks.add(week);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: ShapeDecoration(
                      color: isSelected ? primaryColor : colors.surfaceMuted,
                      shape: McSmoothCorners.shape(
                        McRadii.cardBorder,
                        side: BorderSide(
                          color: isSelected
                              ? primaryColor
                              : colors.borderStrong,
                        ),
                      ),
                    ),
                    child: Text(
                      l10n.weekUnit(week),
                      style: TextStyle(
                        color: isSelected
                            ? colors.onAccent
                            : colors.secondaryLabel,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: colors.secondaryLabel),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: colors.onAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: McSmoothCorners.shape(McRadii.controlBorder),
                elevation: 0,
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<McPopoverMenuItem<T>> items,
    required ValueChanged<T> onSelected,
  }) {
    final colors = context.mc.colors;
    return McPopoverMenu<T>(
      items: items,
      selectedValue: value,
      matchTriggerWidth: true,
      offset: const Offset(0, 6),
      onSelected: onSelected,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: colors.surfaceRaised,
          shape: McSmoothCorners.shape(
            McRadii.navigationBorder,
            side: BorderSide(color: colors.borderStrong),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool required = false,
  }) {
    final colors = context.mc.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.danger,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.tertiaryLabel),
            prefixIcon: Icon(icon, size: 20, color: colors.tertiaryLabel),
            filled: true,
            fillColor: colors.surfaceRaised,
            border: OutlineInputBorder(
              borderRadius: McRadii.controlBorder,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: McRadii.controlBorder,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: McRadii.controlBorder,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
