import 'package:intl/intl.dart';

import '../../../core/utils/app_logger.dart';
import '../apis/bus_api.dart';
import '../models/bus_model.dart';

class BusService {
  static Future<BusModel> getBus({
    String? dayDate,
    bool forceRefresh = false,
    bool throwOnError = false,
  }) async {
    try {
      final response = await BusApi.getBus(
        dayDate: dayDate,
        forceRefresh: forceRefresh,
      );
      final now = DateTime.now();
      var result = response;
      if (result.records.isNotEmpty &&
          (dayDate == null ||
              dayDate.isEmpty ||
              dayDate == DateFormat('yyyy-MM-dd').format(now))) {
        result.records = result.records.where((element) {
          final split = element.runTime.split(':');
          if (split.length < 2) {
            return false;
          }
          final time = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(split[0]),
            int.parse(split[1]),
          );
          return time.isAfter(now);
        }).toList();
      }
      return result;
    } catch (e, stackTrace) {
      if (throwOnError) rethrow;
      AppLogger.error('获取校巴信息失败', error: e, stackTrace: stackTrace);
    }

    return BusModel(records: [], total: 0);
  }
}
