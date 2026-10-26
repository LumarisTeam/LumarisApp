import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';

void main() {
  test('ElectricData should allow reading and updating value', () {
    final ts = DateTime(2026, 3, 2, 10, 0, 0);
    final data = ElectricData(timestamp: ts, value: 12.5);

    expect(data.timestamp, ts);
    expect(data.value, 12.5);

    data.value = 18.0;
    expect(data.value, 18.0);
  });

  test('should_parse_lowercase_json_keys_when_deserializing', () {
    final data = ElectricData.fromJson(<String, dynamic>{
      'timestamp': '2026-03-02T10:00:00.000',
      'value': '12.5',
    });

    expect(data.timestamp, DateTime(2026, 3, 2, 10));
    expect(data.value, 12.5);
  });

  test('should_parse_uppercase_json_keys_when_deserializing', () {
    final data = ElectricData.fromJson(<String, dynamic>{
      'Timestamp': '2026-03-02T11:00:00.000',
      'Value': 8,
    });

    expect(data.timestamp, DateTime(2026, 3, 2, 11));
    expect(data.value, 8.0);
  });

  test('should_serialize_to_lowercase_json_keys', () {
    final data = ElectricData(timestamp: DateTime(2026, 3, 2, 12), value: 6.5);

    expect(data.toJson(), <String, dynamic>{
      'timestamp': '2026-03-02T12:00:00.000',
      'value': 6.5,
    });
  });

  test('should_throw_argument_error_when_timestamp_is_invalid', () {
    expect(
      () => ElectricData.fromJson(<String, dynamic>{
        'timestamp': 'not-a-date',
        'value': 1,
      }),
      throwsArgumentError,
    );
  });

  test('should_throw_argument_error_when_value_type_is_invalid', () {
    expect(
      () => ElectricData.fromJson(<String, dynamic>{
        'timestamp': '2026-03-02T10:00:00.000',
        'value': <String>['bad'],
      }),
      throwsArgumentError,
    );
  });
}
