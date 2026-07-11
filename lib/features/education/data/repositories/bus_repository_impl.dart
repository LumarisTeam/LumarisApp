import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/result.dart';
import '../../../../core/services/network_exception.dart';
import '../../domain/repositories/bus_repository.dart';
import '../../models/bus_model.dart';
import '../remote/bus_remote_data_source.dart';

class BusRepositoryImpl implements BusRepository {
  const BusRepositoryImpl(this._remote);

  final BusRemoteDataSource _remote;

  @override
  Future<Result<BusModel>> getBus({
    String? dayDate,
    bool forceRefresh = false,
  }) async {
    try {
      final model = await _remote.getBus(
        dayDate: dayDate,
        forceRefresh: forceRefresh,
      );
      _filterDepartedBuses(model, dayDate);
      return Result.success(model);
    } catch (error) {
      return Result.failure(_mapError(error));
    }
  }

  void _filterDepartedBuses(BusModel model, String? dayDate) {
    final now = DateTime.now();
    final isToday = dayDate == null ||
        dayDate.isEmpty ||
        dayDate == DateFormat('yyyy-MM-dd').format(now);
    if (!isToday) return;

    model.records = model.records.where((item) {
      final parts = item.runTime.split(':');
      if (parts.length < 2) return false;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return false;
      return DateTime(now.year, now.month, now.day, hour, minute).isAfter(now);
    }).toList();
  }

  AppError _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return AppError.authentication('登录状态已失效', code: statusCode);
      }
      if (statusCode != null && statusCode >= 500) {
        return AppError.server('校巴服务暂时不可用', statusCode: statusCode);
      }
      return AppError.network(error.message ?? '网络连接失败', originalError: error);
    }
    if (error is NetworkException) {
      return AppError.network(error.message, originalError: error);
    }
    if (error is FormatException || error is TypeError) {
      return AppError.parsing('校巴数据格式错误', originalError: error);
    }
    return AppError.business(error.toString());
  }
}
