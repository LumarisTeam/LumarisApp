import 'package:curriculum/warehouse.dart';
import 'package:go_router/go_router.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/warehouse_repo_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page/warehouse_import_webview_page.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

/// 从拾光适配仓库选择学校和适配器的页面。
class WarehouseImportPage extends StatefulWidget {
  /// 创建页面。
  const WarehouseImportPage({super.key});

  @override
  State<WarehouseImportPage> createState() => _WarehouseImportPageState();
}

class _WarehouseImportPageState extends State<WarehouseImportPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<WarehouseRegistry> _future;
  WarehouseCategory? _category;

  @override
  void initState() {
    super.initState();
    _future = WarehouseRepoService.instance.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload({bool forceRefresh = false}) {
    setState(() {
      _future = WarehouseRepoService.instance.load(forceRefresh: forceRefresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return Scaffold(
      appBar: McAppBar(
        title: l10n.warehouseImport,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshRepository,
            onPressed: () => _reload(forceRefresh: true),
          ),
        ],
      ),
      body: FutureBuilder<WarehouseRegistry>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _LoadingState(message: l10n.loadingSchoolList);
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            AppLogger.warning('[Warehouse] 加载学校列表失败: $error');
            return _ErrorState(
              message: l10n.warehouseRepositoryUnavailable,
              retryLabel: l10n.retry,
              onRetry: _reload,
            );
          }

          final registry = snapshot.data;
          if (registry == null) {
            return _ErrorState(
              message: l10n.warehouseRepositoryUnavailable,
              retryLabel: l10n.retry,
              onRetry: _reload,
            );
          }

          final schools = _filteredSchools(registry);
          return Column(
            children: [
              _buildHint(context, colors, l10n),
              _buildSearch(context, colors, l10n),
              _buildCategoryChips(context, l10n),
              Expanded(
                child: schools.isEmpty
                    ? Center(
                        child: Text(
                          l10n.warehouseNoSchoolFound,
                          style: TextStyle(color: colors.secondaryLabel),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: schools.length,
                        itemBuilder: (context, index) => _SchoolTile(
                          school: schools[index],
                          onTap: () => _chooseAdapter(schools[index]),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(
                      l10n.warehouseSchoolCount(schools.length),
                      style: TextStyle(fontSize: 12, color: colors.secondaryLabel),
                    ),
                    const Spacer(),
                    Text(
                      l10n.warehouseVersion(registry.catalog.versionId),
                      style: TextStyle(fontSize: 12, color: colors.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHint(BuildContext context, McColors colors, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.warehouseSelectSchoolHint,
        style: TextStyle(fontSize: 13, color: colors.primary),
      ),
    );
  }

  Widget _buildSearch(BuildContext context, McColors colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: l10n.searchSchool,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: colors.groupedBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, AppLocalizations l10n) {
    final options = <(WarehouseCategory?, String)>[
      (null, l10n.warehouseCategoryAll),
      (WarehouseCategory.bachelorAndAssociate, l10n.warehouseCategoryUndergrad),
      (WarehouseCategory.postgraduate, l10n.warehouseCategoryPostgrad),
      (WarehouseCategory.generalTool, l10n.warehouseCategoryTools),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(option.$2),
                selected: _category == option.$1,
                onSelected: (_) => setState(() => _category = option.$1),
              ),
            ),
        ],
      ),
    );
  }

  List<WarehouseSchool> _filteredSchools(WarehouseRegistry registry) {
    final query = _searchController.text;
    final searched = registry.search(query);
    final category = _category;
    if (category == null) return searched;
    return searched
        .where(
          (school) => school.adapters.any((adapter) => adapter.category == category),
        )
        .toList(growable: false);
  }

  Future<void> _chooseAdapter(WarehouseSchool school) async {
    if (school.adapters.isEmpty) return;
    if (school.adapters.length == 1) {
      await _openAdapter(school, school.adapters.first);
      return;
    }

    final selected = await showModalBottomSheet<WarehouseAdapter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                context.l10n.selectAdapter,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            for (final adapter in school.adapters)
              ListTile(
                title: Text(adapter.adapterName),
                subtitle: adapter.description == null
                    ? null
                    : Text(
                        adapter.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(adapter),
              ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await _openAdapter(school, selected);
    }
  }

  Future<void> _openAdapter(WarehouseSchool school, WarehouseAdapter adapter) async {
    var url = adapter.importUrl?.trim() ?? '';
    if (url.isEmpty) {
      final input = await _askForUrl();
      if (input == null || input.trim().isEmpty) return;
      url = input.trim();
    }

    if (!mounted) return;
    final imported = await AppRouter.push<bool>(
      AppRoutes.warehouseImportWebview,
      extra: WarehouseImportArgs(
        adapter: adapter,
        url: url,
        schoolName: school.name,
      ),
    );
    if (imported == true && mounted) {
      context.pop(true);
    }
  }

  Future<String?> _askForUrl() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) {
          final l10n = context.l10n;
          return AlertDialog(
            title: Text(l10n.enterCustomUrl),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(hintText: l10n.urlHint),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }
}

class _SchoolTile extends StatelessWidget {
  const _SchoolTile({required this.school, required this.onTap});

  final WarehouseSchool school;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.groupedBackground,
        shape: McSmoothCorners.shape(BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(school.name),
          subtitle: Text(
            school.adapters.map((adapter) => adapter.adapterName).join(' / '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (school.adapters.length > 1)
                Text(
                  '${school.adapters.length}',
                  style: TextStyle(color: colors.secondaryLabel, fontSize: 12),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
