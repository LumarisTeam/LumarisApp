import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';

@immutable
class ClubColors extends ThemeExtension<ClubColors> {
  const ClubColors({
    required this.appBackground,
    required this.groupedBackground,
    required this.cardBackground,
    required this.cardOverlay,
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.surfaceSunken,
    required this.separator,
    required this.borderStrong,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.quaternaryLabel,
    required this.inverseLabel,
    required this.primary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.indigo,
    required this.purple,
    required this.pink,
    required this.cyan,
    required this.yellow,
    required this.successSoft,
    required this.warningSoft,
    required this.dangerSoft,
    required this.primarySoft,
    required this.indigoSoft,
    required this.purpleSoft,
    required this.pinkSoft,
    required this.cyanSoft,
    required this.yellowSoft,
    required this.onAccent,
    required this.selectionFill,
    required this.shadowColor,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  final Color appBackground;
  final Color groupedBackground;
  final Color cardBackground;
  final Color cardOverlay;
  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color surfaceSunken;
  final Color separator;
  final Color borderStrong;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color quaternaryLabel;
  final Color inverseLabel;
  final Color primary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color indigo;
  final Color purple;
  final Color pink;
  final Color cyan;
  final Color yellow;
  final Color successSoft;
  final Color warningSoft;
  final Color dangerSoft;
  final Color primarySoft;
  final Color indigoSoft;
  final Color purpleSoft;
  final Color pinkSoft;
  final Color cyanSoft;
  final Color yellowSoft;
  final Color onAccent;
  final Color selectionFill;
  final Color shadowColor;
  final Color skeletonBase;
  final Color skeletonHighlight;

  static const ClubColors light = ClubColors(
    appBackground: Color(0xFFFFFFFF),
    groupedBackground: Color(0xFFF8F8F8),
    // Neutralized iOS-style background
    cardBackground: Color(0xFFFFFFFF),
    cardOverlay: Color(0xB3FFFFFF),
    surfaceRaised: Color(0xFFF2F2F7),
    surfaceMuted: Color(0xFFEFEFF4),
    surfaceSunken: Color(0xFFE5E5EA),
    separator: Color(0x333C3C43),
    borderStrong: Color(0xFFD1D1D6),
    label: Color(0xFF000000),
    secondaryLabel: Color(0x993C3C43),
    tertiaryLabel: Color(0x4D3C3C43),
    quaternaryLabel: Color(0x2E3C3C43),
    inverseLabel: Color(0xFFFFFFFF),
    primary: Color(0xFF007AFF),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    danger: Color(0xFFFF3B30),
    indigo: Color(0xFF5856D6),
    purple: Color(0xFFAF52DE),
    pink: Color(0xFFFF2D55),
    cyan: Color(0xFF5AC8FA),
    yellow: Color(0xFFFFCC00),
    successSoft: Color(0x1F34C759),
    warningSoft: Color(0x1FFF9500),
    dangerSoft: Color(0x1FFF3B30),
    primarySoft: Color(0x1F007AFF),
    indigoSoft: Color(0x1F5856D6),
    purpleSoft: Color(0x1FAF52DE),
    pinkSoft: Color(0x1FFF2D55),
    cyanSoft: Color(0x1F5AC8FA),
    yellowSoft: Color(0x1FFFCC00),
    onAccent: Color(0xFFFFFFFF),
    selectionFill: Color(0x1F787880),
    shadowColor: Color(0x1A000000),
    skeletonBase: Color(0xFFEBEBF4),
    skeletonHighlight: Color(0xFFF4F4F4),
  );

  static const ClubColors dark = ClubColors(
    appBackground: Color(0xFF000000),
    groupedBackground: Color(0xFF000000),
    cardBackground: Color(0xFF1C1C1E),
    cardOverlay: Color(0x1FEBEBF5),
    surfaceRaised: Color(0xFF2C2C2E),
    surfaceMuted: Color(0xFF242426),
    surfaceSunken: Color(0xFF3A3A3C),
    separator: Color(0x33545458),
    borderStrong: Color(0xFF545458),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0x99EBEBF5),
    tertiaryLabel: Color(0x4DEBEBF5),
    quaternaryLabel: Color(0x2EEBEBF5),
    inverseLabel: Color(0xFF000000),
    primary: Color(0xFF0A84FF),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    danger: Color(0xFFFF453A),
    indigo: Color(0xFF5E5CE6),
    purple: Color(0xFFBF5AF2),
    pink: Color(0xFFFF375F),
    cyan: Color(0xFF64D2FF),
    yellow: Color(0xFFFFD60A),
    successSoft: Color(0x2630D158),
    warningSoft: Color(0x26FF9F0A),
    dangerSoft: Color(0x26FF453A),
    primarySoft: Color(0x260A84FF),
    indigoSoft: Color(0x265E5CE6),
    purpleSoft: Color(0x26BF5AF2),
    pinkSoft: Color(0x26FF375F),
    cyanSoft: Color(0x2664D2FF),
    yellowSoft: Color(0x26FFD60A),
    onAccent: Color(0xFFFFFFFF),
    selectionFill: Color(0x33787880),
    shadowColor: Color(0x00000000),
    skeletonBase: Color(0xFF2C2C2E),
    skeletonHighlight: Color(0xFF3A3A3C),
  );

  @override
  ThemeExtension<ClubColors> copyWith({
    Color? appBackground,
    Color? groupedBackground,
    Color? cardBackground,
    Color? cardOverlay,
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? surfaceSunken,
    Color? separator,
    Color? borderStrong,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? quaternaryLabel,
    Color? inverseLabel,
    Color? primary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? indigo,
    Color? purple,
    Color? pink,
    Color? cyan,
    Color? yellow,
    Color? successSoft,
    Color? warningSoft,
    Color? dangerSoft,
    Color? primarySoft,
    Color? indigoSoft,
    Color? purpleSoft,
    Color? pinkSoft,
    Color? cyanSoft,
    Color? yellowSoft,
    Color? onAccent,
    Color? selectionFill,
    Color? shadowColor,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return ClubColors(
      appBackground: appBackground ?? this.appBackground,
      groupedBackground: groupedBackground ?? this.groupedBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      cardOverlay: cardOverlay ?? this.cardOverlay,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      separator: separator ?? this.separator,
      borderStrong: borderStrong ?? this.borderStrong,
      label: label ?? this.label,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
      quaternaryLabel: quaternaryLabel ?? this.quaternaryLabel,
      inverseLabel: inverseLabel ?? this.inverseLabel,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      indigo: indigo ?? this.indigo,
      purple: purple ?? this.purple,
      pink: pink ?? this.pink,
      cyan: cyan ?? this.cyan,
      yellow: yellow ?? this.yellow,
      successSoft: successSoft ?? this.successSoft,
      warningSoft: warningSoft ?? this.warningSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      primarySoft: primarySoft ?? this.primarySoft,
      indigoSoft: indigoSoft ?? this.indigoSoft,
      purpleSoft: purpleSoft ?? this.purpleSoft,
      pinkSoft: pinkSoft ?? this.pinkSoft,
      cyanSoft: cyanSoft ?? this.cyanSoft,
      yellowSoft: yellowSoft ?? this.yellowSoft,
      onAccent: onAccent ?? this.onAccent,
      selectionFill: selectionFill ?? this.selectionFill,
      shadowColor: shadowColor ?? this.shadowColor,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  ThemeExtension<ClubColors> lerp(
    covariant ThemeExtension<ClubColors>? other,
    double t,
  ) {
    if (other is! ClubColors) {
      return this;
    }

    return ClubColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      groupedBackground:
          Color.lerp(groupedBackground, other.groupedBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardOverlay: Color.lerp(cardOverlay, other.cardOverlay, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      label: Color.lerp(label, other.label, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      tertiaryLabel: Color.lerp(tertiaryLabel, other.tertiaryLabel, t)!,
      quaternaryLabel: Color.lerp(quaternaryLabel, other.quaternaryLabel, t)!,
      inverseLabel: Color.lerp(inverseLabel, other.inverseLabel, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      indigo: Color.lerp(indigo, other.indigo, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      indigoSoft: Color.lerp(indigoSoft, other.indigoSoft, t)!,
      purpleSoft: Color.lerp(purpleSoft, other.purpleSoft, t)!,
      pinkSoft: Color.lerp(pinkSoft, other.pinkSoft, t)!,
      cyanSoft: Color.lerp(cyanSoft, other.cyanSoft, t)!,
      yellowSoft: Color.lerp(yellowSoft, other.yellowSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      selectionFill: Color.lerp(selectionFill, other.selectionFill, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}

/// Whether the given locale typically produces longer text strings
/// (e.g. German, Russian) and benefits from a slightly smaller font size.
bool _isLongTextLocale(Locale? locale) {
  if (locale == null) return false;
  final lang = locale.languageCode;
  return lang == 'de' || lang == 'ru';
}

class ClubTheme {
  ClubTheme._();

  static ThemeData lightTheme({String? fontFamily, Locale? locale}) {
    return _buildTheme(
      brightness: Brightness.light,
      fontFamily: fontFamily,
      colors: ClubColors.light,
      locale: locale,
    );
  }

  static ThemeData darkTheme({String? fontFamily, Locale? locale}) {
    return _buildTheme(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      colors: ClubColors.dark,
      locale: locale,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ClubColors colors,
    String? fontFamily,
    Locale? locale,
  }) {
    final shrink = _isLongTextLocale(locale);
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: Colors.white,
      secondary: colors.primary,
      onSecondary: Colors.white,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.cardBackground,
      onSurface: colors.label,
      surfaceTint: Colors.transparent, // Disable Material 3 surface tinting
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.groupedBackground,
      canvasColor: colors.groupedBackground,
      dividerColor: colors.separator,
      disabledColor: colors.tertiaryLabel,
      splashColor: colors.selectionFill,
      highlightColor: colors.selectionFill,
      hoverColor: colors.cardOverlay,
      shadowColor: colors.shadowColor,
      cardColor: colors.cardBackground,
      extensions: <ThemeExtension<dynamic>>[colors],
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.cardBackground,
        contentTextStyle: TextStyle(
          color: colors.label,
          fontSize: shrink ? 13 : 14,
        ),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: ClubSmoothCorners.shape(
          ClubRadii.card,
          side: BorderSide(
            color: colors.separator.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.groupedBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Ensure no elevation on scroll
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardBackground,
        modalBackgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colors.label,
          fontSize: shrink ? 16 : 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: colors.secondaryLabel,
          fontSize: shrink ? 13 : 14,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.secondaryLabel,
        labelStyle: TextStyle(
          fontSize: shrink ? 14 : 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: shrink ? 14 : 15,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: colors.primary,
        scaffoldBackgroundColor: colors.groupedBackground,
        barBackgroundColor: colors.groupedBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: colors.primary,
          textStyle: TextStyle(
            color: colors.label,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(baseTheme.textTheme, colors.label, shrink),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.label,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.secondaryLabel,
        textColor: colors.label,
      ),
    );
  }

  /// Safely builds a TextTheme by only applying fontSizeFactor to styles
  /// with explicit font sizes, avoiding the assertion when [TextStyle.apply]
  /// receives a null fontSize with a non-1.0 factor.
  static TextTheme _buildTextTheme(
    TextTheme base,
    Color color,
    bool shrink,
  ) {
    final applied = base.apply(bodyColor: color, displayColor: color);
    if (!shrink) return applied;

    const double factor = 0.92;
    return TextTheme(
      displayLarge: _scaleStyle(applied.displayLarge, factor),
      displayMedium: _scaleStyle(applied.displayMedium, factor),
      displaySmall: _scaleStyle(applied.displaySmall, factor),
      headlineLarge: _scaleStyle(applied.headlineLarge, factor),
      headlineMedium: _scaleStyle(applied.headlineMedium, factor),
      headlineSmall: _scaleStyle(applied.headlineSmall, factor),
      titleLarge: _scaleStyle(applied.titleLarge, factor),
      titleMedium: _scaleStyle(applied.titleMedium, factor),
      titleSmall: _scaleStyle(applied.titleSmall, factor),
      bodyLarge: _scaleStyle(applied.bodyLarge, factor),
      bodyMedium: _scaleStyle(applied.bodyMedium, factor),
      bodySmall: _scaleStyle(applied.bodySmall, factor),
      labelLarge: _scaleStyle(applied.labelLarge, factor),
      labelMedium: _scaleStyle(applied.labelMedium, factor),
      labelSmall: _scaleStyle(applied.labelSmall, factor),
    );
  }

  static TextStyle? _scaleStyle(TextStyle? style, double factor) {
    if (style == null || style.fontSize == null) return style;
    return style.copyWith(fontSize: style.fontSize! * factor);
  }
}

extension ClubThemeBuildContext on BuildContext {
  ClubColors get clubColors {
    return Theme.of(this).extension<ClubColors>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? ClubColors.dark
            : ClubColors.light);
  }
}

class ClubThemeModeCodec {
  ClubThemeModeCodec._();

  static ThemeMode fromPreference(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String toPreference(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
