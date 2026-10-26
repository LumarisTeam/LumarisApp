import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

enum AppLocaleCode { system, zh, en, ja, ru, fr, de, ko, zhHant }

class AppLocaleOption {
  const AppLocaleOption({
    required this.code,
    required this.locale,
    required this.labelBuilder,
  });

  final AppLocaleCode code;
  final Locale? locale;
  final String Function(AppLocalizations l10n) labelBuilder;
}

class AppLocaleService {
  const AppLocaleService._();

  static const String systemPreferenceValue = 'system';
  static const String zhPreferenceValue = 'zh';
  static const String enPreferenceValue = 'en';
  static const String jaPreferenceValue = 'ja';
  static const String ruPreferenceValue = 'ru';
  static const String frPreferenceValue = 'fr';
  static const String dePreferenceValue = 'de';
  static const String koPreferenceValue = 'ko';
  static const String zhHantPreferenceValue = 'zh_Hant';

  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('ru'),
    Locale('fr'),
    Locale('de'),
    Locale('ko'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  static final List<AppLocaleOption> options = [
    AppLocaleOption(
      code: AppLocaleCode.system,
      locale: null,
      labelBuilder: (l10n) => l10n.systemLanguage,
    ),
    AppLocaleOption(
      code: AppLocaleCode.zh,
      locale: const Locale('zh'),
      labelBuilder: (l10n) => l10n.simplifiedChinese,
    ),
    AppLocaleOption(
      code: AppLocaleCode.en,
      locale: const Locale('en'),
      labelBuilder: (l10n) => l10n.english,
    ),
    AppLocaleOption(
      code: AppLocaleCode.ja,
      locale: const Locale('ja'),
      labelBuilder: (l10n) => l10n.japanese,
    ),
    AppLocaleOption(
      code: AppLocaleCode.ru,
      locale: const Locale('ru'),
      labelBuilder: (l10n) => l10n.russian,
    ),
    AppLocaleOption(
      code: AppLocaleCode.fr,
      locale: const Locale('fr'),
      labelBuilder: (l10n) => l10n.french,
    ),
    AppLocaleOption(
      code: AppLocaleCode.de,
      locale: const Locale('de'),
      labelBuilder: (l10n) => l10n.german,
    ),
    AppLocaleOption(
      code: AppLocaleCode.ko,
      locale: const Locale('ko'),
      labelBuilder: (l10n) => l10n.korean,
    ),
    AppLocaleOption(
      code: AppLocaleCode.zhHant,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      labelBuilder: (l10n) => l10n.traditionalChinese,
    ),
  ];

  static String toPreference(AppLocaleCode code) {
    switch (code) {
      case AppLocaleCode.system:
        return systemPreferenceValue;
      case AppLocaleCode.zh:
        return zhPreferenceValue;
      case AppLocaleCode.en:
        return enPreferenceValue;
      case AppLocaleCode.ja:
        return jaPreferenceValue;
      case AppLocaleCode.ru:
        return ruPreferenceValue;
      case AppLocaleCode.fr:
        return frPreferenceValue;
      case AppLocaleCode.de:
        return dePreferenceValue;
      case AppLocaleCode.ko:
        return koPreferenceValue;
      case AppLocaleCode.zhHant:
        return zhHantPreferenceValue;
    }
  }

  static AppLocaleCode fromPreference(String? value) {
    switch (value) {
      case zhPreferenceValue:
        return AppLocaleCode.zh;
      case enPreferenceValue:
        return AppLocaleCode.en;
      case jaPreferenceValue:
        return AppLocaleCode.ja;
      case ruPreferenceValue:
        return AppLocaleCode.ru;
      case frPreferenceValue:
        return AppLocaleCode.fr;
      case dePreferenceValue:
        return AppLocaleCode.de;
      case koPreferenceValue:
        return AppLocaleCode.ko;
      case zhHantPreferenceValue:
        return AppLocaleCode.zhHant;
      case systemPreferenceValue:
      default:
        return AppLocaleCode.system;
    }
  }

  static Locale? localeOf(AppLocaleCode code) {
    switch (code) {
      case AppLocaleCode.system:
        return null;
      case AppLocaleCode.zh:
        return const Locale('zh');
      case AppLocaleCode.en:
        return const Locale('en');
      case AppLocaleCode.ja:
        return const Locale('ja');
      case AppLocaleCode.ru:
        return const Locale('ru');
      case AppLocaleCode.fr:
        return const Locale('fr');
      case AppLocaleCode.de:
        return const Locale('de');
      case AppLocaleCode.ko:
        return const Locale('ko');
      case AppLocaleCode.zhHant:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
  }

  static String labelOf(AppLocalizations l10n, AppLocaleCode code) {
    return options
        .firstWhere((option) => option.code == code)
        .labelBuilder(l10n);
  }

  static Locale resolveLocale([Locale? preferredLocale]) {
    final locale =
        preferredLocale ?? WidgetsBinding.instance.platformDispatcher.locale;

    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return supportedLocales.first;
  }

  static AppLocalizations currentL10n() {
    final preference = PrefsService.instance.getString(PrefsKeys.LOCALE_CODE);
    final configuredLocale = localeOf(fromPreference(preference));
    return lookupAppLocalizations(resolveLocale(configuredLocale));
  }
}
