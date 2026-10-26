import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'prefs_service.dart';

enum ExternalMap { apple, google, amap, baidu }

typedef MapLauncher = Future<bool> Function(Uri uri);

/// External walking navigation. All input coordinates are WGS-84.
class ExternalNavigationService {
  ExternalNavigationService({
    TargetPlatform? platform,
    bool? isWeb,
    MapLauncher? canLaunch,
    MapLauncher? launch,
  }) : platform = platform ?? defaultTargetPlatform,
       isWeb = isWeb ?? kIsWeb,
       _canLaunch = canLaunch ?? canLaunchUrl,
       _launch = launch ?? _launchExternally;

  static const String _preferenceKey = 'external_navigation_map';
  final TargetPlatform platform;
  final bool isWeb;
  final MapLauncher _canLaunch;
  final MapLauncher _launch;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  static String _query(Map<String, String> parameters) => parameters.entries
      .map(
        (entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
      )
      .join('&');

  Uri uriFor(
    ExternalMap map, {
    required double latitude,
    required double longitude,
    required String name,
  }) {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      throw ArgumentError('Invalid WGS-84 destination');
    }
    final String coordinates = '$latitude,$longitude';
    switch (map) {
      case ExternalMap.apple:
        return Uri.https('maps.apple.com', '/', {
          'daddr': coordinates,
          'dirflg': 'w',
        });
      case ExternalMap.google:
        if (platform == TargetPlatform.iOS) {
          return Uri(
            scheme: 'comgooglemaps',
            host: '',
            query: _query({'daddr': coordinates, 'directionsmode': 'walking'}),
          );
        }
        return Uri.parse('google.navigation:q=$coordinates&mode=w');
      case ExternalMap.amap:
        return Uri(
          scheme: platform == TargetPlatform.iOS ? 'iosamap' : 'androidamap',
          host: platform == TargetPlatform.iOS ? 'path' : 'route',
          path: platform == TargetPlatform.iOS ? null : '/plan/',
          query: _query({
            'sourceApplication': '光序',
            'dlat': '$latitude',
            'dlon': '$longitude',
            'dname': name,
            // AMap converts raw GPS (WGS-84) coordinates when dev=1.
            'dev': '1',
            't': '2',
          }),
        );
      case ExternalMap.baidu:
        return Uri(
          scheme: 'baidumap',
          host: 'map',
          path: '/direction',
          query: _query({
            'destination': 'latlng:$coordinates|name:$name',
            'mode': 'walking',
            'coord_type': 'wgs84',
            'src': '光序',
          }),
        );
    }
  }

  Uri webUri({
    required ExternalMap map,
    required double latitude,
    required double longitude,
    required String name,
  }) {
    // Also validates the coordinates before building a web URL.
    final Uri appUri = uriFor(
      map,
      latitude: latitude,
      longitude: longitude,
      name: name,
    );
    if (map == ExternalMap.apple) return appUri;
    if (map == ExternalMap.google) {
      return Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '$latitude,$longitude',
        'travelmode': 'walking',
      });
    }
    // Domestic web fallback accepts WGS-84 explicitly and shows the destination.
    return Uri.https('api.map.baidu.com', '/marker', {
      'location': '$latitude,$longitude',
      'coord_type': 'wgs84',
      'title': name,
      'content': name,
      'output': 'html',
      'src': '光序',
    });
  }

  Future<List<ExternalMap>> availableMaps() async {
    if (isWeb ||
        (platform != TargetPlatform.iOS &&
            platform != TargetPlatform.android)) {
      return const <ExternalMap>[];
    }
    final List<ExternalMap> candidates = platform == TargetPlatform.iOS
        ? const [
            ExternalMap.apple,
            ExternalMap.amap,
            ExternalMap.baidu,
            ExternalMap.google,
          ]
        : const [ExternalMap.google, ExternalMap.amap, ExternalMap.baidu];
    final List<ExternalMap> available = [];
    for (final ExternalMap map in candidates) {
      // Apple Maps' custom scheme detects installation; https could match Safari.
      final Uri probe = map == ExternalMap.apple
          ? Uri.parse('maps://')
          : uriFor(map, latitude: 0, longitude: 0, name: '');
      try {
        if (await _canLaunch(probe)) available.add(map);
      } catch (error) {
        debugPrint(
          'ExternalNavigationService: availability check failed for $map: $error',
        );
      }
    }
    return available;
  }

  Future<ExternalMap?> preferredMap() async {
    final prefs = await PrefsService.getInstanceAsync();
    final String? saved = prefs.getString(_preferenceKey);
    for (final ExternalMap map in ExternalMap.values) {
      if (map.name == saved) return map;
    }
    return null;
  }

  Future<bool> open({
    required ExternalMap map,
    required double latitude,
    required double longitude,
    required String name,
    bool webOnly = false,
  }) async {
    final Uri appUri = uriFor(
      map,
      latitude: latitude,
      longitude: longitude,
      name: name,
    );
    if (!webOnly && !isWeb) {
      try {
        if (await _launch(appUri)) {
          // A preference write failure must not undo a successful launch.
          try {
            final prefs = await PrefsService.getInstanceAsync();
            await prefs.setString(_preferenceKey, map.name);
          } catch (error) {
            debugPrint(
              'ExternalNavigationService: cannot save preference: $error',
            );
          }
          return true;
        }
      } catch (error) {
        debugPrint('ExternalNavigationService: cannot open $map: $error');
      }
    }
    try {
      return await _launch(
        webUri(map: map, latitude: latitude, longitude: longitude, name: name),
      );
    } catch (error) {
      debugPrint('ExternalNavigationService: web fallback failed: $error');
      return false;
    }
  }
}
