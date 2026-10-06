import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  ///
  ///
  /// In zh, this message translates to:
  /// **'光序'**
  String get appName;

  ///
  ///
  /// In zh, this message translates to:
  /// **'试着把大学囊括其中'**
  String get appSlogan;

  ///
  ///
  /// In zh, this message translates to:
  /// **'致力于为大学生提供更好的服务'**
  String get tagline;

  ///
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课表'**
  String get schedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'成绩'**
  String get score;

  ///
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profile;

  ///
  ///
  /// In zh, this message translates to:
  /// **'电费'**
  String get electricity;

  ///
  ///
  /// In zh, this message translates to:
  /// **'校车'**
  String get schoolBus;

  ///
  ///
  /// In zh, this message translates to:
  /// **'饭卡'**
  String get payment;

  ///
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get map;

  ///
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  ///
  ///
  /// In zh, this message translates to:
  /// **'基本设置'**
  String get basicSettings;

  ///
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  ///
  ///
  /// In zh, this message translates to:
  /// **'小组件'**
  String get widgets;

  ///
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  ///
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get other;

  ///
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedback;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提交问题或建议，帮助我们改进'**
  String get feedbackSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'问题描述'**
  String get feedbackContentLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请描述你遇到的问题'**
  String get feedbackContentHint;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请填写问题描述'**
  String get feedbackContentRequired;

  ///
  ///
  /// In zh, this message translates to:
  /// **'联系方式'**
  String get feedbackContactLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'手机号 / 邮箱 / QQ 等'**
  String get feedbackContactHint;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请填写联系方式'**
  String get feedbackContactRequired;

  ///
  ///
  /// In zh, this message translates to:
  /// **'图片（选填，最多 6 张）'**
  String get feedbackImagesLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加图片'**
  String get feedbackAddImage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get feedbackSubmit;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提交中…'**
  String get feedbackSubmitting;

  ///
  ///
  /// In zh, this message translates to:
  /// **'反馈已提交，感谢你的支持！'**
  String get feedbackSubmitSuccess;

  ///
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败，请重试'**
  String get feedbackPickImageFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'图片上传失败，请重试'**
  String get feedbackImageUploadFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'最多上传 6 张图片'**
  String get feedbackImageTooMany;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新数据'**
  String get refreshData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在刷新数据...'**
  String get refreshingData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新数据成功'**
  String get refreshDataSuccess;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新数据失败'**
  String get refreshDataFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  ///
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  ///
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get light;

  ///
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dark;

  ///
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  ///
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemLanguage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  ///
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  ///
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get japanese;

  ///
  ///
  /// In zh, this message translates to:
  /// **'Русский'**
  String get russian;

  ///
  ///
  /// In zh, this message translates to:
  /// **'Français'**
  String get french;

  ///
  ///
  /// In zh, this message translates to:
  /// **'Deutsch'**
  String get german;

  ///
  ///
  /// In zh, this message translates to:
  /// **'한국어'**
  String get korean;

  ///
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get traditionalChinese;

  ///
  ///
  /// In zh, this message translates to:
  /// **'制作团队'**
  String get team;

  ///
  ///
  /// In zh, this message translates to:
  /// **'Lumaris Team'**
  String get teamName;

  ///
  ///
  /// In zh, this message translates to:
  /// **'开源协议'**
  String get openSourceLicense;

  ///
  ///
  /// In zh, this message translates to:
  /// **'MIT License'**
  String get mitLicense;

  ///
  ///
  /// In zh, this message translates to:
  /// **'隐私协议'**
  String get privacyPolicy;

  ///
  ///
  /// In zh, this message translates to:
  /// **'了解我们如何保护你的隐私'**
  String get privacyPolicySubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get userAgreement;

  ///
  ///
  /// In zh, this message translates to:
  /// **'使用本应用即表示你同意本协议'**
  String get userAgreementSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在浏览器中打开'**
  String get protocolOpenInBrowser;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前平台无法在应用内显示协议内容，请前往浏览器查看。'**
  String get protocolInlineUnsupported;

  ///
  ///
  /// In zh, this message translates to:
  /// **'无法打开协议页面'**
  String get protocolOpenFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get clearCache;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在清除缓存...'**
  String get clearingCache;

  ///
  ///
  /// In zh, this message translates to:
  /// **'缓存清除成功'**
  String get cacheCleared;

  ///
  ///
  /// In zh, this message translates to:
  /// **'确定清除缓存吗？'**
  String get confirmClearCacheTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'这将删除所有缓存的数据，下次打开应用需要重新加载数据'**
  String get confirmClearCacheContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'退出教务系统'**
  String get logoutEduSystem;

  ///
  ///
  /// In zh, this message translates to:
  /// **'确定退出登录吗？'**
  String get confirmLogoutTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'退出后需要重新登录才能访问教务系统数据'**
  String get confirmLogoutContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  ///
  ///
  /// In zh, this message translates to:
  /// **'协议授权状态 [Debug]'**
  String get agreementAuthDebug;

  ///
  ///
  /// In zh, this message translates to:
  /// **'关闭后下次启动将重新显示授权页'**
  String get agreementAuthDebugSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加到桌面'**
  String get addToDesktop;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加小组件到桌面'**
  String get widgetSetupTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请按照以下步骤操作：'**
  String get widgetSetupIntro;

  ///
  ///
  /// In zh, this message translates to:
  /// **'长按手机桌面空白处'**
  String get widgetSetupStep1;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击“小组件”或“Widgets”选项'**
  String get widgetSetupStep2;

  ///
  ///
  /// In zh, this message translates to:
  /// **'找到“光序”并选择合适的小组件'**
  String get widgetSetupStep3;

  ///
  ///
  /// In zh, this message translates to:
  /// **'将小组件拖拽到桌面合适位置'**
  String get widgetSetupStep4;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提示：小组件可以显示今日课程等信息，方便快速查看'**
  String get widgetSetupTip;

  ///
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 更新下载弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'正在下载更新 {version}'**
  String downloadingUpdateTitle(Object version);

  /// 更新下载成功提示
  ///
  /// In zh, this message translates to:
  /// **'下载完成，正在安装...'**
  String get downloadCompletedInstalling;

  /// 更新下载失败提示
  ///
  /// In zh, this message translates to:
  /// **'下载失败: {error}'**
  String downloadFailed(Object error);

  ///
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  ///
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  ///
  ///
  /// In zh, this message translates to:
  /// **'收起侧边栏'**
  String get collapseSidebar;

  ///
  ///
  /// In zh, this message translates to:
  /// **'展开侧边栏'**
  String get expandSidebar;

  ///
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get notLoggedIn;

  ///
  ///
  /// In zh, this message translates to:
  /// **'教务系统'**
  String get academicSystem;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击登录'**
  String get clickToLogin;

  ///
  ///
  /// In zh, this message translates to:
  /// **'关闭窗口'**
  String get closeWindow;

  ///
  ///
  /// In zh, this message translates to:
  /// **'选择您要执行的操作'**
  String get closeWindowChoice;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示窗口'**
  String get showWindow;

  ///
  ///
  /// In zh, this message translates to:
  /// **'最小化到任务栏'**
  String get minimizeToTray;

  ///
  ///
  /// In zh, this message translates to:
  /// **'退出程序'**
  String get quitApp;

  ///
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get goToSettings;

  ///
  ///
  /// In zh, this message translates to:
  /// **'去授权'**
  String get goAuthorize;

  ///
  ///
  /// In zh, this message translates to:
  /// **'需要权限'**
  String get permissionRequired;

  ///
  ///
  /// In zh, this message translates to:
  /// **'该功能需要您授予相应权限才能正常使用'**
  String get permissionRequiredContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'权限已拒绝'**
  String get permissionDenied;

  ///
  ///
  /// In zh, this message translates to:
  /// **'该权限已被永久拒绝，请前往系统设置手动开启'**
  String get permissionDeniedContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'有新版本了！'**
  String get updateAvailable;

  ///
  ///
  /// In zh, this message translates to:
  /// **'忽略本次更新'**
  String get ignoreThisUpdate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'忽略所有更新'**
  String get ignoreAllUpdates;

  ///
  ///
  /// In zh, this message translates to:
  /// **'前往浏览器更新'**
  String get goToBrowserUpdate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'前往浏览器'**
  String get goToBrowser;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂不更新'**
  String get dontUpdate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'是否更新最新版本: {version}'**
  String confirmUpdateTitle(String version);

  ///
  ///
  /// In zh, this message translates to:
  /// **'发现新版本可用，将在浏览器中打开下载链接，是否继续？'**
  String get confirmUpdateContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更新日志'**
  String get updateLog;

  ///
  ///
  /// In zh, this message translates to:
  /// **'忽略版本更新'**
  String get ignoreVersionUpdate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'已打开浏览器，请在浏览器中下载安装更新'**
  String get updateOpened;

  ///
  ///
  /// In zh, this message translates to:
  /// **'打开更新链接失败'**
  String get openUpdateFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get loginRequired;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请先登录教务处账号'**
  String get pleaseLoginEduAccount;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加载失败，点击重试'**
  String get loadFailedTapRetry;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get empty;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加载中'**
  String get loading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在同步数据'**
  String get syncingData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'网络较慢时可能需要几秒，请稍等一下'**
  String get syncingDataSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'学分概览'**
  String get creditOverview;

  ///
  ///
  /// In zh, this message translates to:
  /// **'完成度'**
  String get completionRate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'分项学分'**
  String get itemizedCredits;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前时间存在多个冲突课程'**
  String get courseConflict;

  /// 课程提醒通知渠道名称
  ///
  /// In zh, this message translates to:
  /// **'课程通知'**
  String get notificationCourseChannelName;

  /// 课程提醒通知渠道描述
  ///
  /// In zh, this message translates to:
  /// **'进行每日课表的课程通知'**
  String get notificationCourseChannelDescription;

  /// 课程提醒通知渠道描述
  ///
  /// In zh, this message translates to:
  /// **'进行每日课表的课程通知，提前{minutes}分钟进行通知'**
  String notificationCourseAdvanceDescription(Object minutes);

  /// 待办提醒通知渠道名称
  ///
  /// In zh, this message translates to:
  /// **'待办事务提醒'**
  String get notificationTodoChannelName;

  /// 待办提醒通知渠道描述
  ///
  /// In zh, this message translates to:
  /// **'待办事务截止提醒'**
  String get notificationTodoChannelDescription;

  /// 课程提醒标题
  ///
  /// In zh, this message translates to:
  /// **'课程提醒'**
  String get courseReminderTitle;

  /// 课程提醒正文后缀
  ///
  /// In zh, this message translates to:
  /// **'将在{minutes}分钟后开始'**
  String courseReminderStartsIn(Object minutes);

  /// 后台运行权限标题
  ///
  /// In zh, this message translates to:
  /// **'允许后台运行'**
  String get allowBackgroundRun;

  /// 后台运行权限说明
  ///
  /// In zh, this message translates to:
  /// **'为了确保课程提醒能准时响铃，请允许应用在后台运行（忽略电池优化）。'**
  String get allowBackgroundRunContent;

  /// 闹钟权限标题
  ///
  /// In zh, this message translates to:
  /// **'请允许使用闹钟'**
  String get allowScheduleAlarm;

  /// 闹钟权限说明
  ///
  /// In zh, this message translates to:
  /// **'您需要允许使用闹钟才能使用通知功能'**
  String get allowScheduleAlarmContent;

  /// 保存失败提示
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请重试'**
  String get saveFailedRetry;

  /// 切换显示状态失败提示
  ///
  /// In zh, this message translates to:
  /// **'切换显示状态失败'**
  String get toggleTileVisibilityFailed;

  /// 重置失败提示
  ///
  /// In zh, this message translates to:
  /// **'重置失败'**
  String get resetFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络设置'**
  String get networkError;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请检查网络连接'**
  String get requestTimeout;

  ///
  ///
  /// In zh, this message translates to:
  /// **'服务器错误，请稍后重试'**
  String get serverError;

  ///
  ///
  /// In zh, this message translates to:
  /// **'未知错误，请重试'**
  String get unknownError;

  ///
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 光序'**
  String get agreementWelcomeTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在使用本应用前，请仔细阅读并同意以下协议。我们将严格遵守相关法律法规，保护您的个人信息安全。'**
  String get agreementDescription;

  ///
  ///
  /// In zh, this message translates to:
  /// **'了解我们如何收集、使用和保护你的个人信息'**
  String get agreementPrivacyDescription;

  ///
  ///
  /// In zh, this message translates to:
  /// **'了解使用本应用的权利、义务和免责条款'**
  String get agreementUserDescription;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击上方卡片可查看协议全文。继续使用即表示你已阅读并同意以上协议。'**
  String get agreementReadTip;

  ///
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get agreeAndContinue;

  ///
  ///
  /// In zh, this message translates to:
  /// **'不同意'**
  String get disagree;

  ///
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意'**
  String get loginAgreementPrefix;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请先阅读并同意用户协议和隐私协议'**
  String get loginAgreementRequired;

  ///
  ///
  /// In zh, this message translates to:
  /// **'开发团队：Lumaris Team\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile'**
  String get privacyContact;

  ///
  ///
  /// In zh, this message translates to:
  /// **'开发团队：Lumaris Team\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile'**
  String get userAgreementContact;

  ///
  ///
  /// In zh, this message translates to:
  /// **'关于作者'**
  String get aboutAuthor;

  ///
  ///
  /// In zh, this message translates to:
  /// **'核心团队'**
  String get coreTeam;

  ///
  ///
  /// In zh, this message translates to:
  /// **'特别致谢'**
  String get specialThanks;

  ///
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get contactUs;

  ///
  ///
  /// In zh, this message translates to:
  /// **'致谢'**
  String get thanksTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'感谢所有为本项目贡献代码、提出建议和报告问题的开发者和用户。你们的支持是我们前进的动力。特别感谢所有测试人员在开发阶段的辛勤付出。'**
  String get thanksContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'GitHub 仓库'**
  String get githubRepository;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加入我们'**
  String get joinUs;

  ///
  ///
  /// In zh, this message translates to:
  /// **'Made with ❤️ in Xi\'an'**
  String get madeWithLove;

  ///
  ///
  /// In zh, this message translates to:
  /// **'🎉 彩蛋'**
  String get easterEggTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'恭喜你发现了隐藏彩蛋！'**
  String get easterEggFound;

  ///
  ///
  /// In zh, this message translates to:
  /// **'你是少数知道这个秘密的人之一！\n\n感谢你对光序的喜爱与支持。\n\n继续探索，也许还有更多惊喜等着你...'**
  String get easterEggContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'字体设置'**
  String get fontSetting;

  ///
  ///
  /// In zh, this message translates to:
  /// **'为桌面平台选择字体(下次打开时才会应用)'**
  String get fontSettingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'系统默认'**
  String get systemDefault;

  ///
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get customFont;

  ///
  ///
  /// In zh, this message translates to:
  /// **'触觉反馈'**
  String get hapticFeedback;

  ///
  ///
  /// In zh, this message translates to:
  /// **'底部导航栏点击时震动'**
  String get hapticFeedbackSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示明日课程'**
  String get showTomorrowCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当今日无课时显示明日课程'**
  String get showTomorrowCoursesSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程通知'**
  String get courseReminder;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上课前进行提醒'**
  String get courseReminderSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提前几分钟提醒'**
  String get remindMinutesBefore;

  ///
  ///
  /// In zh, this message translates to:
  /// **'{n}分钟'**
  String remindMinutes(int n);

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程页'**
  String get schedulePage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'成绩页'**
  String get scorePage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'个人页'**
  String get profilePage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'打开应用的第一个页面'**
  String get firstPageOnLaunch;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get sunday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get monday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get tuesday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get wednesday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get thursday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get friday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get saturday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get sundayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get mondayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get tuesdayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get wednesdayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get thursdayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get fridayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get saturdayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'1月'**
  String get janShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'2月'**
  String get febShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'3月'**
  String get marShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'4月'**
  String get aprShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'5月'**
  String get mayShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'6月'**
  String get junShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'7月'**
  String get julShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'8月'**
  String get augShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'9月'**
  String get sepShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'10月'**
  String get octShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'11月'**
  String get novShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'12月'**
  String get decShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'{n}周'**
  String weekUnit(int n);

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前为第{n}周'**
  String currentWeek(int n);

  ///
  ///
  /// In zh, this message translates to:
  /// **'距离开学还有{n}周'**
  String weeksUntilStart(int n);

  ///
  ///
  /// In zh, this message translates to:
  /// **'第{start}-{end}节'**
  String periodRange(int start, int end);

  ///
  ///
  /// In zh, this message translates to:
  /// **'全部课表'**
  String get allSchedules;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上一周'**
  String get previousWeek;

  ///
  ///
  /// In zh, this message translates to:
  /// **'下一周'**
  String get nextWeek;

  ///
  ///
  /// In zh, this message translates to:
  /// **'切换样式'**
  String get switchStyle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新课表'**
  String get refreshSchedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课表设置'**
  String get scheduleSettingsTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'紧凑'**
  String get compact;

  ///
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get standard;

  ///
  ///
  /// In zh, this message translates to:
  /// **'宽松'**
  String get relaxed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'选择要查看的课程'**
  String get selectCourse;

  ///
  ///
  /// In zh, this message translates to:
  /// **'编辑课程'**
  String get editCourse;

  ///
  ///
  /// In zh, this message translates to:
  /// **'删除课程'**
  String get deleteCourse;

  ///
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  ///
  ///
  /// In zh, this message translates to:
  /// **'确定要删除课程\"{name}\"吗？'**
  String confirmDeleteCourseContent(String name);

  ///
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程修改成功'**
  String get courseModified;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程删除成功'**
  String get courseDeleted;

  ///
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get deleteFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'无地点'**
  String get noLocation;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加课程'**
  String get addCourse;

  ///
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程名称'**
  String get courseName;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上课地点'**
  String get courseRoom;

  ///
  ///
  /// In zh, this message translates to:
  /// **'授课教师'**
  String get courseTeacher;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程学分'**
  String get courseCredits;

  ///
  ///
  /// In zh, this message translates to:
  /// **'星期几'**
  String get courseWeekday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'开始节次'**
  String get courseStartUnit;

  ///
  ///
  /// In zh, this message translates to:
  /// **'结束节次'**
  String get courseEndUnit;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上课周次'**
  String get courseWeeks;

  ///
  ///
  /// In zh, this message translates to:
  /// **'已选{count}周'**
  String selectedWeeks(int count);

  ///
  ///
  /// In zh, this message translates to:
  /// **'自定义课程'**
  String get customCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'{count} 门课程'**
  String customCoursesCount(int count);

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无自定义课程'**
  String get noCustomCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击右上角 + 号添加课程'**
  String get noCustomCoursesSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取自定义课程'**
  String get readingCustomCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在整理本地保存的课程配置'**
  String get readingCustomCoursesSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程添加成功'**
  String get courseAdded;

  ///
  ///
  /// In zh, this message translates to:
  /// **'成绩与绩点'**
  String get scoresAndGpa;

  ///
  ///
  /// In zh, this message translates to:
  /// **'通过课程'**
  String get passedCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'总学分'**
  String get totalCredits;

  ///
  ///
  /// In zh, this message translates to:
  /// **'说明'**
  String get creditInfoTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数'**
  String get creditInfoContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'没有成绩'**
  String get noScores;

  ///
  ///
  /// In zh, this message translates to:
  /// **'建议刷新或退出重进'**
  String get noScoresSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新数据'**
  String get refreshDataBtn;

  ///
  ///
  /// In zh, this message translates to:
  /// **'前往登录'**
  String get goToLogin;

  ///
  ///
  /// In zh, this message translates to:
  /// **'辅修课程'**
  String get minorCourse;

  ///
  ///
  /// In zh, this message translates to:
  /// **'成绩详情'**
  String get scoreDetail;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程学分'**
  String get courseCreditLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程成绩'**
  String get courseScoreLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程绩点'**
  String get courseGpaLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在获取成绩数据...'**
  String get fetchingScores;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新失败，已回退到本地数据'**
  String get refreshFailedFallback;

  ///
  ///
  /// In zh, this message translates to:
  /// **'获取数据超时，请检查网络连接后重试'**
  String get fetchTimeout;

  ///
  ///
  /// In zh, this message translates to:
  /// **'获取数据失败'**
  String get fetchFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请先去登录即可查看成绩'**
  String get pleaseLoginFirst;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取缓存并同步教务成绩，网络较慢时可能需要几秒'**
  String get readingScoresSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'是的，在下绩点5.0'**
  String get foolishModeMessage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'{credit} 学分'**
  String creditUnit(String credit);

  ///
  ///
  /// In zh, this message translates to:
  /// **'成绩 {grade}'**
  String gradeLabel(String grade);

  ///
  ///
  /// In zh, this message translates to:
  /// **'绩点 {gpa}'**
  String gpaLabel(String gpa);

  ///
  ///
  /// In zh, this message translates to:
  /// **'{weekRanges}周 每周{weekday} 第{start}-{end}节'**
  String scheduleCourseTime(
    String weekRanges,
    String weekday,
    int start,
    int end,
  );

  ///
  ///
  /// In zh, this message translates to:
  /// **'{start}至{end}年 第{num}学期'**
  String semesterRange(String start, String end, String num);

  ///
  ///
  /// In zh, this message translates to:
  /// **'上'**
  String get semesterAutumnShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'下'**
  String get semesterSpringShort;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大一'**
  String get year1;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大二'**
  String get year2;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大三'**
  String get year3;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大四'**
  String get year4;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大五'**
  String get year5;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大六'**
  String get year6;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大七'**
  String get year7;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大八'**
  String get year8;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大九'**
  String get year9;

  ///
  ///
  /// In zh, this message translates to:
  /// **'大十'**
  String get year10;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录教务系统'**
  String get loginTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请使用您的账号继续'**
  String get loginSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'学号'**
  String get studentId;

  ///
  ///
  /// In zh, this message translates to:
  /// **'统一身份认证密码'**
  String get password;

  ///
  ///
  /// In zh, this message translates to:
  /// **'忘记密码?'**
  String get forgotPassword;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在登录教务系统'**
  String get loggingIn;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在验证账号并同步课程、成绩等基础数据，首次登录可能需要几秒'**
  String get loggingInSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'用户名和密码不能为空'**
  String get emptyCredentials;

  ///
  ///
  /// In zh, this message translates to:
  /// **'教务系统登录超时，请检查网络连接'**
  String get loginTimeoutEdu;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请检查用户名和密码'**
  String get loginFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录超时，请检查网络连接后重试'**
  String get loginTimeout;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录成功，但安全存储不可用，下次启动后可能需要重新输入账号密码'**
  String get loginSecurityStorageUnavailable;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在同步数据'**
  String get loadingDefaultTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'网络较慢时可能需要几秒，请稍等一下'**
  String get loadingDefaultSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'出错了'**
  String get errorOccurred;

  ///
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上课地点'**
  String get classroom;

  ///
  ///
  /// In zh, this message translates to:
  /// **'授课教师'**
  String get teacherLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上课时间'**
  String get classTime;

  ///
  ///
  /// In zh, this message translates to:
  /// **'上课校区'**
  String get classCampus;

  ///
  ///
  /// In zh, this message translates to:
  /// **'今日课表'**
  String get todayScheduleLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'明日课表'**
  String get tomorrowSchedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'今天没有课了'**
  String get noCourseToday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'好好休息会儿吧，学一天累死个人'**
  String get noCourseTodaySubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示明天的课表'**
  String get showTomorrowSchedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'再按一次退出应用'**
  String get doubleTapExit;

  ///
  ///
  /// In zh, this message translates to:
  /// **'已复制: {text}'**
  String copySuccess(String text);

  ///
  ///
  /// In zh, this message translates to:
  /// **'复制文本'**
  String get copyTooltip;

  ///
  ///
  /// In zh, this message translates to:
  /// **'页面设置'**
  String get pageSettings;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示校车磁贴'**
  String get showBusTile;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在首页显示最近的班车信息'**
  String get showBusTileSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加到首页'**
  String get addToHome;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在首页显示电费磁贴'**
  String get showElectricityTile;

  ///
  ///
  /// In zh, this message translates to:
  /// **'电费充值'**
  String get electricityRecharge;

  ///
  ///
  /// In zh, this message translates to:
  /// **'跳转至微信进行电费充值'**
  String get electricityRechargeSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示饭卡磁贴'**
  String get showPaymentTile;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在首页显示余额概览'**
  String get showPaymentTileSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更改'**
  String get change;

  ///
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  ///
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get done;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取待办事务'**
  String get readingTodos;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在加载本地待办列表与提醒状态'**
  String get readingTodosSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前没有待办事务'**
  String get noTodos;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击右上角添加待办事项'**
  String get noTodosSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'截止日期: {date}'**
  String deadlineLabel(String date);

  ///
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get noDeadline;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  ///
  ///
  /// In zh, this message translates to:
  /// **'近期考试'**
  String get upcomingExams;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在加载考试信息'**
  String get loadingExams;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在同步近期考试安排、考场和座位信息'**
  String get loadingExamsSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'最近没有考试'**
  String get noExams;

  ///
  ///
  /// In zh, this message translates to:
  /// **'说不定刷新一下就有了'**
  String get noExamsSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'考试时间'**
  String get examTime;

  ///
  ///
  /// In zh, this message translates to:
  /// **'考试地点'**
  String get examLocation;

  ///
  ///
  /// In zh, this message translates to:
  /// **'座位号'**
  String get seatNumber;

  ///
  ///
  /// In zh, this message translates to:
  /// **'座位号 {seat}'**
  String seatNumberLabel(String seat);

  ///
  ///
  /// In zh, this message translates to:
  /// **'未登录，请先登录'**
  String get examNotLoggedIn;

  ///
  ///
  /// In zh, this message translates to:
  /// **'认证失败，请重新登录'**
  String get examAuthFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'获取考试信息失败，轻点重试'**
  String get examFetchFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get quickFeatures;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无快捷功能'**
  String get noQuickFeatures;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请在编辑模式中添加'**
  String get noQuickFeaturesSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更多功能'**
  String get moreFeatures;

  ///
  ///
  /// In zh, this message translates to:
  /// **'导入到日历'**
  String get scheduleWidgetTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'订阅链接'**
  String get subscriptionLink;

  ///
  ///
  /// In zh, this message translates to:
  /// **'复制成功!'**
  String get copiedSuccess;

  ///
  ///
  /// In zh, this message translates to:
  /// **'不会导入？'**
  String get howToImport;

  ///
  ///
  /// In zh, this message translates to:
  /// **'自定义课程管理'**
  String get customCourseManage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示课表网格线'**
  String get showCourseGrid;

  ///
  ///
  /// In zh, this message translates to:
  /// **'无背景'**
  String get noBackground;

  ///
  ///
  /// In zh, this message translates to:
  /// **'自定义图片'**
  String get customImage;

  ///
  ///
  /// In zh, this message translates to:
  /// **'未选择图片'**
  String get noImageSelected;

  ///
  ///
  /// In zh, this message translates to:
  /// **'没有找到日历应用，请手动导入'**
  String get noCalendarApp;

  ///
  ///
  /// In zh, this message translates to:
  /// **'无法打开日历应用'**
  String get cannotOpenCalendar;

  ///
  ///
  /// In zh, this message translates to:
  /// **'背景图片设置成功'**
  String get bgImageSetSuccess;

  ///
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败'**
  String get selectImageFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加日历订阅'**
  String get addCalendarSub;

  ///
  ///
  /// In zh, this message translates to:
  /// **'明白了'**
  String get understand;

  ///
  ///
  /// In zh, this message translates to:
  /// **'日历订阅'**
  String get calendarSubscription;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课表管理'**
  String get scheduleManagement;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课表背景'**
  String get scheduleBackground;

  ///
  ///
  /// In zh, this message translates to:
  /// **'忽略课程'**
  String get ignoreCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在加载课表'**
  String get loadingSchedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取课程、偏好设置和背景配置'**
  String get loadingScheduleSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在更新课表...'**
  String get updatingSchedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更新完成'**
  String get updateComplete;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更新超时，请检查网络连接后重试'**
  String get updateTimeout;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更新失败: {error}'**
  String updateFailed(String error);

  ///
  ///
  /// In zh, this message translates to:
  /// **'链接已复制到剪贴板'**
  String get linkCopiedToClipboard;

  ///
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get currentWeekLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'第{n}节'**
  String periodUnit(int n);

  ///
  ///
  /// In zh, this message translates to:
  /// **'您的设备似乎没有应用可以直接处理日历订阅。请按照以下步骤手动添加:'**
  String get calendarGuidanceIntro;

  ///
  ///
  /// In zh, this message translates to:
  /// **'1. 打开您的日历应用'**
  String get calendarGuidanceStep1;

  ///
  ///
  /// In zh, this message translates to:
  /// **'2. 找到\"添加日历\"或\"订阅\"选项'**
  String get calendarGuidanceStep2;

  ///
  ///
  /// In zh, this message translates to:
  /// **'3. 选择\"通过URL添加\"或类似选项'**
  String get calendarGuidanceStep3;

  ///
  ///
  /// In zh, this message translates to:
  /// **'4. 粘贴以下链接:'**
  String get calendarGuidanceStep4;

  ///
  ///
  /// In zh, this message translates to:
  /// **'注意: 不同的日历应用可能有不同的添加步骤。如果您遇到困难，请查阅您的日历应用帮助文档。'**
  String get calendarGuidanceNote;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取账号信息'**
  String get profileReading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在同步本地登录状态和个人资料入口，请稍等一下'**
  String get profileReadingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'校园工具箱'**
  String get campusNavigation;

  ///
  ///
  /// In zh, this message translates to:
  /// **'设置/关于'**
  String get settingsAbout;

  ///
  ///
  /// In zh, this message translates to:
  /// **'培养方案'**
  String get programLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'校园地图'**
  String get campusMap;

  ///
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help;

  ///
  ///
  /// In zh, this message translates to:
  /// **'教务系统账号'**
  String get academicAccount;

  ///
  ///
  /// In zh, this message translates to:
  /// **'游客'**
  String get guest;

  ///
  ///
  /// In zh, this message translates to:
  /// **'游客模式'**
  String get guestMode;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录后可使用完整功能'**
  String get guestModeSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在同步学业信息'**
  String get syncingAcademic;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取学分与个人信息卡片'**
  String get syncingAcademicSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录教务系统'**
  String get loginEduSystem;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在加载培养方案'**
  String get programLoading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在整理学期课程结构和课程类别，请稍等一下'**
  String get programLoadingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get programLoadFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get programNoData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新失败，当前展示的是上次同步的培养方案'**
  String get programRefreshFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在加载导航链接'**
  String get linkLoading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在整理常用站点与分类入口'**
  String get linkLoadingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get linkLoadFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无导航数据'**
  String get linkNoData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请重新进入此页，或检查当前网络'**
  String get linkNoDataSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在同步饭卡余额'**
  String get paymentLoading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在获取最新流水，请稍候...'**
  String get paymentLoadingSubtitle;

  /// 饭卡查询用的可选密码标题
  ///
  /// In zh, this message translates to:
  /// **'饭卡密码'**
  String get paymentPasswordTitle;

  /// 饭卡密码输入说明
  ///
  /// In zh, this message translates to:
  /// **'可选，留空则按默认方式查询'**
  String get paymentPasswordSubtitle;

  /// 保存饭卡密码并立即刷新
  ///
  /// In zh, this message translates to:
  /// **'保存并刷新'**
  String get paymentSaveAndRefresh;

  ///
  ///
  /// In zh, this message translates to:
  /// **'校园一卡通'**
  String get campusCard;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前余额'**
  String get currentBalance;

  ///
  ///
  /// In zh, this message translates to:
  /// **'最近交易'**
  String get recentTransactions;

  ///
  ///
  /// In zh, this message translates to:
  /// **'支付'**
  String get paymentFilter;

  ///
  ///
  /// In zh, this message translates to:
  /// **'消费'**
  String get consumptionFilter;

  ///
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get rechargeFilter;

  ///
  ///
  /// In zh, this message translates to:
  /// **'无饭卡数据'**
  String get noCardData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请登录教务处账号以查看余额和交易流水'**
  String get noCardDataSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在获取校车班次'**
  String get busLoading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在按日期整理两校区往返班车信息'**
  String get busLoadingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'今天没有车了'**
  String get noBusToday;

  ///
  ///
  /// In zh, this message translates to:
  /// **'明天再来吧'**
  String get noBusTodaySubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'出发时间'**
  String get departureTime;

  ///
  ///
  /// In zh, this message translates to:
  /// **'终点站'**
  String get destination;

  ///
  ///
  /// In zh, this message translates to:
  /// **'预计到达'**
  String get estimatedArrival;

  ///
  ///
  /// In zh, this message translates to:
  /// **'班次信息'**
  String get busInfo;

  ///
  ///
  /// In zh, this message translates to:
  /// **'出发'**
  String get departure;

  ///
  ///
  /// In zh, this message translates to:
  /// **'到达'**
  String get arrival;

  ///
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  ///
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copiedToClipboard;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前余额'**
  String get electricityBalance;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get electricityNoData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'余额不足，请及时充值'**
  String get electricityLowBalance;

  ///
  ///
  /// In zh, this message translates to:
  /// **'余额充足'**
  String get electricitySufficient;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击右上角添加电费数据'**
  String get electricityAddTip;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在刷新用电趋势'**
  String get electricityLoading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取最新电费记录'**
  String get electricityLoadingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'没有用电明细'**
  String get noUsageDetails;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新后会在这里展示每小时花费'**
  String get noUsageDetailsSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'用电花费'**
  String get electricityCost;

  ///
  ///
  /// In zh, this message translates to:
  /// **'近{n}天'**
  String lastNDays(int n);

  ///
  ///
  /// In zh, this message translates to:
  /// **'总计花费'**
  String get totalCost;

  ///
  ///
  /// In zh, this message translates to:
  /// **'今日花费'**
  String get todayCost;

  ///
  ///
  /// In zh, this message translates to:
  /// **'日均花费'**
  String get avgDailyCost;

  ///
  ///
  /// In zh, this message translates to:
  /// **'峰值时段'**
  String get peakHours;

  ///
  ///
  /// In zh, this message translates to:
  /// **'每小时明细'**
  String get hourlyDetails;

  ///
  ///
  /// In zh, this message translates to:
  /// **'低余额订阅'**
  String get lowBalanceSub;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当余额低于阈值时...'**
  String get lowBalanceSubDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'先添加电费页面后...'**
  String get addElectricityFirst;

  ///
  ///
  /// In zh, this message translates to:
  /// **'还没有电费数据'**
  String get noElectricityData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'先在本页绑定宿舍电费链接...'**
  String get noElectricityDataSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'已开启低余额提醒'**
  String get lowBalanceEnabled;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加低余额提醒'**
  String get addLowBalanceAlert;

  ///
  ///
  /// In zh, this message translates to:
  /// **'删除订阅'**
  String get deleteSubscription;

  ///
  ///
  /// In zh, this message translates to:
  /// **'取消当前邮箱的低余额提醒...'**
  String get deleteSubDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'电费管理'**
  String get electricityManagement;

  ///
  ///
  /// In zh, this message translates to:
  /// **'选择要执行的操作'**
  String get chooseAction;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更换房间'**
  String get changeRoom;

  ///
  ///
  /// In zh, this message translates to:
  /// **'获取电费'**
  String get getElectricity;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请打开建大财务处电费详情页面，复制页面URL并粘贴到下方输入框'**
  String get electricityUrlPrompt;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请输入URL'**
  String get urlPlaceholder;

  ///
  ///
  /// In zh, this message translates to:
  /// **'添加低余额提醒'**
  String get createLowBalanceAlert;

  ///
  ///
  /// In zh, this message translates to:
  /// **'系统会使用当前绑定的宿舍电费页面，在余额低于设定阈值时发送邮件提醒。'**
  String get lowBalanceAlertDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提醒邮箱'**
  String get remindEmail;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提醒邮箱'**
  String get remindEmailPlaceholder;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提醒阈值，例如 10'**
  String get remindThreshold;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提醒阈值，例如 10'**
  String get remindThresholdPlaceholder;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请输入提醒邮箱'**
  String get pleaseEnterEmail;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的邮箱地址'**
  String get pleaseEnterValidEmail;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请输入大于 0 的提醒阈值'**
  String get pleaseEnterThreshold;

  ///
  ///
  /// In zh, this message translates to:
  /// **'低余额提醒已创建'**
  String get lowBalanceAlertCreated;

  ///
  ///
  /// In zh, this message translates to:
  /// **'创建电费订阅失败'**
  String get createSubFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前邮箱 {email} 低于 {threshold} 元时提醒'**
  String currentSubInfo(String email, String threshold);

  ///
  ///
  /// In zh, this message translates to:
  /// **'设置阈值后，余额低于该金额时将通过邮箱提醒'**
  String get subSetupHint;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提醒邮箱'**
  String get remindEmailLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet;

  ///
  ///
  /// In zh, this message translates to:
  /// **'提醒阈值'**
  String get remindThresholdLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get gotIt;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前没有可删除的订阅'**
  String get noSubToDelete;

  ///
  ///
  /// In zh, this message translates to:
  /// **'删除订阅'**
  String get deleteSubTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'确定要删除当前的低余额订阅吗？'**
  String get deleteSubConfirmContent;

  ///
  ///
  /// In zh, this message translates to:
  /// **'低余额提醒已删除'**
  String get lowBalanceAlertDeleted;

  ///
  ///
  /// In zh, this message translates to:
  /// **'删除电费订阅失败'**
  String get deleteSubFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'加载电费订阅失败'**
  String get electricitySubLoadFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'订阅内容'**
  String get subscriptionDetail;

  ///
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂不支持Web版'**
  String get webNotSupported;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请使用其他版本'**
  String get webNotSupportedSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'重新排序失败'**
  String get reorderFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'搜索地点或建筑...'**
  String get searchLocation;

  ///
  ///
  /// In zh, this message translates to:
  /// **'搜索...'**
  String get search;

  ///
  ///
  /// In zh, this message translates to:
  /// **'建筑介绍'**
  String get buildingIntro;

  ///
  ///
  /// In zh, this message translates to:
  /// **'具体位置'**
  String get specificLocation;

  ///
  ///
  /// In zh, this message translates to:
  /// **'开源许可证'**
  String get licenseTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取许可证'**
  String get licenseLoading;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在加载应用附带的开源协议文本'**
  String get licenseLoadingSubtitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'无法加载许可证文件'**
  String get licenseLoadFailed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'功能介绍'**
  String get helpFeaturesTab;

  ///
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get helpInstructionsTab;

  ///
  ///
  /// In zh, this message translates to:
  /// **'注意事项'**
  String get helpNotesTab;

  ///
  ///
  /// In zh, this message translates to:
  /// **'关于应用'**
  String get helpAboutTab;

  ///
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get helpFeatureHome;

  ///
  ///
  /// In zh, this message translates to:
  /// **'信息中心，展示个人信息、课程、待办事项和考试安排'**
  String get helpFeatureHomeDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程表'**
  String get helpFeatureSchedule;

  ///
  ///
  /// In zh, this message translates to:
  /// **'管理周课程安排，支持切换校区和设置提醒'**
  String get helpFeatureScheduleDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'成绩查询'**
  String get helpFeatureScore;

  ///
  ///
  /// In zh, this message translates to:
  /// **'查看学期成绩单、绩点计算和分析'**
  String get helpFeatureScoreDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'个人资料'**
  String get helpFeatureProfile;

  ///
  ///
  /// In zh, this message translates to:
  /// **'展示学号、姓名、学院等个人信息'**
  String get helpFeatureProfileDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'校园巴士'**
  String get helpFeatureBus;

  ///
  ///
  /// In zh, this message translates to:
  /// **'查看校区间班车时刻表和路线信息'**
  String get helpFeatureBusDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'培养方案'**
  String get helpFeatureProgram;

  ///
  ///
  /// In zh, this message translates to:
  /// **'显示专业培养计划和学分要求'**
  String get helpFeatureProgramDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'电费查询'**
  String get helpFeatureElectricity;

  ///
  ///
  /// In zh, this message translates to:
  /// **'查看宿舍电量和用电历史记录'**
  String get helpFeatureElectricityDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'饭卡消费'**
  String get helpFeaturePayment;

  ///
  ///
  /// In zh, this message translates to:
  /// **'查看饭卡余额和消费明细'**
  String get helpFeaturePaymentDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'常用链接'**
  String get helpFeatureLinks;

  ///
  ///
  /// In zh, this message translates to:
  /// **'收集教务系统等常用工具链接'**
  String get helpFeatureLinksDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'登录与账户'**
  String get helpInstructionLogin;

  ///
  ///
  /// In zh, this message translates to:
  /// **'首次使用需登录教务系统账户'**
  String get helpInstructionLoginDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'课程管理'**
  String get helpInstructionCourse;

  ///
  ///
  /// In zh, this message translates to:
  /// **'进入课程表查看当周课程，左右滑动切换周次，点击课程查看详情'**
  String get helpInstructionCourseDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'日程提醒'**
  String get helpInstructionReminder;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在设置中开启课程提醒，应用会在上课前发送通知提醒'**
  String get helpInstructionReminderDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'数据同步'**
  String get helpInstructionSync;

  ///
  ///
  /// In zh, this message translates to:
  /// **'应用自动同步教务系统数据，需要网络连接。下拉刷新可手动更新'**
  String get helpInstructionSyncDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'桌面小组件'**
  String get helpInstructionWidget;

  ///
  ///
  /// In zh, this message translates to:
  /// **'在桌面长按添加应用小组件，快速查看课程信息'**
  String get helpInstructionWidgetDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请保持应用更新以获得最新功能和修复'**
  String get helpNoteUpdate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'数据不准确时，请检查是否正确登录教务系统'**
  String get helpNoteData;

  ///
  ///
  /// In zh, this message translates to:
  /// **'遇到问题可通过设置页面进行反馈'**
  String get helpNoteFeedback;

  ///
  ///
  /// In zh, this message translates to:
  /// **'应用不会收集或上传您的个人隐私信息'**
  String get helpNotePrivacy;

  ///
  ///
  /// In zh, this message translates to:
  /// **'平台支持'**
  String get helpAboutPlatform;

  ///
  ///
  /// In zh, this message translates to:
  /// **'跨平台应用，支持以下平台：'**
  String get helpAboutPlatformDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'开源项目'**
  String get helpAboutOpenSource;

  ///
  ///
  /// In zh, this message translates to:
  /// **'本应用基于 MIT 许可证开源'**
  String get helpAboutOpenSourceDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'仓库地址：'**
  String get helpAboutRepoLabel;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在维护！'**
  String get underMaintenanceTitle;

  ///
  ///
  /// In zh, this message translates to:
  /// **'我们目前正在进行定期维护。请稍后再查看。感谢您的耐心等待。'**
  String get underMaintenanceDescription;

  ///
  ///
  /// In zh, this message translates to:
  /// **'正在读取饭卡'**
  String get readingPaymentCard;

  ///
  ///
  /// In zh, this message translates to:
  /// **'余额不足'**
  String get lowBalance;

  ///
  ///
  /// In zh, this message translates to:
  /// **'饭卡余额'**
  String get campusCardBalance;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击查看'**
  String get tapToView;

  ///
  ///
  /// In zh, this message translates to:
  /// **'点击订阅'**
  String get tapToSubscribe;

  ///
  ///
  /// In zh, this message translates to:
  /// **'草堂'**
  String get campusCaoTang;

  ///
  ///
  /// In zh, this message translates to:
  /// **'雁塔'**
  String get campusYanTa;

  ///
  ///
  /// In zh, this message translates to:
  /// **'刷新完成，已保留上次校车数据'**
  String get busRefreshStale;

  ///
  ///
  /// In zh, this message translates to:
  /// **'{h}小时 {m}分钟'**
  String arrivalStationTime(String h, String m);

  ///
  ///
  /// In zh, this message translates to:
  /// **'主图书馆'**
  String get poiMainLibrary;

  ///
  ///
  /// In zh, this message translates to:
  /// **'24小时开放自习室'**
  String get poiMainLibraryDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'草堂校区北门'**
  String get poiCaoTangNorthGate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'学校主入口'**
  String get poiCaoTangNorthGateDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'雁塔校区东门'**
  String get poiYanTaEastGate;

  ///
  ///
  /// In zh, this message translates to:
  /// **'历史悠久的老校区入口'**
  String get poiYanTaEastGateDesc;

  ///
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get shortcuts;

  ///
  ///
  /// In zh, this message translates to:
  /// **'更多功能'**
  String get moreFunctions;

  ///
  ///
  /// In zh, this message translates to:
  /// **'暂无快捷功能'**
  String get noShortcuts;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请在编辑模式中添加'**
  String get addInEditMode;

  ///
  ///
  /// In zh, this message translates to:
  /// **'教务系统'**
  String get eduSystem;

  ///
  ///
  /// In zh, this message translates to:
  /// **'HTML导入'**
  String get htmlImport;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请粘贴课表HTML代码'**
  String get pasteHtmlHint;

  ///
  ///
  /// In zh, this message translates to:
  /// **'解析预览'**
  String get parseAndPreview;

  ///
  ///
  /// In zh, this message translates to:
  /// **'导入课程'**
  String get importCourses;

  ///
  ///
  /// In zh, this message translates to:
  /// **'解析结果'**
  String get parseResult;

  ///
  ///
  /// In zh, this message translates to:
  /// **'未解析到课程'**
  String get noCoursesParsed;

  ///
  ///
  /// In zh, this message translates to:
  /// **'搜索学校…'**
  String get searchSchool;

  ///
  ///
  /// In zh, this message translates to:
  /// **'基础'**
  String get basicSupport;

  ///
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get advancedSupport;

  ///
  ///
  /// In zh, this message translates to:
  /// **'当前学校不支持此功能'**
  String get schoolNotSupported;

  ///
  ///
  /// In zh, this message translates to:
  /// **'切换学校'**
  String get switchSchool;

  ///
  ///
  /// In zh, this message translates to:
  /// **'选择学校'**
  String get selectSchool;

  ///
  ///
  /// In zh, this message translates to:
  /// **'或输入自定义网址'**
  String get enterCustomUrl;

  ///
  ///
  /// In zh, this message translates to:
  /// **'请输入网址'**
  String get urlHint;

  ///
  ///
  /// In zh, this message translates to:
  /// **'ICP备案号'**
  String get icp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'fr',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
