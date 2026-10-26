import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

import '../../features/education/models/course_model.dart';
import 'course_color_manager.dart';

/// Stable color mapping for schedule course blocks.
///
/// Provides consistent color assignment across platforms using DJB2 hashing,
/// color pool mapping, and automatic contrast-based text colors. This is
/// separate from [CourseColorManager] to avoid affecting existing color
/// schemes on home/score pages.
class ScheduleColorResolver {
  const ScheduleColorResolver._();

  /// Computes a stable 32-bit DJB2 hash of the given string.
  ///
  /// **Platform stability**: Does NOT use `String.hashCode` because Dart does
  /// not guarantee it remains stable across versions or platforms. Also avoids
  /// 64-bit hashes (like FNV-1a) because JavaScript numbers lose precision
  /// beyond 2^53, causing inconsistencies on web.
  ///
  /// DJB2 uses only 32-bit arithmetic, ensuring identical results across
  /// Android, iOS, desktop, and web platforms.
  static int stableHash(String value) {
    var hash = 5381;
    for (final byte in utf8.encode(value.trim())) {
      hash = ((hash * 33) + byte) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Maps a course name to a color from the given pool using stable hashing.
  ///
  /// Returns the fallback color from [CourseColorManager] if the pool is empty.
  static Color colorFor(String courseName, List<Color> pool) {
    if (pool.isEmpty) {
      return CourseColorManager.generateSoftColor(courseName);
    }
    if (courseName.trim().isEmpty) {
      return pool.first;
    }
    return pool[stableHash(courseName) % pool.length];
  }

  /// Generates a stable key for manual course color overrides.
  ///
  /// Prioritizes the teaching class ID (`lessonId`) so that all sections of the
  /// same class share the same color. Falls back to normalized course name for
  /// courses without IDs (e.g., HTML imports, custom courses).
  static String courseKey({
    required String lessonId,
    required String courseName,
  }) {
    final id = lessonId.trim();
    if (id.isNotEmpty) return 'id:$id';

    final name = normalizeCourseName(courseName);
    return 'name:$name';
  }

  static String normalizeCourseName(String courseName) {
    return courseName.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 先查手动覆盖，再回退到按课程名哈希的色池颜色。
  static Color colorForCourse(
    CourseModel course,
    List<Color> pool,
    Map<String, Color> overrides, {
    String? themeId,
  }) {
    final key = courseKey(
      lessonId: course.lessonId,
      courseName: course.courseName,
    );
    final override = overrides[key];
    if (override != null) return override;

    // Lumaris was the pre-personalization default: a soft HSL color derived
    // directly from the course name rather than a shared palette.
    if (themeId == 'lumaris') {
      return CourseColorManager.generateSoftColor(course.courseName);
    }
    return colorFor(course.courseName, pool);
  }

  /// 明显偏浅的底色使用黑字，其余底色使用白字。
  ///
  /// HSL 明度达到 75% 才视为浅色，避免中等明度的彩色课程块过早切换黑字。
  static Color autoContrast(Color background) {
    final double lightness = HSLColor.fromColor(background).lightness;
    return lightness >= 0.75
        ? McColors.light.foreground
        : McColors.dark.foreground;
  }
}
