// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Lumaris';

  @override
  String get appSlogan => 'Toute la vie étudiante dans une seule app';

  @override
  String get tagline => 'Dédié à offrir un meilleur service aux étudiants';

  @override
  String get home => 'Accueil';

  @override
  String get schedule => 'Emploi du temps';

  @override
  String get score => 'Notes';

  @override
  String get profile => 'Moi';

  @override
  String get electricity => 'Électricité';

  @override
  String get schoolBus => 'Bus';

  @override
  String get payment => 'Carte';

  @override
  String get map => 'Plan';

  @override
  String get settings => 'Paramètres';

  @override
  String get basicSettings => 'Général';

  @override
  String get version => 'Version';

  @override
  String get widgets => 'Widgets';

  @override
  String get about => 'À propos';

  @override
  String get other => 'Autre';

  @override
  String get feedback => '意见反馈';

  @override
  String get feedbackSubtitle => '提交问题或建议，帮助我们改进';

  @override
  String get feedbackContentLabel => '问题描述';

  @override
  String get feedbackContentHint => '请描述你遇到的问题';

  @override
  String get feedbackContentRequired => '请填写问题描述';

  @override
  String get feedbackContactLabel => '联系方式';

  @override
  String get feedbackContactHint => '手机号 / 邮箱 / QQ 等';

  @override
  String get feedbackContactRequired => '请填写联系方式';

  @override
  String get feedbackImagesLabel => '图片（选填，最多 6 张）';

  @override
  String get feedbackAddImage => '添加图片';

  @override
  String get feedbackSubmit => '提交';

  @override
  String get feedbackSubmitting => '提交中…';

  @override
  String get feedbackSubmitSuccess => '反馈已提交，感谢你的支持！';

  @override
  String get feedbackPickImageFailed => '选择图片失败，请重试';

  @override
  String get feedbackImageUploadFailed => '图片上传失败，请重试';

  @override
  String get feedbackImageTooMany => '最多上传 6 张图片';

  @override
  String get refreshData => 'Actualiser';

  @override
  String get refreshingData => 'Actualisation...';

  @override
  String get refreshDataSuccess => 'Données actualisées';

  @override
  String get refreshDataFailed => 'Échec de l\'actualisation';

  @override
  String get appearance => 'Apparence';

  @override
  String get followSystem => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get systemLanguage => 'Système';

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
  String get team => 'Équipe';

  @override
  String get teamName => 'Lumaris Team';

  @override
  String get openSourceLicense => 'Licence open source';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get privacyPolicy => 'Confidentialité';

  @override
  String get privacyPolicySubtitle =>
      'Découvrez comment nous protégeons votre vie privée';

  @override
  String get userAgreement => 'Conditions d\'utilisation';

  @override
  String get userAgreementSubtitle =>
      'En utilisant l\'app, vous acceptez ces conditions';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get clearingCache => 'Nettoyage du cache...';

  @override
  String get cacheCleared => 'Cache vidé';

  @override
  String get confirmClearCacheTitle => 'Vider le cache ?';

  @override
  String get confirmClearCacheContent =>
      'Toutes les données en cache seront supprimées et rechargées au prochain lancement';

  @override
  String get logoutEduSystem => 'Se déconnecter';

  @override
  String get confirmLogoutTitle => 'Se déconnecter ?';

  @override
  String get confirmLogoutContent =>
      'Vous devrez vous reconnecter pour accéder aux données académiques';

  @override
  String get logout => 'Déconnexion';

  @override
  String get agreementAuthDebug => 'État de l\'accord [Debug]';

  @override
  String get agreementAuthDebugSubtitle =>
      'Désactivez pour réafficher la page d\'accord au prochain lancement';

  @override
  String get addToDesktop => 'Ajouter à l\'écran d\'accueil';

  @override
  String get widgetSetupTitle => 'Ajouter un widget';

  @override
  String get widgetSetupIntro => 'Suivez ces étapes :';

  @override
  String get widgetSetupStep1 =>
      'Appuyez longuement sur une zone vide de l\'écran d\'accueil';

  @override
  String get widgetSetupStep2 => 'Appuyez sur Widgets';

  @override
  String get widgetSetupStep3 => 'Trouvez Lumaris et sélectionnez un widget';

  @override
  String get widgetSetupStep4 =>
      'Faites glisser le widget à l\'endroit souhaité';

  @override
  String get widgetSetupTip =>
      'Astuce : les widgets affichent les cours du jour';

  @override
  String get cancel => 'Annuler';

  @override
  String downloadingUpdateTitle(Object version) {
    return 'Téléchargement de la mise à jour $version';
  }

  @override
  String get downloadCompletedInstalling =>
      'Téléchargement terminé, installation en cours...';

  @override
  String downloadFailed(Object error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get back => 'Retour';

  @override
  String get collapseSidebar => 'Réduire';

  @override
  String get expandSidebar => 'Développer';

  @override
  String get notLoggedIn => 'Non connecté';

  @override
  String get academicSystem => 'Système académique';

  @override
  String get clickToLogin => 'Appuyez pour vous connecter';

  @override
  String get closeWindow => 'Fermer la fenêtre';

  @override
  String get closeWindowChoice => 'Choisissez une action';

  @override
  String get showWindow => 'Afficher la fenêtre';

  @override
  String get minimizeToTray => 'Réduire dans la barre';

  @override
  String get quitApp => 'Quitter';

  @override
  String get goToSettings => 'Paramètres';

  @override
  String get goAuthorize => 'Autoriser';

  @override
  String get permissionRequired => 'Permission requise';

  @override
  String get permissionRequiredContent =>
      'Cette fonction nécessite l\'autorisation correspondante';

  @override
  String get permissionDenied => 'Autorisation refusée';

  @override
  String get permissionDeniedContent =>
      'Cette autorisation a été définitivement refusée. Veuillez l\'activer dans les paramètres système';

  @override
  String get updateAvailable => 'Nouvelle version disponible !';

  @override
  String get ignoreThisUpdate => 'Ignorer';

  @override
  String get ignoreAllUpdates => 'Tout ignorer';

  @override
  String get goToBrowserUpdate => 'Ouvrir le navigateur';

  @override
  String get goToBrowser => 'Ouvrir le navigateur';

  @override
  String get dontUpdate => 'Plus tard';

  @override
  String confirmUpdateTitle(String version) {
    return 'Mettre à jour vers la dernière version : $version ?';
  }

  @override
  String get confirmUpdateContent =>
      'Une nouvelle version est disponible. Ouvrir le navigateur pour la télécharger ?';

  @override
  String get updateLog => 'Journal des mises à jour';

  @override
  String get ignoreVersionUpdate => 'Ignorer les mises à jour';

  @override
  String get updateOpened =>
      'Navigateur ouvert. Téléchargez et installez la mise à jour';

  @override
  String get openUpdateFailed => 'Impossible d\'ouvrir le lien de mise à jour';

  @override
  String get loginRequired => 'Connexion requise';

  @override
  String get pleaseLoginEduAccount =>
      'Connectez-vous d\'abord au système académique';

  @override
  String get loadFailedTapRetry =>
      'Échec du chargement. Appuyez pour réessayer';

  @override
  String get empty => 'Aucune donnée';

  @override
  String get loading => 'Chargement';

  @override
  String get syncingData => 'Synchronisation';

  @override
  String get syncingDataSubtitle =>
      'Peut prendre quelques secondes sur un réseau lent';

  @override
  String get creditOverview => 'Aperçu des crédits';

  @override
  String get completionRate => 'Complétion';

  @override
  String get itemizedCredits => 'Crédits par matière';

  @override
  String get courseConflict => 'Plusieurs cours se chevauchent à cette heure';

  @override
  String get notificationCourseChannelName => 'Rappels de cours';

  @override
  String get notificationCourseChannelDescription =>
      'Notifications pour votre emploi du temps quotidien';

  @override
  String notificationCourseAdvanceDescription(Object minutes) {
    return 'Notifications pour votre emploi du temps quotidien, envoyées $minutes minutes à l\'avance';
  }

  @override
  String get notificationTodoChannelName => 'Rappels de tâches';

  @override
  String get notificationTodoChannelDescription =>
      'Rappels d\'échéance pour les tâches';

  @override
  String get courseReminderTitle => 'Rappel de cours';

  @override
  String courseReminderStartsIn(Object minutes) {
    return 'commence dans $minutes minutes';
  }

  @override
  String get todoReminderTitle => 'Rappel de tâche';

  @override
  String todoReminderBody(Object title) {
    return 'Votre tâche $title arrive à échéance';
  }

  @override
  String get allowBackgroundRun => 'Autoriser l\'exécution en arrière-plan';

  @override
  String get allowBackgroundRunContent =>
      'Pour garantir que les rappels de cours sonnent à l\'heure, veuillez autoriser l\'application à s\'exécuter en arrière-plan et à ignorer l\'optimisation de la batterie.';

  @override
  String get allowScheduleAlarm => 'Autoriser les alarmes';

  @override
  String get allowScheduleAlarmContent =>
      'Vous devez autoriser les alarmes pour utiliser les notifications.';

  @override
  String get saveFailedRetry =>
      'Échec de l\'enregistrement, veuillez réessayer';

  @override
  String get toggleTileVisibilityFailed =>
      'Impossible de modifier la visibilité';

  @override
  String get resetFailed => 'Échec de la réinitialisation';

  @override
  String get networkError => 'Erreur réseau. Vérifiez votre connexion';

  @override
  String get requestTimeout =>
      'Délai d\'attente dépassé. Vérifiez votre connexion';

  @override
  String get serverError => 'Erreur serveur. Réessayez plus tard';

  @override
  String get unknownError => 'Erreur inconnue. Réessayez';

  @override
  String get agreementWelcomeTitle => 'Bienvenue dans Lumaris';

  @override
  String get agreementDescription =>
      'Avant d\'utiliser l\'application, veuillez lire et accepter les accords suivants.';

  @override
  String get agreementPrivacyDescription =>
      'Découvrez comment nous collectons, utilisons et protégeons vos informations';

  @override
  String get agreementUserDescription =>
      'Découvrez vos droits, obligations et les clauses de non-responsabilité';

  @override
  String get agreementReadTip =>
      'Appuyez sur les cartes ci-dessus pour voir le texte complet. En continuant, vous acceptez ces accords.';

  @override
  String get agreeAndContinue => 'Accepter et continuer';

  @override
  String get disagree => 'Refuser';

  @override
  String get loginAgreementPrefix => 'J\'ai lu et j\'accepte';

  @override
  String get loginAgreementRequired =>
      'Veuillez lire et accepter les Conditions d\'Utilisation et la Politique de Confidentialité';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité Lumaris';

  @override
  String get privacyPolicyUpdatedAt => 'Mise à jour : 5 mai 2026';

  @override
  String get privacyPolicyEffectiveAt => 'Entrée en vigueur : 5 mai 2026';

  @override
  String get privacyPolicyIntro =>
      'Bienvenue dans Lumaris. Cette politique explique comment nous collectons, utilisons, stockons et protégeons vos informations.';

  @override
  String get privacySection1Title => '1. Informations collectées';

  @override
  String get privacySection1_1 =>
      '1.1 Informations de compte : Pour vous connecter au système académique, votre identifiant et mot de passe sont requis. Ces données sont stockées uniquement sur votre appareil.';

  @override
  String get privacySection1_2 =>
      '1.2 Données de cours et notes : Après connexion, l\'application récupère votre emploi du temps, vos notes et votre parcours académique.';

  @override
  String get privacySection1_3 =>
      '1.3 Vie étudiante : L\'application peut récupérer votre solde d\'électricité, vos transactions de carte et votre utilisation réseau.';

  @override
  String get privacySection1_4 =>
      '1.4 Appareil : Modèle et version du système pour l\'analyse et le dépannage.';

  @override
  String get privacySection1_5 =>
      '1.5 Cache : Pour améliorer les performances, certaines données sont mises en cache localement. Vous pouvez les effacer dans les paramètres.';

  @override
  String get privacySection2Title => '2. Utilisation des informations';

  @override
  String get privacySection2_1 => '2.1 Fournir les services essentiels.';

  @override
  String get privacySection2_2 => '2.2 Améliorer la qualité du service.';

  @override
  String get privacySection2_3 =>
      '2.3 Prendre en charge les widgets d\'écran d\'accueil.';

  @override
  String get privacySection2_4 => '2.4 Planifier des notifications locales.';

  @override
  String get privacySection3Title => '3. Stockage et sécurité';

  @override
  String get privacySection3_1 =>
      '3.1 Vos informations sont stockées localement sur votre appareil.';

  @override
  String get privacySection3_2 =>
      '3.2 Les transmissions entre l\'application et les serveurs sont chiffrées.';

  @override
  String get privacySection3_3 =>
      '3.3 Vous pouvez vider le cache ou vous déconnecter à tout moment.';

  @override
  String get privacySection4Title => '4. Services tiers';

  @override
  String get privacySection4_1 =>
      '4.1 L\'application communique avec le système académique de l\'université.';

  @override
  String get privacySection4_2 =>
      '4.2 L\'application vérifie les mises à jour via Gitee.';

  @override
  String get privacySection4_3 =>
      '4.3 Nous ne vendons ni ne louons vos informations à des tiers.';

  @override
  String get privacySection5Title => '5. Vos droits';

  @override
  String get privacySection5_1 =>
      '5.1 Vous pouvez consulter et corriger vos informations dans l\'application.';

  @override
  String get privacySection5_2 =>
      '5.2 Vous pouvez supprimer vos données en vous déconnectant ou en désinstallant l\'application.';

  @override
  String get privacySection5_3 =>
      '5.3 Vous pouvez retirer votre consentement à tout moment.';

  @override
  String get privacySection6Title => '6. Mineurs';

  @override
  String get privacySection6_1 =>
      '6.1 Cette application est principalement destinée aux étudiants universitaires.';

  @override
  String get privacySection6_2 =>
      '6.2 Nous ne collectons pas activement d\'informations sur les mineurs.';

  @override
  String get privacySection7Title => '7. Mises à jour de la politique';

  @override
  String get privacySection7_1 =>
      '7.1 Cette politique peut être mise à jour occasionnellement.';

  @override
  String get privacySection7_2 =>
      '7.2 L\'utilisation continue signifie l\'acceptation de la politique mise à jour.';

  @override
  String get privacySection8Title => '8. Nous contacter';

  @override
  String get privacySection8_1 =>
      'Pour toute question ou suggestion, contactez-nous :';

  @override
  String get privacyContact =>
      'Équipe : Lumaris Team\nDépôt : https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get userAgreementTitle => 'Conditions d\'utilisation Lumaris';

  @override
  String get userAgreementUpdatedAt => 'Mise à jour : 5 mai 2026';

  @override
  String get userAgreementEffectiveAt => 'Entrée en vigueur : 5 mai 2026';

  @override
  String get userAgreementIntro =>
      'Bienvenue dans Lumaris. Veuillez lire attentivement ces conditions avant d\'utiliser l\'application.';

  @override
  String get userAgreementSection1Title => '1. Description du service';

  @override
  String get userAgreementSection1_1 =>
      '1.1 Cette application est un assistant de campus pour les étudiants.';

  @override
  String get userAgreementSection1_2 =>
      '1.2 Certaines fonctions nécessitent l\'accès au réseau universitaire.';

  @override
  String get userAgreementSection1_3 =>
      '1.3 Les données académiques sont fournies à titre indicatif seulement.';

  @override
  String get userAgreementSection2Title => '2. Compte et sécurité';

  @override
  String get userAgreementSection2_1 =>
      '2.1 Vous devez vous connecter avec votre compte du système académique.';

  @override
  String get userAgreementSection2_2 =>
      '2.2 Vos identifiants sont stockés uniquement sur votre appareil.';

  @override
  String get userAgreementSection2_3 =>
      '2.3 Changez immédiatement votre mot de passe en cas de risque.';

  @override
  String get userAgreementSection3Title => '3. Conduite de l\'utilisateur';

  @override
  String get userAgreementSection3_1 =>
      '3.1 Vous devez respecter les lois et règlements applicables.';

  @override
  String get userAgreementSection3_2 =>
      '3.2 Le code source est disponible sous licence MIT.';

  @override
  String get userAgreementSection3_3 =>
      '3.3 Vous ne devez pas perturber le fonctionnement normal de l\'application.';

  @override
  String get userAgreementSection3_4 =>
      '3.4 Vous ne devez pas exploiter les vulnérabilités pour un accès non autorisé.';

  @override
  String get userAgreementSection4Title => '4. Propriété intellectuelle';

  @override
  String get userAgreementSection4_1 =>
      '4.1 Le code source est publié sous licence MIT.';

  @override
  String get userAgreementSection4_2 =>
      '4.2 Le nom, l\'icône et le design de l\'interface appartiennent à Lumaris Team.';

  @override
  String get userAgreementSection4_3 =>
      '4.3 Les noms et logos de l\'université appartiennent à l\'université.';

  @override
  String get userAgreementSection5Title => '5. Avertissement';

  @override
  String get userAgreementSection5_1 =>
      '5.1 L\'application est fournie « en l\'état ».';

  @override
  String get userAgreementSection5_2 =>
      '5.2 Nous ne sommes pas responsables des interruptions dues au réseau ou aux serveurs.';

  @override
  String get userAgreementSection5_3 =>
      '5.3 Les informations académiques sont fournies à titre indicatif seulement.';

  @override
  String get userAgreementSection5_4 =>
      '5.4 Nous ne sommes pas responsables des dommages à l\'appareil ou des pertes de données, sauf obligation légale.';

  @override
  String get userAgreementSection6Title => '6. Modifications et résiliation';

  @override
  String get userAgreementSection6_1 =>
      '6.1 Ces conditions peuvent être modifiées occasionnellement.';

  @override
  String get userAgreementSection6_2 =>
      '6.2 L\'utilisation continue signifie l\'acceptation des conditions mises à jour.';

  @override
  String get userAgreementSection6_3 =>
      '6.3 Nous pouvons mettre fin au service si nécessaire.';

  @override
  String get userAgreementSection7Title => '7. Divers';

  @override
  String get userAgreementSection7_1 =>
      '7.1 Si une clause est invalide, les autres restent en vigueur.';

  @override
  String get userAgreementSection7_2 =>
      '7.2 Les présentes conditions sont régies par le droit de la RPC.';

  @override
  String get userAgreementSection7_3 =>
      '7.3 Les litiges sont résolus par négociation amiable.';

  @override
  String get userAgreementSection8Title => '8. Nous contacter';

  @override
  String get userAgreementSection8_1 =>
      'Pour toute question concernant ces conditions, contactez-nous :';

  @override
  String get userAgreementContact =>
      'Équipe : Lumaris Team\nDépôt : https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get aboutAuthor => 'À propos des auteurs';

  @override
  String get coreTeam => 'Équipe principale';

  @override
  String get specialThanks => 'Remerciements';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get thanksTitle => 'Merci';

  @override
  String get thanksContent =>
      'Merci à tous les développeurs et utilisateurs qui ont contribué au projet.';

  @override
  String get githubRepository => 'Dépôt GitHub';

  @override
  String get joinUs => 'Nous rejoindre';

  @override
  String get madeWithLove => 'Made with ❤️ in Xi\'an';

  @override
  String get easterEggTitle => '🎉 Easter Egg';

  @override
  String get easterEggFound =>
      'Félicitations ! Vous avez trouvé l\'easter egg caché !';

  @override
  String get easterEggContent =>
      'Vous êtes l\'une des rares personnes à connaître ce secret !\n\nMerci d\'aimer et de soutenir Lumaris.\n\nContinuez à explorer, d\'autres surprises vous attendent peut-être...';

  @override
  String get fontSetting => 'Paramètre de police';

  @override
  String get fontSettingSubtitle =>
      'Choisir une police pour le bureau (appliqué au prochain lancement)';

  @override
  String get systemDefault => 'Par défaut';

  @override
  String get customFont => 'Personnalisé';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get hapticFeedbackSubtitle =>
      'Vibrer au toucher de la navigation inférieure';

  @override
  String get cloudSyncTodo => 'Sauvegarder les tâches dans le cloud';

  @override
  String get servicePaused => 'Service suspendu';

  @override
  String get showTomorrowCourses => 'Afficher les cours de demain';

  @override
  String get showTomorrowCoursesSubtitle =>
      'Afficher les cours du lendemain quand il n\'y a pas de cours aujourd\'hui';

  @override
  String get courseReminder => 'Rappel de cours';

  @override
  String get courseReminderSubtitle => 'Rappeler avant le début du cours';

  @override
  String get remindMinutesBefore => 'Rappeler combien de minutes avant';

  @override
  String remindMinutes(int n) {
    return '$n minutes';
  }

  @override
  String get todoReminder => 'Rappel de tâches';

  @override
  String get todoReminderSubtitle => 'Rappeler avant l\'échéance des tâches';

  @override
  String get schedulePage => 'Emploi du temps';

  @override
  String get scorePage => 'Notes';

  @override
  String get profilePage => 'Profil';

  @override
  String get firstPageOnLaunch => 'Première page au lancement';

  @override
  String get sunday => 'dimanche';

  @override
  String get monday => 'lundi';

  @override
  String get tuesday => 'mardi';

  @override
  String get wednesday => 'mercredi';

  @override
  String get thursday => 'jeudi';

  @override
  String get friday => 'vendredi';

  @override
  String get saturday => 'samedi';

  @override
  String get sundayShort => 'Dim';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mer';

  @override
  String get thursdayShort => 'Jeu';

  @override
  String get fridayShort => 'Ven';

  @override
  String get saturdayShort => 'Sam';

  @override
  String get janShort => 'janv.';

  @override
  String get febShort => 'févr.';

  @override
  String get marShort => 'mars';

  @override
  String get aprShort => 'avr.';

  @override
  String get mayShort => 'mai';

  @override
  String get junShort => 'juin';

  @override
  String get julShort => 'juil.';

  @override
  String get augShort => 'août';

  @override
  String get sepShort => 'sept.';

  @override
  String get octShort => 'oct.';

  @override
  String get novShort => 'nov.';

  @override
  String get decShort => 'déc.';

  @override
  String weekUnit(int n) {
    return 'Semaine $n';
  }

  @override
  String currentWeek(int n) {
    return 'Semaine $n en cours';
  }

  @override
  String weeksUntilStart(int n) {
    return '$n semaine(s) avant la rentrée';
  }

  @override
  String periodRange(int start, int end) {
    return 'Période $start-$end';
  }

  @override
  String get allSchedules => 'Tous les cours';

  @override
  String get previousWeek => 'Semaine précédente';

  @override
  String get nextWeek => 'Semaine suivante';

  @override
  String get switchStyle => 'Changer le style';

  @override
  String get refreshSchedule => 'Actualiser les cours';

  @override
  String get scheduleSettingsTitle => 'Paramètres de l\'emploi du temps';

  @override
  String get compact => 'Compact';

  @override
  String get standard => 'Standard';

  @override
  String get relaxed => 'Relaxé';

  @override
  String get selectCourse => 'Sélectionner un cours';

  @override
  String get editCourse => 'Modifier le cours';

  @override
  String get deleteCourse => 'Supprimer le cours';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String confirmDeleteCourseContent(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get courseModified => 'Cours mis à jour';

  @override
  String get courseDeleted => 'Cours supprimé';

  @override
  String get deleteFailed => 'Échec de la suppression';

  @override
  String get noLocation => 'Aucun emplacement';

  @override
  String get addCourse => 'Ajouter un cours';

  @override
  String get save => 'Enregistrer';

  @override
  String get courseName => 'Nom du cours';

  @override
  String get courseRoom => 'Salle';

  @override
  String get courseTeacher => 'Professeur';

  @override
  String get courseCredits => 'Crédits';

  @override
  String get courseWeekday => 'Jour de la semaine';

  @override
  String get courseStartUnit => 'Période de début';

  @override
  String get courseEndUnit => 'Période de fin';

  @override
  String get courseWeeks => 'Semaines';

  @override
  String selectedWeeks(int count) {
    return '$count semaine(s) sélectionnée(s)';
  }

  @override
  String get customCourses => 'Cours personnalisés';

  @override
  String customCoursesCount(int count) {
    return '$count cours';
  }

  @override
  String get noCustomCourses => 'Aucun cours personnalisé';

  @override
  String get noCustomCoursesSubtitle => 'Appuyez sur + pour ajouter un cours';

  @override
  String get readingCustomCourses => 'Lecture des cours personnalisés';

  @override
  String get readingCustomCoursesSubtitle =>
      'Organisation des cours sauvegardés localement';

  @override
  String get courseAdded => 'Cours ajouté';

  @override
  String get scoresAndGpa => 'Notes et GPA';

  @override
  String get passedCourses => 'Validés';

  @override
  String get totalCredits => 'Total des crédits';

  @override
  String get creditInfoTitle => 'Remarque';

  @override
  String get creditInfoContent =>
      'Les crédits sont calculés sur la base des cours validés. Le système officiel peut afficher un nombre différent.';

  @override
  String get noScores => 'Aucune note';

  @override
  String get noScoresSubtitle => 'Essayez d\'actualiser ou de revenir';

  @override
  String get refreshDataBtn => 'Actualiser';

  @override
  String get goToLogin => 'Se connecter';

  @override
  String get minorCourse => 'Cours secondaire';

  @override
  String get scoreDetail => 'Détails des notes';

  @override
  String get courseCreditLabel => 'Crédits du cours';

  @override
  String get courseScoreLabel => 'Note du cours';

  @override
  String get courseGpaLabel => 'GPA du cours';

  @override
  String get fetchingScores => 'Récupération des notes...';

  @override
  String get refreshFailedFallback =>
      'Échec de l\'actualisation, affichage des données locales';

  @override
  String get fetchTimeout => 'Délai dépassé. Vérifiez votre réseau.';

  @override
  String get fetchFailed => 'Échec de la récupération des données';

  @override
  String get pleaseLoginFirst => 'Connectez-vous pour voir les notes';

  @override
  String get readingScoresSubtitle =>
      'Lecture du cache et synchronisation des notes';

  @override
  String get foolishModeMessage => 'Oui, j\'ai un GPA de 5.0';

  @override
  String creditUnit(String credit) {
    return '$credit crédits';
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
      String weekRanges, String weekday, int start, int end) {
    return 'Semaine $weekRanges chaque $weekday Période $start-$end';
  }

  @override
  String semesterRange(String start, String end, String num) {
    return '$start-$end Semestre $num';
  }

  @override
  String get semesterAutumnShort => 'Automne';

  @override
  String get semesterSpringShort => 'Printemps';

  @override
  String get year1 => '1re année';

  @override
  String get year2 => '2e année';

  @override
  String get year3 => '3e année';

  @override
  String get year4 => '4e année';

  @override
  String get year5 => '5e année';

  @override
  String get year6 => '6e année';

  @override
  String get year7 => '7e année';

  @override
  String get year8 => '8e année';

  @override
  String get year9 => '9e année';

  @override
  String get year10 => '10e année';

  @override
  String get loginTitle => 'Connexion au système académique';

  @override
  String get loginSubtitle => 'Veuillez utiliser votre compte';

  @override
  String get studentId => 'Identifiant étudiant';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String get loggingInSubtitle =>
      'Vérification et synchronisation des cours, notes et autres données';

  @override
  String get emptyCredentials =>
      'L\'identifiant et le mot de passe sont requis';

  @override
  String get loginTimeoutEdu =>
      'Délai de connexion dépassé, vérifiez votre réseau';

  @override
  String get loginFailed => 'Échec de connexion, vérifiez vos identifiants';

  @override
  String get loginTimeout =>
      'Connexion expirée. Vérifiez votre réseau et réessayez.';

  @override
  String get loginSecurityStorageUnavailable =>
      'Connexion réussie, mais le stockage sécurisé est indisponible.';

  @override
  String get loadingDefaultTitle => 'Synchronisation';

  @override
  String get loadingDefaultSubtitle =>
      'Peut prendre quelques secondes sur un réseau lent';

  @override
  String get errorOccurred => 'Une erreur est survenue';

  @override
  String get retry => 'Réessayer';

  @override
  String get loadFailed => 'Échec du chargement';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get ok => 'OK';

  @override
  String get classroom => 'Salle';

  @override
  String get teacherLabel => 'Professeur';

  @override
  String get classTime => 'Horaire';

  @override
  String get classCampus => 'Campus';

  @override
  String get todayScheduleLabel => 'Emploi du temps du jour';

  @override
  String get tomorrowSchedule => 'Emploi du temps de demain';

  @override
  String get noCourseToday => 'Pas de cours aujourd\'hui';

  @override
  String get noCourseTodaySubtitle => 'Reposez-vous, vous le méritez';

  @override
  String get showTomorrowSchedule => 'Afficher les cours de demain';

  @override
  String get doubleTapExit => 'Appuyez à nouveau pour quitter';

  @override
  String copySuccess(String text) {
    return 'Copié : $text';
  }

  @override
  String get copyTooltip => 'Copier';

  @override
  String get pageSettings => 'Paramètres des pages';

  @override
  String get showBusTile => 'Afficher le widget Bus';

  @override
  String get showBusTileSubtitle => 'Afficher les infos de bus sur l\'accueil';

  @override
  String get addToHome => 'Ajouter à l\'accueil';

  @override
  String get showElectricityTile => 'Afficher le widget Électricité';

  @override
  String get electricityRecharge => 'Recharger';

  @override
  String get electricityRechargeSubtitle =>
      'Ouvrir WeChat pour recharger l\'électricité';

  @override
  String get showPaymentTile => 'Afficher le widget Carte';

  @override
  String get showPaymentTileSubtitle =>
      'Afficher l\'aperçu du solde sur l\'accueil';

  @override
  String get addTodo => 'Ajouter une tâche';

  @override
  String get todoTitle => 'Titre';

  @override
  String get deadline => 'Date limite';

  @override
  String get change => 'Modifier';

  @override
  String get edit => 'Modifier';

  @override
  String get done => 'Terminé';

  @override
  String get todoListLabel => 'Liste de tâches';

  @override
  String get readingTodos => 'Lecture des tâches';

  @override
  String get readingTodosSubtitle =>
      'Chargement de la liste locale et des rappels';

  @override
  String get noTodos => 'Aucune tâche';

  @override
  String get noTodosSubtitle => 'Appuyez sur + pour ajouter une tâche';

  @override
  String get todoLoadFailedSubtitle => 'Impossible de charger les tâches';

  @override
  String deadlineLabel(String date) {
    return 'Date limite : $date';
  }

  @override
  String get noDeadline => 'Aucune';

  @override
  String get titleRequired => 'Le titre est requis';

  @override
  String get deadlineRequired => 'La date limite est requise';

  @override
  String get add => 'Ajouter';

  @override
  String get upcomingExams => 'Examens à venir';

  @override
  String get loadingExams => 'Chargement des examens';

  @override
  String get loadingExamsSubtitle =>
      'Synchronisation des examens, salles et places';

  @override
  String get noExams => 'Aucun examen à venir';

  @override
  String get noExamsSubtitle => 'Réactualisez pour voir';

  @override
  String get examTime => 'Horaire';

  @override
  String get examLocation => 'Lieu';

  @override
  String get seatNumber => 'Place n°';

  @override
  String seatNumberLabel(String seat) {
    return 'Place n° $seat';
  }

  @override
  String get examNotLoggedIn => 'Veuillez vous connecter d\'abord';

  @override
  String get examAuthFailed =>
      'Échec d\'authentification, veuillez vous reconnecter';

  @override
  String get examFetchFailed =>
      'Échec de récupération des examens, appuyez pour réessayer';

  @override
  String get quickFeatures => 'Fonctions rapides';

  @override
  String get noQuickFeatures => 'Aucune fonction rapide';

  @override
  String get noQuickFeaturesSubtitle => 'Ajoutez-en en mode édition';

  @override
  String get moreFeatures => 'Plus de fonctions';

  @override
  String get scheduleWidgetTitle => 'Importer dans le calendrier';

  @override
  String get subscriptionLink => 'Lien d\'abonnement';

  @override
  String get copiedSuccess => 'Copié !';

  @override
  String get howToImport => 'Comment importer ?';

  @override
  String get customCourseManage => 'Gestion des cours personnalisés';

  @override
  String get showCourseGrid => 'Afficher la grille';

  @override
  String get noBackground => 'Aucun arrière-plan';

  @override
  String get customImage => 'Image personnalisée';

  @override
  String get noImageSelected => 'Aucune image sélectionnée';

  @override
  String get noCalendarApp =>
      'Aucune application de calendrier trouvée, veuillez importer manuellement';

  @override
  String get cannotOpenCalendar => 'Impossible d\'ouvrir le calendrier';

  @override
  String get bgImageSetSuccess => 'Image d\'arrière-plan définie';

  @override
  String get selectImageFailed => 'Échec de la sélection d\'image';

  @override
  String get addCalendarSub => 'Ajouter un abonnement calendrier';

  @override
  String get understand => 'Compris';

  @override
  String get calendarSubscription => 'Abonnement calendrier';

  @override
  String get scheduleManagement => 'Gestion des cours';

  @override
  String get scheduleBackground => 'Arrière-plan de l\'emploi du temps';

  @override
  String get ignoreCourses => 'Ignorer les cours';

  @override
  String get loadingSchedule => 'Chargement de l\'emploi du temps';

  @override
  String get loadingScheduleSubtitle =>
      'Lecture des cours, préférences et arrière-plan';

  @override
  String get updatingSchedule => 'Mise à jour de l\'emploi du temps...';

  @override
  String get updateComplete => 'Mise à jour terminée';

  @override
  String get updateTimeout => 'Mise à jour expirée. Vérifiez votre réseau.';

  @override
  String updateFailed(String error) {
    return 'Échec de la mise à jour : $error';
  }

  @override
  String get linkCopiedToClipboard => 'Lien copié';

  @override
  String get currentWeekLabel => 'Cette semaine';

  @override
  String periodUnit(int n) {
    return 'Période $n';
  }

  @override
  String get calendarGuidanceIntro =>
      'Aucune application trouvée pour les abonnements calendrier. Ajoutez manuellement :';

  @override
  String get calendarGuidanceStep1 => '1. Ouvrez votre application calendrier';

  @override
  String get calendarGuidanceStep2 =>
      '2. Trouvez « Ajouter un calendrier » ou « S\'abonner »';

  @override
  String get calendarGuidanceStep3 => '3. Sélectionnez « Ajouter par URL »';

  @override
  String get calendarGuidanceStep4 => '4. Collez le lien suivant :';

  @override
  String get calendarGuidanceNote =>
      'Note : les étapes varient selon l\'application. Consultez l\'aide de votre calendrier.';

  @override
  String get profileReading => 'Lecture du compte';

  @override
  String get profileReadingSubtitle =>
      'Synchronisation du statut de connexion et des données du profil';

  @override
  String get campusNavigation => 'Boîte à outils du campus';

  @override
  String get settingsAbout => 'Paramètres / À propos';

  @override
  String get programLabel => 'Programme';

  @override
  String get campusMap => 'Plan du campus';

  @override
  String get help => 'Aide';

  @override
  String get academicAccount => 'Compte académique';

  @override
  String get guest => 'Invité';

  @override
  String get guestMode => 'Mode invité';

  @override
  String get guestModeSubtitle =>
      'Connectez-vous pour accéder à toutes les fonctionnalités';

  @override
  String get syncingAcademic => 'Synchronisation académique';

  @override
  String get syncingAcademicSubtitle =>
      'Lecture des crédits et des fiches de profil';

  @override
  String get loginEduSystem => 'Connexion au système académique';

  @override
  String get programLoading => 'Chargement du programme';

  @override
  String get programLoadingSubtitle =>
      'Organisation de la structure des cours par semestre';

  @override
  String get programLoadFailed => 'Échec du chargement';

  @override
  String get programNoData => 'Aucune donnée';

  @override
  String get programRefreshFailed =>
      'Échec de l\'actualisation, affichage du dernier programme synchronisé';

  @override
  String get linkLoading => 'Chargement des liens de navigation';

  @override
  String get linkLoadingSubtitle => 'Organisation des sites et catégories';

  @override
  String get linkLoadFailed => 'Échec du chargement';

  @override
  String get linkNoData => 'Aucun lien de navigation';

  @override
  String get linkNoDataSubtitle =>
      'Réessayez d\'accéder à cette page ou vérifiez votre réseau';

  @override
  String get paymentLoading => 'Synchronisation du solde de la carte';

  @override
  String get paymentLoadingSubtitle =>
      'Récupération des dernières transactions';

  @override
  String get paymentPasswordTitle => 'Mot de passe de la carte';

  @override
  String get paymentPasswordSubtitle =>
      'Facultatif. Laissez vide pour la recherche par défaut.';

  @override
  String get paymentSaveAndRefresh => 'Enregistrer et actualiser';

  @override
  String get campusCard => 'Carte du campus';

  @override
  String get currentBalance => 'Solde actuel';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get paymentFilter => 'Paiements';

  @override
  String get consumptionFilter => 'Consommations';

  @override
  String get rechargeFilter => 'Recharges';

  @override
  String get noCardData => 'Aucune donnée de carte';

  @override
  String get noCardDataSubtitle =>
      'Connectez-vous pour voir le solde et les transactions';

  @override
  String get busLoading => 'Récupération des horaires de bus';

  @override
  String get busLoadingSubtitle => 'Organisation par campus et date';

  @override
  String get noBusToday => 'Pas de bus aujourd\'hui';

  @override
  String get noBusTodaySubtitle => 'Revenez demain';

  @override
  String get departureTime => 'Départ';

  @override
  String get destination => 'Destination';

  @override
  String get estimatedArrival => 'Arrivée est.';

  @override
  String get busInfo => 'Infos bus';

  @override
  String get departure => 'Départ';

  @override
  String get arrival => 'Arrivée';

  @override
  String get netRefreshFailed =>
      'Échec de l\'actualisation, affichage des données actuelles';

  @override
  String get netData => 'Données réseau';

  @override
  String get usedTraffic => 'Trafic utilisé';

  @override
  String onlineDuration(String time) {
    return 'En ligne : $time';
  }

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get ipAddress => 'Adresse IP';

  @override
  String get productPackage => 'Forfait';

  @override
  String get unknown => 'Inconnu';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get netLoading => 'Lecture des données réseau';

  @override
  String get netLoadingSubtitle =>
      'Synchronisation du trafic, temps en ligne et infos du compte';

  @override
  String get netLoadFailed => 'Échec du chargement';

  @override
  String get netNoData => 'Aucune donnée';

  @override
  String get electricityBalance => 'Solde actuel';

  @override
  String get electricityNoData => 'Aucune donnée';

  @override
  String get electricityLowBalance => 'Solde faible, veuillez recharger';

  @override
  String get electricitySufficient => 'Solde suffisant';

  @override
  String get electricityAddTip =>
      'Appuyez en haut à droite pour ajouter des données d\'électricité';

  @override
  String get electricityLoading =>
      'Actualisation des tendances de consommation';

  @override
  String get electricityLoadingSubtitle =>
      'Lecture des derniers relevés d\'électricité';

  @override
  String get noUsageDetails => 'Aucun détail de consommation';

  @override
  String get noUsageDetailsSubtitle =>
      'Le coût horaire apparaîtra ici après actualisation';

  @override
  String get electricityCost => 'Coût de l\'électricité';

  @override
  String lastNDays(int n) {
    return 'Derniers $n jours';
  }

  @override
  String get totalCost => 'Coût total';

  @override
  String get todayCost => 'Coût du jour';

  @override
  String get avgDailyCost => 'Coût moyen/jour';

  @override
  String get peakHours => 'Heures de pointe';

  @override
  String get hourlyDetails => 'Détails horaires';

  @override
  String get lowBalanceSub => 'Alerte solde faible';

  @override
  String get lowBalanceSubDesc =>
      'Recevoir une notification lorsque le solde est bas';

  @override
  String get addElectricityFirst => 'Ajoutez d\'abord une page électricité';

  @override
  String get noElectricityData => 'Aucune donnée d\'électricité';

  @override
  String get noElectricityDataSubtitle =>
      'Liez d\'abord la page électricité de votre résidence';

  @override
  String get lowBalanceEnabled => 'Alerte solde faible activée';

  @override
  String get addLowBalanceAlert => 'Ajouter une alerte solde faible';

  @override
  String get deleteSubscription => 'Supprimer l\'abonnement';

  @override
  String get deleteSubDesc => 'Annuler l\'alerte par email pour solde faible';

  @override
  String get electricityManagement => 'Gestion de l\'électricité';

  @override
  String get chooseAction => 'Choisir une action';

  @override
  String get changeRoom => 'Changer de chambre';

  @override
  String get getElectricity => 'Obtenir l\'électricité';

  @override
  String get electricityUrlPrompt =>
      'Ouvrez la page électricité de l\'université, copiez l\'URL et collez-la ci-dessous';

  @override
  String get urlPlaceholder => 'Saisir l\'URL';

  @override
  String get createLowBalanceAlert => 'Créer une alerte solde faible';

  @override
  String get lowBalanceAlertDesc =>
      'Le système utilisera la page électricité liée pour envoyer des alertes par email lorsque le solde passe sous le seuil.';

  @override
  String get remindEmail => 'Email d\'alerte';

  @override
  String get remindEmailPlaceholder => 'Email d\'alerte';

  @override
  String get remindThreshold => 'Seuil (ex. 10)';

  @override
  String get remindThresholdPlaceholder => 'Seuil (ex. 10)';

  @override
  String get pleaseEnterEmail => 'Veuillez saisir un email';

  @override
  String get pleaseEnterValidEmail => 'Veuillez saisir un email valide';

  @override
  String get pleaseEnterThreshold => 'Veuillez saisir un seuil supérieur à 0';

  @override
  String get lowBalanceAlertCreated => 'Alerte solde faible créée';

  @override
  String get createSubFailed => 'Échec de la création de l\'abonnement';

  @override
  String currentSubInfo(String email, String threshold) {
    return 'Email $email alerté lorsque solde < ¥$threshold';
  }

  @override
  String get subSetupHint =>
      'Après configuration du seuil, vous recevrez des alertes par email lorsque le solde est bas';

  @override
  String get remindEmailLabel => 'Email d\'alerte';

  @override
  String get notSet => 'Non défini';

  @override
  String get remindThresholdLabel => 'Seuil';

  @override
  String get gotIt => 'Compris';

  @override
  String get noSubToDelete => 'Aucun abonnement à supprimer';

  @override
  String get deleteSubTitle => 'Supprimer l\'abonnement';

  @override
  String get deleteSubConfirmContent =>
      'Êtes-vous sûr de vouloir supprimer l\'abonnement de solde faible actuel ?';

  @override
  String get lowBalanceAlertDeleted => 'Alerte solde faible supprimée';

  @override
  String get deleteSubFailed => 'Échec de la suppression de l\'abonnement';

  @override
  String get electricitySubLoadFailed => 'Échec du chargement de l\'abonnement';

  @override
  String get subscriptionDetail => 'Détail de l\'abonnement';

  @override
  String get create => 'Créer';

  @override
  String get webNotSupported => 'Non pris en charge sur le Web';

  @override
  String get webNotSupportedSubtitle => 'Veuillez utiliser une autre version';

  @override
  String get reorderFailed => 'Échec de la réorganisation';

  @override
  String get searchLocation => 'Rechercher des lieux ou bâtiments...';

  @override
  String get search => 'Rechercher...';

  @override
  String get buildingIntro => 'Infos bâtiment';

  @override
  String get specificLocation => 'Emplacement';

  @override
  String get licenseTitle => 'Licences open source';

  @override
  String get licenseLoading => 'Chargement des licences';

  @override
  String get licenseLoadingSubtitle =>
      'Chargement des textes de licence open source';

  @override
  String get licenseLoadFailed => 'Échec du chargement du fichier de licence';

  @override
  String get helpFeaturesTab => 'Fonctionnalités';

  @override
  String get helpInstructionsTab => 'Instructions';

  @override
  String get helpNotesTab => 'Remarques';

  @override
  String get helpAboutTab => 'À propos';

  @override
  String get helpFeatureHome => 'Accueil';

  @override
  String get helpFeatureHomeDesc =>
      'Centre d\'information avec données personnelles, cours, tâches et examens';

  @override
  String get helpFeatureSchedule => 'Emploi du temps';

  @override
  String get helpFeatureScheduleDesc =>
      'Gérer l\'emploi du temps hebdomadaire avec changement de campus et rappels';

  @override
  String get helpFeatureScore => 'Notes';

  @override
  String get helpFeatureScoreDesc =>
      'Voir les relevés de notes, calcul de moyenne et analyse';

  @override
  String get helpFeatureProfile => 'Profil';

  @override
  String get helpFeatureProfileDesc =>
      'Afficher le numéro d\'étudiant, nom, faculté et autres informations';

  @override
  String get helpFeatureBus => 'Bus du campus';

  @override
  String get helpFeatureBusDesc =>
      'Voir les horaires et itinéraires des bus inter-campus';

  @override
  String get helpFeatureProgram => 'Programme';

  @override
  String get helpFeatureProgramDesc =>
      'Afficher le plan d\'études et les exigences de crédits';

  @override
  String get helpFeatureElectricity => 'Électricité';

  @override
  String get helpFeatureElectricityDesc =>
      'Voir la consommation et l\'historique électrique du dortoir';

  @override
  String get helpFeaturePayment => 'Carte de campus';

  @override
  String get helpFeaturePaymentDesc =>
      'Voir le solde et l\'historique des transactions';

  @override
  String get helpFeatureNet => 'Réseau du campus';

  @override
  String get helpFeatureNetDesc =>
      'Voir l\'utilisation et les statistiques du réseau';

  @override
  String get helpFeatureLinks => 'Liens utiles';

  @override
  String get helpFeatureLinksDesc =>
      'Collection de liens utiles pour les systèmes académiques';

  @override
  String get helpInstructionLogin => 'Connexion et compte';

  @override
  String get helpInstructionLoginDesc =>
      'Connectez-vous avec votre compte académique lors de la première utilisation';

  @override
  String get helpInstructionCourse => 'Gestion des cours';

  @override
  String get helpInstructionCourseDesc =>
      'Voir les cours dans l\'emploi du temps, glisser pour changer de semaine, appuyer pour les détails';

  @override
  String get helpInstructionReminder => 'Rappels de cours';

  @override
  String get helpInstructionReminderDesc =>
      'Activez les rappels dans les paramètres pour être notifié avant le cours';

  @override
  String get helpInstructionSync => 'Synchronisation';

  @override
  String get helpInstructionSyncDesc =>
      'L\'application se synchronise automatiquement. Tirez vers le bas pour actualiser manuellement';

  @override
  String get helpInstructionWidget => 'Widgets';

  @override
  String get helpInstructionWidgetDesc =>
      'Appuyez longuement sur l\'écran d\'accueil pour ajouter un widget';

  @override
  String get helpNoteNetwork =>
      'Certaines fonctions nécessitent le réseau du campus';

  @override
  String get helpNoteUpdate =>
      'Gardez l\'application à jour pour les dernières fonctionnalités';

  @override
  String get helpNoteData =>
      'Si les données sont inexactes, vérifiez votre connexion académique';

  @override
  String get helpNoteFeedback =>
      'Signalez les problèmes via la page des paramètres';

  @override
  String get helpNotePrivacy =>
      'Cette application ne collecte pas vos informations personnelles';

  @override
  String get helpAboutPlatform => 'Plateformes';

  @override
  String get helpAboutPlatformDesc =>
      'Application multiplateforme, prenant en charge :';

  @override
  String get helpAboutOpenSource => 'Open Source';

  @override
  String get helpAboutOpenSourceDesc =>
      'Cette application est open source sous licence MIT';

  @override
  String get helpAboutRepoLabel => 'Dépôt :';

  @override
  String get underMaintenanceTitle => 'Maintenance en cours !';

  @override
  String get underMaintenanceDescription =>
      'Nous effectuons actuellement une maintenance programmée. Veuillez revenir plus tard. Merci de votre patience.';

  @override
  String get readingPaymentCard => 'Chargement de la carte';

  @override
  String get lowBalance => 'Solde faible';

  @override
  String get campusCardBalance => 'Solde de la carte';

  @override
  String get tapToView => 'Appuyez pour voir';

  @override
  String get tapToSubscribe => 'Appuyez pour vous abonner';

  @override
  String get campusCaoTang => 'Caotang';

  @override
  String get campusYanTa => 'Yanta';

  @override
  String get busRefreshStale => 'Actualisation terminée, données conservées';

  @override
  String arrivalStationTime(String h, String m) {
    return '${h}h ${m}min';
  }

  @override
  String get poiMainLibrary => 'Bibliothèque principale';

  @override
  String get poiMainLibraryDesc => 'Salle d\'étude ouverte 24h/24';

  @override
  String get poiCaoTangNorthGate => 'Porte nord de Caotang';

  @override
  String get poiCaoTangNorthGateDesc => 'Entrée principale du campus';

  @override
  String get poiYanTaEastGate => 'Porte est de Yanta';

  @override
  String get poiYanTaEastGateDesc => 'Entrée du campus historique';

  @override
  String durationDHMS(String d, String h, String m, String s) {
    return '${d}j ${h}h ${m}min ${s}s';
  }

  @override
  String get shortcuts => 'Raccourcis';

  @override
  String get moreFunctions => 'Plus de fonctions';

  @override
  String get noShortcuts => 'Aucun raccourci';

  @override
  String get addInEditMode => 'Ajouter en mode édition';

  @override
  String get eduSystem => 'Système éducatif';

  @override
  String get htmlImport => 'Import HTML';

  @override
  String get pasteHtmlHint => 'Collez le HTML de l\'emploi du temps ici';

  @override
  String get parseAndPreview => 'Analyser & Aperçu';

  @override
  String get importCourses => 'Importer les cours';

  @override
  String get parseResult => 'Résultat de l\'analyse';

  @override
  String get noCoursesParsed => 'Aucun cours analysé';

  @override
  String get searchSchool => 'Rechercher un établissement...';

  @override
  String get basicSupport => 'Basique';

  @override
  String get advancedSupport => 'Avancé';

  @override
  String get schoolNotSupported =>
      'Cette fonctionnalité n\'est pas prise en charge par l\'établissement actuel';

  @override
  String get switchSchool => 'Changer d\'établissement';

  @override
  String get selectSchool => 'Sélectionner l\'école';

  @override
  String get enterCustomUrl => 'Ou entrer une URL personnalisée';

  @override
  String get urlHint => 'Entrer l\'URL du site web';

  @override
  String get icp => 'ICP';
}
