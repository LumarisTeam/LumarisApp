import 'package:material_ui/material_ui.dart';

import 'image_helper_stub.dart'
    if (dart.library.io) 'image_helper_io.dart'
    if (dart.library.html) 'image_helper_web.dart';

/// 获取本地图片 Widget
///
/// 根据平台不同返回不同的实现：
/// - Mobile/Desktop: 返回 Image.file
/// - Web: 返回 Container (不支持本地文件路径)
Widget getLocalImage(
  String path, {
  BoxFit? fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return getImage(path, fit: fit, errorBuilder: errorBuilder);
}
