import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class HtmlImportPage extends ConsumerStatefulWidget {
  const HtmlImportPage({super.key});

  @override
  ConsumerState<HtmlImportPage> createState() => _HtmlImportPageState();
}

class _HtmlImportPageState extends ConsumerState<HtmlImportPage> {
  final _urlController = TextEditingController();

  /// 选中的学校 code；手填自定义网址时为 null。
  String? _selectedCode;

  /// 实际用于加载 WebView 的网址：选中学校时是 school.website，否则是手填值。
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    // 默认选中当前学校，省掉一次「我已经选过了」的操作。
    final current = ref.read(schoolStoreProvider).school;
    if (current != null && current.website.trim().isNotEmpty) {
      _selectedCode = current.code;
      _selectedUrl = current.website;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _selectSchool(School school) {
    setState(() {
      _selectedCode = school.code;
      _selectedUrl = school.website;
    });
    _urlController.clear();
  }

  void _openWebView() {
    final url = _selectedUrl ?? _urlController.text.trim();
    if (url.isEmpty) return;

    // 选了学校就把代号带过去，解析时优先用该校适配器；手填网址则交给自动探测。
    final code = _selectedUrl != null ? _selectedCode : null;
    final location = code == null || code.isEmpty
        ? AppRoutes.htmlImportWebview
        : '${AppRoutes.htmlImportWebview}?school=${Uri.encodeQueryComponent(code)}';
    context.push(location, extra: url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;

    // 学校列表来自 SchoolApi，接口失败时 Provider 内部已退回 fallbackList。
    final schools =
        ref.watch(importSchoolListProvider).valueOrNull ?? School.fallbackList;
    // 没有网址的学校点不动（会加载一个空 URI），直接不展示。
    final selectable =
        schools.where((school) => school.website.trim().isNotEmpty).toList();

    final canImport =
        _selectedUrl != null || _urlController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: ClubAppBar(title: l10n.htmlImport),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.selectSchool,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.label,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...selectable.map(
                  (school) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Material(
                      color: _selectedCode == school.code
                          ? colors.selectionFill
                          : colors.groupedBackground,
                      shape: ClubSmoothCorners.shape(BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        customBorder:
                            ClubSmoothCorners.shape(BorderRadius.circular(12)),
                        onTap: () => _selectSchool(school),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      school.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: colors.label,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      school.website,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.secondaryLabel,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedCode == school.code)
                                Icon(Icons.check_circle, color: colors.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    l10n.enterCustomUrl,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colors.label,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: l10n.urlHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colors.groupedBackground,
                    ),
                    // 无论清空选中还是首次输入都要重建，否则「导入」按钮的可用
                    // 状态不会跟着输入更新。
                    onChanged: (_) {
                      setState(() {
                        if (_urlController.text.trim().isNotEmpty) {
                          _selectedCode = null;
                          _selectedUrl = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canImport ? _openWebView : null,
                icon: const Icon(Icons.open_in_browser),
                label: Text(l10n.htmlImport),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
