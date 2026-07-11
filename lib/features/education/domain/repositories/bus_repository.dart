import '../../../../core/models/result.dart';
import '../../models/bus_model.dart';

abstract interface class BusRepository {
  Future<Result<BusModel>> getBus({
    String? dayDate,
    bool forceRefresh = false,
  });
}
