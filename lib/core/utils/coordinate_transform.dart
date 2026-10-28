import 'dart:math' as math;

/// 坐标系统一约定：
///
/// * 接口返回的 POI 经纬度是 **GCJ-02**（火星坐标，与高德底图同源）；
/// * 手机定位（Geolocator）拿到的是 **WGS-84**，贴上高德底图前需要 [wgs84ToGcj02]；
/// * 需要喂给 WGS-84 消费方（如 Google Maps）时用 [gcj02ToWgs84] 反解。
///
/// 中国境外不做偏移。
typedef Coordinate = ({double latitude, double longitude});

const double _a = 6378245.0;
const double _ee = 0.00669342162296594323;

bool outOfChina(double latitude, double longitude) {
  if (longitude < 72.004 || longitude > 137.8347) return true;
  if (latitude < 0.8293 || latitude > 55.8271) return true;
  return false;
}

/// WGS-84 → GCJ-02
Coordinate wgs84ToGcj02(double latitude, double longitude) {
  if (outOfChina(latitude, longitude)) {
    return (latitude: latitude, longitude: longitude);
  }

  double dLat = _transformLat(longitude - 105.0, latitude - 35.0);
  double dLng = _transformLng(longitude - 105.0, latitude - 35.0);
  final double radLat = latitude / 180.0 * math.pi;
  double magic = math.sin(radLat);
  magic = 1 - _ee * magic * magic;
  final double sqrtMagic = math.sqrt(magic);
  dLat = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * math.pi);
  dLng = (dLng * 180.0) / (_a / sqrtMagic * math.cos(radLat) * math.pi);

  return (latitude: latitude + dLat, longitude: longitude + dLng);
}

/// GCJ-02 → WGS-84（不动点迭代反解，3 次后误差在 1m 以内）
Coordinate gcj02ToWgs84(double latitude, double longitude) {
  if (outOfChina(latitude, longitude)) {
    return (latitude: latitude, longitude: longitude);
  }

  double wgsLat = latitude;
  double wgsLng = longitude;
  for (var i = 0; i < 3; i++) {
    final Coordinate gcj = wgs84ToGcj02(wgsLat, wgsLng);
    wgsLat += latitude - gcj.latitude;
    wgsLng += longitude - gcj.longitude;
  }
  return (latitude: wgsLat, longitude: wgsLng);
}

double _transformLat(double x, double y) {
  double ret =
      -100.0 +
      2.0 * x +
      3.0 * y +
      0.2 * y * y +
      0.1 * x * y +
      0.2 * math.sqrt(x.abs());
  ret +=
      (20.0 * math.sin(6.0 * x * math.pi) +
          20.0 * math.sin(2.0 * x * math.pi)) *
      2.0 /
      3.0;
  ret +=
      (20.0 * math.sin(y * math.pi) + 40.0 * math.sin(y / 3.0 * math.pi)) *
      2.0 /
      3.0;
  ret +=
      (160.0 * math.sin(y / 12.0 * math.pi) +
          320 * math.sin(y * math.pi / 30.0)) *
      2.0 /
      3.0;
  return ret;
}

double _transformLng(double x, double y) {
  double ret =
      300.0 +
      x +
      2.0 * y +
      0.1 * x * x +
      0.1 * x * y +
      0.1 * math.sqrt(x.abs());
  ret +=
      (20.0 * math.sin(6.0 * x * math.pi) +
          20.0 * math.sin(2.0 * x * math.pi)) *
      2.0 /
      3.0;
  ret +=
      (20.0 * math.sin(x * math.pi) + 40.0 * math.sin(x / 3.0 * math.pi)) *
      2.0 /
      3.0;
  ret +=
      (150.0 * math.sin(x / 12.0 * math.pi) +
          300.0 * math.sin(x / 30.0 * math.pi)) *
      2.0 /
      3.0;
  return ret;
}
