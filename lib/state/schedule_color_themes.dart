import 'package:material_ui/material_ui.dart';

/// 一个具名课表颜色主题。
///
/// 手写不可变 DTO：freezed 对 `Map<String, ScheduleColorTheme>` 的深比较依赖
/// value 的 `==`，因此这里必须提供结构相等。
@immutable
class ScheduleColorTheme {
  ScheduleColorTheme({required this.name, required List<Color> colors})
    : colors = List<Color>.unmodifiable(colors) {
    assert(
      colors.isNotEmpty && colors.length <= ScheduleColorThemeCatalog.maxColors,
      'A color theme must contain 1..${ScheduleColorThemeCatalog.maxColors} colors',
    );
  }

  final String name;
  final List<Color> colors;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleColorTheme &&
        other.name == name &&
        _listEquals(other.colors, colors);
  }

  @override
  int get hashCode => Object.hash(name, Object.hashAll(colors));

  @override
  String toString() => 'ScheduleColorTheme(name: $name, colors: $colors)';

  static bool _listEquals(List<Color> a, List<Color> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Lumaris 旧版配色与 Catppuccin Latte / Macchiato 色板。
///
/// 每个 flavor 使用官方 accent 顺序：
/// rosewater, flamingo, pink, mauve, red, maroon, peach, yellow,
/// green, teal, sky, sapphire, blue, lavender。
abstract final class ScheduleColorThemeCatalog {
  static const String latteId = 'latte';
  static const String macchiatoId = 'macchiato';
  static const String lumarisId = 'lumaris';

  /// 自定义主题 ID 前缀，避免与内置 ID 碰撞。
  static const String customIdPrefix = 'custom:';

  static const int maxColors = 32;
  static const int maxNameLength = 40;

  /// 新用户浅色池与深色池的默认主题都为 Lumaris。
  static const String defaultThemeId = lumarisId;
  static const List<Color> defaultColorPool = lumarisPreviewColors;

  static const List<Color> latteAccents = <Color>[
    Color(0xFFDC8A78), // rosewater
    Color(0xFFDD7878), // flamingo
    Color(0xFFEA76CB), // pink
    Color(0xFF8839EF), // mauve
    Color(0xFFD20F39), // red
    Color(0xFFE64553), // maroon
    Color(0xFFFE640B), // peach
    Color(0xFFDF8E1D), // yellow
    Color(0xFF40A02B), // green
    Color(0xFF179299), // teal
    Color(0xFF04A5E5), // sky
    Color(0xFF209FB5), // sapphire
    Color(0xFF1E66F5), // blue
    Color(0xFF7287FD), // lavender
  ];

  static const List<Color> macchiatoAccents = <Color>[
    Color(0xFFF4DBD6), // rosewater
    Color(0xFFF0C6C6), // flamingo
    Color(0xFFF5BDE6), // pink
    Color(0xFFC6A0F6), // mauve
    Color(0xFFED8796), // red
    Color(0xFFEE99A0), // maroon
    Color(0xFFF5A97F), // peach
    Color(0xFFEED49F), // yellow
    Color(0xFFA6DA95), // green
    Color(0xFF8BD5CA), // teal
    Color(0xFF91D7E3), // sky
    Color(0xFF7DC4E4), // sapphire
    Color(0xFF8AADF4), // blue
    Color(0xFFB7BDF8), // lavender
  ];

  /// 旧版课表使用按课程名生成的 HSL 颜色，没有固定色池。这里的颜色仅用于
  /// 主题选择器预览；实际渲染由 [ScheduleColorResolver] 恢复旧算法。
  static const List<Color> lumarisPreviewColors = <Color>[
    Color(0xFFDB8C8C),
    Color(0xFFDBA38C),
    Color(0xFFDBBF8C),
    Color(0xFFB9DB8C),
    Color(0xFF8FDB8C),
    Color(0xFF8CDBA8),
    Color(0xFF8CDBC9),
    Color(0xFF8CBFDB),
    Color(0xFF8C9DDB),
    Color(0xFFA98CDB),
    Color(0xFFD08CDB),
    Color(0xFFDB8CB8),
    Color(0xFFDB8C9C),
    Color(0xFFDB8CA4),
  ];

  static const Map<String, List<Color>> accentsById = <String, List<Color>>{
    lumarisId: lumarisPreviewColors,
    latteId: latteAccents,
    macchiatoId: macchiatoAccents,
  };

  static const Map<String, String> displayNames = <String, String>{
    lumarisId: 'Lumaris',
    latteId: 'Latte',
    macchiatoId: 'Macchiato',
  };

  /// 一级菜单中的内置主题顺序。
  static const List<String> builtInIds = <String>[
    lumarisId,
    latteId,
    macchiatoId,
  ];

  static bool isBuiltIn(String id) => accentsById.containsKey(id);

  static bool isCustomId(String id) => id.startsWith(customIdPrefix);

  static String nameFor(
    String id,
    Map<String, ScheduleColorTheme> customThemes,
  ) {
    return displayNames[id] ?? customThemes[id]?.name ?? id;
  }

  /// 主题名保留给内置 flavor（同时检查 ID 和显示名，忽略大小写）。
  static bool isReservedName(String rawName) {
    final name = rawName.trim().toLowerCase();
    if (name.isEmpty) return false;
    if (builtInIds.any((id) => id.toLowerCase() == name)) return true;
    return displayNames.values.any(
      (displayName) => displayName.toLowerCase() == name,
    );
  }

  /// 解析活动主题对应的颜色池；未知 ID 回退到默认 Lumaris。
  static List<Color> resolvePool({
    required String themeId,
    required Map<String, ScheduleColorTheme> customThemes,
  }) {
    final builtIn = accentsById[themeId];
    if (builtIn != null) return builtIn;

    final custom = customThemes[themeId];
    if (custom != null) return custom.colors;

    return defaultColorPool;
  }
}
