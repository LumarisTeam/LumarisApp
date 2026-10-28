import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/coordinate_transform.dart';

void main() {
  test('should shift WGS-84 into GCJ-02 inside China', () {
    final Coordinate gcj = wgs84ToGcj02(34.015855, 108.744123);
    expect(gcj.latitude, closeTo(34.014341, 1e-5));
    expect(gcj.longitude, closeTo(108.748822, 1e-5));
  });

  test('should invert GCJ-02 back to WGS-84 within a few metres', () {
    // 草堂校区校史馆：库里存的是 GCJ-02，对应 OSM（WGS-84）的 34.015855, 108.744123。
    final Coordinate wgs = gcj02ToWgs84(34.014325, 108.748813);
    expect(wgs.latitude, closeTo(34.015855, 1e-4));
    expect(wgs.longitude, closeTo(108.744123, 1e-4));
  });

  test('should round trip without drift', () {
    const double latitude = 34.23;
    const double longitude = 108.96;
    final Coordinate gcj = wgs84ToGcj02(latitude, longitude);
    final Coordinate wgs = gcj02ToWgs84(gcj.latitude, gcj.longitude);
    expect(wgs.latitude, closeTo(latitude, 1e-9));
    expect(wgs.longitude, closeTo(longitude, 1e-9));
  });

  test('should leave coordinates outside China untouched', () {
    const double latitude = 51.5074;
    const double longitude = -0.1278;
    final Coordinate gcj = wgs84ToGcj02(latitude, longitude);
    final Coordinate wgs = gcj02ToWgs84(latitude, longitude);
    expect(gcj.latitude, latitude);
    expect(gcj.longitude, longitude);
    expect(wgs.latitude, latitude);
    expect(wgs.longitude, longitude);
  });
}
