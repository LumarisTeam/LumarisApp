import 'package:material_ui/material_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ios_club_app/core/utils/image_helper.dart';

/// 课表背景图：同时支持网络图片和本地文件。
class ScheduleBackgroundImage extends StatelessWidget {
  const ScheduleBackgroundImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image(
        image: CachedNetworkImageProvider(imagePath),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Theme.of(context).scaffoldBackgroundColor);
        },
      );
    }

    // 本地文件图片（使用 image_helper 处理平台差异）
    return getLocalImage(
      imagePath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: Theme.of(context).scaffoldBackgroundColor);
      },
    );
  }
}
