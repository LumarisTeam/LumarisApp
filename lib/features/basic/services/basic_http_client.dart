import 'package:ios_club_app/core/constants/api_endpoints.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';

/// Basic API 的配置入口；传输、重试、缓存和错误处理均由 [BaseHttpClient] 提供。
class BasicHttpClient extends BaseHttpClient {
  BasicHttpClient({super.dio})
    : super(
        baseUrl: ApiEndpoints.luminousHost,
        defaultHeaders: const <String, dynamic>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
}
