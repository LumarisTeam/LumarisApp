import '../../models/api_response.dart';
import '../../models/bus_model.dart';
import '../edu_api_client.dart';

class BusRemoteDataSource {
  const BusRemoteDataSource(this._client);

  final EduApiClient _client;

  Future<BusModel> getBus({
    String? dayDate,
    bool forceRefresh = false,
  }) async {
    final rawResponse = await _client.get(
      '/Bus/${dayDate ?? ''}',
      bypassCache: forceRefresh,
    );
    final response = ApiResponse<List<BusItem>>.parsed(
      rawResponse,
      (data) => (data as List<dynamic>)
          .map((item) => BusItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
    if (!response.isSuccess) {
      throw StateError(response.message ?? '校巴请求失败');
    }
    final records = response.data ?? <BusItem>[];
    return BusModel(
      records: records,
      total: response.total ?? records.length,
    );
  }
}
