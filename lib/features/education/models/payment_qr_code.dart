import 'dart:convert';
import 'dart:typed_data';

/// 校园卡支付码内容。
///
/// 服务端统一返回 Base64 编码的原始字节：离线码是二进制载荷，普通码是
/// 20 位条码，渲染二维码时必须按字节编码（不能用字符串的 UTF-8 编码）。
class PaymentQrCode {
  const PaymentQrCode({required this.data, required this.mode});

  static const String offlineMode = 'offline';
  static const String onlineMode = 'online';

  /// 二维码需要编码的原始字节。
  final Uint8List data;

  /// [offlineMode] 或 [onlineMode]。
  final String mode;

  bool get isOffline => mode == offlineMode;

  /// 从 EduApi 响应解析；`payload` 是 Base64，`mode` 缺省按离线码处理。
  factory PaymentQrCode.fromJson(Map<String, dynamic> json) {
    final payload = json['payload']?.toString().trim() ?? '';
    if (payload.isEmpty) {
      throw const FormatException('支付码为空');
    }

    final bytes = base64Decode(payload);
    if (bytes.isEmpty) {
      throw const FormatException('支付码为空');
    }

    final mode = json['mode']?.toString().trim() ?? '';
    return PaymentQrCode(data: bytes, mode: mode.isEmpty ? offlineMode : mode);
  }
}
