import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';

void main() {
  group('PaymentModel', () {
    test('should create instance with provided values', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '食堂午餐',
        amount: 15.50,
      );

      expect(payment.turnoverType, '消费');
      expect(payment.datetimeStr, '2023-01-01 12:00:00');
      expect(payment.resume, '食堂午餐');
      expect(payment.amount, 15.50);
    });

    test('should create instance from JSON', () {
      final json = {
        'turnoverType': '充值',
        'datetimeStr': '2023-01-01 10:00:00',
        'resume': '支付宝充值',
        'tranamt': 100,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.turnoverType, '充值');
      expect(payment.datetimeStr, '2023-01-01 10:00:00');
      expect(payment.resume, '支付宝充值');
      expect(payment.amount, 100.0);
    });

    test('should handle missing fields in JSON gracefully', () {
      final json = {
        'turnoverType': '消费',
        'datetimeStr': '2023-01-01 12:00:00',
        // 'resume' field missing
        // 'tranamt' field missing
      };

      expect(() => PaymentModel.fromJson(json), throwsArgumentError);
    });

    test('should handle empty string values in JSON', () {
      final json = {
        'turnoverType': '',
        'datetimeStr': '',
        'resume': '',
        'tranamt': 0,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.turnoverType, '');
      expect(payment.datetimeStr, '');
      expect(payment.resume, '');
      expect(payment.amount, 0.0);
    });

    test('should format toString correctly with different turnover types', () {
      final payment1 = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '食堂午餐',
        amount: 15.50,
      );

      final payment2 = PaymentModel(
        turnoverType: '充值',
        datetimeStr: '2023-01-01 10:00:00',
        resume: '支付宝充值',
        amount: 10000,
      );

      expect(payment1.toString(), '2023-01-01 12:00:00 | 消费 | 0.15 元 | 食堂午餐');
      expect(
        payment2.toString(),
        '2023-01-01 10:00:00 | 充值 | 100.00 元 | 支付宝充值',
      );
    });

    test('should handle zero amount correctly', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '免费餐',
        amount: 0,
      );

      expect(payment.toString(), '2023-01-01 12:00:00 | 消费 | 0.00 元 | 免费餐');
    });

    test('should handle large amount correctly', () {
      final payment = PaymentModel(
        turnoverType: '充值',
        datetimeStr: '2023-01-01 10:00:00',
        resume: '大额充值',
        amount: 1000000,
      );

      expect(
        payment.toString(),
        '2023-01-01 10:00:00 | 充值 | 10000.00 元 | 大额充值',
      );
    });

    test('should trim resume whitespace in toString', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '  食堂午餐  ',
        amount: 15.50,
      );

      expect(payment.toString(), '2023-01-01 12:00:00 | 消费 | 0.15 元 | 食堂午餐');
    });

    test('should handle negative amount correctly', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '退款',
        amount: -15.50,
      );

      expect(payment.toString(), '2023-01-01 12:00:00 | 消费 | -0.15 元 | 退款');
    });
  });

  group('PaymentData', () {
    test('should create instance with provided values', () {
      final payments = [
        PaymentModel(
          turnoverType: '消费',
          datetimeStr: '2023-01-01 12:00:00',
          resume: '食堂午餐',
          amount: 15.50,
        ),
      ];
      final paymentData = PaymentData(payments, 100.0);

      expect(paymentData.payments, payments);
      expect(paymentData.balance, 100.0);
    });

    test('should create instance from JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          },
        ],
        'balance': 100.0,
      };

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments, isNotEmpty);
      expect(paymentData.payments.length, 1);
      expect(paymentData.payments[0].turnoverType, '消费');
      expect(paymentData.balance, 100.0);
    });

    test('should handle empty records list in JSON', () {
      final json = {'records': [], 'balance': 0.0};

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments, isEmpty);
      expect(paymentData.balance, 0.0);
    });

    test('should handle large number of records in JSON', () {
      final records = List.generate(
        100,
        (index) => {
          'turnoverType': index % 2 == 0 ? '消费' : '充值',
          'datetimeStr': '2023-01-01 12:00:00',
          'resume': '交易$index',
          'tranamt': index * 10,
        },
      );

      final json = {'records': records, 'balance': 1000.0};

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments.length, 100);
      expect(paymentData.balance, 1000.0);
      expect(paymentData.payments[0].resume, '交易0');
      expect(paymentData.payments[99].resume, '交易99');
    });

    test('should handle extreme record count in JSON', () {
      final records = List.generate(
        10000,
        (index) => {
          'turnoverType': index.isEven ? '消费' : '充值',
          'datetimeStr': '2023-01-01 12:00:00',
          'resume': '极限交易$index',
          'tranamt': index,
        },
      );

      final json = {'records': records, 'balance': 49995000.0};

      final paymentData = PaymentData.fromJson(json);
      expect(paymentData.payments.length, 10000);
      expect(paymentData.payments.first.resume, '极限交易0');
      expect(paymentData.payments.last.resume, '极限交易9999');
    });

    test('should handle missing total field in JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          },
        ],
        // 'balance' field missing
      };

      expect(() => PaymentData.fromJson(json), throwsArgumentError);
    });

    test('should handle non-numeric total in JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          },
        ],
        'balance': 'not_a_number',
      };

      expect(() => PaymentData.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw when records type is invalid', () {
      final json = {'records': 'invalid-records', 'balance': 1.0};

      expect(() => PaymentData.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('should handle zero total correctly', () {
      final json = {'records': [], 'balance': 0.0};

      final paymentData = PaymentData.fromJson(json);
      expect(paymentData.balance, 0.0);
      expect(paymentData.payments, isEmpty);
    });

    test('should handle negative total correctly', () {
      final json = {'records': [], 'balance': -100.0};

      final paymentData = PaymentData.fromJson(json);
      expect(paymentData.balance, -100.0);
    });
  });
}
