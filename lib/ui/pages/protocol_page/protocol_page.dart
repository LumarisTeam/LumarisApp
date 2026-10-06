import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 协议正文只在服务端维护一份，App 内不再内置副本：修订条款不需要发版，
/// 也就不会出现内置文案与线上版本对不上的情况。
enum ProtocolDocument {
  privacyPolicy(
    'https://app.xauat.site/protocols/36ab2fc8-8e09-4c38-b96f-4f2d7e58263d',
  ),
  userAgreement(
    'https://app.xauat.site/protocols/9b0e570c-4447-475f-8cfd-e346e23e105b',
  );

  const ProtocolDocument(this.url);

  final String url;

  String title(AppLocalizations l10n) => switch (this) {
    ProtocolDocument.privacyPolicy => l10n.privacyPolicy,
    ProtocolDocument.userAgreement => l10n.userAgreement,
  };
}

/// 允许在应用内继续跳转的主机；跳到别处一律交给系统浏览器，
/// 免得用户被困在一个只有"返回"能退出的网页里。
const _inlineHost = 'app.xauat.site';

/// `webview_flutter` 只实现了 Android / iOS / macOS。其余平台的
/// `WebViewPlatform.instance` 为空，构造 controller 会直接抛异常，
/// 因此这些平台回退到系统浏览器。
bool get _canRenderInline =>
    PlatformUtils.isAndroid || PlatformUtils.isIOS || PlatformUtils.isMacOS;

/// 协议正文页。移动端与 macOS 用应用内 WebView 打开，
/// Windows / Linux / Web 交给系统浏览器。
class ProtocolPage extends StatefulWidget {
  const ProtocolPage({super.key, required this.document});

  final ProtocolDocument document;

  @override
  State<ProtocolPage> createState() => _ProtocolPageState();
}

class _ProtocolPageState extends State<ProtocolPage> {
  WebViewController? _controller;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_canRenderInline) {
      _controller = _createController();
    }
  }

  WebViewController _createController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value / 100);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _error = null);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 1);
          },
          onWebResourceError: (error) {
            // 图片、字体这类子资源失败不该把整页判定为加载失败。
            if (error.isForMainFrame == false) return;
            AppLogger.error(
              '协议页加载失败: ${widget.document.url}',
              error: error.description,
            );
            if (mounted) setState(() => _error = error.description);
          },
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host;
            if (host == null || host == _inlineHost) {
              return NavigationDecision.navigate;
            }
            _openExternally(Uri.parse(request.url));
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.document.url));
  }

  Future<void> _openExternally(Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (e) {
      AppLogger.error('打开协议链接失败: $uri', error: e);
    }
    if (mounted) {
      showClubSnackBar(context, Text(context.l10n.protocolOpenFailed));
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _progress = 0;
    });
    _controller?.loadRequest(Uri.parse(widget.document.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(title: widget.document.title(context.l10n)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!_canRenderInline) {
      return _ProtocolFallback(
        message: context.l10n.protocolInlineUnsupported,
        actionLabel: context.l10n.protocolOpenInBrowser,
        onAction: () => _openExternally(Uri.parse(widget.document.url)),
      );
    }

    if (_error != null) {
      return _ProtocolFallback(
        message: context.l10n.loadFailed,
        actionLabel: context.l10n.retry,
        onAction: _retry,
        secondaryLabel: context.l10n.protocolOpenInBrowser,
        onSecondary: () => _openExternally(Uri.parse(widget.document.url)),
      );
    }

    return Column(
      children: [
        if (_progress < 1)
          LinearProgressIndicator(value: _progress == 0 ? null : _progress),
        Expanded(child: WebViewWidget(controller: _controller!)),
      ],
    );
  }
}

/// 无法内嵌渲染或渲染失败时的兜底视图。
class _ProtocolFallback extends StatelessWidget {
  const _ProtocolFallback({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: colors.secondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colors.secondaryLabel),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
