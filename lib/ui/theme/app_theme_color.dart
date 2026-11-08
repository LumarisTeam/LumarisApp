import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Stable preference IDs for the app's accent colors.
enum AppThemeColor {
  blue(Color(0xFF007AFF), Color(0xFF0A84FF)),
  green(Color(0xFF34C759), Color(0xFF30D158)),
  orange(Color(0xFFFF9500), Color(0xFFFF9F0A));

  const AppThemeColor(this.light, this.dark);

  final Color light;
  final Color dark;

  static AppThemeColor fromPreference(String? value) =>
      AppThemeColor.values.where((color) => color.name == value).firstOrNull ??
      AppThemeColor.blue;

  McColors colorsFor(Brightness brightness) {
    final base = brightness == Brightness.dark ? McColors.dark : McColors.light;
    // Preserve the existing default theme exactly.
    if (this == AppThemeColor.blue) return base;
    final accent = brightness == Brightness.dark ? dark : light;
    return base.copyWith(
      primary: accent,
      primarySoft: accent.withValues(
        alpha: brightness == Brightness.dark ? 0.15 : 0.12,
      ),
      primaryForeground: const Color(0xFF000000),
    );
  }

  ThemeData materialTheme(
    Brightness brightness, {
    String? fontFamily,
    Locale? locale,
  }) {
    final colors = colorsFor(brightness);
    final theme = McThemeData.materialTheme(
      colors,
      fontFamily: fontFamily,
      locale: locale,
    );
    return theme.copyWith(
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(CupertinoIcons.chevron_back),
        closeButtonIconBuilder: (_) => const Icon(CupertinoIcons.xmark),
      ),
      colorScheme: theme.colorScheme.copyWith(
        onPrimary: colors.primaryForeground,
        onSecondary: colors.primaryForeground,
      ),
    );
  }
}
