import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ios_club_app/core/services/course_html_parser.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/education/services/warehouse_import_store.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/schedule_store.dart';

class HtmlImportWebViewPage extends ConsumerStatefulWidget {
  final String url;

  /// 用户在导入页选中的学校代号（如 `XAUAT`）；手填网址时为 null。
  final String? schoolCode;

  const HtmlImportWebViewPage({super.key, required this.url, this.schoolCode});

  @override
  ConsumerState<HtmlImportWebViewPage> createState() =>
      _HtmlImportWebViewPageState();
}

class _HtmlImportWebViewPageState extends ConsumerState<HtmlImportWebViewPage> {
  late final WebViewController _controller;
  var _isImporting = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (_isImporting) setState(() => _isImporting = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _importHtml() async {
    setState(() => _isImporting = true);

    try {
      final result = await _controller.runJavaScriptReturningResult(
        'document.documentElement.outerHTML',
      );
      final html = result.toString();

      if (html.isEmpty) {
        if (mounted) {
          McFeedback.showMessage(
            context,
            message: context.l10n.noCoursesParsed,
          );
        }
        return;
      }

      final parsed = CourseHtmlParser.parseHtml(
        html,
        schoolCode: widget.schoolCode,
      );

      if (parsed.isEmpty) {
        // 线上排查靠这段：适配器、课程数、被跳过的课程数，以及每条诊断。
        AppLogger.warning(
          '[HtmlImport] 未解析到课程 (school=${widget.schoolCode ?? '-'}, '
          'url=${widget.url})\n${parsed.diagnosticReport}',
        );
        if (mounted) {
          McFeedback.showMessage(
            context,
            message: context.l10n.noCoursesParsed,
          );
        }
        return;
      }

      final courses = parsed.courses;

      // 这次导入不再来自适配仓库，清掉导入作息，避免沿用上一所学校的节次时间。
      TimeService.clearImportedTable();
      await WarehouseImportStore.clear();

      await ref.read(courseStoreProvider.notifier).saveGuestCourses(courses);
      final scheduleStore = ref.read(scheduleStoreProvider.notifier);
      await scheduleStore.loadGuestCourseData();
      // 回到没有适配器学期配置的游客课表：第 1 周、默认 20 周。
      scheduleStore.applyImportedWeekConfig();

      if (mounted) {
        McFeedback.showMessage(
          context,
          message:
              '${context.l10n.importCourses} ${courses.length} ${context.l10n.parseResult}',
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        McFeedback.showMessage(
          context,
          message: '${context.l10n.noCoursesParsed}: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: McAppBar(title: context.l10n.htmlImport),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              context.l10n.pasteHtmlHint,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isImporting ? null : _importHtml,
        icon: _isImporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download),
        label: Text(context.l10n.importCourses),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
