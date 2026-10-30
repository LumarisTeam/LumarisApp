import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/models/mcp_tool.dart';
import 'package:ios_club_app/features/mcp/services/mcp_config_generator.dart';
import 'package:ios_club_app/features/mcp/services/mcp_probe_service.dart';
import 'package:ios_club_app/features/mcp/services/mcp_token_store.dart';

/// 单列内容的最大宽度，与设置页保持一致。
const double _kPageMaxWidth = 600;

/// iOS 建议的最小点按尺寸。
const double _kMinTapTarget = 44;

/// 等宽文本（地址、配置、工具名）的统一字重与行高。
TextStyle _monoStyle({required double size, required Color color}) {
  return TextStyle(
    fontFamily: 'monospace',
    fontSize: size,
    height: 1.5,
    color: color,
  );
}

/// 光序 MCP 配置页：展示服务地址、保存令牌，并生成可复制的客户端配置。
///
/// 视觉上只保留一条信息主线：服务 → 令牌 → 配置 → 连通性。整页只有一个
/// 填充蓝的主操作（测试连接），复制、切换等辅助动作退成中性灰，让页面安静。
class McpPage extends StatefulWidget {
  const McpPage({super.key, this.tokenStore, this.probeService});

  /// 测试可注入的令牌存储。
  final McpTokenStore? tokenStore;

  /// 测试可注入的探测服务。
  final McpProbeService? probeService;

  @override
  State<McpPage> createState() => _McpPageState();
}

/// 配置卡片的两种展示格式。
enum _ConfigFormat { json, cli }

class _McpPageState extends State<McpPage> {
  final TextEditingController _tokenController = TextEditingController();
  late final McpTokenStore _tokenStore;
  late final McpProbeService _probeService;

  bool _tokenLoaded = false;
  bool _obscureToken = true;
  bool _savingToken = false;
  bool _testing = false;
  String? _savedToken;
  McpProbeResult? _probeResult;
  _ConfigFormat _configFormat = _ConfigFormat.json;

  String? get _normalizedToken =>
      McpConfigGenerator.normalizeToken(_tokenController.text);

  /// 只有内容相对已保存值发生变化时才允许保存。
  bool get _canSave =>
      _tokenLoaded && !_savingToken && _normalizedToken != _savedToken;

  /// 输入框或安全存储里还有内容时才允许清除。
  bool get _canClear =>
      _tokenLoaded &&
      !_savingToken &&
      (_normalizedToken != null || _tokenController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _tokenStore = widget.tokenStore ?? const McpTokenStore();
    _probeService = widget.probeService ?? McpProbeService();
    _tokenController.addListener(_onTokenChanged);
    _loadToken();
  }

  @override
  void dispose() {
    _tokenController.removeListener(_onTokenChanged);
    _tokenController.dispose();
    super.dispose();
  }

  void _onTokenChanged() {
    setState(() {});
  }

  Future<void> _loadToken() async {
    final token = await _tokenStore.read();
    if (!mounted) {
      return;
    }

    if (_tokenController.text.isEmpty) {
      _tokenController.text = token ?? '';
    }
    setState(() {
      _savedToken = token;
      _tokenLoaded = true;
    });
  }

  Future<void> _saveToken() async {
    setState(() => _savingToken = true);
    final saved = await _tokenStore.save(_tokenController.text);
    if (!mounted) {
      return;
    }

    setState(() {
      _savingToken = false;
      if (saved) {
        _savedToken = McpConfigGenerator.normalizeToken(_tokenController.text);
      }
    });

    McFeedback.showMessage(
      context,
      message: saved
          ? context.l10n.mcpTokenSaved
          : context.l10n.mcpTokenSaveFailed,
    );
  }

  Future<void> _clearToken() async {
    final confirmed = await showMcConfirmDialog(
      context: context,
      title: context.l10n.mcpTokenSection,
      message: context.l10n.mcpTokenClearConfirm,
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _savingToken = true);
    final cleared = await _tokenStore.clear();
    if (!mounted) {
      return;
    }

    setState(() {
      _savingToken = false;
      if (cleared) {
        _savedToken = null;
        _tokenController.text = '';
      }
    });

    if (!cleared) {
      McFeedback.showMessage(context, message: context.l10n.mcpTokenSaveFailed);
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }

    McFeedback.showMessage(context, message: context.l10n.copiedToClipboard);
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _probeResult = null;
    });

    final result = await _probeService.probe(token: _tokenController.text);
    if (!mounted) {
      return;
    }

    setState(() {
      _testing = false;
      _probeResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = _configFormat == _ConfigFormat.json
        ? McpConfigGenerator.buildJson(_tokenController.text)
        : McpConfigGenerator.buildClaudeCodeCommand(_tokenController.text);
    final copyLabel = _configFormat == _ConfigFormat.json
        ? l10n.mcpCopyJson
        : l10n.mcpCopyCli;

    return Scaffold(
      appBar: McAppBar(title: l10n.mcpTitle),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > _kPageMaxWidth
              ? 32.0
              : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kPageMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PageLead(text: l10n.mcpSubtitle),
                    const SizedBox(height: 20),
                    _SectionLabel(text: l10n.mcpServerSection),
                    const SizedBox(height: 8),
                    _buildServerGroup(context),
                    const SizedBox(height: 24),
                    _SectionLabel(text: l10n.mcpTokenSection),
                    const SizedBox(height: 8),
                    _buildTokenGroup(context),
                    const SizedBox(height: 24),
                    _SectionLabel(text: l10n.mcpConfigSection),
                    const SizedBox(height: 8),
                    _buildConfigGroup(
                      context,
                      config: config,
                      copyLabel: copyLabel,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(text: l10n.mcpConnectionSection),
                    const SizedBox(height: 8),
                    _buildConnectionGroup(context),
                    const SizedBox(height: 20),
                    _Footnote(text: l10n.mcpSecurityNote),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 服务 ────────────────────────────────────────────────────────────────

  Widget _buildServerGroup(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;

    return _GroupCard(
      rows: [
        McListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          leading: Icon(
            CupertinoIcons.link,
            size: 20,
            color: colors.secondaryLabel,
          ),
          title: Text(l10n.mcpServerAddress),
          subtitle: SelectableText(
            McpConstants.endpoint,
            style: _monoStyle(size: 12, color: colors.label),
          ),
          trailing: _CopyIconButton(
            label: l10n.copyTooltip,
            onPressed: () => _copy(McpConstants.endpoint),
          ),
        ),
        McListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: Icon(
            CupertinoIcons.arrow_2_circlepath,
            size: 20,
            color: colors.secondaryLabel,
          ),
          title: const Text('Streamable HTTP · POST'),
          subtitle: Text(
            'MCP ${McpConstants.protocolVersion}',
            style: _monoStyle(size: 12, color: colors.secondaryLabel),
          ),
        ),
      ],
    );
  }

  // ── 访问令牌 ─────────────────────────────────────────────────────────────

  Widget _buildTokenGroup(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题可伸缩，状态最多占一半宽度：大字号时状态省略而不是把标题挤没。
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.mcpTokenLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors.label,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.5,
                    ),
                    child: _buildTokenStatus(context),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _tokenController,
            obscureText: _obscureToken,
            autocorrect: false,
            enableSuggestions: false,
            placeholder: 'Bearer …',
            placeholderStyle: TextStyle(
              fontSize: 15,
              color: colors.secondaryLabel,
            ),
            style: TextStyle(fontSize: 15, color: colors.label),
            cursorColor: colors.primary,
            padding: const EdgeInsets.only(
              left: 14,
              right: 6,
              top: 13,
              bottom: 13,
            ),
            decoration: BoxDecoration(
              color: colors.input,
              borderRadius: BorderRadius.circular(10),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canSave) {
                _saveToken();
              }
            },
            suffix: Tooltip(
              message: _obscureToken ? l10n.mcpTokenShow : l10n.mcpTokenHide,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(_kMinTapTarget, _kMinTapTarget),
                pressedOpacity: 0.4,
                onPressed: () {
                  setState(() => _obscureToken = !_obscureToken);
                },
                child: Icon(
                  _obscureToken ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 18,
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mcpTokenHint,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 14),
          // 用 Wrap 而不是 Row：长语种文案或更大的动态字体下按钮换行而不是溢出。
          Wrap(
            spacing: 4,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              McButton.primary(
                onPressed: _canSave ? _saveToken : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_savingToken) ...[
                      const CupertinoActivityIndicator(
                        radius: 7,
                        color: CupertinoColors.white,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              McButton.ghost(
                onPressed: _canClear ? _clearToken : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Text(
                  l10n.delete,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _canClear ? colors.danger : colors.tertiaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStatus(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final normalized = _normalizedToken;

    final (String text, Color tint) status = switch (normalized) {
      null => (l10n.mcpTokenNotSet, colors.tertiaryLabel),
      _ when normalized == _savedToken => (l10n.mcpTokenSaved, colors.success),
      _ => (l10n.mcpTokenUnsaved, colors.warning),
    };

    return _StatusIndicator(text: status.$1, tint: status.$2);
  }

  // ── 配置 ────────────────────────────────────────────────────────────────

  Widget _buildConfigGroup(
    BuildContext context, {
    required String config,
    required String copyLabel,
  }) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final enabled = _tokenLoaded;

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.mcpConfigSubtitle,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 14),
          _FormatSelector(
            value: _configFormat,
            onChanged: (value) => setState(() => _configFormat = value),
          ),
          const SizedBox(height: 12),
          _CodeBlock(text: config),
          const SizedBox(height: 12),
          McButton.secondary(
            onPressed: enabled ? () => _copy(config) : null,
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.doc_on_doc,
                  size: 16,
                  color: enabled
                      ? colors.secondaryForeground
                      : colors.tertiaryLabel,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    copyLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 连通性 ──────────────────────────────────────────────────────────────

  Widget _buildConnectionGroup(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final result = _probeResult;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          McButton.primary(
            onPressed: _testing || !_tokenLoaded ? null : _testConnection,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_testing) ...[
                  const CupertinoActivityIndicator(
                    radius: 8,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    _testing ? l10n.mcpTesting : l10n.mcpTestConnection,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_tokenLoaded && _normalizedToken == null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.mcpNoTokenHint,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: colors.secondaryLabel,
              ),
            ),
          ],
          AnimatedSize(
            duration: animate
                ? const Duration(milliseconds: 200)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: result == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: _buildProbeResult(context, result),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbeResult(BuildContext context, McpProbeResult result) {
    final colors = context.mc.colors;
    final l10n = context.l10n;

    if (!result.isSuccess) {
      final detail = result.detail;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 18,
            color: colors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _probeFailureText(context, result.failure!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: colors.label,
                  ),
                ),
                if (detail != null && detail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: _monoStyle(size: 12, color: colors.secondaryLabel),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final summary = _serverSummary(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: 18,
              color: colors.success,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.mcpTestSuccess,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.label,
                ),
              ),
            ),
          ],
        ),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              summary,
              style: _monoStyle(size: 12, color: colors.secondaryLabel),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _Hairline(color: colors.separator, indent: 0),
        const SizedBox(height: 12),
        Text(
          l10n.mcpToolCount(result.tools.length),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 2),
        for (var index = 0; index < result.tools.length; index++) ...[
          if (index > 0) _Hairline(color: colors.separator, indent: 0),
          _ToolRow(tool: result.tools[index]),
        ],
      ],
    );
  }

  String _serverSummary(McpProbeResult result) {
    final name = result.serverName;
    final version = result.serverVersion;
    final server = [name, version].where((part) => part.isNotEmpty).join(' ');
    final protocol = result.protocolVersion.isEmpty
        ? ''
        : 'MCP ${result.protocolVersion}';

    return [server, protocol].where((part) => part.isNotEmpty).join(' · ');
  }

  String _probeFailureText(BuildContext context, McpProbeFailure failure) {
    switch (failure) {
      case McpProbeFailure.unauthorized:
      case McpProbeFailure.forbidden:
        return context.l10n.mcpErrorAuth;
      case McpProbeFailure.rateLimited:
        return context.l10n.mcpErrorRateLimited;
      case McpProbeFailure.network:
        return context.l10n.mcpErrorNetwork;
      case McpProbeFailure.server:
        return context.l10n.mcpErrorServer;
      case McpProbeFailure.protocol:
      case McpProbeFailure.unexpected:
        return context.l10n.mcpErrorProtocol;
    }
  }
}

// ── 页面内的展示组件 ──────────────────────────────────────────────────────

/// 页面导语：一句话说明这个页面做什么。
class _PageLead extends StatelessWidget {
  const _PageLead({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.45,
          color: colors.secondaryLabel,
        ),
      ),
    );
  }
}

/// iOS 分组列表式的小节标题。
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: colors.secondaryLabel,
        ),
      ),
    );
  }
}

/// 行与行之间 0.5px 的分隔线，左侧留出与图标对齐的缩进。
class _Hairline extends StatelessWidget {
  const _Hairline({required this.color, this.indent = 16});

  final Color color;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(height: 0.5, color: color),
    );
  }
}

/// 一组行共用一张卡片。
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    final children = <Widget>[];

    for (var index = 0; index < rows.length; index++) {
      if (index > 0) {
        children.add(_Hairline(color: colors.separator));
      }
      children.add(rows[index]);
    }

    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// 地址、配置与状态行共用的复制按钮。
class _CopyIconButton extends StatelessWidget {
  const _CopyIconButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Tooltip(
      message: label,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(_kMinTapTarget, _kMinTapTarget),
        pressedOpacity: 0.4,
        onPressed: onPressed,
        child: Icon(
          CupertinoIcons.doc_on_doc,
          size: 18,
          color: onPressed == null
              ? colors.quaternaryLabel
              : colors.secondaryLabel,
        ),
      ),
    );
  }
}

/// 圆点表示状态色，文字始终读得清楚——不只靠颜色传达信息。
class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.text, required this.tint});

  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.secondaryLabel,
            ),
          ),
        ),
      ],
    );
  }
}

/// JSON / Claude Code 两种配置的切换。
class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.value, required this.onChanged});

  final _ConfigFormat value;
  final ValueChanged<_ConfigFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    Widget segment(String text, _ConfigFormat format) {
      final selected = format == value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colors.label : colors.secondaryLabel,
          ),
        ),
      );
    }

    // 保留 CupertinoSlidingSegmentedControl 的系统外观：轨道和选中滑块都用
    // 系统动态色（浅色白滑块 / 深色 #636366），随主题自动适配，无需手写分支。
    return CupertinoSlidingSegmentedControl<_ConfigFormat>(
      groupValue: value,
      onValueChanged: (next) {
        if (next != null && next != value) {
          onChanged(next);
        }
      },
      children: {
        _ConfigFormat.json: segment('JSON', _ConfigFormat.json),
        _ConfigFormat.cli: segment('Claude Code', _ConfigFormat.cli),
      },
    );
  }
}

/// 等宽代码块，长行横向滚动而不是折行。
class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(McRadii.md),
      child: ColoredBox(
        color: colors.surfaceRaised,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: SelectableText(
            text,
            style: _monoStyle(
              size: 12,
              color: colors.label,
            ).copyWith(height: 1.55),
          ),
        ),
      ),
    );
  }
}

/// 探测结果里的单个工具。
class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.tool});

  final McpTool tool;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tool.name,
            style: _monoStyle(
              size: 12.5,
              color: colors.label,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          if (tool.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                tool.description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.secondaryLabel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 页面底部的安全说明。
class _Footnote extends StatelessWidget {
  const _Footnote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              CupertinoIcons.lock,
              size: 12,
              color: colors.tertiaryLabel,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
