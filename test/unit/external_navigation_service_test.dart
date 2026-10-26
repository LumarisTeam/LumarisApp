import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/external_navigation_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });
  setUp(() async => PrefsService.instance.clear());

  Uri destination(ExternalNavigationService service, ExternalMap map) => service
      .uriFor(map, latitude: 34.23, longitude: 108.96, name: '教学楼 A & B');

  test('should preserve WGS84 and walking mode when building map links', () {
    for (final TargetPlatform platform in [
      TargetPlatform.iOS,
      TargetPlatform.android,
    ]) {
      final service = ExternalNavigationService(platform: platform);
      final apple = destination(service, ExternalMap.apple);
      expect(apple.queryParameters['daddr'], '34.23,108.96');
      expect(apple.queryParameters['dirflg'], 'w');
      final amap = destination(service, ExternalMap.amap);
      expect(
        amap.scheme,
        platform == TargetPlatform.iOS ? 'iosamap' : 'androidamap',
      );
      expect(amap.queryParameters['dev'], '1');
      expect(amap.queryParameters['t'], '2');
      expect(amap.queryParameters['dlat'], '34.23');
      expect(amap.queryParameters['dlon'], '108.96');
      expect(amap.queryParameters['dname'], '教学楼 A & B');
      expect(amap.toString(), isNot(contains('+')));
      final baidu = destination(service, ExternalMap.baidu);
      expect(baidu.queryParameters['coord_type'], 'wgs84');
      expect(
        baidu.queryParameters['destination'],
        'latlng:34.23,108.96|name:教学楼 A & B',
      );
      expect(baidu.queryParameters['mode'], 'walking');
      final google = destination(service, ExternalMap.google);
      if (platform == TargetPlatform.iOS) {
        expect(google.scheme, 'comgooglemaps');
        expect(google.queryParameters['directionsmode'], 'walking');
      } else {
        expect(google.toString(), 'google.navigation:q=34.23,108.96&mode=w');
      }
    }
  });

  test(
    'should filter unavailable apps and tolerate probe failure when detecting maps',
    () async {
      final service = ExternalNavigationService(
        platform: TargetPlatform.android,
        canLaunch: (uri) async {
          if (uri.scheme == 'google.navigation') {
            throw StateError('unavailable');
          }
          return uri.scheme == 'androidamap';
        },
      );
      expect(await service.availableMaps(), [ExternalMap.amap]);
    },
  );

  test(
    'should detect Apple Maps with native scheme when checking iOS',
    () async {
      final service = ExternalNavigationService(
        platform: TargetPlatform.iOS,
        canLaunch: (uri) async => uri.scheme == 'maps',
      );
      expect(await service.availableMaps(), [ExternalMap.apple]);
    },
  );

  test('should avoid native probes when running on web or desktop', () async {
    for (final service in [
      ExternalNavigationService(
        isWeb: true,
        canLaunch: (_) async => throw StateError('native probe'),
      ),
      ExternalNavigationService(
        platform: TargetPlatform.windows,
        canLaunch: (_) async => throw StateError('native probe'),
      ),
    ]) {
      expect(await service.availableMaps(), isEmpty);
    }
  });

  test('should remember chosen app when native launch succeeds', () async {
    final launched = <Uri>[];
    final service = ExternalNavigationService(
      platform: TargetPlatform.android,
      launch: (uri) async {
        launched.add(uri);
        return true;
      },
    );
    expect(await service.preferredMap(), isNull);
    expect(
      await service.open(
        map: ExternalMap.amap,
        latitude: 34.23,
        longitude: 108.96,
        name: '图书馆',
      ),
      isTrue,
    );
    expect(await service.preferredMap(), ExternalMap.amap);
    expect(launched.single.scheme, 'androidamap');
  });

  test(
    'should fall back to domestic web destination when native launch throws',
    () async {
      final launched = <Uri>[];
      final service = ExternalNavigationService(
        platform: TargetPlatform.android,
        launch: (uri) async {
          launched.add(uri);
          if (uri.scheme != 'https') throw StateError('app removed');
          return true;
        },
      );
      expect(
        await service.open(
          map: ExternalMap.baidu,
          latitude: 34.23,
          longitude: 108.96,
          name: '图书馆',
        ),
        isTrue,
      );
      expect(launched.length, 2);
      expect(launched.last.host, 'api.map.baidu.com');
      expect(launched.last.queryParameters['coord_type'], 'wgs84');
      expect(await service.preferredMap(), isNull);
    },
  );

  test('should return failure when both native and web launch fail', () async {
    final service = ExternalNavigationService(launch: (_) async => false);
    expect(
      await service.open(
        map: ExternalMap.google,
        latitude: 34.23,
        longitude: 108.96,
        name: '图书馆',
      ),
      isFalse,
    );
  });

  test(
    'should skip native launch when opening web fallback directly',
    () async {
      final launched = <Uri>[];
      final service = ExternalNavigationService(
        launch: (uri) async {
          launched.add(uri);
          return true;
        },
      );
      expect(
        await service.open(
          map: ExternalMap.google,
          latitude: 34.23,
          longitude: 108.96,
          name: '图书馆',
          webOnly: true,
        ),
        isTrue,
      );
      expect(launched.single.host, 'www.google.com');
      expect(launched.single.queryParameters['destination'], '34.23,108.96');
    },
  );

  test('should reject invalid coordinates when constructing a destination', () {
    final service = ExternalNavigationService();
    for (final double latitude in [double.nan, double.infinity, 91]) {
      expect(
        () => service.uriFor(
          ExternalMap.amap,
          latitude: latitude,
          longitude: 108,
          name: '',
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => service.uriFor(
        ExternalMap.amap,
        latitude: 34,
        longitude: -181,
        name: '',
      ),
      throwsArgumentError,
    );
  });
}
