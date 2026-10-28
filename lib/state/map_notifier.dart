import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/coordinate_transform.dart';
import 'package:ios_club_app/features/education/apis/map_api.dart';
import 'package:latlong2/latlong.dart';

import 'map_state.dart';

class MapNotifier extends Notifier<MapState> {
  static const Duration _locationTimeout = Duration(seconds: 8);
  static const Duration _streamFallbackTimeout = Duration(seconds: 10);
  static const Duration _maxLastKnownAge = Duration(minutes: 5);

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
      final models = await MapApi.getMap();
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

  Future<void> checkLocationPermission({
    bool openSettingsOnFailure = false,
  }) async {
    if (state.isLoadingLocation) return; // Prevent concurrent requests

    state = state.copyWith(isLoadingLocation: true);
    AppLogger.debug('MapNotifier: Starting location check...');

    try {
      // Use geolocator as the single source of truth. Mixing its permission
      // state with permission_handler can report permission as granted while
      // CoreLocation still rejects getCurrentPosition (notably on macOS).
      var permission = await Geolocator.checkPermission();
      AppLogger.debug('MapNotifier: Location permission: $permission');

      if (permission == LocationPermission.deniedForever) {
        AppLogger.info(
          'MapNotifier: Location permission is permanently denied',
        );
        if (openSettingsOnFailure) {
          await Geolocator.openAppSettings();
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        AppLogger.debug(
          'MapNotifier: Location permission after request: $permission',
        );
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        AppLogger.info(
          'MapNotifier: Location unavailable because permission is $permission',
        );
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      AppLogger.debug('MapNotifier: GPS service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        AppLogger.info('MapNotifier: Location services are disabled');
        if (openSettingsOnFailure) {
          await Geolocator.openLocationSettings();
        }
        return;
      }

      // 3. Get position - try current position first, fallback to last known
      AppLogger.debug('MapNotifier: Attempting to get current position...');
      final locationSettings = _buildLocationSettings();
      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        AppLogger.debug('MapNotifier: Current position obtained successfully');
      } on PermissionDeniedException {
        rethrow;
      } on LocationServiceDisabledException {
        rethrow;
      } catch (e) {
        AppLogger.debug(
          'MapNotifier: Failed to get current position ($e), trying stream fallback...',
        );
        position = await _getPositionFromStream(locationSettings);

        position ??= await _getFreshLastKnownPosition();
      }

      if (position == null) {
        throw Exception('Unable to get any location data');
      }

      AppLogger.debug(
        'MapNotifier: Position received: ${position.latitude}, ${position.longitude}',
      );

      final Coordinate gcj02Location = wgs84ToGcj02(
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(
        currentLocation: LatLng(
          gcj02Location.latitude,
          gcj02Location.longitude,
        ),
      );
      AppLogger.debug('MapNotifier: State updated with location');
    } on PermissionDeniedException catch (e) {
      // Permission denial is an expected user choice, not an application error.
      AppLogger.info('MapNotifier: Location permission denied: $e');
    } on LocationServiceDisabledException catch (e) {
      AppLogger.info('MapNotifier: Location services are disabled: $e');
    } catch (e) {
      AppLogger.error('MapNotifier: Error during location check: $e');
    } finally {
      state = state.copyWith(isLoadingLocation: false);
    }
  }

  LocationSettings _buildLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        timeLimit: _locationTimeout,
        // Prefer the Android framework provider on domestic Android devices.
        forceLocationManager: true,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      timeLimit: _locationTimeout,
    );
  }

  Future<Position?> _getPositionFromStream(
    LocationSettings locationSettings,
  ) async {
    try {
      final stream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      );
      final position = await stream.first.timeout(_streamFallbackTimeout);
      AppLogger.debug('MapNotifier: Stream fallback returned a live position');
      return position;
    } on TimeoutException catch (e) {
      AppLogger.info('MapNotifier: Stream fallback timed out: $e');
      return null;
    } catch (e) {
      AppLogger.info('MapNotifier: Stream fallback failed: $e');
      return null;
    }
  }

  Future<Position?> _getFreshLastKnownPosition() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) {
      AppLogger.info('MapNotifier: No last known position available');
      return null;
    }

    final age = DateTime.now().difference(position.timestamp);
    if (age > _maxLastKnownAge) {
      AppLogger.info(
        'MapNotifier: Ignoring stale last known position older than $_maxLastKnownAge',
      );
      return null;
    }

    AppLogger.debug(
      'MapNotifier: Using recent last known position as fallback',
    );
    return position;
  }
}

final mapNotifierProvider = NotifierProvider<MapNotifier, MapState>(
  MapNotifier.new,
);
