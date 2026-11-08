import 'dart:async';
import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../components/page_app_bar.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../features/system/screen_capture_protection.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes/router.dart';
import '../../../state/payment_store.dart';
import '../../components/empty_widget.dart';

/// 校园卡离线支付码。
///
/// 支付码有时效，页面打开期间每 50 秒自动重新获取一次；App 退到后台时
/// 暂停计时，回到前台立即刷新，避免把已失效的码留在屏幕上。
class PaymentQrPage extends ConsumerStatefulWidget {
  const PaymentQrPage({super.key, this.fromPaymentTile = false});

  final bool fromPaymentTile;

  @override
  ConsumerState<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends ConsumerState<PaymentQrPage>
    with WidgetsBindingObserver {
  static const Duration _refreshInterval = Duration(seconds: 50);

  Timer? _ticker;
  int _secondsRemaining = _refreshInterval.inSeconds;
  QrCode? _qrCode;
  bool _isLoading = true;
  bool _isFetching = false;
  String _errorMessage = '';
  late final ScreenCaptureProtection _setCaptureProtection;
  Future<bool>? _protectionReady;
  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setCaptureProtection = ref.read(screenCaptureProtectionProvider);
    _protectionReady = _setCaptureProtection(true);
    _startTicker();
    Future<void>.microtask(_loadQrCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    unawaited(_setCaptureProtection(false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isForeground = state == AppLifecycleState.resumed;
      _qrCode = null;
    });
    if (state == AppLifecycleState.resumed) {
      _startTicker();
      _loadQrCode();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _secondsRemaining = _refreshInterval.inSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        }
      });

      if (_secondsRemaining == 0) {
        _loadQrCode();
      }
    });
  }

  Future<void> _loadQrCode() async {
    if (_isFetching) {
      return;
    }

    _isFetching = true;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      _protectionReady ??= _setCaptureProtection(true);
      if (!await _protectionReady!) {
        _protectionReady = null;
        throw StateError('支付码页面截图保护未能开启');
      }
      if (!mounted) return;

      final studentId = await ref.read(paymentStudentIdReaderProvider)();
      if (studentId == null || studentId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'auth_required';
          _qrCode = null;
        });
        return;
      }

      final password = await ref.read(paymentPasswordReaderProvider)();
      final paymentQrCode = await ref.read(paymentQrFetcherProvider)(
        studentId,
        password,
      );

      // 离线码是多字节二进制载荷，必须按字节编码，不能当字符串处理。
      // 在这里一次性生成 QrCode，避免每秒计时器触发的 rebuild 重算矩阵。
      final qrCode = QrCode.fromUint8List(
        data: paymentQrCode.data,
        errorCorrectLevel: QrErrorCorrectLevel.L,
      );

      if (!mounted || !_isForeground) return;
      setState(() {
        _qrCode = qrCode;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (_) {
      // 失效的支付码不能继续展示，宁可让用户重试。
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'load_failed';
        _qrCode = null;
      });
    } finally {
      _isFetching = false;
      if (mounted) {
        setState(() => _secondsRemaining = _refreshInterval.inSeconds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return Scaffold(
      appBar: PageAppBar(
        title: l10n.paymentQrCode,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: _isFetching ? null : _loadQrCode,
            tooltip: l10n.refreshData,
          ),
        ],
      ),
      bottomNavigationBar: widget.fromPaymentTile && _isForeground
          ? SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: CupertinoButton(
                    foregroundColor: colors.primary,
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    onPressed: () => ref
                        .read(appRouterProvider)
                        .replace<void>(AppRoutes.payment),
                    child: Text(
                      l10n.returnToPaymentPage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: !_isForeground
          ? const SizedBox.shrink()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_qrCode == null && _errorMessage.isNotEmpty)
                        _buildError(l10n)
                      else ...[
                        _buildQrCode(context, l10n),
                        const SizedBox(height: 24),
                        Text(
                          l10n.paymentQrCodeSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusLine(colors, l10n),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildQrCode(BuildContext context, AppLocalizations l10n) {
    final size = math.max(
      120.0,
      math.min(MediaQuery.sizeOf(context).width - 96, 320.0),
    );

    return Container(
      width: size + 32,
      height: size + 32,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 二维码必须是纯白底，不能跟着深色主题走
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _qrCode != null
          ? QrImageView.withQr(
              qr: _qrCode!,
              size: size,
              padding: const EdgeInsets.all(12),
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              semanticsLabel: l10n.paymentQrCode,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    final message = _errorMessage == 'auth_required'
        ? l10n.pleaseLoginEduAccount
        : l10n.paymentQrCodeError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EmptyWidget(title: message, subtitle: '', icon: CupertinoIcons.qrcode),
        CupertinoButton.filled(
          onPressed: _isFetching ? null : _loadQrCode,
          child: Text(l10n.retry),
        ),
      ],
    );
  }

  Widget _buildStatusLine(McColors colors, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLoading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.secondaryLabel,
            ),
          )
        else
          Icon(
            CupertinoIcons.arrow_2_circlepath,
            size: 16,
            color: colors.secondaryLabel,
          ),
        const SizedBox(width: 8),
        Text(
          _isLoading
              ? l10n.paymentQrCodeLoading
              : l10n.paymentQrCodeAutoRefresh(_secondsRemaining),
          style: TextStyle(fontSize: 13, color: colors.secondaryLabel),
        ),
      ],
    );
  }
}
