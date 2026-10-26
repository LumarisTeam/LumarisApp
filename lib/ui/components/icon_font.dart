import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/features/education/models/link_model.dart';

class IconUtil {
  static Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        image: CachedNetworkImageProvider(
          imageUrl,
          maxWidth: 80,
          maxHeight: 80,
        ),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.link_rounded, size: 20, color: Colors.grey),
          );
        },
      ),
    );
  }

  static Future<Widget?> getFontIcon(LinkModel model) async {
    final String? icon = model.icon;
    if (icon == null || icon.isEmpty || icon.startsWith('http')) {
      return null;
    }

    final dateList = await rootBundle.loadString(
      'assets/iconfont/iconfont.json',
    );
    final dynamic iconMap = jsonDecode(dateList);
    final List<dynamic> glyphs = iconMap['glyphs'] as List<dynamic>;
    final dynamic matchedGlyph = glyphs
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (element) => element?['font_class'] == icon,
          orElse: () => null,
        );

    if (matchedGlyph == null) {
      return null;
    }

    return Icon(
      createIconData(matchedGlyph['unicode_decimal'] as int),
      size: 35,
      color: CourseColorManager.generateSoftColor(model, isDark: true),
    );
  }

  static Future<Widget> getIconFont(LinkModel model) async {
    final String? rawIcon = model.icon;
    final String icon = rawIcon?.trim() ?? '';
    if (icon.isEmpty) {
      final Uri? uri = Uri.tryParse(model.url);
      final String? host = uri?.host;
      if (host == null || host.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildNetworkImage('https://$host/favicon.ico');
    }

    if (icon.startsWith('http')) {
      return _buildNetworkImage(icon);
    }

    return (await getFontIcon(model)) ?? const SizedBox.shrink();
  }

  // 添加一个静态方法来创建 IconData 实例，以解决 tree shaking 问题
  static IconData createIconData(int codePoint) {
    return IconData(
      // codePoint 来自运行时解析的 iconfont.json，无法是编译期常量。
      // 项目构建已通过 --no-tree-shake-icons 关闭图标 tree-shaking，故此处可安全忽略。
      // ignore: non_const_argument_for_const_parameter
      codePoint,
      fontFamily: 'IconFont',
      matchTextDirection: false,
    );
  }
}
