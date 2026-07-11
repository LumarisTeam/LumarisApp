import 'package:flutter/widgets.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/l10n/app_localizations_zh.dart';

extension AppLocalizationsX on BuildContext {
  /// Uses Chinese as a defensive fallback for isolated widget hosts that do
  /// not install the app localization delegate (for example previews/tests).
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsZh();
}
