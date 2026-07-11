import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/result.dart';
import 'package:ios_club_app/features/education/data/edu_api_client.dart';
import 'package:ios_club_app/features/education/data/remote/bus_remote_data_source.dart';
import 'package:ios_club_app/features/education/data/repositories/bus_repository_impl.dart';

class _FakeEduApiClient implements EduApiClient {
  _FakeEduApiClient(this.response);

  dynamic response;
  Object? error;
  bool? lastBypassCache;
  String? lastPath;

  @override
  String baseUrl = 'https://school.example';

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool bypassCache = false,
  }) async {
    lastPath = path;
    lastBypassCache = bypassCache;
    if (error != null) throw error!;
    return response;
  }

  @override
  Future<dynamic> post(String path,
          {data, Map<String, dynamic>? queryParameters, Options? options}) =>
      throw UnimplementedError();

  @override
  Future<dynamic> delete(String path,
          {data, Map<String, dynamic>? queryParameters, Options? options}) =>
      throw UnimplementedError();

  @override
  void updateBaseUrl(String newBaseUrl) => baseUrl = newBaseUrl;

  @override
  void dispose() {}
}

void main() {
  test('should_return_parsed_bus_data_and_forward_refresh_policy', () async {
    final client = _FakeEduApiClient({
      'success': true,
      'data': [
        {
          'lineName': '测试线路',
          'description': '',
          'departureStation': 'A',
          'arrivalStation': 'B',
          'runTime': '08:00:00',
          'arrivalStationTime': 'x01:00',
        },
      ],
      'total': 1,
    });
    final repository = BusRepositoryImpl(BusRemoteDataSource(client));

    final result = await repository.getBus(
      dayDate: '2099-01-01',
      forceRefresh: true,
    );

    expect(result.isSuccess, isTrue);
    expect(result.data.records.single.lineName, '测试线路');
    expect(client.lastPath, '/Bus/2099-01-01');
    expect(client.lastBypassCache, isTrue);
  });

  test('should_map_malformed_payload_to_parsing_error', () async {
    final client = _FakeEduApiClient(const <String, dynamic>{});
    client.error = const FormatException('bad payload');
    final repository = BusRepositoryImpl(BusRemoteDataSource(client));

    final result = await repository.getBus(dayDate: '2099-01-01');

    expect(result.isSuccess, isFalse);
    expect(result.error.type, AppErrorType.parsing);
  });
}
