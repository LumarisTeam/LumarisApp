import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:latlong2/latlong.dart';
import 'map_state.dart';

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() {
    return const MapState();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> fetchCampusPOIs() async {
    if (state.isLoadingPOIs) return;

    state = state.copyWith(isLoadingPOIs: true);
    try {
      final result = await ref.read(mapRepositoryProvider).getMap();
      if (!result.isSuccess) throw result.error;
      final models = result.data;
      final pois = models.where((m) => m.isActive).map((m) {
        return CampusPOI(
          name: m.name,
          description: m.description ?? '',
          position: LatLng(double.parse(m.latitude), double.parse(m.longitude)),
        );
      }).toList();

      if (pois.isNotEmpty) {
        state = state.copyWith(campusPOIs: pois, isLoadingPOIs: false);
      } else {
        state = state.copyWith(isLoadingPOIs: false);
      }
    } catch (e) {
      AppLogger.error('MapNotifier: Failed to fetch POIs: $e');
      state = state.copyWith(isLoadingPOIs: false);
    }
  }

  Future<void> checkLocationPermission() async {
    if (state.isLoadingLocation) return; // Prevent concurrent requests

    state = state.copyWith(isLoadingLocation: true);
    AppLogger.debug('MapNotifier: Starting location check...');

    try {
      // On macOS, permission_handler doesn't handle location permissions
      // properly — geolocator manages its own CoreLocation permission flow.
      if (!PlatformUtils.isMacOS) {
        final status = await PermissionService.request(Permission.location);
        AppLogger.debug('MapNotifier: Permission status: $status');

        if (status != PermissionStatus.granted &&
            status != PermissionStatus.limited &&
            status != PermissionStatus.provisional) {
          state = state.copyWith(isLoadingLocation: false);
          return;
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      AppLogger.debug('MapNotifier: GPS service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        state = state.copyWith(isLoadingLocation: false);
        return;
      }

      // 3. Get position - try current position first, fallback to last known
      AppLogger.debug('MapNotifier: Attempting to get current position...');
      Position? position;

      try {
        // Try to get current position (most accurate)
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy
                .medium, // Use medium accuracy for faster results
            timeLimit: Duration(seconds: 8),
          ),
        );
        AppLogger.debug('MapNotifier: Current position obtained successfully');
      } catch (e) {
        // If current position fails (timeout, no signal, etc.), use last known position
        AppLogger.debug(
            'MapNotifier: Failed to get current position ($e), falling back to last known position...');
        position = await Geolocator.getLastKnownPosition();

        if (position != null) {
          AppLogger.debug('MapNotifier: Using last known position as fallback');
        }
      }

      if (position == null) {
        throw Exception('Unable to get any location data');
      }

      AppLogger.debug(
          'MapNotifier: Position received: ${position.latitude}, ${position.longitude}');

      final gcj02Location =
          _wgs84ToGcj02(position.latitude, position.longitude);
      state = state.copyWith(
        currentLocation: gcj02Location,
        isLoadingLocation: false,
      );
      AppLogger.debug('MapNotifier: State updated with location');
    } catch (e) {
      AppLogger.error('MapNotifier: Error during location check: $e');
      state = state.copyWith(isLoadingLocation: false);
    }
  }

  // ==========================================
  // 核心纠偏算法：WGS-84 (国际标准) 转 GCJ-02 (火星坐标/高德地图)
  // 用于消除由于设备硬件返回 WGS84 导致的定位在地图上偏移问题
  // ==========================================
  static const double _a = 6378245.0;
  static const double _ee = 0.00669342162296594323;

  LatLng _wgs84ToGcj02(double lat, double lng) {
    if (_outOfChina(lat, lng)) return LatLng(lat, lng);

    double dLat = _transformLat(lng - 105.0, lat - 35.0);
    double dLng = _transformLng(lng - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * math.pi;
    double magic = math.sin(radLat);
    magic = 1 - _ee * magic * magic;
    double sqrtMagic = math.sqrt(magic);
    dLat = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * math.pi);
    dLng = (dLng * 180.0) / (_a / sqrtMagic * math.cos(radLat) * math.pi);

    return LatLng(lat + dLat, lng + dLng);
  }

  bool _outOfChina(double lat, double lng) {
    if (lng < 72.004 || lng > 137.8347) return true;
    if (lat < 0.8293 || lat > 55.8271) return true;
    return false;
  }

  double _transformLat(double x, double y) {
    double ret = -100.0 +
        2.0 * x +
        3.0 * y +
        0.2 * y * y +
        0.1 * x * y +
        0.2 * math.sqrt(x.abs());
    ret += (20.0 * math.sin(6.0 * x * math.pi) +
            20.0 * math.sin(2.0 * x * math.pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(y * math.pi) + 40.0 * math.sin(y / 3.0 * math.pi)) *
        2.0 /
        3.0;
    ret += (160.0 * math.sin(y / 12.0 * math.pi) +
            320 * math.sin(y * math.pi / 30.0)) *
        2.0 /
        3.0;
    return ret;
  }

  double _transformLng(double x, double y) {
    double ret = 300.0 +
        x +
        2.0 * y +
        0.1 * x * x +
        0.1 * x * y +
        0.1 * math.sqrt(x.abs());
    ret += (20.0 * math.sin(6.0 * x * math.pi) +
            20.0 * math.sin(2.0 * x * math.pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(x * math.pi) + 40.0 * math.sin(x / 3.0 * math.pi)) *
        2.0 /
        3.0;
    ret += (150.0 * math.sin(x / 12.0 * math.pi) +
            300.0 * math.sin(x / 30.0 * math.pi)) *
        2.0 /
        3.0;
    return ret;
  }
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
