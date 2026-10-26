import 'package:ios_club_app/features/basic/services/basic_http_client.dart';

class BasicHttpClientManager {
  BasicHttpClientManager._() {
    _client = BasicHttpClient();
  }

  static BasicHttpClientManager? _shared;

  late BasicHttpClient _client;

  static BasicHttpClientManager get current {
    return _shared ??= BasicHttpClientManager._();
  }

  static BasicHttpClient get instance => current._client;

  static void initialize() {
    _shared = BasicHttpClientManager._();
  }

  void dispose() {
    _client.dispose();
  }
}
