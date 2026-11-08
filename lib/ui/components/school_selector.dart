import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

class SchoolSelector extends StatelessWidget {
  const SchoolSelector({
    super.key,
    required this.selectedSchool,
    required this.onChanged,
    this.schools,
  });

  final School? selectedSchool;
  final ValueChanged<School> onChanged;
  final List<School>? schools;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.mc.colors;
    final allSchools = schools ?? School.fallbackList;

    return Autocomplete<School>(
      initialValue: TextEditingValue(text: selectedSchool?.name ?? ''),
      displayStringForOption: (school) => school.name,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return allSchools;
        return School.searchLocally(allSchools, textEditingValue.text);
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 17),
          decoration: InputDecoration(
            // 关闭主题默认的填充，背景与圆角由外层分组容器负责绘制。
            filled: false,
            hintText: l10n.selectSchool,
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              CupertinoIcons.building_2_fill,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              size: 22,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            isDense: true,
          ),
          onSubmitted: (value) {
            final match = School.searchLocally(allSchools, value);
            if (match.isNotEmpty) {
              onChanged(match.first);
              controller.text = match.first.name;
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final school = options.elementAt(index);
                  final isSelected = school.code == selectedSchool?.code;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: colors.primary.withValues(alpha: 0.1),
                    leading: Icon(
                      CupertinoIcons.building_2_fill,
                      color: isSelected ? colors.primary : null,
                      size: 22,
                    ),
                    title: Text(
                      school.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? colors.primary : null,
                      ),
                    ),
                    subtitle: Text(
                      school.code,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: _SchoolFeatureBadge(school: school),
                    onTap: () => onSelected(school),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: onChanged,
    );
  }
}

class _SchoolFeatureBadge extends StatelessWidget {
  const _SchoolFeatureBadge({required this.school});

  final School school;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasTimetable = school.features.contains(Feature.timetable);
    final hasLogin = school.features.contains(Feature.login);
    final isAdvanced = hasTimetable && hasLogin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdvanced
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isAdvanced ? l10n.advancedSupport : l10n.basicSupport,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAdvanced ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }
}
