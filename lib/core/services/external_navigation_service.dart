import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/utils/coordinate_transform.dart';
import 'package:url_launcher/url_launcher.dart';

import 'prefs_service.dart';

enum ExternalMap { apple, google, amap, baidu }

typedef MapLauncher = Future<bool> Function(Uri uri);

/// External walking navigation.
///
/// 入参坐标与接口返回的 POI 一致，是 GCJ-02（火星坐标），与高德底图同源；
/// 只有 Google Maps 这类 WGS-84 消费方在这里自行转换。
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
      throw ArgumentError('Invalid destination coordinates');
    }
    final String gcjCoordinates = '$latitude,$longitude';
    switch (map) {
      case ExternalMap.apple:
        // 中国大陆的 Apple Maps 使用高德数据（GCJ-02），坐标原样传入即可。
        return Uri.https('maps.apple.com', '/', {
          'daddr': gcjCoordinates,
          'dirflg': 'w',
        });
      case ExternalMap.google:
        final Coordinate wgs = gcj02ToWgs84(latitude, longitude);
        final String coordinates = '${wgs.latitude},${wgs.longitude}';
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
            // 坐标已是 GCJ-02，不能再带 dev=1（那会让高德把 GPS 原始坐标再纠偏一次）。
            't': '2',
          }),
        );
      case ExternalMap.baidu:
        return Uri(
          scheme: 'baidumap',
          host: 'map',
          path: '/direction',
          query: _query({
            'destination': 'latlng:$gcjCoordinates|name:$name',
            'mode': 'walking',
            // 2 = 国测局坐标（GCJ-02）
            'coord_type': '2',
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
      final Coordinate wgs = gcj02ToWgs84(latitude, longitude);
      return Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '${wgs.latitude},${wgs.longitude}',
        'travelmode': 'walking',
      });
    }
    // 百度 Web 兜底接受显式坐标系声明，传入的就是 GCJ-02。
    return Uri.https('api.map.baidu.com', '/marker', {
      'location': '$latitude,$longitude',
      'coord_type': 'gcj02',
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
