import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/payment_qr_code.dart';

void main() {
  test('PaymentQrCode should decode Base64 payload into raw bytes', () {
    // 含非 ASCII 字节，验证不会经过字符串的 UTF-8 编码
    final bytes = Uint8List.fromList([0x00, 0x53, 0x4F, 0x80, 0xFF]);

    final qrCode = PaymentQrCode.fromJson(<String, dynamic>{
      'payload': base64Encode(bytes),
      'mode': 'offline',
    });

    expect(qrCode.data, bytes);
    expect(qrCode.mode, PaymentQrCode.offlineMode);
    expect(qrCode.isOffline, isTrue);
  });

  test('PaymentQrCode should default to offline when mode is missing', () {
    final qrCode = PaymentQrCode.fromJson(<String, dynamic>{
      'payload': base64Encode(utf8.encode('12345678901234567890')),
    });

    expect(qrCode.mode, PaymentQrCode.offlineMode);
  });

  test('PaymentQrCode should reject empty or invalid payloads', () {
    expect(
      () => PaymentQrCode.fromJson(<String, dynamic>{'payload': ''}),
      throwsFormatException,
    );
    expect(
      () => PaymentQrCode.fromJson(<String, dynamic>{'payload': 'not-base64!'}),
      throwsFormatException,
    );
  });
}
