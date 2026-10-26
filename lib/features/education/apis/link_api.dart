import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/link_model.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

import '../services/edu_http_client_manager.dart';

class LinkApi {
  static Future<List<CategoryModel>> getLinks() async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get('/SchoolNav');
      final apiResponse = ApiResponse<List<CategoryModel>>.parsed(
        rawResponse,
        (data) =>
            (data as List<dynamic>)
                .map(
                  (item) =>
                      CategoryModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
              ..sort((a, b) => a.index.compareTo(b.index)),
      );
      return apiResponse.data ?? [];
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.error(
          'Error fetching links',
          error: e,
          stackTrace: stackTrace,
        );
      }
      return [];
    }
  }
}
