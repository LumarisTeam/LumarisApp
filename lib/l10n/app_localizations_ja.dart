// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Lumaris';

  @override
  String get appSlogan => 'キャンパスライフをひとつのアプリに';

  @override
  String get tagline => '大学生により良いサービスを';

  @override
  String get home => 'ホーム';

  @override
  String get schedule => '時間割';

  @override
  String get score => '成績';

  @override
  String get profile => 'マイ';

  @override
  String get electricity => '電気料金';

  @override
  String get schoolBus => '学内バス';

  @override
  String get payment => 'カード';

  @override
  String get map => 'マップ';

  @override
  String get settings => '設定';

  @override
  String get basicSettings => '基本設定';

  @override
  String get version => 'バージョン';

  @override
  String get widgets => 'ウィジェット';

  @override
  String get about => 'アプリについて';

  @override
  String get other => 'その他';

  @override
  String get feedback => 'フィードバック';

  @override
  String get feedbackSubtitle => '問題の報告や改善案を送信できます';

  @override
  String get feedbackContentLabel => '内容';

  @override
  String get feedbackContentHint => '発生した問題について説明してください';

  @override
  String get feedbackContentRequired => '問題の内容を入力してください';

  @override
  String get feedbackContactLabel => '連絡先';

  @override
  String get feedbackContactHint => '電話番号 / メールアドレス / QQ など';

  @override
  String get feedbackContactRequired => '連絡先を入力してください';

  @override
  String get feedbackImagesLabel => '画像（任意、最大6枚）';

  @override
  String get feedbackAddImage => '画像を追加';

  @override
  String get feedbackSubmit => '送信';

  @override
  String get feedbackSubmitting => '送信中…';

  @override
  String get feedbackSubmitSuccess => 'フィードバックを送信しました。ご協力ありがとうございます！';

  @override
  String get feedbackPickImageFailed => '画像を選択できませんでした。もう一度お試しください';

  @override
  String get feedbackImageUploadFailed => '画像をアップロードできませんでした。もう一度お試しください';

  @override
  String get feedbackImageTooMany => '画像は6枚まで追加できます';

  @override
  String get refreshData => 'データ更新';

  @override
  String get refreshingData => 'データ更新中...';

  @override
  String get refreshDataSuccess => 'データ更新完了';

  @override
  String get refreshDataFailed => 'データ更新に失敗しました';

  @override
  String get appearance => '外観';

  @override
  String get followSystem => 'システム';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get systemLanguage => 'システム';

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
  String get team => 'チーム';

  @override
  String get teamName => 'Lumaris Team';

  @override
  String get openSourceLicense => 'オープンソースライセンス';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get privacyPolicySubtitle => 'あなたのプライバシーをどのように保護するか';

  @override
  String get userAgreement => '利用規約';

  @override
  String get userAgreementSubtitle => '本アプリの使用により本規約に同意したものとみなします';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get clearingCache => 'キャッシュをクリア中...';

  @override
  String get cacheCleared => 'キャッシュをクリアしました';

  @override
  String get confirmClearCacheTitle => 'キャッシュをクリアしますか？';

  @override
  String get confirmClearCacheContent => 'キャッシュされたデータがすべて削除され、次回起動時に再読み込みされます';

  @override
  String get logoutEduSystem => '学務システムからログアウト';

  @override
  String get confirmLogoutTitle => 'ログアウトしますか？';

  @override
  String get confirmLogoutContent => '学務システムのデータにアクセスするには再度ログインが必要です';

  @override
  String get logout => 'ログアウト';

  @override
  String get agreementAuthDebug => '同意認証状態 [Debug]';

  @override
  String get agreementAuthDebugSubtitle => 'オフにすると次回起動時に同意ページが再表示されます';

  @override
  String get addToDesktop => 'ホーム画面に追加';

  @override
  String get widgetSetupTitle => 'ウィジェットをホーム画面に追加';

  @override
  String get widgetSetupIntro => '以下の手順に従ってください：';

  @override
  String get widgetSetupStep1 => 'ホーム画面の何もない場所を長押し';

  @override
  String get widgetSetupStep2 => '「ウィジェット」をタップ';

  @override
  String get widgetSetupStep3 => 'Lumarisを見つけてウィジェットを選択';

  @override
  String get widgetSetupStep4 => 'ウィジェットを適切な位置にドラッグ';

  @override
  String get widgetSetupTip => 'ヒント：ウィジェットで今日の授業を素早く確認できます';

  @override
  String get cancel => 'キャンセル';

  @override
  String downloadingUpdateTitle(Object version) {
    return '更新 $version をダウンロード中';
  }

  @override
  String get downloadCompletedInstalling => 'ダウンロードが完了しました。インストールを開始します...';

  @override
  String downloadFailed(Object error) {
    return 'ダウンロードに失敗しました: $error';
  }

  @override
  String get confirm => '確認';

  @override
  String get back => '戻る';

  @override
  String get collapseSidebar => 'サイドバーを折りたたむ';

  @override
  String get expandSidebar => 'サイドバーを展開';

  @override
  String get notLoggedIn => '未ログイン';

  @override
  String get academicSystem => '学務システム';

  @override
  String get clickToLogin => 'タップしてログイン';

  @override
  String get closeWindow => 'ウィンドウを閉じる';

  @override
  String get closeWindowChoice => '操作を選択してください';

  @override
  String get showWindow => 'ウィンドウを表示';

  @override
  String get minimizeToTray => 'タスクトレイに最小化';

  @override
  String get quitApp => '終了';

  @override
  String get goToSettings => '設定へ';

  @override
  String get goAuthorize => '許可する';

  @override
  String get permissionRequired => '権限が必要です';

  @override
  String get permissionRequiredContent => 'この機能を使用するには対応する権限が必要です';

  @override
  String get permissionDenied => '権限が拒否されました';

  @override
  String get permissionDeniedContent => 'この権限は永続的に拒否されました。システム設定で有効にしてください';

  @override
  String get updateAvailable => '新しいバージョンがあります！';

  @override
  String get ignoreThisUpdate => '今回の更新をスキップ';

  @override
  String get ignoreAllUpdates => 'すべての更新を無視';

  @override
  String get goToBrowserUpdate => 'ブラウザで開く';

  @override
  String get goToBrowser => 'ブラウザで開く';

  @override
  String get dontUpdate => '後で';

  @override
  String confirmUpdateTitle(String version) {
    return '最新バージョンに更新しますか: $version？';
  }

  @override
  String get confirmUpdateContent => '新しいバージョンが利用可能です。ブラウザでダウンロードリンクを開きますか？';

  @override
  String get updateLog => '更新ログ';

  @override
  String get ignoreVersionUpdate => '更新を無視';

  @override
  String get updateOpened => 'ブラウザを開きました。ブラウザで更新をダウンロードしてください';

  @override
  String get openUpdateFailed => '更新リンクを開けませんでした';

  @override
  String get loginRequired => '先にログインしてください';

  @override
  String get pleaseLoginEduAccount => '先に学務アカウントにログインしてください';

  @override
  String get loadFailedTapRetry => '読み込みに失敗しました。タップして再試行';

  @override
  String get empty => 'データなし';

  @override
  String get loading => '読み込み中';

  @override
  String get syncingData => 'データ同期中';

  @override
  String get syncingDataSubtitle => '低速ネットワークでは数秒かかる場合があります';

  @override
  String get creditOverview => '単位概要';

  @override
  String get completionRate => '完了率';

  @override
  String get itemizedCredits => '単位内訳';

  @override
  String get courseConflict => 'この時間帯に複数の授業が重複しています';

  @override
  String get notificationCourseChannelName => '授業リマインダー';

  @override
  String get notificationCourseChannelDescription => '毎日の時間割に関する通知';

  @override
  String notificationCourseAdvanceDescription(Object minutes) {
    return '毎日の時間割に関する通知を $minutes 分前に送信します';
  }

  @override
  String get notificationTodoChannelName => 'ToDo リマインダー';

  @override
  String get notificationTodoChannelDescription => 'ToDo の期限リマインダー';

  @override
  String get courseReminderTitle => '授業リマインダー';

  @override
  String courseReminderStartsIn(Object minutes) {
    return '$minutes 分後に開始します';
  }

  @override
  String get todoReminderTitle => 'ToDo リマインダー';

  @override
  String todoReminderBody(Object title) {
    return 'ToDo「$title」の期限です';
  }

  @override
  String get allowBackgroundRun => 'バックグラウンド実行を許可';

  @override
  String get allowBackgroundRunContent =>
      '授業リマインダーを時間どおりに鳴らすため、アプリのバックグラウンド実行とバッテリー最適化の除外を許可してください。';

  @override
  String get allowScheduleAlarm => 'アラームを許可';

  @override
  String get allowScheduleAlarmContent => '通知機能を使うにはアラームの許可が必要です。';

  @override
  String get saveFailedRetry => '保存に失敗しました。もう一度お試しください';

  @override
  String get toggleTileVisibilityFailed => '表示状態の切り替えに失敗しました';

  @override
  String get resetFailed => 'リセットに失敗しました';

  @override
  String get networkError => 'ネットワーク接続に失敗しました。ネットワーク設定を確認してください';

  @override
  String get requestTimeout => 'リクエストがタイムアウトしました。ネットワーク接続を確認してください';

  @override
  String get serverError => 'サーバーエラー。しばらくしてから再試行してください';

  @override
  String get unknownError => '不明なエラー。再試行してください';

  @override
  String get agreementWelcomeTitle => 'Lumaris へようこそ';

  @override
  String get agreementDescription =>
      'アプリを使用する前に、以下の規約をお読みいただき同意してください。適用される法令に従い、お客様の個人情報を保護します。';

  @override
  String get agreementPrivacyDescription => '個人情報の収集、使用、保護方法について';

  @override
  String get agreementUserDescription => '本アプリ使用時の権利、義務、免責事項について';

  @override
  String get agreementReadTip =>
      '上のカードをタップして全文を表示できます。続行すると、これらの規約を読み同意したものとみなします。';

  @override
  String get agreeAndContinue => '同意して続行';

  @override
  String get disagree => '同意しない';

  @override
  String get loginAgreementPrefix => 'ログインすることで、以下の規約に同意したものとみなされます：';

  @override
  String get loginAgreementRequired => '利用規約とプライバシーポリシーを必ずご確認の上、同意してください。';

  @override
  String get privacyPolicyTitle => 'Lumaris プライバシーポリシー';

  @override
  String get privacyPolicyUpdatedAt => '更新日：2026年5月5日';

  @override
  String get privacyPolicyEffectiveAt => '発効日：2026年5月5日';

  @override
  String get privacyPolicyIntro =>
      'Lumaris へようこそ。このプライバシーポリシーでは、個人情報の収集、使用、保存、保護方法について説明します。';

  @override
  String get privacySection1Title => '1. 収集する情報';

  @override
  String get privacySection1_1 =>
      '1.1 アカウント情報：学務システムのログイン機能を使用する際、学籍番号とパスワードが必要です。この情報はお客様のデバイスにのみ保存されます。';

  @override
  String get privacySection1_2 =>
      '1.2 授業・成績情報：ログイン後、アプリは学務システムから時間割、成績、履修計画などを取得します。';

  @override
  String get privacySection1_3 =>
      '1.3 キャンパス生活情報：関連機能の使用時に、電気料金残高、食堂カード取引、ネットワーク使用量などを取得する場合があります。';

  @override
  String get privacySection1_4 =>
      '1.4 デバイス情報：分析とトラブルシューティングのためにデバイスモデルとOSバージョンを収集する場合があります。';

  @override
  String get privacySection1_5 =>
      '1.5 キャッシュデータ：パフォーマンス向上のため、一部のデータをローカルにキャッシュします。設定でいつでもクリアできます。';

  @override
  String get privacySection2Title => '2. 情報の利用方法';

  @override
  String get privacySection2_1 => '2.1 コアサービスの提供のため。';

  @override
  String get privacySection2_2 => '2.2 サービス品質向上のため。';

  @override
  String get privacySection2_3 => '2.3 ホーム画面ウィジェットのサポートのため。';

  @override
  String get privacySection2_4 => '2.4 ローカル通知のスケジュールのため。';

  @override
  String get privacySection3Title => '3. 保存とセキュリティ';

  @override
  String get privacySection3_1 => '3.1 個人情報はお客様のデバイスにローカル保存されます。';

  @override
  String get privacySection3_2 => '3.2 アプリと学校サーバー間のデータ通信は暗号化されています。';

  @override
  String get privacySection3_3 => '3.3 キャッシュデータのクリアやログアウトはいつでも可能です。';

  @override
  String get privacySection4Title => '4. サードパーティサービス';

  @override
  String get privacySection4_1 => '4.1 本アプリは学務機能を提供するために大学の学務システムと通信します。';

  @override
  String get privacySection4_2 => '4.2 本アプリはGiteeを通じて更新情報を確認します。';

  @override
  String get privacySection4_3 => '4.3 個人情報を第三者に販売または貸与することはありません。';

  @override
  String get privacySection5Title => '5. お客様の権利';

  @override
  String get privacySection5_1 => '5.1 アプリ内で情報の確認と訂正が可能です。';

  @override
  String get privacySection5_2 =>
      '5.2 ログアウト、キャッシュクリア、またはアンインストールによりデータを削除できます。';

  @override
  String get privacySection5_3 => '5.3 ログアウトまたはアンインストールにより同意を撤回できます。';

  @override
  String get privacySection6Title => '6. 未成年者';

  @override
  String get privacySection6_1 => '6.1 本アプリは主に大学生を対象としています。';

  @override
  String get privacySection6_2 => '6.2 未成年者の個人情報を積極的に収集することはありません。';

  @override
  String get privacySection7Title => '7. 本ポリシーの更新';

  @override
  String get privacySection7_1 => '7.1 本ポリシーは随時更新される場合があります。';

  @override
  String get privacySection7_2 => '7.2 更新後の継続利用は更新されたポリシーに同意したものとみなします。';

  @override
  String get privacySection8Title => '8. お問い合わせ';

  @override
  String get privacySection8_1 => 'ご質問やご提案がございましたら、以下までご連絡ください：';

  @override
  String get privacyContact =>
      '開発チーム：Lumaris Team\nリポジトリ：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get userAgreementTitle => 'Lumaris 利用規約';

  @override
  String get userAgreementUpdatedAt => '更新日：2026年5月5日';

  @override
  String get userAgreementEffectiveAt => '発効日：2026年5月5日';

  @override
  String get userAgreementIntro => 'Lumaris へようこそ。アプリを使用する前にこの利用規約をよくお読みください。';

  @override
  String get userAgreementSection1Title => '1. サービス説明';

  @override
  String get userAgreementSection1_1 => '1.1 本アプリは学生向けのキャンパスアシスタントアプリです。';

  @override
  String get userAgreementSection1_2 => '1.2 一部の機能は大学ネットワークへのアクセスが必要です。';

  @override
  String get userAgreementSection1_3 => '1.3 学務データは参考用です。公式の学校システムが優先されます。';

  @override
  String get userAgreementSection2Title => '2. アカウントとセキュリティ';

  @override
  String get userAgreementSection2_1 => '2.1 学務システムのアカウントでログインする必要があります。';

  @override
  String get userAgreementSection2_2 => '2.2 認証情報はお客様のデバイスにのみ保存されます。';

  @override
  String get userAgreementSection2_3 => '2.3 アカウントにリスクがある場合は直ちにパスワードを変更してください。';

  @override
  String get userAgreementSection3Title => '3. 利用者の行動';

  @override
  String get userAgreementSection3_1 => '3.1 適用法令を遵守する必要があります。';

  @override
  String get userAgreementSection3_2 => '3.2 MITライセンスの下でソースコードを使用できます。';

  @override
  String get userAgreementSection3_3 => '3.3 アプリの通常動作を妨害してはいけません。';

  @override
  String get userAgreementSection3_4 => '3.4 脆弱性を悪用して不正アクセスを行ってはいけません。';

  @override
  String get userAgreementSection4Title => '4. 知的財産権';

  @override
  String get userAgreementSection4_1 => '4.1 ソースコードはMITライセンスの下で公開されています。';

  @override
  String get userAgreementSection4_2 =>
      '4.2 アプリ名、アイコン、UIデザインはLumaris Teamに帰属します。';

  @override
  String get userAgreementSection4_3 => '4.3 学校名とロゴは大学に帰属します。';

  @override
  String get userAgreementSection5Title => '5. 免責事項';

  @override
  String get userAgreementSection5_1 => '5.1 本アプリは現状有姿で提供されます。';

  @override
  String get userAgreementSection5_2 =>
      '5.2 ネットワークや学校サーバーの問題による中断について責任を負いません。';

  @override
  String get userAgreementSection5_3 => '5.3 学務情報は参考用です。';

  @override
  String get userAgreementSection5_4 =>
      '5.4 法令で義務付けられている場合を除き、アプリ使用による機器の損傷やデータ損失について責任を負いません。';

  @override
  String get userAgreementSection6Title => '6. 変更と終了';

  @override
  String get userAgreementSection6_1 => '6.1 本規約は随時変更される場合があります。';

  @override
  String get userAgreementSection6_2 => '6.2 変更後の継続利用は更新された規約に同意したものとみなします。';

  @override
  String get userAgreementSection6_3 => '6.3 必要に応じてサービスを終了する場合があります。';

  @override
  String get userAgreementSection7Title => '7. その他';

  @override
  String get userAgreementSection7_1 => '7.1 いずれかの条項が無効でも、残りの条項は有効に存続します。';

  @override
  String get userAgreementSection7_2 => '7.2 本規約は中華人民共和国の法律に準拠します。';

  @override
  String get userAgreementSection7_3 => '7.3 紛争は友好的な協議により解決するものとします。';

  @override
  String get userAgreementSection8Title => '8. お問い合わせ';

  @override
  String get userAgreementSection8_1 => '本規約に関するご質問は以下までご連絡ください：';

  @override
  String get userAgreementContact =>
      '開発チーム：Lumaris Team\nリポジトリ：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get aboutAuthor => '作者について';

  @override
  String get coreTeam => 'コアチーム';

  @override
  String get specialThanks => 'スペシャルサンクス';

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get thanksTitle => '謝辞';

  @override
  String get thanksContent => 'コード、提案、バグ報告を提供してくださったすべての開発者とユーザーに感謝します。';

  @override
  String get githubRepository => 'GitHub リポジトリ';

  @override
  String get joinUs => '参加する';

  @override
  String get madeWithLove => '西安で❤️を込めて作られました';

  @override
  String get easterEggTitle => '🎉 イースターエッグ';

  @override
  String get easterEggFound => 'おめでとうございます！隠されたイースターエッグを見つけました！';

  @override
  String get easterEggContent =>
      'この秘密を知る数少ない人の一人です！\n\nLumarisを愛しサポートしてくださりありがとうございます。\n\n探索を続ければ、さらなる驚きが待っているかもしれません...';

  @override
  String get fontSetting => 'フォント設定';

  @override
  String get fontSettingSubtitle => 'デスクトップのフォントを選択（次回起動時に適用）';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get customFont => 'カスタム';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get hapticFeedbackSubtitle => 'ボトムナビゲーションタップ時に振動';

  @override
  String get cloudSyncTodo => 'ToDoをクラウドに保存';

  @override
  String get servicePaused => 'サービス一時停止中';

  @override
  String get showTomorrowCourses => '明日の授業を表示';

  @override
  String get showTomorrowCoursesSubtitle => '本日の授業がない場合に明日の授業を表示';

  @override
  String get courseReminder => '授業リマインダー';

  @override
  String get courseReminderSubtitle => '授業前にリマインド';

  @override
  String get remindMinutesBefore => '何分前にリマインドするか';

  @override
  String remindMinutes(int n) {
    return '$n分';
  }

  @override
  String get todoReminder => 'ToDoリマインダー';

  @override
  String get todoReminderSubtitle => 'ToDoの期限前にリマインド';

  @override
  String get schedulePage => '時間割';

  @override
  String get scorePage => '成績';

  @override
  String get profilePage => 'プロフィール';

  @override
  String get firstPageOnLaunch => '起動時の最初のページ';

  @override
  String get sunday => '日曜日';

  @override
  String get monday => '月曜日';

  @override
  String get tuesday => '火曜日';

  @override
  String get wednesday => '水曜日';

  @override
  String get thursday => '木曜日';

  @override
  String get friday => '金曜日';

  @override
  String get saturday => '土曜日';

  @override
  String get sundayShort => '日';

  @override
  String get mondayShort => '月';

  @override
  String get tuesdayShort => '火';

  @override
  String get wednesdayShort => '水';

  @override
  String get thursdayShort => '木';

  @override
  String get fridayShort => '金';

  @override
  String get saturdayShort => '土';

  @override
  String get janShort => '1月';

  @override
  String get febShort => '2月';

  @override
  String get marShort => '3月';

  @override
  String get aprShort => '4月';

  @override
  String get mayShort => '5月';

  @override
  String get junShort => '6月';

  @override
  String get julShort => '7月';

  @override
  String get augShort => '8月';

  @override
  String get sepShort => '9月';

  @override
  String get octShort => '10月';

  @override
  String get novShort => '11月';

  @override
  String get decShort => '12月';

  @override
  String weekUnit(int n) {
    return '第$n週';
  }

  @override
  String currentWeek(int n) {
    return '現在第$n週';
  }

  @override
  String weeksUntilStart(int n) {
    return '開講まであと$n週間';
  }

  @override
  String periodRange(int start, int end) {
    return '$start-$end限';
  }

  @override
  String get allSchedules => '全時間割';

  @override
  String get previousWeek => '前の週';

  @override
  String get nextWeek => '次の週';

  @override
  String get switchStyle => '表示切替';

  @override
  String get refreshSchedule => '時間割を更新';

  @override
  String get scheduleSettingsTitle => '時間割設定';

  @override
  String get compact => 'コンパクト';

  @override
  String get standard => '標準';

  @override
  String get relaxed => 'リラックス';

  @override
  String get selectCourse => '授業を選択';

  @override
  String get editCourse => '授業を編集';

  @override
  String get deleteCourse => '授業を削除';

  @override
  String get confirmDelete => '削除確認';

  @override
  String confirmDeleteCourseContent(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String get delete => '削除';

  @override
  String get courseModified => '授業を更新しました';

  @override
  String get courseDeleted => '授業を削除しました';

  @override
  String get deleteFailed => '削除に失敗しました';

  @override
  String get noLocation => '場所なし';

  @override
  String get addCourse => '授業を追加';

  @override
  String get save => '保存';

  @override
  String get courseName => '授業名';

  @override
  String get courseRoom => '教室';

  @override
  String get courseTeacher => '教員';

  @override
  String get courseCredits => '単位数';

  @override
  String get courseWeekday => '曜日';

  @override
  String get courseStartUnit => '開始時限';

  @override
  String get courseEndUnit => '終了時限';

  @override
  String get courseWeeks => '週';

  @override
  String selectedWeeks(int count) {
    return '$count週選択済み';
  }

  @override
  String get customCourses => 'カスタム授業';

  @override
  String customCoursesCount(int count) {
    return '$count件の授業';
  }

  @override
  String get noCustomCourses => 'カスタム授業はありません';

  @override
  String get noCustomCoursesSubtitle => '右上の+をタップして授業を追加';

  @override
  String get readingCustomCourses => 'カスタム授業を読み込み中';

  @override
  String get readingCustomCoursesSubtitle => 'ローカルに保存された授業設定を整理中';

  @override
  String get courseAdded => '授業が追加されました';

  @override
  String get scoresAndGpa => '成績とGPA';

  @override
  String get passedCourses => '合格';

  @override
  String get totalCredits => '総単位';

  @override
  String get creditInfoTitle => '注意';

  @override
  String get creditInfoContent => '単位は合格した授業に基づいて計算されます。公式システムの数値とは異なる場合があります。';

  @override
  String get noScores => '成績がありません';

  @override
  String get noScoresSubtitle => '更新するか再度入室してください';

  @override
  String get refreshDataBtn => '更新';

  @override
  String get goToLogin => 'ログインへ';

  @override
  String get minorCourse => '副専攻';

  @override
  String get scoreDetail => '成績詳細';

  @override
  String get courseCreditLabel => '単位数';

  @override
  String get courseScoreLabel => '成績';

  @override
  String get courseGpaLabel => 'GPA';

  @override
  String get fetchingScores => '成績を取得中...';

  @override
  String get refreshFailedFallback => '更新に失敗しました。ローカルデータを表示します';

  @override
  String get fetchTimeout => 'リクエストがタイムアウトしました。ネットワークを確認してください。';

  @override
  String get fetchFailed => 'データの取得に失敗しました';

  @override
  String get pleaseLoginFirst => '成績を表示するにはログインしてください';

  @override
  String get readingScoresSubtitle => 'キャッシュを読み込み、学務成績を同期中';

  @override
  String get foolishModeMessage => 'はい、GPAは5.0です';

  @override
  String creditUnit(String credit) {
    return '$credit単位';
  }

  @override
  String gradeLabel(String grade) {
    return '成績 $grade';
  }

  @override
  String gpaLabel(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String scheduleCourseTime(
      String weekRanges, String weekday, int start, int end) {
    return '第$weekRanges週 毎$weekday曜日 $start-$end限';
  }

  @override
  String semesterRange(String start, String end, String num) {
    return '$start～$end年 第$num学期';
  }

  @override
  String get semesterAutumnShort => '前期';

  @override
  String get semesterSpringShort => '後期';

  @override
  String get year1 => '1年生';

  @override
  String get year2 => '2年生';

  @override
  String get year3 => '3年生';

  @override
  String get year4 => '4年生';

  @override
  String get year5 => '5年生';

  @override
  String get year6 => '6年生';

  @override
  String get year7 => '7年生';

  @override
  String get year8 => '8年生';

  @override
  String get year9 => '9年生';

  @override
  String get year10 => '10年生';

  @override
  String get loginTitle => '学務システムログイン';

  @override
  String get loginSubtitle => 'アカウントでログインしてください';

  @override
  String get studentId => '学籍番号';

  @override
  String get password => 'パスワード';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get loggingIn => 'ログイン中...';

  @override
  String get loggingInSubtitle => '認証情報を確認し、授業・成績などのデータを同期中';

  @override
  String get emptyCredentials => 'ユーザー名とパスワードを入力してください';

  @override
  String get loginTimeoutEdu => 'ログインがタイムアウトしました。ネットワークを確認してください';

  @override
  String get loginFailed => 'ログインに失敗しました。認証情報を確認してください';

  @override
  String get loginTimeout => 'ログインがタイムアウトしました。ネットワークを確認して再試行してください';

  @override
  String get loginSecurityStorageUnavailable =>
      'ログインに成功しましたが、安全なストレージが利用できません。次回起動時に認証情報の再入力が必要になる場合があります';

  @override
  String get loadingDefaultTitle => 'データ同期中';

  @override
  String get loadingDefaultSubtitle => '低速ネットワークでは数秒かかる場合があります';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get retry => '再試行';

  @override
  String get loadFailed => '読み込み失敗';

  @override
  String get noData => 'データなし';

  @override
  String get ok => 'OK';

  @override
  String get classroom => '教室';

  @override
  String get teacherLabel => '教員';

  @override
  String get classTime => '時間';

  @override
  String get classCampus => 'キャンパス';

  @override
  String get todayScheduleLabel => '今日の時間割';

  @override
  String get tomorrowSchedule => '明日の時間割';

  @override
  String get noCourseToday => '今日の授業はありません';

  @override
  String get noCourseTodaySubtitle => 'ゆっくり休んでください';

  @override
  String get showTomorrowSchedule => '明日の授業を表示';

  @override
  String get doubleTapExit => 'もう一度押して終了';

  @override
  String copySuccess(String text) {
    return 'コピーしました: $text';
  }

  @override
  String get copyTooltip => 'コピー';

  @override
  String get pageSettings => 'ページ設定';

  @override
  String get showBusTile => 'バスタイルを表示';

  @override
  String get showBusTileSubtitle => 'ホームページにバス情報を表示';

  @override
  String get addToHome => 'ホームに追加';

  @override
  String get showElectricityTile => '電気料金タイルを表示';

  @override
  String get electricityRecharge => 'チャージ';

  @override
  String get electricityRechargeSubtitle => 'WeChatで電気料金チャージを開く';

  @override
  String get showPaymentTile => 'カードタイルを表示';

  @override
  String get showPaymentTileSubtitle => 'ホームページに残高概要を表示';

  @override
  String get addTodo => 'ToDoを追加';

  @override
  String get todoTitle => 'タイトル';

  @override
  String get deadline => '期限';

  @override
  String get change => '更新';

  @override
  String get edit => '編集';

  @override
  String get done => '完了';

  @override
  String get todoListLabel => 'タスクリスト';

  @override
  String get readingTodos => 'タスクを読み込み中';

  @override
  String get readingTodosSubtitle => 'ローカルのタスクリストとリマインダー状態を読み込み中';

  @override
  String get noTodos => '現在タスクはありません';

  @override
  String get noTodosSubtitle => '右上の＋をタップして追加';

  @override
  String get todoLoadFailedSubtitle => 'タスクを読み込めません';

  @override
  String deadlineLabel(String date) {
    return '締切日: $date';
  }

  @override
  String get noDeadline => 'なし';

  @override
  String get titleRequired => 'タイトルは必須です';

  @override
  String get deadlineRequired => '締切日は必須です';

  @override
  String get add => '追加';

  @override
  String get upcomingExams => '近日の試験';

  @override
  String get loadingExams => '試験情報を読み込み中';

  @override
  String get loadingExamsSubtitle => '最近の試験日程、会場、座席情報を同期中';

  @override
  String get noExams => '試験はありません';

  @override
  String get noExamsSubtitle => '更新すると表示されるかもしれません';

  @override
  String get examTime => '試験時間';

  @override
  String get examLocation => '試験会場';

  @override
  String get seatNumber => '座席番号';

  @override
  String seatNumberLabel(String seat) {
    return '座席番号 $seat';
  }

  @override
  String get examNotLoggedIn => 'ログインしてください';

  @override
  String get examAuthFailed => '認証に失敗しました。再ログインしてください';

  @override
  String get examFetchFailed => '試験情報の取得に失敗しました。タップして再試行';

  @override
  String get quickFeatures => 'クイック機能';

  @override
  String get noQuickFeatures => 'クイック機能がありません';

  @override
  String get noQuickFeaturesSubtitle => '編集モードで追加してください';

  @override
  String get moreFeatures => 'その他の機能';

  @override
  String get scheduleWidgetTitle => 'カレンダーにインポート';

  @override
  String get subscriptionLink => 'サブスクリプションリンク';

  @override
  String get copiedSuccess => 'コピーしました！';

  @override
  String get howToImport => 'インポート方法';

  @override
  String get customCourseManage => 'カスタム授業管理';

  @override
  String get showCourseGrid => '時間割のグリッド線を表示';

  @override
  String get noBackground => '背景なし';

  @override
  String get customImage => 'カスタム画像';

  @override
  String get noImageSelected => '画像が選択されていません';

  @override
  String get noCalendarApp => 'カレンダーアプリが見つかりません。手動でインポートしてください';

  @override
  String get cannotOpenCalendar => 'カレンダーアプリを開けません';

  @override
  String get bgImageSetSuccess => '背景画像を設定しました';

  @override
  String get selectImageFailed => '画像の選択に失敗しました';

  @override
  String get addCalendarSub => 'カレンダー購読を追加';

  @override
  String get understand => '了解';

  @override
  String get calendarSubscription => 'カレンダー購読';

  @override
  String get scheduleManagement => '授業管理';

  @override
  String get scheduleBackground => '時間割背景';

  @override
  String get ignoreCourses => '授業を除外';

  @override
  String get loadingSchedule => '時間割を読み込み中';

  @override
  String get loadingScheduleSubtitle => '授業、設定、背景設定を読み込み中';

  @override
  String get updatingSchedule => '時間割を更新中...';

  @override
  String get updateComplete => '更新完了';

  @override
  String get updateTimeout => '更新がタイムアウトしました。ネットワークを確認して再試行してください';

  @override
  String updateFailed(String error) {
    return '更新失敗: $error';
  }

  @override
  String get linkCopiedToClipboard => 'リンクをクリップボードにコピーしました';

  @override
  String get currentWeekLabel => '今週';

  @override
  String periodUnit(int n) {
    return '第$n限';
  }

  @override
  String get calendarGuidanceIntro =>
      'カレンダー購読を直接処理できるアプリが見つかりません。以下の手順で手動追加してください:';

  @override
  String get calendarGuidanceStep1 => '1. カレンダーアプリを開く';

  @override
  String get calendarGuidanceStep2 => '2. 「カレンダーを追加」または「購読」オプションを見つける';

  @override
  String get calendarGuidanceStep3 => '3. 「URLで追加」または類似のオプションを選択';

  @override
  String get calendarGuidanceStep4 => '4. 以下のリンクを貼り付け:';

  @override
  String get calendarGuidanceNote =>
      '注意: カレンダーアプリによって手順が異なる場合があります。問題が発生した場合は、カレンダーアプリのヘルプをご確認ください。';

  @override
  String get profileReading => 'アカウント情報を読み込み中';

  @override
  String get profileReadingSubtitle => 'ログイン状態とプロフィールデータを同期中';

  @override
  String get campusNavigation => 'キャンパスツールボックス';

  @override
  String get settingsAbout => '設定 / について';

  @override
  String get programLabel => '履修計画';

  @override
  String get campusMap => 'キャンパスマップ';

  @override
  String get help => 'ヘルプ';

  @override
  String get academicAccount => '学務アカウント';

  @override
  String get guest => 'ゲスト';

  @override
  String get guestMode => 'ゲストモード';

  @override
  String get guestModeSubtitle => 'ログインするとすべての機能を使用できます';

  @override
  String get syncingAcademic => '学務情報を同期中';

  @override
  String get syncingAcademicSubtitle => '単位とプロフィールカードを読み込み中';

  @override
  String get loginEduSystem => '学務システムにログイン';

  @override
  String get programLoading => '履修計画を読み込み中';

  @override
  String get programLoadingSubtitle => '学期ごとに授業構成を整理中';

  @override
  String get programLoadFailed => '読み込みに失敗しました';

  @override
  String get programNoData => 'データがありません';

  @override
  String get programRefreshFailed => '更新に失敗しました。最後に同期した計画を表示します';

  @override
  String get linkLoading => 'ナビゲーションリンクを読み込み中';

  @override
  String get linkLoadingSubtitle => 'サイトとカテゴリを整理中';

  @override
  String get linkLoadFailed => '読み込みに失敗しました';

  @override
  String get linkNoData => 'ナビゲーションデータがありません';

  @override
  String get linkNoDataSubtitle => 'ページを再表示するか、ネットワークを確認してください';

  @override
  String get paymentLoading => 'カード残高を同期中';

  @override
  String get paymentLoadingSubtitle => '最新の取引を取得中';

  @override
  String get paymentPasswordTitle => 'カードパスワード';

  @override
  String get paymentPasswordSubtitle => '任意です。空欄の場合は既定の方法で照会します。';

  @override
  String get paymentSaveAndRefresh => '保存して更新';

  @override
  String get campusCard => '学内カード';

  @override
  String get currentBalance => '現在の残高';

  @override
  String get recentTransactions => '最近の取引';

  @override
  String get paymentFilter => '支払い';

  @override
  String get consumptionFilter => '消費';

  @override
  String get rechargeFilter => 'チャージ';

  @override
  String get noCardData => 'カードデータがありません';

  @override
  String get noCardDataSubtitle => 'ログインして残高と取引を表示してください';

  @override
  String get busLoading => 'バス時刻表を取得中';

  @override
  String get busLoadingSubtitle => 'キャンパス・日付別にバス情報を整理中';

  @override
  String get noBusToday => '本日のバスはありません';

  @override
  String get noBusTodaySubtitle => '明日また確認してください';

  @override
  String get departureTime => '出発時間';

  @override
  String get destination => '行き先';

  @override
  String get estimatedArrival => '到着予定';

  @override
  String get busInfo => 'バス情報';

  @override
  String get departure => '出発';

  @override
  String get arrival => '到着';

  @override
  String get netRefreshFailed => '更新に失敗しました。現在のデータを表示します';

  @override
  String get netData => 'ネットワークデータ';

  @override
  String get usedTraffic => '使用済み通信量';

  @override
  String onlineDuration(String time) {
    return 'オンライン時間: $time';
  }

  @override
  String get username => 'ユーザー名';

  @override
  String get ipAddress => 'IPアドレス';

  @override
  String get productPackage => '製品プラン';

  @override
  String get unknown => '不明';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get netLoading => 'ネットワークデータを読み込み中';

  @override
  String get netLoadingSubtitle => '通信量、オンライン時間、アカウント情報を同期中';

  @override
  String get netLoadFailed => '読み込みに失敗しました';

  @override
  String get netNoData => 'データがありません';

  @override
  String get electricityBalance => '現在の残高';

  @override
  String get electricityNoData => 'データなし';

  @override
  String get electricityLowBalance => '残高が不足しています。チャージしてください';

  @override
  String get electricitySufficient => '残高は十分です';

  @override
  String get electricityAddTip => '右上をタップして電気料金データを追加';

  @override
  String get electricityLoading => '使用傾向を更新中';

  @override
  String get electricityLoadingSubtitle => '最新の電気使用記録を読み込み中';

  @override
  String get noUsageDetails => '使用詳細がありません';

  @override
  String get noUsageDetailsSubtitle => '更新後、時間別の料金がここに表示されます';

  @override
  String get electricityCost => '電気料金';

  @override
  String lastNDays(int n) {
    return '過去$n日間';
  }

  @override
  String get totalCost => '総費用';

  @override
  String get todayCost => '本日の費用';

  @override
  String get avgDailyCost => '平均日額';

  @override
  String get peakHours => 'ピーク時間';

  @override
  String get hourlyDetails => '時間別詳細';

  @override
  String get lowBalanceSub => '残高不足アラート';

  @override
  String get lowBalanceSubDesc => '残高が少なくなったときに通知を受け取る';

  @override
  String get addElectricityFirst => '先に電気料金ページを追加してください';

  @override
  String get noElectricityData => '電気料金データがありません';

  @override
  String get noElectricityDataSubtitle => '先に寮の電気料金ページをバインドしてください';

  @override
  String get lowBalanceEnabled => '残高不足アラートが有効になりました';

  @override
  String get addLowBalanceAlert => '残高不足アラートを追加';

  @override
  String get deleteSubscription => 'サブスクリプションを削除';

  @override
  String get deleteSubDesc => '残高不足のメール通知をキャンセル';

  @override
  String get electricityManagement => '電気料金管理';

  @override
  String get chooseAction => '操作を選択';

  @override
  String get changeRoom => '部屋を変更';

  @override
  String get getElectricity => '電気料金を取得';

  @override
  String get electricityUrlPrompt => '大学の財務電気料金ページを開き、URLをコピーして下に貼り付けてください';

  @override
  String get urlPlaceholder => 'URLを入力';

  @override
  String get createLowBalanceAlert => '残高不足アラートを作成';

  @override
  String get lowBalanceAlertDesc =>
      'システムはバインドされた寮の電気料金ページを使用して、残高が閾値を下回ったときにメールアラートを送信します。';

  @override
  String get remindEmail => '通知メール';

  @override
  String get remindEmailPlaceholder => '通知メールアドレス';

  @override
  String get remindThreshold => '閾値（例：10）';

  @override
  String get remindThresholdPlaceholder => '閾値（例：10）';

  @override
  String get pleaseEnterEmail => 'メールアドレスを入力してください';

  @override
  String get pleaseEnterValidEmail => '有効なメールアドレスを入力してください';

  @override
  String get pleaseEnterThreshold => '0より大きい閾値を入力してください';

  @override
  String get lowBalanceAlertCreated => '残高不足アラートが作成されました';

  @override
  String get createSubFailed => 'サブスクリプションの作成に失敗しました';

  @override
  String currentSubInfo(String email, String threshold) {
    return '残高が¥$thresholdを下回った場合、$emailに通知';
  }

  @override
  String get subSetupHint => '閾値を設定すると、残高が不足したときにメール通知が届きます';

  @override
  String get remindEmailLabel => '通知メール';

  @override
  String get notSet => '未設定';

  @override
  String get remindThresholdLabel => '閾値';

  @override
  String get gotIt => '了解';

  @override
  String get noSubToDelete => '削除するサブスクリプションがありません';

  @override
  String get deleteSubTitle => 'サブスクリプションを削除';

  @override
  String get deleteSubConfirmContent => '現在の残高不足サブスクリプションを削除してもよろしいですか？';

  @override
  String get lowBalanceAlertDeleted => '残高不足アラートが削除されました';

  @override
  String get deleteSubFailed => 'サブスクリプションの削除に失敗しました';

  @override
  String get electricitySubLoadFailed => '電気料金サブスクリプションの読み込みに失敗しました';

  @override
  String get subscriptionDetail => 'サブスクリプション内容';

  @override
  String get create => '作成';

  @override
  String get webNotSupported => 'Web版は未対応です';

  @override
  String get webNotSupportedSubtitle => '他のバージョンをお使いください';

  @override
  String get reorderFailed => '並べ替えに失敗しました';

  @override
  String get searchLocation => '場所や建物を検索...';

  @override
  String get search => '検索...';

  @override
  String get buildingIntro => '建物情報';

  @override
  String get specificLocation => '場所';

  @override
  String get licenseTitle => 'オープンソースライセンス';

  @override
  String get licenseLoading => 'ライセンスを読み込み中';

  @override
  String get licenseLoadingSubtitle => 'アプリケーションのオープンソースライセンステキストを読み込み中';

  @override
  String get licenseLoadFailed => 'ライセンスファイルの読み込みに失敗しました';

  @override
  String get helpFeaturesTab => '機能紹介';

  @override
  String get helpInstructionsTab => '使用方法';

  @override
  String get helpNotesTab => '注意事項';

  @override
  String get helpAboutTab => 'アプリについて';

  @override
  String get helpFeatureHome => 'ホーム';

  @override
  String get helpFeatureHomeDesc => '個人情報、授業、予定、試験を表示する情報センター';

  @override
  String get helpFeatureSchedule => '時間割';

  @override
  String get helpFeatureScheduleDesc => '週間授業を管理、キャンパス切替と通知設定';

  @override
  String get helpFeatureScore => '成績';

  @override
  String get helpFeatureScoreDesc => '学期成績、GPA計算と分析を表示';

  @override
  String get helpFeatureProfile => 'プロフィール';

  @override
  String get helpFeatureProfileDesc => '学籍番号、氏名、学部などの個人情報を表示';

  @override
  String get helpFeatureBus => 'キャンパスバス';

  @override
  String get helpFeatureBusDesc => 'キャンパス間バスの時刻表と経路情報';

  @override
  String get helpFeatureProgram => '履修計画';

  @override
  String get helpFeatureProgramDesc => '専攻の履修計画と単位要件を表示';

  @override
  String get helpFeatureElectricity => '電気料金';

  @override
  String get helpFeatureElectricityDesc => '寮の電力使用量と履歴を表示';

  @override
  String get helpFeaturePayment => '学生証';

  @override
  String get helpFeaturePaymentDesc => '残高と取引履歴を表示';

  @override
  String get helpFeatureNet => 'キャンパスネットワーク';

  @override
  String get helpFeatureNetDesc => 'ネットワーク使用量と統計を表示';

  @override
  String get helpFeatureLinks => '便利リンク';

  @override
  String get helpFeatureLinksDesc => '教務システムなどの便利なリンク集';

  @override
  String get helpInstructionLogin => 'ログインとアカウント';

  @override
  String get helpInstructionLoginDesc => '初回利用時に教務システムアカウントでログイン';

  @override
  String get helpInstructionCourse => '授業管理';

  @override
  String get helpInstructionCourseDesc => '時間割で週間授業を確認、スワイプで週切替、授業をタップで詳細';

  @override
  String get helpInstructionReminder => '授業リマインダー';

  @override
  String get helpInstructionReminderDesc => '設定で授業通知を有効にすると、授業前に通知';

  @override
  String get helpInstructionSync => 'データ同期';

  @override
  String get helpInstructionSyncDesc => 'アプリが自動で教務データを同期。プルダウンで手動更新';

  @override
  String get helpInstructionWidget => 'ウィジェット';

  @override
  String get helpInstructionWidgetDesc => 'ホーム画面を長押ししてウィジェットを追加';

  @override
  String get helpNoteNetwork => '一部の機能はキャンパスネットワークが必要';

  @override
  String get helpNoteUpdate => '最新機能と修正のためアプリを更新してください';

  @override
  String get helpNoteData => 'データが不正確な場合は教務システムログインを確認';

  @override
  String get helpNoteFeedback => '問題は設定ページから報告してください';

  @override
  String get helpNotePrivacy => 'このアプリは個人情報を収集・アップロードしません';

  @override
  String get helpAboutPlatform => '対応プラットフォーム';

  @override
  String get helpAboutPlatformDesc => 'クロスプラットフォーム対応：';

  @override
  String get helpAboutOpenSource => 'オープンソース';

  @override
  String get helpAboutOpenSourceDesc => 'このアプリはMITライセンスでオープンソース';

  @override
  String get helpAboutRepoLabel => 'リポジトリ：';

  @override
  String get underMaintenanceTitle => 'メンテナンス中！';

  @override
  String get underMaintenanceDescription => '定期メンテナンス中です。しばらくしてから再度ご確認ください。';

  @override
  String get readingPaymentCard => 'カード情報読み込み中';

  @override
  String get lowBalance => '残高不足';

  @override
  String get campusCardBalance => 'カード残高';

  @override
  String get tapToView => 'タップして表示';

  @override
  String get tapToSubscribe => 'タップして購読';

  @override
  String get campusCaoTang => '草堂';

  @override
  String get campusYanTa => '雁塔';

  @override
  String get busRefreshStale => '更新完了、最後のデータを保持';

  @override
  String arrivalStationTime(String h, String m) {
    return '$h時間 $m分';
  }

  @override
  String get poiMainLibrary => '中央図書館';

  @override
  String get poiMainLibraryDesc => '24時間開放の自習室';

  @override
  String get poiCaoTangNorthGate => '草堂キャンパス北門';

  @override
  String get poiCaoTangNorthGateDesc => 'メインエントランス';

  @override
  String get poiYanTaEastGate => '雁塔キャンパス東門';

  @override
  String get poiYanTaEastGateDesc => '歴史あるキャンパスの入り口';

  @override
  String durationDHMS(String d, String h, String m, String s) {
    return '$d日$h時間$m分$s秒';
  }

  @override
  String get shortcuts => 'ショートカット';

  @override
  String get moreFunctions => 'その他の機能';

  @override
  String get noShortcuts => 'ショートカットなし';

  @override
  String get addInEditMode => '編集モードで追加';

  @override
  String get eduSystem => '教育システム';

  @override
  String get htmlImport => 'HTMLインポート';

  @override
  String get pasteHtmlHint => '時間割のHTMLコードを貼り付けてください';

  @override
  String get parseAndPreview => '解析＆プレビュー';

  @override
  String get importCourses => '授業をインポート';

  @override
  String get parseResult => '解析結果';

  @override
  String get noCoursesParsed => '授業が解析されませんでした';

  @override
  String get searchSchool => '学校を検索...';

  @override
  String get basicSupport => '基本';

  @override
  String get advancedSupport => '高度';

  @override
  String get schoolNotSupported => '現在の学校ではこの機能はサポートされていません';

  @override
  String get switchSchool => '学校を切り替える';

  @override
  String get selectSchool => '学校を選択';

  @override
  String get enterCustomUrl => 'またはカスタムURLを入力';

  @override
  String get urlHint => 'ウェブサイトのURLを入力';

  @override
  String get icp => 'ICP';
}
