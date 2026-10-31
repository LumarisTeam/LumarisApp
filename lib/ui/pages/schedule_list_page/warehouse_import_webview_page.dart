import 'dart:async';
import 'dart:convert';

import 'package:curriculum/warehouse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/warehouse_course_mapper.dart';
import 'package:ios_club_app/features/education/services/warehouse_import_store.dart';
import 'package:ios_club_app/features/education/services/warehouse_repo_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 打开适配器 WebView 所需的参数。
class WarehouseImportArgs {
  /// 创建参数。
  const WarehouseImportArgs({
    required this.adapter,
    required this.url,
    required this.schoolName,
  });

  /// 选中的适配器。
  final WarehouseAdapter adapter;

  /// 教务系统地址。
  final String url;

  /// 学校名称，用于标题与持久化。
  final String schoolName;
}

/// 在 WebView 里登录教务系统并执行仓库适配器的导入页。
class WarehouseImportWebViewPage extends ConsumerStatefulWidget {
  /// 创建页面。
  const WarehouseImportWebViewPage({super.key, required this.args});

  /// 导入参数。
  final WarehouseImportArgs args;

  @override
  ConsumerState<WarehouseImportWebViewPage> createState() =>
      _WarehouseImportWebViewPageState();
}

class _WarehouseImportWebViewPageState
    extends ConsumerState<WarehouseImportWebViewPage> {
  late final WebViewController _controller;
  WarehouseImportSession? _session;
  Timer? _importTimer;

  bool _isPreparing = true;
  bool _pageReady = false;
  bool _isImporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _pageReady = false);
          },
          onPageFinished: (_) => unawaited(_onPageFinished()),
          onWebResourceError: (error) {
            AppLogger.debug(
              '[Warehouse] WebView 资源错误: ${error.description} (${error.errorCode})',
            );
          },
        ),
      );
    unawaited(
      _controller.addJavaScriptChannel(
        kWarehouseBridgeChannel,
        onMessageReceived: _onJsMessage,
      ),
    );
    unawaited(_prepare());
  }

  @override
  void dispose() {
    _importTimer?.cancel();
    super.dispose();
  }

  Future<void> _prepare() async {
    setState(() {
      _isPreparing = true;
      _error = null;
    });

    try {
      final source = await WarehouseRepoService.instance.loadScript(
        widget.args.adapter,
      );
      if (!mounted) return;

      final session = WarehouseImportSession(
        script: WarehouseAdapterScript(
          adapter: widget.args.adapter,
          source: source,
        ),
        host: _WebViewImportHost(this),
      );
      setState(() {
        _session = session;
        _isPreparing = false;
      });

      unawaited(
        session.completed.then<void>(
          (result) {
            if (mounted) unawaited(_handleCompleted(result));
          },
          onError: (Object error, StackTrace stackTrace) {
            if (mounted) _handleSessionError(error, stackTrace);
          },
        ),
      );

      await _controller.loadRequest(Uri.parse(widget.args.url));
    } catch (error, stackTrace) {
      AppLogger.error(
        '[Warehouse] 准备适配器失败',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _isPreparing = false;
        _error = '$error';
      });
    }
  }

  Future<void> _onPageFinished() async {
    final session = _session;
    if (session == null) return;
    try {
      await _controller.runJavaScript(session.bootstrapScript);
      if (mounted) setState(() => _pageReady = true);
    } catch (error, stackTrace) {
      AppLogger.warning(
        '[Warehouse] 注入 bridge shim 失败',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onJsMessage(JavaScriptMessage message) {
    final session = _session;
    if (session == null) return;
    unawaited(session.handleMessage(message.message));
  }

  Future<void> _startImport() async {
    final session = _session;
    if (session == null || !_pageReady) {
      if (mounted) {
        McFeedback.showMessage(context, message: context.l10n.pageNotReady);
      }
      return;
    }
    if (_isImporting) return;

    setState(() => _isImporting = true);
    _importTimer?.cancel();
    _importTimer = Timer(const Duration(seconds: 90), () {
      if (!mounted || !_isImporting) return;
      setState(() => _isImporting = false);
      McFeedback.showMessage(
        context,
        message: context.l10n.warehouseImportFailed,
      );
    });

    try {
      await _controller.runJavaScript(session.startScript);
    } catch (error, stackTrace) {
      _importTimer?.cancel();
      AppLogger.error(
        '[Warehouse] 执行适配器失败',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isImporting = false);
      McFeedback.showMessage(
        context,
        message: context.l10n.warehouseImportFailed,
      );
    }
  }

  Future<void> _handleCompleted(CourseImportResult result) async {
    _importTimer?.cancel();
    if (!mounted) return;

    final l10n = context.l10n;

    // 先切换作息，再用导入表把自定义时间映射到节次。
    TimeService.clearImportedTable();
    if (result.timeSlots.isNotEmpty) {
      TimeService.installImportedSlots(result.timeSlots);
    }

    final mapResult = WarehouseCourseMapper.toCourseModels(
      result.courses,
      fallbackWeeks:
          result.config?.semesterTotalWeeks ?? WarehouseCourseMapper.defaultWeeks,
      table: TimeService.tables.first,
    );
    AppLogger.info(
      '[Warehouse] 适配器完成 ${widget.args.adapter.adapterId}\n'
      '${_session?.diagnostics.report}',
    );

    if (mapResult.courses.isEmpty) {
      setState(() => _isImporting = false);
      McFeedback.showMessage(context, message: l10n.noCoursesParsed);
      return;
    }

    try {
      await ref
          .read(courseStoreProvider.notifier)
          .saveGuestCourses(mapResult.courses);
      await WarehouseImportStore.save(
        WarehouseImportedTimetable(
          schoolId: widget.args.adapter.schoolId,
          schoolName: widget.args.schoolName,
          adapterId: widget.args.adapter.adapterId,
          adapterName: widget.args.adapter.adapterName,
          importedAt: DateTime.now(),
          timeSlots: result.timeSlots,
          config: result.config,
          comboSchedule: result.comboSchedule,
        ),
      );
      await ref.read(scheduleStoreProvider.notifier).loadGuestCourseData();
      ref
          .read(scheduleStoreProvider.notifier)
          .applyImportedWeekConfig(
            semesterStartDate: result.config?.semesterStartDate,
            semesterTotalWeeks: result.config?.semesterTotalWeeks,
            firstDayOfWeek: result.config?.firstDayOfWeek,
          );
    } catch (error, stackTrace) {
      AppLogger.error(
        '[Warehouse] 保存导入课程失败',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isImporting = false);
      McFeedback.showMessage(context, message: l10n.warehouseImportFailed);
      return;
    }

    if (!mounted) return;
    McFeedback.showSuccess(
      context,
      message: l10n.warehouseImportSuccess(mapResult.courses.length),
    );
    context.pop(true);
  }

  void _handleSessionError(Object error, StackTrace stackTrace) {
    _importTimer?.cancel();
    AppLogger.error(
      '[Warehouse] 适配器会话异常',
      error: error,
      stackTrace: stackTrace,
    );
    if (!mounted) return;
    setState(() => _isImporting = false);
    McFeedback.showMessage(
      context,
      message: context.l10n.warehouseImportFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return Scaffold(
      appBar: McAppBar(title: widget.args.schoolName),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.primary.withValues(alpha: 0.08),
            child: Text(
              l10n.warehouseImportHint,
              style: TextStyle(fontSize: 13, color: colors.primary),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: _buildBody(l10n)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pageReady && !_isImporting && _error == null
                    ? _startImport
                    : null,
                icon: _isImporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isImporting
                      ? l10n.warehouseImportInProgress
                      : l10n.startImport,
                ),
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

  Widget _buildBody(AppLocalizations l10n) {
    if (_isPreparing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loading),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _prepare,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return WebViewWidget(controller: _controller);
  }
}

class _WebViewImportHost implements WarehouseImportHost {
  _WebViewImportHost(this._state);

  final _WarehouseImportWebViewPageState _state;

  @override
  Future<String?> evaluateJavascript(String script) async {
    try {
      final result = await _state._controller.runJavaScriptReturningResult(
        script,
      );
      return result.toString();
    } catch (error, stackTrace) {
      AppLogger.debug(
        '[Warehouse] 执行 JS 失败',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> showToast(String message) async {
    if (!_state.mounted) return;
    // Toast 自身会停留 3 秒；不能阻塞 Bridge 消息队列。
    unawaited(McFeedback.showMessage(_state.context, message: message));
  }

  @override
  Future<void> showAlert({
    required String title,
    required String content,
    String? confirmText,
  }) async {
    if (!_state.mounted) return;
    final l10n = _state.context.l10n;
    await showDialog<void>(
      context: _state.context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              confirmText != null && confirmText.trim().isNotEmpty
                  ? confirmText
                  : l10n.ok,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<String?> showPrompt({
    required String title,
    required String tip,
    String defaultText = '',
    String? validatorJsFunction,
  }) async {
    if (!_state.mounted) return null;
    final l10n = _state.context.l10n;
    final controller = TextEditingController(text: defaultText);

    try {
      return await showDialog<String>(
        context: _state.context,
        builder: (dialogContext) {
          String? errorText;
          var isSubmitting = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> submitWithState() async {
                if (isSubmitting) return;
                isSubmitting = true;
                try {
                  final value = controller.text;
                  final validator = validatorJsFunction?.trim() ?? '';
                  if (validator.isNotEmpty) {
                    final raw = await evaluateJavascript(
                      '$validator(${jsonEncode(value)})',
                    );
                    final error = _validatorError(raw);
                    if (error != null) {
                      setDialogState(() => errorText = error);
                      return;
                    }
                  }
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(value);
                  }
                } finally {
                  isSubmitting = false;
                }
              }

              return AlertDialog(
                title: Text(title),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: tip,
                    errorText: errorText,
                  ),
                  onSubmitted: (_) => unawaited(submitWithState()),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => unawaited(submitWithState()),
                    child: Text(l10n.ok),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Future<int?> showSingleSelection({
    required String title,
    required List<String> items,
    int defaultIndex = -1,
  }) async {
    if (!_state.mounted || items.isEmpty) return null;
    final l10n = _state.context.l10n;

    return showModalBottomSheet<int>(
      context: _state.context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (var index = 0; index < items.length; index++)
              ListTile(
                selected: index == defaultIndex,
                leading: index == defaultIndex
                    ? const Icon(Icons.check_circle)
                    : null,
                title: Text(items[index]),
                onTap: () => Navigator.of(context).pop(index),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 把 WebView `runJavaScriptReturningResult` 的返回值归一化为校验错误。
///
/// 拾光的校验函数约定：返回非空字符串表示失败，返回空串、`false` 或 `null`
/// 表示通过。iOS 会把字符串再包一层 JSON 引号，所以这里要尝试解码。
String? _validatorError(String? raw) {
  if (raw == null) return null;
  var value = raw.trim();
  if (value.isEmpty || value == 'null' || value == 'false' || value == '""') {
    return null;
  }
  if (value.startsWith('"') && value.endsWith('"')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is String) value = decoded;
    } catch (_) {
      // 保持原值。
    }
  }
  value = value.trim();
  if (value.isEmpty || value.toLowerCase() == 'false' || value == 'null') {
    return null;
  }
  return value;
}
