import 'package:material_ui/material_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片加载工具类
class ImageLoader {
  /// 单例实例
  static final ImageLoader instance = ImageLoader._internal();

  /// 工厂构造函数
  factory ImageLoader() => instance;

  /// 内部构造函数
  ImageLoader._internal();

  /// 根据设备分辨率加载合适大小的图片
  ///
  /// [assetName] 图片资源名称
  /// [context] BuildContext
  /// [fit] 图片缩放模式
  /// [width] 图片宽度
  /// [height] 图片高度
  Image loadImage(
    String assetName,
    BuildContext context, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final cacheSize = _cacheSizeFor(context, width: width, height: height);

    return Image(
      image: _assetProvider(assetName, cacheSize),
      fit: fit,
      width: width,
      height: height,
    );
  }

  /// 加载网络图片
  ///
  /// [url] 图片URL
  /// [context] BuildContext
  /// [fit] 图片缩放模式
  /// [width] 图片宽度
  /// [height] 图片高度
  Image loadNetworkImage(
    String url,
    BuildContext context, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final cacheSize = _cacheSizeFor(context, width: width, height: height);
    return Image(
      image: CachedNetworkImageProvider(
        url,
        maxWidth: cacheSize.width,
        maxHeight: cacheSize.height,
      ),
      fit: fit,
      width: width,
      height: height,
    );
  }

  _ImageCacheSize _cacheSizeFor(
    BuildContext context, {
    double? width,
    double? height,
  }) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return _ImageCacheSize(
      width: width == null ? null : (width * pixelRatio).round(),
      height: height == null ? null : (height * pixelRatio).round(),
    );
  }

  ImageProvider _assetProvider(String assetName, _ImageCacheSize cacheSize) {
    final provider = AssetImage(assetName);
    if (cacheSize.width == null && cacheSize.height == null) {
      return provider;
    }
    return ResizeImage(
      provider,
      width: cacheSize.width,
      height: cacheSize.height,
    );
  }

  /// 获取适合当前设备的图片路径
  ///
  /// [basePath] 图片基础路径（不包含扩展名）
  /// [context] BuildContext
  /// [extension] 图片扩展名
  String getDeviceSpecificImagePath(
    String basePath,
    BuildContext context, {
    String extension = 'webp',
  }) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // 根据设备像素比选择合适的图片分辨率
    // 实际项目中，应该根据不同分辨率准备不同大小的图片资源
    // 例如：assets/icon@1x.webp, assets/icon@2x.webp, assets/icon@3x.webp

    if (devicePixelRatio >= 3.0) {
      return '$basePath@3x.$extension';
    } else if (devicePixelRatio >= 2.0) {
      return '$basePath@2x.$extension';
    } else {
      return '$basePath@1x.$extension';
    }
  }

  /// 预加载图片
  ///
  /// [assetNames] 图片资源名称列表
  /// [context] BuildContext，用于预加载图片
  Future<void> preloadImages(
    List<String> assetNames,
    BuildContext context,
  ) async {
    for (final assetName in assetNames) {
      await precacheImage(AssetImage(assetName), context);
    }
  }

  /// 预加载网络图片
  ///
  /// [urls] 图片URL列表
  /// [context] BuildContext，用于预加载图片
  Future<void> preloadNetworkImages(
    List<String> urls,
    BuildContext context,
  ) async {
    for (final url in urls) {
      await precacheImage(CachedNetworkImageProvider(url), context);
    }
  }
}

class _ImageCacheSize {
  const _ImageCacheSize({this.width, this.height});

  final int? width;
  final int? height;
}
