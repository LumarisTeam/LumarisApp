// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Lumaris';

  @override
  String get appSlogan => 'Das gesamte Campusleben in einer App';

  @override
  String get tagline => 'Engagiert, Studenten einen besseren Service zu bieten';

  @override
  String get home => 'Start';

  @override
  String get schedule => 'Stundenplan';

  @override
  String get score => 'Noten';

  @override
  String get profile => 'Ich';

  @override
  String get electricity => 'Strom';

  @override
  String get schoolBus => 'Bus';

  @override
  String get payment => 'Karte';

  @override
  String get map => 'Plan';

  @override
  String get settings => 'Einstellungen';

  @override
  String get basicSettings => 'Allgemein';

  @override
  String get version => 'Version';

  @override
  String get widgets => 'Widgets';

  @override
  String get about => 'Über';

  @override
  String get other => 'Sonstiges';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackSubtitle =>
      'Probleme melden oder Verbesserungen vorschlagen';

  @override
  String get feedbackContentLabel => 'Beschreibung';

  @override
  String get feedbackContentHint => 'Beschreiben Sie das aufgetretene Problem';

  @override
  String get feedbackContentRequired => 'Bitte beschreiben Sie das Problem';

  @override
  String get feedbackContactLabel => 'Kontaktdaten';

  @override
  String get feedbackContactHint => 'Telefon / E-Mail / QQ usw.';

  @override
  String get feedbackContactRequired => 'Bitte geben Sie Ihre Kontaktdaten an';

  @override
  String get feedbackImagesLabel => 'Bilder (optional, maximal 6)';

  @override
  String get feedbackAddImage => 'Bild hinzufügen';

  @override
  String get feedbackSubmit => 'Senden';

  @override
  String get feedbackSubmitting => 'Wird gesendet…';

  @override
  String get feedbackSubmitSuccess =>
      'Feedback gesendet. Vielen Dank für Ihre Unterstützung!';

  @override
  String get feedbackPickImageFailed =>
      'Bild konnte nicht ausgewählt werden. Bitte versuchen Sie es erneut';

  @override
  String get feedbackImageUploadFailed =>
      'Bild konnte nicht hochgeladen werden. Bitte versuchen Sie es erneut';

  @override
  String get feedbackImageTooMany =>
      'Es können maximal 6 Bilder hochgeladen werden';

  @override
  String get refreshData => 'Aktualisieren';

  @override
  String get refreshingData => 'Daten werden aktualisiert...';

  @override
  String get refreshDataSuccess => 'Daten aktualisiert';

  @override
  String get refreshDataFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get followSystem => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get systemLanguage => 'System';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get russian => 'Русский';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get korean => '한국어';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get team => 'Team';

  @override
  String get teamName => 'Lumaris Team';

  @override
  String get openSourceLicense => 'Open-Source-Lizenz';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get privacyPolicySubtitle =>
      'Erfahren Sie, wie wir Ihre Privatsphäre schützen';

  @override
  String get userAgreement => 'Nutzungsbedingungen';

  @override
  String get userAgreementSubtitle =>
      'Durch die Nutzung stimmen Sie diesen Bedingungen zu';

  @override
  String get protocolOpenInBrowser => 'Im Browser öffnen';

  @override
  String get protocolInlineUnsupported =>
      'Diese Plattform kann das Dokument nicht in der App anzeigen. Bitte im Browser öffnen.';

  @override
  String get protocolOpenFailed => 'Dokument konnte nicht geöffnet werden';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get clearingCache => 'Cache leeren...';

  @override
  String get cacheCleared => 'Cache geleert';

  @override
  String get confirmClearCacheTitle => 'Cache leeren?';

  @override
  String get confirmClearCacheContent =>
      'Alle zwischengespeicherten Daten werden gelöscht und beim nächsten Start neu geladen';

  @override
  String get logoutEduSystem => 'Abmelden';

  @override
  String get confirmLogoutTitle => 'Abmelden?';

  @override
  String get confirmLogoutContent =>
      'Sie müssen sich erneut anmelden, um auf akademische Daten zuzugreifen';

  @override
  String get logout => 'Abmelden';

  @override
  String get agreementAuthDebug => 'Zustimmungsstatus [Debug]';

  @override
  String get agreementAuthDebugSubtitle =>
      'Deaktivieren, um die Zustimmungsseite beim nächsten Start erneut anzuzeigen';

  @override
  String get addToDesktop => 'Zum Startbildschirm';

  @override
  String get widgetSetupTitle => 'Widget hinzufügen';

  @override
  String get widgetSetupIntro => 'Folgen Sie diesen Schritten:';

  @override
  String get widgetSetupStep1 =>
      'Leeren Bereich auf dem Startbildschirm lange drücken';

  @override
  String get widgetSetupStep2 => 'Auf Widgets tippen';

  @override
  String get widgetSetupStep3 => 'Lumaris finden und Widget auswählen';

  @override
  String get widgetSetupStep4 => 'Widget an die gewünschte Position ziehen';

  @override
  String get widgetSetupTip => 'Tipp: Widgets zeigen die heutigen Kurse an';

  @override
  String get cancel => 'Abbrechen';

  @override
  String downloadingUpdateTitle(Object version) {
    return 'Update $version wird heruntergeladen';
  }

  @override
  String get downloadCompletedInstalling =>
      'Download abgeschlossen, Installation wird gestartet...';

  @override
  String downloadFailed(Object error) {
    return 'Download fehlgeschlagen: $error';
  }

  @override
  String get confirm => 'Bestätigen';

  @override
  String get back => 'Zurück';

  @override
  String get collapseSidebar => 'Seitenleiste einklappen';

  @override
  String get expandSidebar => 'Seitenleiste ausklappen';

  @override
  String get notLoggedIn => 'Nicht angemeldet';

  @override
  String get academicSystem => 'Hochschulsystem';

  @override
  String get clickToLogin => 'Zum Anmelden tippen';

  @override
  String get closeWindow => 'Fenster schließen';

  @override
  String get closeWindowChoice => 'Aktion wählen';

  @override
  String get showWindow => 'Fenster anzeigen';

  @override
  String get minimizeToTray => 'In Taskleiste minimieren';

  @override
  String get quitApp => 'Beenden';

  @override
  String get goToSettings => 'Einstellungen';

  @override
  String get goAuthorize => 'Erlauben';

  @override
  String get permissionRequired => 'Berechtigung erforderlich';

  @override
  String get permissionRequiredContent =>
      'Diese Funktion benötigt die entsprechende Berechtigung';

  @override
  String get permissionDenied => 'Berechtigung verweigert';

  @override
  String get permissionDeniedContent =>
      'Diese Berechtigung wurde dauerhaft verweigert. Bitte in den Systemeinstellungen aktivieren';

  @override
  String get updateAvailable => 'Neue Version verfügbar!';

  @override
  String get ignoreThisUpdate => 'Diese ignorieren';

  @override
  String get ignoreAllUpdates => 'Alle ignorieren';

  @override
  String get goToBrowserUpdate => 'Browser öffnen';

  @override
  String get goToBrowser => 'Browser öffnen';

  @override
  String get dontUpdate => 'Später';

  @override
  String confirmUpdateTitle(String version) {
    return 'Auf neueste Version aktualisieren: $version?';
  }

  @override
  String get confirmUpdateContent =>
      'Eine neue Version ist verfügbar. Browser zum Herunterladen öffnen?';

  @override
  String get updateLog => 'Update-Verlauf';

  @override
  String get ignoreVersionUpdate => 'Version ignorieren';

  @override
  String get updateOpened =>
      'Browser geöffnet. Bitte Update herunterladen und installieren';

  @override
  String get openUpdateFailed => 'Update-Link konnte nicht geöffnet werden';

  @override
  String get loginRequired => 'Anmeldung erforderlich';

  @override
  String get pleaseLoginEduAccount =>
      'Bitte melden Sie sich zuerst im Hochschulsystem an';

  @override
  String get loadFailedTapRetry =>
      'Laden fehlgeschlagen. Zum Wiederholen tippen';

  @override
  String get empty => 'Keine Daten';

  @override
  String get loading => 'Laden';

  @override
  String get syncingData => 'Synchronisierung';

  @override
  String get syncingDataSubtitle =>
      'Kann bei langsamem Netzwerk einige Sekunden dauern';

  @override
  String get creditOverview => 'Leistungspunkte-Übersicht';

  @override
  String get completionRate => 'Abschluss';

  @override
  String get itemizedCredits => 'Aufschlüsselung';

  @override
  String get courseConflict =>
      'Mehrere Kurse überschneiden sich zu dieser Zeit';

  @override
  String get notificationCourseChannelName => 'Kurs-Erinnerungen';

  @override
  String get notificationCourseChannelDescription =>
      'Benachrichtigungen für den täglichen Stundenplan';

  @override
  String notificationCourseAdvanceDescription(Object minutes) {
    return 'Benachrichtigungen für den täglichen Stundenplan, $minutes Minuten im Voraus';
  }

  @override
  String get notificationTodoChannelName => 'Aufgaben-Erinnerungen';

  @override
  String get notificationTodoChannelDescription =>
      'Erinnerungen an fällige Aufgaben';

  @override
  String get courseReminderTitle => 'Kurs-Erinnerung';

  @override
  String courseReminderStartsIn(Object minutes) {
    return 'beginnt in $minutes Minuten';
  }

  @override
  String get allowBackgroundRun => 'Hintergrundausführung erlauben';

  @override
  String get allowBackgroundRunContent =>
      'Damit Kurserinnerungen pünktlich ausgelöst werden, erlauben Sie bitte die Ausführung im Hintergrund und ignorieren Sie die Akkuoptimierung.';

  @override
  String get allowScheduleAlarm => 'Alarme erlauben';

  @override
  String get allowScheduleAlarmContent =>
      'Sie müssen Alarme erlauben, um Benachrichtigungen zu verwenden.';

  @override
  String get saveFailedRetry =>
      'Speichern fehlgeschlagen, bitte erneut versuchen';

  @override
  String get toggleTileVisibilityFailed =>
      'Sichtbarkeit konnte nicht geändert werden';

  @override
  String get resetFailed => 'Zurücksetzen fehlgeschlagen';

  @override
  String get networkError => 'Netzwerkfehler. Verbindung überprüfen';

  @override
  String get requestTimeout => 'Zeitüberschreitung. Verbindung überprüfen';

  @override
  String get serverError => 'Serverfehler. Später erneut versuchen';

  @override
  String get unknownError => 'Unbekannter Fehler. Erneut versuchen';

  @override
  String get agreementWelcomeTitle => 'Willkommen bei Lumaris';

  @override
  String get agreementDescription =>
      'Bitte lesen und akzeptieren Sie die folgenden Vereinbarungen vor der Nutzung der App.';

  @override
  String get agreementPrivacyDescription =>
      'Erfahren Sie, wie wir Ihre Daten sammeln, nutzen und schützen';

  @override
  String get agreementUserDescription =>
      'Erfahren Sie mehr über Ihre Rechte, Pflichten und Haftungsausschlüsse';

  @override
  String get agreementReadTip =>
      'Tippen Sie auf die Karten oben, um die vollständigen Texte anzuzeigen. Mit der Fortsetzung stimmen Sie den Vereinbarungen zu.';

  @override
  String get agreeAndContinue => 'Akzeptieren und fortfahren';

  @override
  String get disagree => 'Ablehnen';

  @override
  String get loginAgreementPrefix => 'Mit der Anmeldung akzeptieren Sie die ';

  @override
  String get loginAgreementRequired =>
      'Bitte lesen und akzeptieren Sie zuerst die Nutzungsbedingungen und die Datenschutzerklärung';

  @override
  String get privacyContact =>
      'Team: Lumaris Team\nRepository: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get userAgreementContact =>
      'Team: Lumaris Team\nRepository: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get aboutAuthor => 'Über die Autoren';

  @override
  String get coreTeam => 'Kernteam';

  @override
  String get specialThanks => 'Besonderer Dank';

  @override
  String get contactUs => 'Kontakt';

  @override
  String get thanksTitle => 'Danke';

  @override
  String get thanksContent =>
      'Danke an alle Entwickler und Nutzer, die zum Projekt beigetragen haben.';

  @override
  String get githubRepository => 'GitHub-Repository';

  @override
  String get joinUs => 'Mitmachen';

  @override
  String get madeWithLove => 'Made with ❤️ in Xi\'an';

  @override
  String get easterEggTitle => '🎉 Easter Egg';

  @override
  String get easterEggFound =>
      'Glückwunsch! Sie haben das versteckte Easter Egg gefunden!';

  @override
  String get easterEggContent =>
      'Sie sind einer der wenigen, die dieses Geheimnis kennen!\n\nVielen Dank, dass Sie Lumaris lieben und unterstützen.\n\nErkunden Sie weiter, vielleicht warten noch mehr Überraschungen auf Sie...';

  @override
  String get fontSetting => 'Schriftart-Einstellung';

  @override
  String get fontSettingSubtitle =>
      'Schriftart für Desktop-Plattformen wählen (beim nächsten Start angewendet)';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get customFont => 'Benutzerdefiniert';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get hapticFeedbackSubtitle =>
      'Vibrieren beim Antippen der unteren Navigation';

  @override
  String get showTomorrowCourses => 'Morgige Kurse anzeigen';

  @override
  String get showTomorrowCoursesSubtitle =>
      'Zeigt die Kurse von morgen an, wenn heute keine Kurse stattfinden';

  @override
  String get courseReminder => 'Kurserinnerung';

  @override
  String get courseReminderSubtitle => 'Vor Kursbeginn erinnern';

  @override
  String get remindMinutesBefore => 'Wie viele Minuten vorher erinnern';

  @override
  String remindMinutes(int n) {
    return '$n Minuten';
  }

  @override
  String get schedulePage => 'Stundenplan';

  @override
  String get scorePage => 'Noten';

  @override
  String get profilePage => 'Profil';

  @override
  String get firstPageOnLaunch => 'Erste Seite beim Start';

  @override
  String get sunday => 'Sonntag';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sundayShort => 'So';

  @override
  String get mondayShort => 'Mo';

  @override
  String get tuesdayShort => 'Di';

  @override
  String get wednesdayShort => 'Mi';

  @override
  String get thursdayShort => 'Do';

  @override
  String get fridayShort => 'Fr';

  @override
  String get saturdayShort => 'Sa';

  @override
  String get janShort => 'Jan.';

  @override
  String get febShort => 'Feb.';

  @override
  String get marShort => 'März';

  @override
  String get aprShort => 'Apr.';

  @override
  String get mayShort => 'Mai';

  @override
  String get junShort => 'Juni';

  @override
  String get julShort => 'Juli';

  @override
  String get augShort => 'Aug.';

  @override
  String get sepShort => 'Sep.';

  @override
  String get octShort => 'Okt.';

  @override
  String get novShort => 'Nov.';

  @override
  String get decShort => 'Dez.';

  @override
  String weekUnit(int n) {
    return 'Woche $n';
  }

  @override
  String currentWeek(int n) {
    return 'Aktuelle Woche $n';
  }

  @override
  String weeksUntilStart(int n) {
    return 'Noch $n Woche(n) bis zum Semesterbeginn';
  }

  @override
  String periodRange(int start, int end) {
    return 'Stunde $start-$end';
  }

  @override
  String get allSchedules => 'Alle Stundenpläne';

  @override
  String get previousWeek => 'Vorherige Woche';

  @override
  String get nextWeek => 'Nächste Woche';

  @override
  String get switchStyle => 'Stil wechseln';

  @override
  String get refreshSchedule => 'Stundenplan aktualisieren';

  @override
  String get scheduleSettingsTitle => 'Stundenplan-Einstellungen';

  @override
  String get compact => 'Kompakt';

  @override
  String get standard => 'Standard';

  @override
  String get relaxed => 'Entspannt';

  @override
  String get selectCourse => 'Kurs auswählen';

  @override
  String get editCourse => 'Kurs bearbeiten';

  @override
  String get deleteCourse => 'Kurs löschen';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String confirmDeleteCourseContent(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen?';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get courseModified => 'Kurs aktualisiert';

  @override
  String get courseDeleted => 'Kurs gelöscht';

  @override
  String get deleteFailed => 'Löschen fehlgeschlagen';

  @override
  String get noLocation => 'Kein Ort';

  @override
  String get addCourse => 'Kurs hinzufügen';

  @override
  String get save => 'Speichern';

  @override
  String get courseName => 'Kursname';

  @override
  String get courseRoom => 'Raum';

  @override
  String get courseTeacher => 'Lehrer';

  @override
  String get courseCredits => 'Credits';

  @override
  String get courseWeekday => 'Wochentag';

  @override
  String get courseStartUnit => 'Anfangsstunde';

  @override
  String get courseEndUnit => 'Endstunde';

  @override
  String get courseWeeks => 'Wochen';

  @override
  String selectedWeeks(int count) {
    return '$count Woche(n) ausgewählt';
  }

  @override
  String get customCourses => 'Eigene Kurse';

  @override
  String customCoursesCount(int count) {
    return '$count Kurs(e)';
  }

  @override
  String get noCustomCourses => 'Keine benutzerdefinierten Kurse';

  @override
  String get noCustomCoursesSubtitle =>
      'Tippen Sie auf + um Kurse hinzuzufügen';

  @override
  String get readingCustomCourses => 'Benutzerdefinierte Kurse werden gelesen';

  @override
  String get readingCustomCoursesSubtitle =>
      'Lokal gespeicherte Kurse werden organisiert';

  @override
  String get courseAdded => 'Kurs hinzugefügt';

  @override
  String get scoresAndGpa => 'Noten & GPA';

  @override
  String get passedCourses => 'Bestanden';

  @override
  String get totalCredits => 'Gesamtcredits';

  @override
  String get creditInfoTitle => 'Hinweis';

  @override
  String get creditInfoContent =>
      'Credits werden basierend auf bestandenen Kursen berechnet. Das offizielle System kann abweichen.';

  @override
  String get noScores => 'Keine Noten';

  @override
  String get noScoresSubtitle =>
      'Versuchen Sie zu aktualisieren oder erneut einzutreten';

  @override
  String get refreshDataBtn => 'Aktualisieren';

  @override
  String get goToLogin => 'Zur Anmeldung';

  @override
  String get minorCourse => 'Nebenfach';

  @override
  String get scoreDetail => 'Notendetails';

  @override
  String get courseCreditLabel => 'Kurs-Credits';

  @override
  String get courseScoreLabel => 'Kurs-Note';

  @override
  String get courseGpaLabel => 'Kurs-GPA';

  @override
  String get fetchingScores => 'Noten werden abgerufen...';

  @override
  String get refreshFailedFallback =>
      'Aktualisierung fehlgeschlagen, lokale Daten werden angezeigt';

  @override
  String get fetchTimeout =>
      'Zeitüberschreitung. Bitte überprüfen Sie Ihr Netzwerk.';

  @override
  String get fetchFailed => 'Daten konnten nicht abgerufen werden';

  @override
  String get pleaseLoginFirst =>
      'Bitte melden Sie sich an, um Noten anzuzeigen';

  @override
  String get readingScoresSubtitle =>
      'Cache lesen und akademische Noten synchronisieren';

  @override
  String get foolishModeMessage => 'Ja, ich habe einen GPA von 5.0';

  @override
  String creditUnit(String credit) {
    return '$credit Credits';
  }

  @override
  String gradeLabel(String grade) {
    return 'Note $grade';
  }

  @override
  String gpaLabel(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String scheduleCourseTime(
    String weekRanges,
    String weekday,
    int start,
    int end,
  ) {
    return 'Woche $weekRanges jeden $weekday Stunde $start-$end';
  }

  @override
  String semesterRange(String start, String end, String num) {
    return '$start-$end Semester $num';
  }

  @override
  String get semesterAutumnShort => 'WiSe';

  @override
  String get semesterSpringShort => 'SoSe';

  @override
  String get year1 => '1. Jahr';

  @override
  String get year2 => '2. Jahr';

  @override
  String get year3 => '3. Jahr';

  @override
  String get year4 => '4. Jahr';

  @override
  String get year5 => '5. Jahr';

  @override
  String get year6 => '6. Jahr';

  @override
  String get year7 => '7. Jahr';

  @override
  String get year8 => '8. Jahr';

  @override
  String get year9 => '9. Jahr';

  @override
  String get year10 => '10. Jahr';

  @override
  String get loginTitle => 'Anmeldung im Hochschulsystem';

  @override
  String get loginSubtitle => 'Bitte verwenden Sie Ihr Konto';

  @override
  String get studentId => 'Studenten-ID';

  @override
  String get password => 'Passwort';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get loggingIn => 'Anmeldung läuft...';

  @override
  String get loggingInSubtitle =>
      'Überprüfung und Synchronisierung von Kursen, Noten und anderen Daten';

  @override
  String get emptyCredentials =>
      'Benutzername und Passwort dürfen nicht leer sein';

  @override
  String get loginTimeoutEdu =>
      'Anmeldung abgelaufen, bitte überprüfen Sie Ihr Netzwerk';

  @override
  String get loginFailed =>
      'Anmeldung fehlgeschlagen, bitte überprüfen Sie Ihre Anmeldedaten';

  @override
  String get loginTimeout =>
      'Anmeldung abgelaufen. Bitte überprüfen Sie Ihr Netzwerk.';

  @override
  String get loginSecurityStorageUnavailable =>
      'Anmeldung erfolgreich, aber sicherer Speicher nicht verfügbar.';

  @override
  String get loadingDefaultTitle => 'Synchronisierung';

  @override
  String get loadingDefaultSubtitle =>
      'Kann bei langsamem Netzwerk einige Sekunden dauern';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get retry => 'Wiederholen';

  @override
  String get loadFailed => 'Laden fehlgeschlagen';

  @override
  String get noData => 'Keine Daten';

  @override
  String get ok => 'OK';

  @override
  String get classroom => 'Raum';

  @override
  String get teacherLabel => 'Lehrer';

  @override
  String get classTime => 'Zeit';

  @override
  String get classCampus => 'Campus';

  @override
  String get todayScheduleLabel => 'Stundenplan heute';

  @override
  String get tomorrowSchedule => 'Stundenplan morgen';

  @override
  String get noCourseToday => 'Keine Kurse heute';

  @override
  String get noCourseTodaySubtitle =>
      'Machen Sie eine Pause, Sie haben sie verdient';

  @override
  String get showTomorrowSchedule => 'Morgige Kurse anzeigen';

  @override
  String get doubleTapExit => 'Erneut drücken zum Beenden';

  @override
  String copySuccess(String text) {
    return 'Kopiert: $text';
  }

  @override
  String get copyTooltip => 'Kopieren';

  @override
  String get pageSettings => 'Seiteneinstellungen';

  @override
  String get showBusTile => 'Bus-Kachel anzeigen';

  @override
  String get showBusTileSubtitle =>
      'Anstehende Bus-Infos auf der Startseite anzeigen';

  @override
  String get addToHome => 'Zum Startbildschirm hinzufügen';

  @override
  String get showElectricityTile => 'Strom-Kachel anzeigen';

  @override
  String get electricityRecharge => 'Aufladen';

  @override
  String get electricityRechargeSubtitle =>
      'WeChat zum Aufladen des Stroms öffnen';

  @override
  String get showPaymentTile => 'Karten-Kachel anzeigen';

  @override
  String get showPaymentTileSubtitle =>
      'Guthabenübersicht auf der Startseite anzeigen';

  @override
  String get change => 'Aktualisieren';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get done => 'Erledigt';

  @override
  String get readingTodos => 'Lese Aufgaben';

  @override
  String get readingTodosSubtitle =>
      'Lade lokale Aufgabenliste und Erinnerungen';

  @override
  String get noTodos => 'Keine Aufgaben';

  @override
  String get noTodosSubtitle => 'Tippen Sie auf + zum Hinzufügen';

  @override
  String deadlineLabel(String date) {
    return 'Frist: $date';
  }

  @override
  String get noDeadline => 'Keine';

  @override
  String get add => 'Hinzufügen';

  @override
  String get upcomingExams => 'Anstehende Prüfungen';

  @override
  String get loadingExams => 'Lade Prüfungen';

  @override
  String get loadingExamsSubtitle =>
      'Synchronisiere Prüfungen, Räume und Sitzplätze';

  @override
  String get noExams => 'Keine anstehenden Prüfungen';

  @override
  String get noExamsSubtitle => 'Zum Aktualisieren neu laden';

  @override
  String get examTime => 'Prüfungszeit';

  @override
  String get examLocation => 'Prüfungsort';

  @override
  String get seatNumber => 'Sitzplatz';

  @override
  String seatNumberLabel(String seat) {
    return 'Sitzplatz $seat';
  }

  @override
  String get examNotLoggedIn => 'Bitte zuerst anmelden';

  @override
  String get examAuthFailed =>
      'Authentifizierung fehlgeschlagen, bitte erneut anmelden';

  @override
  String get examFetchFailed =>
      'Prüfungsdaten konnten nicht geladen werden, zum Wiederholen tippen';

  @override
  String get quickFeatures => 'Schnellfunktionen';

  @override
  String get noQuickFeatures => 'Keine Schnellfunktionen';

  @override
  String get noQuickFeaturesSubtitle =>
      'Fügen Sie welche im Bearbeitungsmodus hinzu';

  @override
  String get moreFeatures => 'Weitere Funktionen';

  @override
  String get scheduleWidgetTitle => 'In Kalender importieren';

  @override
  String get subscriptionLink => 'Abonnement-Link';

  @override
  String get copiedSuccess => 'Kopiert!';

  @override
  String get howToImport => 'Wie importieren?';

  @override
  String get customCourseManage => 'Eigene Kursverwaltung';

  @override
  String get showCourseGrid => 'Raster anzeigen';

  @override
  String get noBackground => 'Kein Hintergrund';

  @override
  String get customImage => 'Eigenes Bild';

  @override
  String get noImageSelected => 'Kein Bild ausgewählt';

  @override
  String get noCalendarApp =>
      'Keine Kalender-App gefunden, bitte manuell importieren';

  @override
  String get cannotOpenCalendar => 'Kalender-App kann nicht geöffnet werden';

  @override
  String get bgImageSetSuccess => 'Hintergrundbild festgelegt';

  @override
  String get selectImageFailed => 'Bildauswahl fehlgeschlagen';

  @override
  String get addCalendarSub => 'Kalender-Abonnement hinzufügen';

  @override
  String get understand => 'Verstanden';

  @override
  String get calendarSubscription => 'Kalender-Abonnement';

  @override
  String get scheduleManagement => 'Kursverwaltung';

  @override
  String get scheduleBackground => 'Stundenplan-Hintergrund';

  @override
  String get ignoreCourses => 'Kurse ignorieren';

  @override
  String get loadingSchedule => 'Stundenplan wird geladen';

  @override
  String get loadingScheduleSubtitle =>
      'Kurse, Einstellungen und Hintergrund werden gelesen';

  @override
  String get updatingSchedule => 'Stundenplan wird aktualisiert...';

  @override
  String get updateComplete => 'Aktualisierung abgeschlossen';

  @override
  String get updateTimeout =>
      'Aktualisierung abgelaufen. Bitte überprüfen Sie Ihr Netzwerk.';

  @override
  String updateFailed(String error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get linkCopiedToClipboard => 'Link kopiert';

  @override
  String get currentWeekLabel => 'Diese Woche';

  @override
  String periodUnit(int n) {
    return 'Stunde $n';
  }

  @override
  String get calendarGuidanceIntro =>
      'Keine App für Kalenderabos gefunden. Bitte manuell hinzufügen:';

  @override
  String get calendarGuidanceStep1 => '1. Kalender-App öffnen';

  @override
  String get calendarGuidanceStep2 =>
      '2. Option \"Kalender hinzufügen\" oder \"Abonnieren\" finden';

  @override
  String get calendarGuidanceStep3 => '3. \"Per URL hinzufügen\" wählen';

  @override
  String get calendarGuidanceStep4 => '4. Folgenden Link einfügen:';

  @override
  String get calendarGuidanceNote =>
      'Hinweis: Schritte können je nach App abweichen. Hilfe in Ihrer Kalender-App aufrufen.';

  @override
  String get profileReading => 'Kontoinformationen lesen';

  @override
  String get profileReadingSubtitle =>
      'Anmeldestatus und Profildaten synchronisieren';

  @override
  String get campusNavigation => 'Campus-Toolbox';

  @override
  String get settingsAbout => 'Einstellungen / Über';

  @override
  String get programLabel => 'Studienplan';

  @override
  String get campusMap => 'Campus-Plan';

  @override
  String get help => 'Hilfe';

  @override
  String get academicAccount => 'Hochschulkonto';

  @override
  String get guest => 'Gast';

  @override
  String get guestMode => 'Gastmodus';

  @override
  String get guestModeSubtitle =>
      'Melden Sie sich an, um alle Funktionen zu nutzen';

  @override
  String get syncingAcademic => 'Akademische Daten werden synchronisiert';

  @override
  String get syncingAcademicSubtitle => 'Credits und Profilkarten lesen';

  @override
  String get loginEduSystem => 'Im Hochschulsystem anmelden';

  @override
  String get programLoading => 'Studienplan wird geladen';

  @override
  String get programLoadingSubtitle =>
      'Kursstruktur nach Semester organisieren';

  @override
  String get programLoadFailed => 'Laden fehlgeschlagen';

  @override
  String get programNoData => 'Keine Daten';

  @override
  String get programRefreshFailed =>
      'Aktualisierung fehlgeschlagen, zuletzt synchronisierter Plan wird angezeigt';

  @override
  String get linkLoading => 'Navigationslinks werden geladen';

  @override
  String get linkLoadingSubtitle => 'Seiten und Kategorien werden organisiert';

  @override
  String get linkLoadFailed => 'Laden fehlgeschlagen';

  @override
  String get linkNoData => 'Keine Navigationsdaten';

  @override
  String get linkNoDataSubtitle =>
      'Bitte rufen Sie diese Seite erneut auf oder überprüfen Sie Ihr Netzwerk';

  @override
  String get paymentLoading => 'Kartenguthaben wird synchronisiert';

  @override
  String get paymentLoadingSubtitle => 'Neueste Transaktionen werden abgerufen';

  @override
  String get paymentPasswordTitle => 'Kartenpasswort';

  @override
  String get paymentPasswordSubtitle =>
      'Optional. Leer lassen, um die Standardsuche zu verwenden.';

  @override
  String get paymentSaveAndRefresh => 'Speichern und aktualisieren';

  @override
  String get campusCard => 'Campus-Karte';

  @override
  String get currentBalance => 'Aktuelles Guthaben';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get paymentFilter => 'Zahlung';

  @override
  String get consumptionFilter => 'Verbrauch';

  @override
  String get rechargeFilter => 'Aufladung';

  @override
  String get noCardData => 'Keine Kartendaten';

  @override
  String get noCardDataSubtitle =>
      'Bitte melden Sie sich an, um Guthaben und Transaktionen anzuzeigen';

  @override
  String get busLoading => 'Busfahrplan wird abgerufen';

  @override
  String get busLoadingSubtitle =>
      'Bus-Infos nach Campus und Datum organisieren';

  @override
  String get noBusToday => 'Heute keine Busse';

  @override
  String get noBusTodaySubtitle => 'Morgen wiederkommen';

  @override
  String get departureTime => 'Abfahrt';

  @override
  String get destination => 'Ziel';

  @override
  String get estimatedArrival => 'Geschätzte Ankunft';

  @override
  String get busInfo => 'Bus-Info';

  @override
  String get departure => 'Abfahren';

  @override
  String get arrival => 'Ankommen';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get electricityBalance => 'Aktuelles Guthaben';

  @override
  String get electricityNoData => 'Keine Daten';

  @override
  String get electricityLowBalance => 'Niedriges Guthaben, bitte aufladen';

  @override
  String get electricitySufficient => 'Guthaben ausreichend';

  @override
  String get electricityAddTip =>
      'Tippen Sie oben rechts, um Stromdaten hinzuzufügen';

  @override
  String get electricityLoading => 'Verbrauchstrends werden aktualisiert';

  @override
  String get electricityLoadingSubtitle => 'Neueste Stromaufzeichnungen lesen';

  @override
  String get noUsageDetails => 'Keine Verbrauchsdetails';

  @override
  String get noUsageDetailsSubtitle =>
      'Stündliche Kosten erscheinen hier nach der Aktualisierung';

  @override
  String get electricityCost => 'Stromkosten';

  @override
  String lastNDays(int n) {
    return 'Letzte $n Tage';
  }

  @override
  String get totalCost => 'Gesamtkosten';

  @override
  String get todayCost => 'Heutige Kosten';

  @override
  String get avgDailyCost => 'Durchschnittliche Tageskosten';

  @override
  String get peakHours => 'Spitzenzeiten';

  @override
  String get hourlyDetails => 'Stündliche Details';

  @override
  String get lowBalanceSub => 'Warnung bei niedrigem Guthaben';

  @override
  String get lowBalanceSubDesc =>
      'Benachrichtigung bei niedrigem Guthaben erhalten';

  @override
  String get addElectricityFirst => 'Zuerst Stromseite hinzufügen';

  @override
  String get noElectricityData => 'Keine Stromdaten';

  @override
  String get noElectricityDataSubtitle =>
      'Binden Sie zuerst Ihre Wohnheim-Stromseite';

  @override
  String get lowBalanceEnabled => 'Warnung bei niedrigem Guthaben aktiviert';

  @override
  String get addLowBalanceAlert => 'Warnung bei niedrigem Guthaben hinzufügen';

  @override
  String get deleteSubscription => 'Abonnement löschen';

  @override
  String get deleteSubDesc =>
      'E-Mail-Warnung bei niedrigem Guthaben deaktivieren';

  @override
  String get electricityManagement => 'Stromverwaltung';

  @override
  String get chooseAction => 'Aktion wählen';

  @override
  String get changeRoom => 'Raum wechseln';

  @override
  String get getElectricity => 'Strom abrufen';

  @override
  String get electricityUrlPrompt =>
      'Öffnen Sie die Finanz-Stromseite der Universität, kopieren Sie die URL und fügen Sie sie unten ein';

  @override
  String get urlPlaceholder => 'URL eingeben';

  @override
  String get createLowBalanceAlert =>
      'Warnung bei niedrigem Guthaben erstellen';

  @override
  String get lowBalanceAlertDesc =>
      'Das System verwendet die gebundene Wohnheim-Stromseite, um E-Mail-Warnungen zu senden, wenn das Guthaben unter den Schwellenwert fällt.';

  @override
  String get remindEmail => 'Warn-E-Mail';

  @override
  String get remindEmailPlaceholder => 'Warn-E-Mail';

  @override
  String get remindThreshold => 'Schwellenwert, z.B. 10';

  @override
  String get remindThresholdPlaceholder => 'Schwellenwert, z.B. 10';

  @override
  String get pleaseEnterEmail => 'Bitte geben Sie eine E-Mail-Adresse ein';

  @override
  String get pleaseEnterValidEmail =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get pleaseEnterThreshold =>
      'Bitte geben Sie einen Schwellenwert größer als 0 ein';

  @override
  String get lowBalanceAlertCreated =>
      'Warnung bei niedrigem Guthaben erstellt';

  @override
  String get createSubFailed => 'Abonnement konnte nicht erstellt werden';

  @override
  String currentSubInfo(String email, String threshold) {
    return 'E-Mail $email wird gewarnt, wenn unter $threshold CNY';
  }

  @override
  String get subSetupHint =>
      'Nach Festlegung des Schwellenwerts erhalten Sie E-Mail-Warnungen bei niedrigem Guthaben';

  @override
  String get remindEmailLabel => 'Warn-E-Mail';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get remindThresholdLabel => 'Schwellenwert';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get noSubToDelete => 'Kein Abonnement zum Löschen';

  @override
  String get deleteSubTitle => 'Abonnement löschen';

  @override
  String get deleteSubConfirmContent =>
      'Möchten Sie das aktuelle Abonnement für niedriges Guthaben wirklich löschen?';

  @override
  String get lowBalanceAlertDeleted =>
      'Warnung bei niedrigem Guthaben gelöscht';

  @override
  String get deleteSubFailed => 'Abonnement konnte nicht gelöscht werden';

  @override
  String get electricitySubLoadFailed =>
      'Abonnement konnte nicht geladen werden';

  @override
  String get subscriptionDetail => 'Abonnementdetails';

  @override
  String get create => 'Erstellen';

  @override
  String get webNotSupported => 'Im Web nicht unterstützt';

  @override
  String get webNotSupportedSubtitle =>
      'Bitte verwenden Sie eine andere Version';

  @override
  String get reorderFailed => 'Neuordnung fehlgeschlagen';

  @override
  String get searchLocation => 'Orte oder Gebäude suchen...';

  @override
  String get search => 'Suchen...';

  @override
  String get buildingIntro => 'Gebäudeinfo';

  @override
  String get specificLocation => 'Ort';

  @override
  String get licenseTitle => 'Open-Source-Lizenzen';

  @override
  String get licenseLoading => 'Lizenzen werden geladen';

  @override
  String get licenseLoadingSubtitle =>
      'Open-Source-Lizenztexte der Anwendung werden geladen';

  @override
  String get licenseLoadFailed => 'Lizenzdatei konnte nicht geladen werden';

  @override
  String get helpFeaturesTab => 'Funktionen';

  @override
  String get helpInstructionsTab => 'Anleitung';

  @override
  String get helpNotesTab => 'Hinweise';

  @override
  String get helpAboutTab => 'Über';

  @override
  String get helpFeatureHome => 'Startseite';

  @override
  String get helpFeatureHomeDesc =>
      'Informationszentrum mit persönlichen Daten, Kursen, Aufgaben und Prüfungen';

  @override
  String get helpFeatureSchedule => 'Stundenplan';

  @override
  String get helpFeatureScheduleDesc =>
      'Wochenplan verwalten, Campus wechseln und Erinnerungen einstellen';

  @override
  String get helpFeatureScore => 'Noten';

  @override
  String get helpFeatureScoreDesc =>
      'Semesternoten, GPA-Berechnung und Analyse anzeigen';

  @override
  String get helpFeatureProfile => 'Profil';

  @override
  String get helpFeatureProfileDesc =>
      'Matrikelnummer, Name, Fakultät und andere Informationen anzeigen';

  @override
  String get helpFeatureBus => 'Campus-Bus';

  @override
  String get helpFeatureBusDesc =>
      'Busfahrpläne und Routen zwischen Campus anzeigen';

  @override
  String get helpFeatureProgram => 'Studienplan';

  @override
  String get helpFeatureProgramDesc =>
      'Studienplan und Leistungspunkt-Anforderungen anzeigen';

  @override
  String get helpFeatureElectricity => 'Strom';

  @override
  String get helpFeatureElectricityDesc =>
      'Stromverbrauch und Verlauf des Wohnheims anzeigen';

  @override
  String get helpFeaturePayment => 'Campus-Karte';

  @override
  String get helpFeaturePaymentDesc =>
      'Kartenguthaben und Transaktionsverlauf anzeigen';

  @override
  String get helpFeatureLinks => 'Nützliche Links';

  @override
  String get helpFeatureLinksDesc =>
      'Sammlung nützlicher Links für akademische Systeme';

  @override
  String get helpInstructionLogin => 'Anmeldung & Konto';

  @override
  String get helpInstructionLoginDesc =>
      'Bei erstmaliger Nutzung mit dem Hochschulkonto anmelden';

  @override
  String get helpInstructionCourse => 'Kursverwaltung';

  @override
  String get helpInstructionCourseDesc =>
      'Wochenkurse im Plan anzeigen, wischen zum Wechseln der Woche, antippen für Details';

  @override
  String get helpInstructionReminder => 'Kurserinnerungen';

  @override
  String get helpInstructionReminderDesc =>
      'Erinnerungen in den Einstellungen aktivieren, um vor Kursen benachrichtigt zu werden';

  @override
  String get helpInstructionSync => 'Datensynchronisation';

  @override
  String get helpInstructionSyncDesc =>
      'Die App synchronisiert automatisch. Zum Aktualisieren nach unten ziehen';

  @override
  String get helpInstructionWidget => 'Widgets';

  @override
  String get helpInstructionWidgetDesc =>
      'Startbildschirm lange drücken, um App-Widget hinzuzufügen';

  @override
  String get helpNoteUpdate =>
      'App aktuell halten für neueste Funktionen und Fehlerbehebungen';

  @override
  String get helpNoteData =>
      'Bei ungenauen Daten die Hochschulanmeldung überprüfen';

  @override
  String get helpNoteFeedback => 'Probleme über die Einstellungsseite melden';

  @override
  String get helpNotePrivacy =>
      'Diese App sammelt keine persönlichen Informationen';

  @override
  String get helpAboutPlatform => 'Plattform-Unterstützung';

  @override
  String get helpAboutPlatformDesc =>
      'Plattformübergreifende App, unterstützt:';

  @override
  String get helpAboutOpenSource => 'Open Source';

  @override
  String get helpAboutOpenSourceDesc =>
      'Diese App ist Open Source unter der MIT-Lizenz';

  @override
  String get helpAboutRepoLabel => 'Repository:';

  @override
  String get underMaintenanceTitle => 'Wartungsarbeiten!';

  @override
  String get underMaintenanceDescription =>
      'Wir führen derzeit planmäßige Wartungsarbeiten durch. Bitte versuchen Sie es später erneut. Vielen Dank für Ihre Geduld.';

  @override
  String get readingPaymentCard => 'Karteninfo wird geladen';

  @override
  String get lowBalance => 'Geringes Guthaben';

  @override
  String get campusCardBalance => 'Kartenguthaben';

  @override
  String get tapToView => 'Zum Anzeigen tippen';

  @override
  String get tapToSubscribe => 'Zum Abonnieren tippen';

  @override
  String get campusCaoTang => 'Caotang';

  @override
  String get campusYanTa => 'Yanta';

  @override
  String get busRefreshStale =>
      'Aktualisierung abgeschlossen, letzte Daten beibehalten';

  @override
  String arrivalStationTime(String h, String m) {
    return '${h}Std ${m}Min';
  }

  @override
  String get poiMainLibrary => 'Hauptbibliothek';

  @override
  String get poiMainLibraryDesc => '24-Stunden-Lernraum';

  @override
  String get poiCaoTangNorthGate => 'Caotang Nordtor';

  @override
  String get poiCaoTangNorthGateDesc => 'Haupteingang des Campus';

  @override
  String get poiYanTaEastGate => 'Yanta Osttor';

  @override
  String get poiYanTaEastGateDesc => 'Historischer Campus-Eingang';

  @override
  String get shortcuts => 'Verknüpfungen';

  @override
  String get moreFunctions => 'Weitere Funktionen';

  @override
  String get noShortcuts => 'Keine Verknüpfungen';

  @override
  String get addInEditMode => 'Im Bearbeitungsmodus hinzufügen';

  @override
  String get eduSystem => 'Bildungssystem';

  @override
  String get htmlImport => 'HTML-Import';

  @override
  String get pasteHtmlHint => 'Stundenplan-HTML hier einfügen';

  @override
  String get parseAndPreview => 'Parsen & Vorschau';

  @override
  String get importCourses => 'Kurse importieren';

  @override
  String get parseResult => 'Parse-Ergebnis';

  @override
  String get noCoursesParsed => 'Keine Kurse analysiert';

  @override
  String get searchSchool => 'Schule suchen...';

  @override
  String get basicSupport => 'Basis';

  @override
  String get advancedSupport => 'Erweitert';

  @override
  String get schoolNotSupported =>
      'Diese Funktion wird von der aktuellen Hochschule nicht unterstützt';

  @override
  String get switchSchool => 'Hochschule wechseln';

  @override
  String get selectSchool => 'Schule auswählen';

  @override
  String get enterCustomUrl => 'Oder eigene URL eingeben';

  @override
  String get urlHint => 'Website-URL eingeben';

  @override
  String get icp => 'ICP';
}
