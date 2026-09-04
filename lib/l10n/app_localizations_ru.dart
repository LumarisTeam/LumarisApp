// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Lumaris';

  @override
  String get appSlogan => 'Вся студенческая жизнь в одном приложении';

  @override
  String get tagline => 'Стремясь предоставить лучший сервис студентам';

  @override
  String get home => 'Главная';

  @override
  String get schedule => 'Расписание';

  @override
  String get score => 'Оценки';

  @override
  String get profile => 'Профиль';

  @override
  String get electricity => 'Электричество';

  @override
  String get schoolBus => 'Автобус';

  @override
  String get payment => 'Карта';

  @override
  String get map => 'Схема';

  @override
  String get settings => 'Настройки';

  @override
  String get basicSettings => 'Основные';

  @override
  String get version => 'Версия';

  @override
  String get widgets => 'Виджеты';

  @override
  String get about => 'О приложении';

  @override
  String get other => 'Прочее';

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
  String get refreshData => 'Обновить';

  @override
  String get refreshingData => 'Обновление данных...';

  @override
  String get refreshDataSuccess => 'Данные обновлены';

  @override
  String get refreshDataFailed => 'Не удалось обновить данные';

  @override
  String get appearance => 'Оформление';

  @override
  String get followSystem => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get systemLanguage => 'Системный';

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
  String get team => 'Команда';

  @override
  String get teamName => 'Lumaris Team';

  @override
  String get openSourceLicense => 'Лицензия';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get privacyPolicy => 'Конфиденциальность';

  @override
  String get privacyPolicySubtitle =>
      'Узнайте, как мы защищаем вашу конфиденциальность';

  @override
  String get userAgreement => 'Соглашение';

  @override
  String get userAgreementSubtitle =>
      'Используя приложение, вы соглашаетесь с соглашением';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearingCache => 'Очистка кэша...';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get confirmClearCacheTitle => 'Очистить кэш?';

  @override
  String get confirmClearCacheContent =>
      'Все кэшированные данные будут удалены и загружены заново при следующем запуске';

  @override
  String get logoutEduSystem => 'Выйти из системы';

  @override
  String get confirmLogoutTitle => 'Выйти?';

  @override
  String get confirmLogoutContent =>
      'Для доступа к данным потребуется повторный вход';

  @override
  String get logout => 'Выйти';

  @override
  String get agreementAuthDebug => 'Статус соглашения [Debug]';

  @override
  String get agreementAuthDebugSubtitle =>
      'Отключите, чтобы показать страницу соглашения при следующем запуске';

  @override
  String get addToDesktop => 'На рабочий стол';

  @override
  String get widgetSetupTitle => 'Добавить виджет';

  @override
  String get widgetSetupIntro => 'Следуйте инструкциям:';

  @override
  String get widgetSetupStep1 =>
      'Нажмите и удерживайте пустое место на рабочем столе';

  @override
  String get widgetSetupStep2 => 'Нажмите «Виджеты»';

  @override
  String get widgetSetupStep3 => 'Найдите Lumaris и выберите виджет';

  @override
  String get widgetSetupStep4 => 'Перетащите виджет в нужное место';

  @override
  String get widgetSetupTip => 'Совет: виджеты показывают сегодняшние занятия';

  @override
  String get cancel => 'Отмена';

  @override
  String downloadingUpdateTitle(Object version) {
    return 'Загрузка обновления $version';
  }

  @override
  String get downloadCompletedInstalling =>
      'Загрузка завершена, начинается установка...';

  @override
  String downloadFailed(Object error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get confirm => 'Подтвердить';

  @override
  String get back => 'Назад';

  @override
  String get collapseSidebar => 'Свернуть панель';

  @override
  String get expandSidebar => 'Развернуть панель';

  @override
  String get notLoggedIn => 'Не в системе';

  @override
  String get academicSystem => 'Учебная система';

  @override
  String get clickToLogin => 'Нажмите для входа';

  @override
  String get closeWindow => 'Закрыть окно';

  @override
  String get closeWindowChoice => 'Выберите действие';

  @override
  String get showWindow => 'Показать окно';

  @override
  String get minimizeToTray => 'Свернуть в трей';

  @override
  String get quitApp => 'Выйти';

  @override
  String get goToSettings => 'Настройки';

  @override
  String get goAuthorize => 'Разрешить';

  @override
  String get permissionRequired => 'Требуется разрешение';

  @override
  String get permissionRequiredContent =>
      'Для работы этой функции требуется соответствующее разрешение';

  @override
  String get permissionDenied => 'Доступ запрещён';

  @override
  String get permissionDeniedContent =>
      'Разрешение было отклонено навсегда. Включите его в системных настройках';

  @override
  String get updateAvailable => 'Доступна новая версия!';

  @override
  String get ignoreThisUpdate => 'Пропустить';

  @override
  String get ignoreAllUpdates => 'Пропустить все';

  @override
  String get goToBrowserUpdate => 'Открыть в браузере';

  @override
  String get goToBrowser => 'Открыть в браузере';

  @override
  String get dontUpdate => 'Не сейчас';

  @override
  String confirmUpdateTitle(String version) {
    return 'Обновить до последней версии: $version?';
  }

  @override
  String get confirmUpdateContent =>
      'Доступна новая версия. Открыть браузер для скачивания?';

  @override
  String get updateLog => 'История обновлений';

  @override
  String get ignoreVersionUpdate => 'Игнорировать обновления';

  @override
  String get updateOpened =>
      'Браузер открыт. Загрузите и установите обновление';

  @override
  String get openUpdateFailed => 'Не удалось открыть ссылку обновления';

  @override
  String get loginRequired => 'Требуется вход';

  @override
  String get pleaseLoginEduAccount => 'Сначала войдите в учебную систему';

  @override
  String get loadFailedTapRetry => 'Ошибка загрузки. Нажмите для повтора';

  @override
  String get empty => 'Нет данных';

  @override
  String get loading => 'Загрузка';

  @override
  String get syncingData => 'Синхронизация';

  @override
  String get syncingDataSubtitle =>
      'Может занять несколько секунд при медленной сети';

  @override
  String get creditOverview => 'Обзор кредитов';

  @override
  String get completionRate => 'Выполнение';

  @override
  String get itemizedCredits => 'По предметам';

  @override
  String get courseConflict => 'Несколько курсов пересекаются в это время';

  @override
  String get notificationCourseChannelName => 'Напоминания о занятиях';

  @override
  String get notificationCourseChannelDescription =>
      'Уведомления о ежедневном расписании';

  @override
  String notificationCourseAdvanceDescription(Object minutes) {
    return 'Уведомления о ежедневном расписании за $minutes минут до начала';
  }

  @override
  String get notificationTodoChannelName => 'Напоминания о задачах';

  @override
  String get notificationTodoChannelDescription =>
      'Напоминания о сроке выполнения задач';

  @override
  String get courseReminderTitle => 'Напоминание о занятии';

  @override
  String courseReminderStartsIn(Object minutes) {
    return 'начнётся через $minutes мин.';
  }

  @override
  String get todoReminderTitle => 'Напоминание о задаче';

  @override
  String todoReminderBody(Object title) {
    return 'Срок выполнения задачи $title наступил';
  }

  @override
  String get allowBackgroundRun => 'Разрешить работу в фоне';

  @override
  String get allowBackgroundRunContent =>
      'Чтобы напоминания о занятиях срабатывали вовремя, разрешите приложению работать в фоне и игнорировать оптимизацию батареи.';

  @override
  String get allowScheduleAlarm => 'Разрешить будильники';

  @override
  String get allowScheduleAlarmContent =>
      'Чтобы использовать уведомления, необходимо разрешить будильники.';

  @override
  String get saveFailedRetry => 'Не удалось сохранить, попробуйте ещё раз';

  @override
  String get toggleTileVisibilityFailed => 'Не удалось изменить видимость';

  @override
  String get resetFailed => 'Сброс не удался';

  @override
  String get networkError => 'Ошибка сети. Проверьте подключение';

  @override
  String get requestTimeout => 'Тайм-аут запроса. Проверьте подключение';

  @override
  String get serverError => 'Ошибка сервера. Повторите позже';

  @override
  String get unknownError => 'Неизвестная ошибка. Повторите попытку';

  @override
  String get agreementWelcomeTitle => 'Добро пожаловать в Lumaris';

  @override
  String get agreementDescription =>
      'Перед использованием приложения ознакомьтесь и согласитесь со следующими соглашениями.';

  @override
  String get agreementPrivacyDescription =>
      'Узнайте, как мы собираем, используем и защищаем вашу информацию';

  @override
  String get agreementUserDescription =>
      'Узнайте о правах, обязанностях и отказе от ответственности';

  @override
  String get agreementReadTip =>
      'Нажмите на карточки выше, чтобы просмотреть полные тексты. Продолжая, вы подтверждаете согласие с соглашениями.';

  @override
  String get agreeAndContinue => 'Согласен и продолжить';

  @override
  String get disagree => 'Не согласен';

  @override
  String get loginAgreementPrefix => 'Я прочитал и согласен с';

  @override
  String get loginAgreementRequired =>
      'Пожалуйста, сначала прочитайте и согласитесь с Пользовательским соглашением и Политикой конфиденциальности';

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности Lumaris';

  @override
  String get privacyPolicyUpdatedAt => 'Обновлено: 5 мая 2026 г.';

  @override
  String get privacyPolicyEffectiveAt => 'Вступает в силу: 5 мая 2026 г.';

  @override
  String get privacyPolicyIntro =>
      'Добро пожаловать в Lumaris. В этой политике объясняется, как мы собираем, используем, храним и защищаем вашу информацию.';

  @override
  String get privacySection1Title => '1. Собираемая информация';

  @override
  String get privacySection1_1 =>
      '1.1 Данные учётной записи: Для входа в учебную систему требуются ваш студенческий ID и пароль. Эти данные хранятся только на вашем устройстве.';

  @override
  String get privacySection1_2 =>
      '1.2 Данные курсов и оценок: После входа приложение получает расписание, оценки и учебный план из системы.';

  @override
  String get privacySection1_3 =>
      '1.3 Данные студенческой жизни: Приложение может получать данные о балансе электроэнергии, транзакциях карты и использовании сети.';

  @override
  String get privacySection1_4 =>
      '1.4 Данные устройства: Модель устройства и версия ОС для аналитики и устранения неполадок.';

  @override
  String get privacySection1_5 =>
      '1.5 Кэш: Для повышения производительности приложение кэширует данные локально. Вы можете очистить кэш в настройках.';

  @override
  String get privacySection2Title => '2. Использование информации';

  @override
  String get privacySection2_1 => '2.1 Для предоставления основных услуг.';

  @override
  String get privacySection2_2 => '2.2 Для улучшения качества обслуживания.';

  @override
  String get privacySection2_3 =>
      '2.3 Для поддержки виджетов на рабочем столе.';

  @override
  String get privacySection2_4 => '2.4 Для локальных уведомлений.';

  @override
  String get privacySection3Title => '3. Хранение и безопасность';

  @override
  String get privacySection3_1 =>
      '3.1 Ваша информация хранится локально на устройстве.';

  @override
  String get privacySection3_2 =>
      '3.2 Передача данных между приложением и серверами шифруется.';

  @override
  String get privacySection3_3 =>
      '3.3 Вы можете очистить кэш или выйти из системы в любое время.';

  @override
  String get privacySection4Title => '4. Сторонние сервисы';

  @override
  String get privacySection4_1 =>
      '4.1 Приложение взаимодействует с учебной системой университета.';

  @override
  String get privacySection4_2 =>
      '4.2 Приложение проверяет обновления через Gitee.';

  @override
  String get privacySection4_3 =>
      '4.3 Мы не продаём и не передаём вашу информацию третьим лицам.';

  @override
  String get privacySection5Title => '5. Ваши права';

  @override
  String get privacySection5_1 =>
      '5.1 Вы можете просматривать и исправлять информацию в приложении.';

  @override
  String get privacySection5_2 =>
      '5.2 Вы можете удалить данные, выйдя из системы или удалив приложение.';

  @override
  String get privacySection5_3 =>
      '5.3 Вы можете отозвать согласие, выйдя из системы или удалив приложение.';

  @override
  String get privacySection6Title => '6. Несовершеннолетние';

  @override
  String get privacySection6_1 =>
      '6.1 Приложение предназначено в основном для студентов университетов.';

  @override
  String get privacySection6_2 =>
      '6.2 Мы не собираем активно информацию несовершеннолетних.';

  @override
  String get privacySection7Title => '7. Обновления политики';

  @override
  String get privacySection7_1 =>
      '7.1 Политика может время от времени обновляться.';

  @override
  String get privacySection7_2 =>
      '7.2 Продолжение использования означает согласие с обновлённой политикой.';

  @override
  String get privacySection8Title => '8. Свяжитесь с нами';

  @override
  String get privacySection8_1 =>
      'Если у вас есть вопросы или предложения, свяжитесь с нами:';

  @override
  String get privacyContact =>
      'Команда: Lumaris Team\nРепозиторий: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get userAgreementTitle => 'Пользовательское соглашение Lumaris';

  @override
  String get userAgreementUpdatedAt => 'Обновлено: 5 мая 2026 г.';

  @override
  String get userAgreementEffectiveAt => 'Вступает в силу: 5 мая 2026 г.';

  @override
  String get userAgreementIntro =>
      'Добро пожаловать в Lumaris. Пожалуйста, внимательно прочитайте это соглашение перед использованием приложения.';

  @override
  String get userAgreementSection1Title => '1. Описание услуг';

  @override
  String get userAgreementSection1_1 =>
      '1.1 Это приложение-помощник для студентов университета.';

  @override
  String get userAgreementSection1_2 =>
      '1.2 Некоторые функции требуют доступа к университетской сети.';

  @override
  String get userAgreementSection1_3 =>
      '1.3 Учебные данные предоставлены только для справки.';

  @override
  String get userAgreementSection2Title => '2. Учётная запись и безопасность';

  @override
  String get userAgreementSection2_1 =>
      '2.1 Требуется вход с учётной записью учебной системы.';

  @override
  String get userAgreementSection2_2 =>
      '2.2 Учётные данные хранятся только на вашем устройстве.';

  @override
  String get userAgreementSection2_3 =>
      '2.3 Немедленно смените пароль при угрозе безопасности учётной записи.';

  @override
  String get userAgreementSection3Title => '3. Поведение пользователя';

  @override
  String get userAgreementSection3_1 =>
      '3.1 Необходимо соблюдать действующее законодательство.';

  @override
  String get userAgreementSection3_2 =>
      '3.2 Исходный код доступен по лицензии MIT.';

  @override
  String get userAgreementSection3_3 =>
      '3.3 Запрещается вмешиваться в нормальную работу приложения.';

  @override
  String get userAgreementSection3_4 =>
      '3.4 Запрещается использовать уязвимости для несанкционированного доступа.';

  @override
  String get userAgreementSection4Title => '4. Интеллектуальная собственность';

  @override
  String get userAgreementSection4_1 =>
      '4.1 Исходный код выпущен под лицензией MIT.';

  @override
  String get userAgreementSection4_2 =>
      '4.2 Название, значок и дизайн принадлежат Lumaris Team.';

  @override
  String get userAgreementSection4_3 =>
      '4.3 Названия и логотипы университета принадлежат университету.';

  @override
  String get userAgreementSection5Title => '5. Отказ от ответственности';

  @override
  String get userAgreementSection5_1 =>
      '5.1 Приложение предоставляется «как есть».';

  @override
  String get userAgreementSection5_2 =>
      '5.2 Мы не несём ответственности за перебои из-за проблем с сетью или сервером.';

  @override
  String get userAgreementSection5_3 =>
      '5.3 Учебная информация предоставляется только для справки.';

  @override
  String get userAgreementSection5_4 =>
      '5.4 Мы не несём ответственности за ущерб устройству или потерю данных, кроме случаев, предусмотренных законом.';

  @override
  String get userAgreementSection6Title => '6. Изменения и прекращение';

  @override
  String get userAgreementSection6_1 =>
      '6.1 Соглашение может время от времени изменяться.';

  @override
  String get userAgreementSection6_2 =>
      '6.2 Продолжение использования означает принятие обновлённого соглашения.';

  @override
  String get userAgreementSection6_3 =>
      '6.3 Мы можем прекратить обслуживание при необходимости.';

  @override
  String get userAgreementSection7Title => '7. Прочее';

  @override
  String get userAgreementSection7_1 =>
      '7.1 Если какое-либо положение недействительно, остальные сохраняют силу.';

  @override
  String get userAgreementSection7_2 =>
      '7.2 Настоящее соглашение регулируется законодательством КНР.';

  @override
  String get userAgreementSection7_3 =>
      '7.3 Споры разрешаются путём дружественных переговоров.';

  @override
  String get userAgreementSection8Title => '8. Свяжитесь с нами';

  @override
  String get userAgreementSection8_1 =>
      'Если у вас есть вопросы по соглашению, свяжитесь с нами:';

  @override
  String get userAgreementContact =>
      'Команда: Lumaris Team\nРепозиторий: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get aboutAuthor => 'Об авторах';

  @override
  String get coreTeam => 'Основная команда';

  @override
  String get specialThanks => 'Благодарности';

  @override
  String get contactUs => 'Контакты';

  @override
  String get thanksTitle => 'Спасибо';

  @override
  String get thanksContent =>
      'Спасибо всем разработчикам и пользователям, внёсшим вклад в проект.';

  @override
  String get githubRepository => 'Репозиторий GitHub';

  @override
  String get joinUs => 'Присоединиться';

  @override
  String get madeWithLove => 'Made with ❤️ in Xi\'an';

  @override
  String get easterEggTitle => '🎉 Пасхалка';

  @override
  String get easterEggFound => 'Поздравляем! Вы нашли скрытую пасхалку!';

  @override
  String get easterEggContent =>
      'Вы один из немногих, кто знает этот секрет!\n\nСпасибо за вашу любовь и поддержку Lumaris.\n\nПродолжайте исследовать — возможно, вас ждёт ещё больше сюрпризов...';

  @override
  String get fontSetting => 'Настройка шрифта';

  @override
  String get fontSettingSubtitle =>
      'Выберите шрифт для ПК (применяется при следующем запуске)';

  @override
  String get systemDefault => 'По умолчанию';

  @override
  String get customFont => 'Свой';

  @override
  String get hapticFeedback => 'Тактильный отклик';

  @override
  String get hapticFeedbackSubtitle =>
      'Вибрация при нажатии на нижнюю навигацию';

  @override
  String get cloudSyncTodo => 'Сохранять задачи в облако';

  @override
  String get servicePaused => 'Сервис приостановлен';

  @override
  String get showTomorrowCourses => 'Показать завтрашние занятия';

  @override
  String get showTomorrowCoursesSubtitle =>
      'Показывать занятия завтра, когда сегодня занятий нет';

  @override
  String get courseReminder => 'Напоминание о занятиях';

  @override
  String get courseReminderSubtitle => 'Напоминать перед началом занятия';

  @override
  String get remindMinutesBefore => 'За сколько минут напоминать';

  @override
  String remindMinutes(int n) {
    return '$n мин.';
  }

  @override
  String get todoReminder => 'Напоминание о задачах';

  @override
  String get todoReminderSubtitle => 'Напоминать о сроках выполнения задач';

  @override
  String get schedulePage => 'Расписание';

  @override
  String get scorePage => 'Оценки';

  @override
  String get profilePage => 'Профиль';

  @override
  String get firstPageOnLaunch => 'Первая страница при запуске';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sundayShort => 'Вс';

  @override
  String get mondayShort => 'Пн';

  @override
  String get tuesdayShort => 'Вт';

  @override
  String get wednesdayShort => 'Ср';

  @override
  String get thursdayShort => 'Чт';

  @override
  String get fridayShort => 'Пт';

  @override
  String get saturdayShort => 'Сб';

  @override
  String get janShort => 'янв.';

  @override
  String get febShort => 'февр.';

  @override
  String get marShort => 'марта';

  @override
  String get aprShort => 'апр.';

  @override
  String get mayShort => 'мая';

  @override
  String get junShort => 'июня';

  @override
  String get julShort => 'июля';

  @override
  String get augShort => 'авг.';

  @override
  String get sepShort => 'сент.';

  @override
  String get octShort => 'окт.';

  @override
  String get novShort => 'нояб.';

  @override
  String get decShort => 'дек.';

  @override
  String weekUnit(int n) {
    return '$n неделя';
  }

  @override
  String currentWeek(int n) {
    return 'Сейчас $n неделя';
  }

  @override
  String weeksUntilStart(int n) {
    return 'До начала семестра: $n нед.';
  }

  @override
  String periodRange(int start, int end) {
    return '$start-$end пара';
  }

  @override
  String get allSchedules => 'Все расписания';

  @override
  String get previousWeek => 'Предыдущая неделя';

  @override
  String get nextWeek => 'Следующая неделя';

  @override
  String get switchStyle => 'Сменить вид';

  @override
  String get refreshSchedule => 'Обновить расписание';

  @override
  String get scheduleSettingsTitle => 'Настройки расписания';

  @override
  String get compact => 'Компактный';

  @override
  String get standard => 'Стандартный';

  @override
  String get relaxed => 'Расширенный';

  @override
  String get selectCourse => 'Выбрать курс';

  @override
  String get editCourse => 'Редактировать курс';

  @override
  String get deleteCourse => 'Удалить курс';

  @override
  String get confirmDelete => 'Подтвердить удаление';

  @override
  String confirmDeleteCourseContent(String name) {
    return 'Вы уверены, что хотите удалить «$name»?';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get courseModified => 'Курс обновлён';

  @override
  String get courseDeleted => 'Курс удалён';

  @override
  String get deleteFailed => 'Не удалось удалить';

  @override
  String get noLocation => 'Место не указано';

  @override
  String get addCourse => 'Добавить курс';

  @override
  String get save => 'Сохранить';

  @override
  String get courseName => 'Название курса';

  @override
  String get courseRoom => 'Аудитория';

  @override
  String get courseTeacher => 'Преподаватель';

  @override
  String get courseCredits => 'Кредиты';

  @override
  String get courseWeekday => 'День недели';

  @override
  String get courseStartUnit => 'Начальная пара';

  @override
  String get courseEndUnit => 'Конечная пара';

  @override
  String get courseWeeks => 'Недели';

  @override
  String selectedWeeks(int count) {
    return 'Выбрано: $count нед.';
  }

  @override
  String get customCourses => 'Свои курсы';

  @override
  String customCoursesCount(int count) {
    return 'Курсов: $count';
  }

  @override
  String get noCustomCourses => 'Нет пользовательских курсов';

  @override
  String get noCustomCoursesSubtitle => 'Нажмите + чтобы добавить курс';

  @override
  String get readingCustomCourses => 'Чтение пользовательских курсов';

  @override
  String get readingCustomCoursesSubtitle =>
      'Организация локально сохранённых конфигураций курсов';

  @override
  String get courseAdded => 'Курс добавлен';

  @override
  String get scoresAndGpa => 'Оценки и GPA';

  @override
  String get passedCourses => 'Пройдено';

  @override
  String get totalCredits => 'Всего кредитов';

  @override
  String get creditInfoTitle => 'Примечание';

  @override
  String get creditInfoContent =>
      'Кредиты рассчитываются по пройденным курсам. В официальной системе данные могут отличаться.';

  @override
  String get noScores => 'Нет оценок';

  @override
  String get noScoresSubtitle => 'Попробуйте обновить или войти заново';

  @override
  String get refreshDataBtn => 'Обновить';

  @override
  String get goToLogin => 'Войти';

  @override
  String get minorCourse => 'Факультатив';

  @override
  String get scoreDetail => 'Детали оценки';

  @override
  String get courseCreditLabel => 'Кредиты курса';

  @override
  String get courseScoreLabel => 'Оценка';

  @override
  String get courseGpaLabel => 'GPA курса';

  @override
  String get fetchingScores => 'Получение оценок...';

  @override
  String get refreshFailedFallback =>
      'Не удалось обновить, показаны локальные данные';

  @override
  String get fetchTimeout => 'Тайм-аут запроса. Проверьте подключение к сети.';

  @override
  String get fetchFailed => 'Не удалось получить данные';

  @override
  String get pleaseLoginFirst => 'Войдите, чтобы посмотреть оценки';

  @override
  String get readingScoresSubtitle => 'Чтение кэша и синхронизация оценок';

  @override
  String get foolishModeMessage => 'Да, у меня GPA 5.0';

  @override
  String creditUnit(String credit) {
    return '$credit кред.';
  }

  @override
  String gradeLabel(String grade) {
    return 'Оценка $grade';
  }

  @override
  String gpaLabel(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String scheduleCourseTime(
      String weekRanges, String weekday, int start, int end) {
    return 'Недели $weekRanges по $weekday $start-$end пара';
  }

  @override
  String semesterRange(String start, String end, String num) {
    return '$start-$end Семестр $num';
  }

  @override
  String get semesterAutumnShort => 'Осень';

  @override
  String get semesterSpringShort => 'Весна';

  @override
  String get year1 => '1 курс';

  @override
  String get year2 => '2 курс';

  @override
  String get year3 => '3 курс';

  @override
  String get year4 => '4 курс';

  @override
  String get year5 => '5 курс';

  @override
  String get year6 => '6 курс';

  @override
  String get year7 => '7 курс';

  @override
  String get year8 => '8 курс';

  @override
  String get year9 => '9 курс';

  @override
  String get year10 => '10 курс';

  @override
  String get loginTitle => 'Вход в учебную систему';

  @override
  String get loginSubtitle => 'Войдите в свою учётную запись';

  @override
  String get studentId => 'Номер студенческого';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loggingIn => 'Вход...';

  @override
  String get loggingInSubtitle =>
      'Проверка данных и синхронизация курсов, оценок и прочего';

  @override
  String get emptyCredentials => 'Логин и пароль не могут быть пустыми';

  @override
  String get loginTimeoutEdu =>
      'Время входа истекло, проверьте подключение к сети';

  @override
  String get loginFailed => 'Ошибка входа. Проверьте учётные данные';

  @override
  String get loginTimeout => 'Время входа истекло. Проверьте сеть и повторите.';

  @override
  String get loginSecurityStorageUnavailable =>
      'Вход выполнен, но защищённое хранилище недоступно. Может потребоваться повторный ввод данных.';

  @override
  String get loadingDefaultTitle => 'Синхронизация';

  @override
  String get loadingDefaultSubtitle =>
      'Может занять несколько секунд при медленной сети';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get loadFailed => 'Ошибка загрузки';

  @override
  String get noData => 'Нет данных';

  @override
  String get ok => 'ОК';

  @override
  String get classroom => 'Аудитория';

  @override
  String get teacherLabel => 'Преподаватель';

  @override
  String get classTime => 'Время';

  @override
  String get classCampus => 'Кампус';

  @override
  String get todayScheduleLabel => 'Сегодняшнее расписание';

  @override
  String get tomorrowSchedule => 'Завтрашнее расписание';

  @override
  String get noCourseToday => 'Сегодня занятий нет';

  @override
  String get noCourseTodaySubtitle => 'Отдохните, вы это заслужили';

  @override
  String get showTomorrowSchedule => 'Показать расписание на завтра';

  @override
  String get doubleTapExit => 'Нажмите ещё раз для выхода';

  @override
  String copySuccess(String text) {
    return 'Скопировано: $text';
  }

  @override
  String get copyTooltip => 'Копировать';

  @override
  String get pageSettings => 'Настройки страниц';

  @override
  String get showBusTile => 'Показать плитку автобуса';

  @override
  String get showBusTileSubtitle =>
      'Показать информацию о ближайшем автобусе на главной';

  @override
  String get addToHome => 'Добавить на главную';

  @override
  String get showElectricityTile => 'Показать плитку электричества';

  @override
  String get electricityRecharge => 'Пополнить';

  @override
  String get electricityRechargeSubtitle =>
      'Открыть WeChat для пополнения электричества';

  @override
  String get showPaymentTile => 'Показать плитку карты';

  @override
  String get showPaymentTileSubtitle => 'Показать баланс карты на главной';

  @override
  String get addTodo => 'Добавить задачу';

  @override
  String get todoTitle => 'Название';

  @override
  String get deadline => 'Срок';

  @override
  String get change => 'Изменить';

  @override
  String get edit => 'Редактировать';

  @override
  String get done => 'Готово';

  @override
  String get todoListLabel => 'Список задач';

  @override
  String get readingTodos => 'Чтение задач';

  @override
  String get readingTodosSubtitle => 'Загрузка локального списка и напоминаний';

  @override
  String get noTodos => 'Нет задач';

  @override
  String get noTodosSubtitle => 'Нажмите + чтобы добавить';

  @override
  String get todoLoadFailedSubtitle => 'Не удалось загрузить задачи';

  @override
  String deadlineLabel(String date) {
    return 'Срок: $date';
  }

  @override
  String get noDeadline => 'Нет';

  @override
  String get titleRequired => 'Требуется название';

  @override
  String get deadlineRequired => 'Требуется срок';

  @override
  String get add => 'Добавить';

  @override
  String get upcomingExams => 'Ближайшие экзамены';

  @override
  String get loadingExams => 'Загрузка экзаменов';

  @override
  String get loadingExamsSubtitle =>
      'Синхронизация экзаменов, аудиторий и мест';

  @override
  String get noExams => 'Нет ближайших экзаменов';

  @override
  String get noExamsSubtitle => 'Обновите чтобы проверить';

  @override
  String get examTime => 'Время экзамена';

  @override
  String get examLocation => 'Место проведения';

  @override
  String get seatNumber => 'Место';

  @override
  String seatNumberLabel(String seat) {
    return 'Место $seat';
  }

  @override
  String get examNotLoggedIn => 'Пожалуйста, сначала войдите';

  @override
  String get examAuthFailed => 'Ошибка аутентификации, войдите снова';

  @override
  String get examFetchFailed =>
      'Не удалось загрузить данные экзаменов, нажмите для повтора';

  @override
  String get quickFeatures => 'Быстрые функции';

  @override
  String get noQuickFeatures => 'Нет быстрых функций';

  @override
  String get noQuickFeaturesSubtitle => 'Добавьте их в режиме редактирования';

  @override
  String get moreFeatures => 'Ещё функции';

  @override
  String get scheduleWidgetTitle => 'Импорт в календарь';

  @override
  String get subscriptionLink => 'Ссылка для подписки';

  @override
  String get copiedSuccess => 'Скопировано!';

  @override
  String get howToImport => 'Как импортировать?';

  @override
  String get customCourseManage => 'Управление своими курсами';

  @override
  String get showCourseGrid => 'Показать сетку';

  @override
  String get noBackground => 'Без фона';

  @override
  String get customImage => 'Своё изображение';

  @override
  String get noImageSelected => 'Изображение не выбрано';

  @override
  String get noCalendarApp =>
      'Приложение календаря не найдено, импортируйте вручную';

  @override
  String get cannotOpenCalendar => 'Не удалось открыть календарь';

  @override
  String get bgImageSetSuccess => 'Фоновое изображение установлено';

  @override
  String get selectImageFailed => 'Не удалось выбрать изображение';

  @override
  String get addCalendarSub => 'Добавить подписку календаря';

  @override
  String get understand => 'Понятно';

  @override
  String get calendarSubscription => 'Подписка календаря';

  @override
  String get scheduleManagement => 'Управление курсами';

  @override
  String get scheduleBackground => 'Фон расписания';

  @override
  String get ignoreCourses => 'Игнорировать курсы';

  @override
  String get loadingSchedule => 'Загрузка расписания';

  @override
  String get loadingScheduleSubtitle => 'Чтение курсов, настроек и фона';

  @override
  String get updatingSchedule => 'Обновление расписания...';

  @override
  String get updateComplete => 'Обновлено';

  @override
  String get updateTimeout => 'Тайм-аут обновления. Проверьте сеть.';

  @override
  String updateFailed(String error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String get linkCopiedToClipboard => 'Ссылка скопирована';

  @override
  String get currentWeekLabel => 'Текущая неделя';

  @override
  String periodUnit(int n) {
    return 'Пара $n';
  }

  @override
  String get calendarGuidanceIntro =>
      'Похоже, на устройстве нет приложения для подписки на календари. Добавьте вручную:';

  @override
  String get calendarGuidanceStep1 => '1. Откройте приложение календаря';

  @override
  String get calendarGuidanceStep2 =>
      '2. Найдите «Добавить календарь» или «Подписка»';

  @override
  String get calendarGuidanceStep3 => '3. Выберите «Добавить по URL»';

  @override
  String get calendarGuidanceStep4 => '4. Вставьте ссылку:';

  @override
  String get calendarGuidanceNote =>
      'Примечание: шаги могут отличаться. Обратитесь к справке приложения.';

  @override
  String get profileReading => 'Чтение информации учётной записи';

  @override
  String get profileReadingSubtitle =>
      'Синхронизация статуса входа и данных профиля';

  @override
  String get campusNavigation => 'Навигация Ящик с инструментами';

  @override
  String get settingsAbout => 'Настройки / О приложении';

  @override
  String get programLabel => 'Учебный план';

  @override
  String get campusMap => 'Схема кампуса';

  @override
  String get help => 'Помощь';

  @override
  String get academicAccount => 'Учебная учётная запись';

  @override
  String get guest => 'Гость';

  @override
  String get guestMode => 'Гостевой режим';

  @override
  String get guestModeSubtitle =>
      'Войдите, чтобы получить доступ ко всем функциям';

  @override
  String get syncingAcademic => 'Синхронизация учебной информации';

  @override
  String get syncingAcademicSubtitle => 'Чтение кредитов и карточек профиля';

  @override
  String get loginEduSystem => 'Войти в учебную систему';

  @override
  String get programLoading => 'Загрузка учебного плана';

  @override
  String get programLoadingSubtitle => 'Структурирование курсов по семестрам';

  @override
  String get programLoadFailed => 'Не удалось загрузить';

  @override
  String get programNoData => 'Нет данных';

  @override
  String get programRefreshFailed =>
      'Ошибка обновления, показан последний синхронизированный план';

  @override
  String get linkLoading => 'Загрузка навигационных ссылок';

  @override
  String get linkLoadingSubtitle => 'Организация сайтов и категорий';

  @override
  String get linkLoadFailed => 'Не удалось загрузить';

  @override
  String get linkNoData => 'Нет данных навигации';

  @override
  String get linkNoDataSubtitle =>
      'Откройте эту страницу снова или проверьте подключение';

  @override
  String get paymentLoading => 'Синхронизация баланса карты';

  @override
  String get paymentLoadingSubtitle => 'Получение последних транзакций';

  @override
  String get paymentPasswordTitle => 'Пароль карты';

  @override
  String get paymentPasswordSubtitle =>
      'Необязательно. Оставьте пустым для стандартного запроса.';

  @override
  String get paymentSaveAndRefresh => 'Сохранить и обновить';

  @override
  String get campusCard => 'Кампусная карта';

  @override
  String get currentBalance => 'Текущий баланс';

  @override
  String get recentTransactions => 'Последние транзакции';

  @override
  String get paymentFilter => 'Платежи';

  @override
  String get consumptionFilter => 'Расходы';

  @override
  String get rechargeFilter => 'Пополнения';

  @override
  String get noCardData => 'Нет данных карты';

  @override
  String get noCardDataSubtitle =>
      'Войдите в систему для просмотра баланса и транзакций';

  @override
  String get busLoading => 'Загрузка расписания автобусов';

  @override
  String get busLoadingSubtitle =>
      'Организация информации об автобусах по кампусу и дате';

  @override
  String get noBusToday => 'Сегодня автобусов нет';

  @override
  String get noBusTodaySubtitle => 'Заходите завтра';

  @override
  String get departureTime => 'Отправление';

  @override
  String get destination => 'Назначение';

  @override
  String get estimatedArrival => 'Прибытие';

  @override
  String get busInfo => 'Информация';

  @override
  String get departure => 'Отправление';

  @override
  String get arrival => 'Прибытие';

  @override
  String get netRefreshFailed => 'Ошибка обновления, показаны текущие данные';

  @override
  String get netData => 'Данные сети';

  @override
  String get usedTraffic => 'Использованный трафик';

  @override
  String onlineDuration(String time) {
    return 'В сети: $time';
  }

  @override
  String get username => 'Имя пользователя';

  @override
  String get ipAddress => 'IP-адрес';

  @override
  String get productPackage => 'Тарифный план';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get netLoading => 'Чтение данных сети';

  @override
  String get netLoadingSubtitle =>
      'Синхронизация трафика, времени в сети и данных учётной записи';

  @override
  String get netLoadFailed => 'Не удалось загрузить';

  @override
  String get netNoData => 'Нет данных';

  @override
  String get electricityBalance => 'Текущий баланс';

  @override
  String get electricityNoData => 'Нет данных';

  @override
  String get electricityLowBalance => 'Низкий баланс, пополните счёт';

  @override
  String get electricitySufficient => 'Баланс достаточен';

  @override
  String get electricityAddTip =>
      'Нажмите справа вверху, чтобы добавить данные электричества';

  @override
  String get electricityLoading => 'Обновление трендов использования';

  @override
  String get electricityLoadingSubtitle =>
      'Чтение последних записей электричества';

  @override
  String get noUsageDetails => 'Нет данных об использовании';

  @override
  String get noUsageDetailsSubtitle =>
      'Почасовая стоимость появится здесь после обновления';

  @override
  String get electricityCost => 'Стоимость электричества';

  @override
  String lastNDays(int n) {
    return 'Последние $n дн.';
  }

  @override
  String get totalCost => 'Общая стоимость';

  @override
  String get todayCost => 'Сегодняшняя стоимость';

  @override
  String get avgDailyCost => 'Средняя дневная стоимость';

  @override
  String get peakHours => 'Пиковые часы';

  @override
  String get hourlyDetails => 'Почасовые детали';

  @override
  String get lowBalanceSub => 'Оповещение о низком балансе';

  @override
  String get lowBalanceSubDesc => 'Получайте уведомления при низком балансе';

  @override
  String get addElectricityFirst => 'Сначала добавьте страницу электричества';

  @override
  String get noElectricityData => 'Нет данных электричества';

  @override
  String get noElectricityDataSubtitle =>
      'Сначала привяжите страницу электричества общежития';

  @override
  String get lowBalanceEnabled => 'Оповещение о низком балансе включено';

  @override
  String get addLowBalanceAlert => 'Добавить оповещение о низком балансе';

  @override
  String get deleteSubscription => 'Удалить подписку';

  @override
  String get deleteSubDesc => 'Отменить почтовое оповещение о низком балансе';

  @override
  String get electricityManagement => 'Управление электричеством';

  @override
  String get chooseAction => 'Выберите действие';

  @override
  String get changeRoom => 'Сменить комнату';

  @override
  String get getElectricity => 'Получить электричество';

  @override
  String get electricityUrlPrompt =>
      'Откройте финансовую страницу электричества университета, скопируйте URL и вставьте ниже';

  @override
  String get urlPlaceholder => 'Введите URL';

  @override
  String get createLowBalanceAlert => 'Создать оповещение о низком балансе';

  @override
  String get lowBalanceAlertDesc =>
      'Система будет использовать привязанную страницу электричества для отправки писем при падении баланса ниже порога.';

  @override
  String get remindEmail => 'Email для оповещения';

  @override
  String get remindEmailPlaceholder => 'Email для оповещения';

  @override
  String get remindThreshold => 'Порог, например 10';

  @override
  String get remindThresholdPlaceholder => 'Порог, например 10';

  @override
  String get pleaseEnterEmail => 'Введите email';

  @override
  String get pleaseEnterValidEmail => 'Введите корректный email';

  @override
  String get pleaseEnterThreshold => 'Введите порог больше 0';

  @override
  String get lowBalanceAlertCreated => 'Оповещение о низком балансе создано';

  @override
  String get createSubFailed => 'Не удалось создать подписку';

  @override
  String currentSubInfo(String email, String threshold) {
    return 'Оповещение на $email при балансе ниже ¥$threshold';
  }

  @override
  String get subSetupHint =>
      'После установки порога вы будете получать письма при низком балансе';

  @override
  String get remindEmailLabel => 'Email для оповещения';

  @override
  String get notSet => 'Не задано';

  @override
  String get remindThresholdLabel => 'Порог';

  @override
  String get gotIt => 'Понятно';

  @override
  String get noSubToDelete => 'Нет подписок для удаления';

  @override
  String get deleteSubTitle => 'Удалить подписку';

  @override
  String get deleteSubConfirmContent =>
      'Вы уверены, что хотите удалить текущее оповещение о низком балансе?';

  @override
  String get lowBalanceAlertDeleted => 'Оповещение о низком балансе удалено';

  @override
  String get deleteSubFailed => 'Не удалось удалить подписку';

  @override
  String get electricitySubLoadFailed =>
      'Не удалось загрузить подписку на электричество';

  @override
  String get subscriptionDetail => 'Детали подписки';

  @override
  String get create => 'Создать';

  @override
  String get webNotSupported => 'Не поддерживается в веб-версии';

  @override
  String get webNotSupportedSubtitle => 'Пожалуйста, используйте другую версию';

  @override
  String get reorderFailed => 'Не удалось изменить порядок';

  @override
  String get searchLocation => 'Поиск мест или зданий...';

  @override
  String get search => 'Поиск...';

  @override
  String get buildingIntro => 'Информация о здании';

  @override
  String get specificLocation => 'Местоположение';

  @override
  String get licenseTitle => 'Лицензии открытого ПО';

  @override
  String get licenseLoading => 'Загрузка лицензий';

  @override
  String get licenseLoadingSubtitle => 'Загрузка текста лицензий открытого ПО';

  @override
  String get licenseLoadFailed => 'Не удалось загрузить файл лицензий';

  @override
  String get helpFeaturesTab => 'Функции';

  @override
  String get helpInstructionsTab => 'Инструкции';

  @override
  String get helpNotesTab => 'Примечания';

  @override
  String get helpAboutTab => 'О приложении';

  @override
  String get helpFeatureHome => 'Главная';

  @override
  String get helpFeatureHomeDesc =>
      'Информационный центр с личными данными, курсами, задачами и экзаменами';

  @override
  String get helpFeatureSchedule => 'Расписание';

  @override
  String get helpFeatureScheduleDesc =>
      'Управление недельным расписанием с переключением кампуса и напоминаниями';

  @override
  String get helpFeatureScore => 'Оценки';

  @override
  String get helpFeatureScoreDesc =>
      'Просмотр оценок по семестрам, расчёт GPA и анализ';

  @override
  String get helpFeatureProfile => 'Профиль';

  @override
  String get helpFeatureProfileDesc =>
      'Отображение номера студента, имени, факультета и другой информации';

  @override
  String get helpFeatureBus => 'Автобус кампуса';

  @override
  String get helpFeatureBusDesc =>
      'Просмотр расписания и маршрутов автобусов между кампусами';

  @override
  String get helpFeatureProgram => 'Учебный план';

  @override
  String get helpFeatureProgramDesc =>
      'Отображение учебного плана и требований к кредитам';

  @override
  String get helpFeatureElectricity => 'Электричество';

  @override
  String get helpFeatureElectricityDesc =>
      'Просмотр расхода и истории электричества в общежитии';

  @override
  String get helpFeaturePayment => 'Карта кампуса';

  @override
  String get helpFeaturePaymentDesc =>
      'Просмотр баланса карты и истории транзакций';

  @override
  String get helpFeatureNet => 'Сеть кампуса';

  @override
  String get helpFeatureNetDesc => 'Просмотр использования и статистики сети';

  @override
  String get helpFeatureLinks => 'Полезные ссылки';

  @override
  String get helpFeatureLinksDesc =>
      'Коллекция полезных ссылок для академических систем';

  @override
  String get helpInstructionLogin => 'Вход и аккаунт';

  @override
  String get helpInstructionLoginDesc =>
      'Войдите с учётной записью академической системы при первом использовании';

  @override
  String get helpInstructionCourse => 'Управление курсами';

  @override
  String get helpInstructionCourseDesc =>
      'Просмотр недельных курсов в расписании, смахивание для смены недели, нажмите для деталей';

  @override
  String get helpInstructionReminder => 'Напоминания о курсах';

  @override
  String get helpInstructionReminderDesc =>
      'Включите напоминания в настройках для уведомлений перед занятиями';

  @override
  String get helpInstructionSync => 'Синхронизация данных';

  @override
  String get helpInstructionSyncDesc =>
      'Приложение автоматически синхронизируется. Потяните вниз для обновления вручную';

  @override
  String get helpInstructionWidget => 'Виджеты';

  @override
  String get helpInstructionWidgetDesc =>
      'Долгое нажатие на главном экране для добавления виджета';

  @override
  String get helpNoteNetwork =>
      'Некоторые функции требуют доступа к сети кампуса';

  @override
  String get helpNoteUpdate =>
      'Обновляйте приложение для последних функций и исправлений';

  @override
  String get helpNoteData =>
      'Если данные неточные, проверьте вход в академическую систему';

  @override
  String get helpNoteFeedback =>
      'Сообщайте о проблемах через страницу настроек';

  @override
  String get helpNotePrivacy =>
      'Это приложение не собирает вашу личную информацию';

  @override
  String get helpAboutPlatform => 'Поддержка платформ';

  @override
  String get helpAboutPlatformDesc =>
      'Кроссплатформенное приложение, поддерживает:';

  @override
  String get helpAboutOpenSource => 'Открытый исходный код';

  @override
  String get helpAboutOpenSourceDesc =>
      'Приложение с открытым исходным кодом по лицензии MIT';

  @override
  String get helpAboutRepoLabel => 'Репозиторий:';

  @override
  String get underMaintenanceTitle => 'Техническое обслуживание!';

  @override
  String get underMaintenanceDescription =>
      'В настоящее время проводится плановое техническое обслуживание. Пожалуйста, зайдите позже. Спасибо за терпение.';

  @override
  String get readingPaymentCard => 'Загрузка данных карты';

  @override
  String get lowBalance => 'Низкий баланс';

  @override
  String get campusCardBalance => 'Баланс карты';

  @override
  String get tapToView => 'Нажмите для просмотра';

  @override
  String get tapToSubscribe => 'Нажмите для подписки';

  @override
  String get campusCaoTang => 'Цаотан';

  @override
  String get campusYanTa => 'Яньта';

  @override
  String get busRefreshStale =>
      'Обновление завершено, сохранены последние данные';

  @override
  String arrivalStationTime(String h, String m) {
    return '$hч $mм';
  }

  @override
  String get poiMainLibrary => 'Главная библиотека';

  @override
  String get poiMainLibraryDesc => 'Круглосуточный читальный зал';

  @override
  String get poiCaoTangNorthGate => 'Северные ворота Цаотан';

  @override
  String get poiCaoTangNorthGateDesc => 'Главный вход в кампус';

  @override
  String get poiYanTaEastGate => 'Восточные ворота Яньта';

  @override
  String get poiYanTaEastGateDesc => 'Вход в исторический кампус';

  @override
  String durationDHMS(String d, String h, String m, String s) {
    return '$dд $hч $mм $sс';
  }

  @override
  String get shortcuts => 'Ярлыки';

  @override
  String get moreFunctions => 'Другие функции';

  @override
  String get noShortcuts => 'Нет ярлыков';

  @override
  String get addInEditMode => 'Добавить в режиме редактирования';

  @override
  String get eduSystem => 'Образовательная система';

  @override
  String get htmlImport => 'HTML импорт';

  @override
  String get pasteHtmlHint => 'Вставьте HTML расписания сюда';

  @override
  String get parseAndPreview => 'Разбор и просмотр';

  @override
  String get importCourses => 'Импорт курсов';

  @override
  String get parseResult => 'Результат разбора';

  @override
  String get noCoursesParsed => 'Курсы не найдены';

  @override
  String get searchSchool => 'Поиск учебного заведения...';

  @override
  String get basicSupport => 'Базовая';

  @override
  String get advancedSupport => 'Расширенная';

  @override
  String get schoolNotSupported =>
      'Эта функция не поддерживается текущим учебным заведением';

  @override
  String get switchSchool => 'Сменить учебное заведение';

  @override
  String get selectSchool => 'Выбрать школу';

  @override
  String get enterCustomUrl => 'Или введите свой URL';

  @override
  String get urlHint => 'Введите URL веб-сайта';

  @override
  String get icp => 'ICP';
}
