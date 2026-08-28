// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Lumaris';

  @override
  String get appSlogan => '대학 생활을 하나의 앱에 담다';

  @override
  String get tagline => '대학생들에게 더 나은 서비스를 제공하기 위해';

  @override
  String get home => '홈';

  @override
  String get schedule => '시간표';

  @override
  String get score => '성적';

  @override
  String get profile => '프로필';

  @override
  String get electricity => '전기요금';

  @override
  String get schoolBus => '스쿨버스';

  @override
  String get payment => '식권';

  @override
  String get map => '지도';

  @override
  String get settings => '설정';

  @override
  String get basicSettings => '기본 설정';

  @override
  String get version => '버전';

  @override
  String get widgets => '위젯';

  @override
  String get about => '정보';

  @override
  String get other => '기타';

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
  String get refreshData => '데이터 새로고침';

  @override
  String get refreshingData => '데이터 새로고침 중...';

  @override
  String get refreshDataSuccess => '데이터 새로고침 완료';

  @override
  String get refreshDataFailed => '데이터 새로고침 실패';

  @override
  String get appearance => '화면 스타일';

  @override
  String get followSystem => '시스템 설정에 따름';

  @override
  String get light => '라이트 모드';

  @override
  String get dark => '다크 모드';

  @override
  String get language => '언어';

  @override
  String get systemLanguage => '시스템 언어에 따름';

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
  String get team => '제작팀';

  @override
  String get teamName => 'Lumaris Team';

  @override
  String get openSourceLicense => '오픈소스 라이선스';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get privacyPolicySubtitle => '개인정보 보호 방식 알아보기';

  @override
  String get userAgreement => '이용약관';

  @override
  String get userAgreementSubtitle => '본 앱을 사용하면 이용약관에 동의하는 것으로 간주됩니다';

  @override
  String get clearCache => '캐시 삭제';

  @override
  String get clearingCache => '캐시 삭제 중...';

  @override
  String get cacheCleared => '캐시가 삭제되었습니다';

  @override
  String get confirmClearCacheTitle => '캐시를 삭제하시겠습니까?';

  @override
  String get confirmClearCacheContent =>
      '모든 캐시 데이터가 삭제되며, 다음에 앱을 열 때 데이터를 다시 로드해야 합니다';

  @override
  String get logoutEduSystem => '학사 시스템 로그아웃';

  @override
  String get confirmLogoutTitle => '로그아웃하시겠습니까?';

  @override
  String get confirmLogoutContent => '로그아웃 후 학사 시스템 데이터에 접근하려면 다시 로그인해야 합니다';

  @override
  String get logout => '로그아웃';

  @override
  String get agreementAuthDebug => '약관 동의 상태 [디버그]';

  @override
  String get agreementAuthDebugSubtitle => '비활성화 시 다음 실행에 약관 동의 페이지가 다시 표시됩니다';

  @override
  String get addToDesktop => '바탕화면에 추가';

  @override
  String get widgetSetupTitle => '위젯을 바탕화면에 추가하기';

  @override
  String get widgetSetupIntro => '다음 단계에 따라 진행하세요:';

  @override
  String get widgetSetupStep1 => '휴대폰 바탕화면 빈 공간을 길게 누르기';

  @override
  String get widgetSetupStep2 => '\"위젯\" 또는 \"Widgets\" 옵션 선택';

  @override
  String get widgetSetupStep3 => '\"Lumaris\"를 찾아 적합한 위젯 선택';

  @override
  String get widgetSetupStep4 => '위젯을 바탕화면의 원하는 위치로 드래그';

  @override
  String get widgetSetupTip => '팁: 위젯을 통해 오늘의 수업 등 정보를 빠르게 확인할 수 있습니다';

  @override
  String get cancel => '취소';

  @override
  String downloadingUpdateTitle(Object version) {
    return '업데이트 $version 다운로드 중';
  }

  @override
  String get downloadCompletedInstalling => '다운로드가 완료되었습니다. 설치를 시작합니다...';

  @override
  String downloadFailed(Object error) {
    return '다운로드 실패: $error';
  }

  @override
  String get confirm => '확인';

  @override
  String get back => '뒤로';

  @override
  String get collapseSidebar => '사이드바 접기';

  @override
  String get expandSidebar => '사이드바 펼치기';

  @override
  String get notLoggedIn => '로그인되지 않음';

  @override
  String get academicSystem => '학사 시스템';

  @override
  String get clickToLogin => '눌러서 로그인';

  @override
  String get closeWindow => '창 닫기';

  @override
  String get closeWindowChoice => '실행할 작업을 선택하세요';

  @override
  String get showWindow => '창 보기';

  @override
  String get minimizeToTray => '트레이로 최소화';

  @override
  String get quitApp => '프로그램 종료';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get goAuthorize => '권한 허용하러 가기';

  @override
  String get permissionRequired => '권한 필요';

  @override
  String get permissionRequiredContent => '이 기능을 사용하려면 해당 권한을 허용해야 합니다';

  @override
  String get permissionDenied => '권한 거부됨';

  @override
  String get permissionDeniedContent =>
      '해당 권한이 영구적으로 거부되었습니다. 시스템 설정에서 수동으로 허용해 주세요';

  @override
  String get updateAvailable => '새 버전이 있습니다!';

  @override
  String get ignoreThisUpdate => '이번 업데이트 건너뛰기';

  @override
  String get ignoreAllUpdates => '모든 업데이트 건너뛰기';

  @override
  String get goToBrowserUpdate => '브라우저에서 업데이트하기';

  @override
  String get goToBrowser => '브라우저로 이동';

  @override
  String get dontUpdate => '나중에 업데이트';

  @override
  String confirmUpdateTitle(String version) {
    return '최신 버전 $version으로 업데이트하시겠습니까?';
  }

  @override
  String get confirmUpdateContent =>
      '새 버전이 있습니다. 브라우저에서 다운로드 링크가 열립니다. 계속하시겠습니까?';

  @override
  String get updateLog => '업데이트 로그';

  @override
  String get ignoreVersionUpdate => '버전 업데이트 무시';

  @override
  String get updateOpened => '브라우저가 열렸습니다. 브라우저에서 업데이트를 다운로드하여 설치하세요';

  @override
  String get openUpdateFailed => '업데이트 링크 열기 실패';

  @override
  String get loginRequired => '먼저 로그인해 주세요';

  @override
  String get pleaseLoginEduAccount => '먼저 학사 시스템 계정으로 로그인해 주세요';

  @override
  String get loadFailedTapRetry => '로드 실패, 눌러서 다시 시도';

  @override
  String get empty => '데이터 없음';

  @override
  String get loading => '로딩 중';

  @override
  String get syncingData => '데이터 동기화 중';

  @override
  String get syncingDataSubtitle => '네트워크가 느린 경우 몇 초 정도 걸릴 수 있습니다. 잠시만 기다려 주세요';

  @override
  String get creditOverview => '학점 개요';

  @override
  String get completionRate => '이수율';

  @override
  String get itemizedCredits => '항목별 학점';

  @override
  String get courseConflict => '현재 시간에 여러 수업이 충돌합니다';

  @override
  String get notificationCourseChannelName => '수업 알림';

  @override
  String get notificationCourseChannelDescription => '일일 시간표 알림';

  @override
  String notificationCourseAdvanceDescription(Object minutes) {
    return '$minutes분 전에 보내는 일일 시간표 알림';
  }

  @override
  String get notificationTodoChannelName => '할 일 알림';

  @override
  String get notificationTodoChannelDescription => '할 일 마감 알림';

  @override
  String get courseReminderTitle => '수업 알림';

  @override
  String courseReminderStartsIn(Object minutes) {
    return '$minutes분 후에 시작합니다';
  }

  @override
  String get todoReminderTitle => '할 일 알림';

  @override
  String todoReminderBody(Object title) {
    return '할 일 $title의 마감 시간이 되었습니다';
  }

  @override
  String get allowBackgroundRun => '백그라운드 실행 허용';

  @override
  String get allowBackgroundRunContent =>
      '수업 알림이 제시간에 울리도록 하려면 앱의 백그라운드 실행과 배터리 최적화 예외를 허용해 주세요.';

  @override
  String get allowScheduleAlarm => '알람 허용';

  @override
  String get allowScheduleAlarmContent => '알림 기능을 사용하려면 알람 권한이 필요합니다.';

  @override
  String get saveFailedRetry => '저장에 실패했습니다. 다시 시도해 주세요';

  @override
  String get toggleTileVisibilityFailed => '표시 상태를 변경하지 못했습니다';

  @override
  String get resetFailed => '초기화에 실패했습니다';

  @override
  String get networkError => '네트워크 연결 실패, 네트워크 설정을 확인해 주세요';

  @override
  String get requestTimeout => '요청 시간 초과, 네트워크 연결을 확인해 주세요';

  @override
  String get serverError => '서버 오류, 잠시 후 다시 시도해 주세요';

  @override
  String get unknownError => '알 수 없는 오류, 다시 시도해 주세요';

  @override
  String get agreementWelcomeTitle => 'Lumaris에 오신 것을 환영합니다';

  @override
  String get agreementDescription =>
      '본 앱을 사용하기 전에 아래 약관을 주의 깊게 읽고 동의해 주세요. 우리는 관련 법률과 규정을 엄격히 준수하여 귀하의 개인정보를 보호합니다.';

  @override
  String get agreementPrivacyDescription => '개인정보 수집, 이용 및 보호 방식 알아보기';

  @override
  String get agreementUserDescription => '본 앱 사용에 관한 권리, 의무 및 면책 조항 알아보기';

  @override
  String get agreementReadTip =>
      '위 카드를 눌러 약관 전문을 확인할 수 있습니다. 계속 사용하면 위 약관을 읽고 동의한 것으로 간주됩니다.';

  @override
  String get agreeAndContinue => '동의하고 계속하기';

  @override
  String get disagree => '동의하지 않음';

  @override
  String get loginAgreementPrefix => '계속 진행하면 귀하가 ';

  @override
  String get loginAgreementRequired => '이용 약관에 동의한 것으로 간주합니다';

  @override
  String get privacyPolicyTitle => 'Lumaris 개인정보 처리방침';

  @override
  String get privacyPolicyUpdatedAt => '갱신일: 2026년 5월 5일';

  @override
  String get privacyPolicyEffectiveAt => '시행일: 2026년 5월 5일';

  @override
  String get privacyPolicyIntro =>
      'Lumaris(이하 \"본 앱\")를 이용해 주셔서 감사합니다. 본 앱은 Lumaris Team(이하 \"당사\")이 개발 및 운영합니다. 당사는 개인정보의 중요성을 잘 알고 있으며, 관련 법률과 규정을 준수하여 합법적이고 정당하며 필요 최소한의 신의성실 원칙에 따라 귀하의 개인정보를 보호합니다. 본 개인정보 처리방침은 당사가 귀하의 개인정보를 수집, 이용, 저장 및 보호하는 방법과 귀하가 가지는 권리에 대해 설명하는 것을 목적으로 합니다. 본 앱을 사용하기 전에 본 개인정보 처리방침을 주의 깊게 읽어 주시기 바랍니다.';

  @override
  String get privacySection1Title => '제1조 수집하는 정보';

  @override
  String get privacySection1_1 =>
      '1.1 계정 정보: 학사 시스템 로그인 기능을 사용할 때, 당사는 신원 확인 및 학사 시스템 데이터 접근을 위해 귀하의 학번과 비밀번호를 수집합니다. 이 정보는 귀하의 기기 로컬에만 저장되며, 당사는 어떠한 서버에도 이를 업로드하지 않습니다.';

  @override
  String get privacySection1_2 =>
      '1.2 수업 및 성적 정보: 로그인 승인 후, 본 앱은 학교 학사 시스템에서 귀하의 시간표, 시험 성적, 교육 과정 등 교육 관련 데이터를 가져와 귀하의 기기 로컬에 저장하고 표시합니다.';

  @override
  String get privacySection1_3 =>
      '1.3 캠퍼스 생활 정보: 관련 기능을 사용할 때, 본 앱은 학교 관련 시스템에서 귀하의 전기요금 잔액, 식권 소비 기록, 캠퍼스 네트워크 사용량 등의 정보를 가져와 귀하의 기기 로컬에 저장하고 표시합니다.';

  @override
  String get privacySection1_4 =>
      '1.4 기기 정보: 더 나은 서비스 경험을 제공하기 위해, 본 앱은 통계 분석 및 문제 해결을 목적으로 귀하의 기기 모델, 운영체제 버전, 기기 식별자 등의 정보를 수집할 수 있습니다.';

  @override
  String get privacySection1_5 =>
      '1.5 캐시 데이터: 앱 응답 속도를 향상시키기 위해, 본 앱은 수업 정보, 성적 데이터, 네트워크 요청 응답 등을 포함한 일부 데이터를 귀하의 기기에 캐시합니다. 설정에서 언제든지 이러한 캐시를 삭제할 수 있습니다.';

  @override
  String get privacySection2Title => '제2조 정보 이용 방법';

  @override
  String get privacySection2_1 =>
      '2.1 핵심 서비스 제공: 당사는 귀하의 학번과 비밀번호를 사용하여 학교 학사 시스템에 신원 인증을 하고, 귀하의 수업 및 성적 등의 정보를 가져와 표시합니다.';

  @override
  String get privacySection2_2 =>
      '2.2 서비스 품질 향상: 당사는 앱 성능을 분석하고 최적화하며 사용자 경험을 향상시키기 위해 기기 정보 및 앱 사용 통계 데이터를 사용할 수 있습니다.';

  @override
  String get privacySection2_3 =>
      '2.3 바탕화면 위젯: 바탕화면 위젯 기능을 사용하는 경우, 본 앱은 위젯의 정상적인 표시를 지원하기 위해 필요한 수업 데이터를 기기 로컬에 저장합니다.';

  @override
  String get privacySection2_4 =>
      '2.4 알림: 수업 알림 기능을 활성화한 경우, 본 앱은 수업 전 알림을 위해 기기에 로컬 알림을 설정합니다. 이 기능은 완전히 기기 로컬에서 이루어지며 데이터 전송이 수반되지 않습니다.';

  @override
  String get privacySection3Title => '제3조 정보의 저장 및 보안';

  @override
  String get privacySection3_1 =>
      '3.1 로컬 저장: 귀하의 개인정보(학번, 비밀번호, 수업 데이터, 성적 등)는 모두 귀하의 기기 로컬에 저장되며, 당사는 이 정보를 자사 서버에 업로드하지 않습니다.';

  @override
  String get privacySection3_2 =>
      '3.2 전송 보안: 본 앱과 학교 서버 간의 데이터 전송은 암호화 통신을 사용하여 전송 중 정보의 보안을 보장합니다.';

  @override
  String get privacySection3_3 =>
      '3.3 데이터 삭제: 설정에서 언제든지 캐시 데이터를 삭제하거나, 로그아웃을 통해 계정 관련 데이터를 삭제할 수 있습니다. 앱을 제거하면 본 앱이 귀하의 기기에 저장한 모든 데이터가 삭제됩니다.';

  @override
  String get privacySection4Title => '제4조 제3자 서비스';

  @override
  String get privacySection4_1 =>
      '4.1 학교 학사 시스템: 본 앱은 수업, 성적 등의 정보를 가져오기 위해 시안건축과학기술대학교 학사 시스템과 데이터를 주고받아야 합니다. 귀하의 로그인 자격 증명은 귀하의 기기와 학교 서버 간에만 전송됩니다.';

  @override
  String get privacySection4_2 =>
      '4.2 앱 업데이트 서비스: 본 앱은 Gitee 플랫폼을 통해 버전 업데이트 정보를 확인하며, 이 과정에서 귀하의 개인정보는 전송되지 않습니다.';

  @override
  String get privacySection4_3 =>
      '4.3 본 앱은 귀하의 개인정보를 제3자에게 공유, 판매 또는 임대하지 않습니다.';

  @override
  String get privacySection5Title => '제5조 귀하의 권리';

  @override
  String get privacySection5_1 =>
      '5.1 열람 및 정정: 앱 내에서 직접 귀하의 개인정보를 열람하고 정정할 수 있습니다.';

  @override
  String get privacySection5_2 =>
      '5.2 데이터 삭제: 로그아웃, 캐시 삭제 또는 앱 제거를 통해 귀하의 데이터를 삭제할 수 있습니다.';

  @override
  String get privacySection5_3 =>
      '5.3 동의 철회: 로그아웃 또는 앱 제거를 통해 본 개인정보 처리방침에 대한 동의를 철회할 수 있습니다. 다만, 동의 철회는 철회 전에 귀하의 동의에 기반하여 이미 수행된 개인정보 처리 활동의 효력에 영향을 미치지 않습니다.';

  @override
  String get privacySection6Title => '제6조 미성년자 보호';

  @override
  String get privacySection6_1 =>
      '6.1 본 앱은 주로 고등교육기관 재학생을 대상으로 합니다. 만 18세 미만의 미성년자인 경우, 보호자의 지도 하에 본 앱을 사용해 주시기 바랍니다.';

  @override
  String get privacySection6_2 =>
      '6.2 당사는 미성년자의 개인정보를 능동적으로 수집하지 않습니다. 보호자의 동의 없이 미성년자의 개인정보가 수집된 것을 발견한 경우, 삭제를 위해 당사에 연락해 주시기 바랍니다.';

  @override
  String get privacySection7Title => '제7조 개인정보 처리방침의 변경';

  @override
  String get privacySection7_1 =>
      '7.1 당사는 본 개인정보 처리방침을 적절히 업데이트할 수 있습니다. 업데이트된 방침은 앱 내에 게시되며, 중대한 변경 사항이 있을 경우 앱 내 알림을 통해 안내해 드립니다.';

  @override
  String get privacySection7_2 =>
      '7.2 정기적으로 본 개인정보 처리방침을 확인하여 당사가 귀하의 정보를 어떻게 보호하는지 알아보시기 바랍니다. 방침 업데이트 후에도 본 앱을 계속 사용하면 업데이트된 개인정보 처리방침에 동의한 것으로 간주됩니다.';

  @override
  String get privacySection8Title => '제8조 문의하기';

  @override
  String get privacySection8_1 =>
      '본 개인정보 처리방침 또는 개인정보 보호에 관한 문의, 의견 또는 제안 사항이 있으시면 다음 방법으로 연락해 주시기 바랍니다:';

  @override
  String get privacyContact =>
      '개발팀: Lumaris Team\n코드 저장소: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get userAgreementTitle => 'Lumaris 이용약관';

  @override
  String get userAgreementUpdatedAt => '갱신일: 2026년 5월 5일';

  @override
  String get userAgreementEffectiveAt => '시행일: 2026년 5월 5일';

  @override
  String get userAgreementIntro =>
      'Lumaris(이하 \"본 앱\")를 이용해 주셔서 감사합니다. 본 앱은 Lumaris Team(이하 \"당사\")이 개발 및 운영합니다. 본 앱을 사용하기 전에 본 이용약관(이하 \"본 약관\")을 주의 깊게 읽어 주시기 바랍니다. 본 앱을 사용하면 본 약관의 모든 내용을 읽고 이해하였으며 이에 동의하는 것으로 간주됩니다. 본 약관의 어떤 조항에도 동의하지 않으시는 경우, 본 앱의 사용을 중단해 주시기 바랍니다.';

  @override
  String get userAgreementSection1Title => '제1조 서비스 설명';

  @override
  String get userAgreementSection1_1 =>
      '1.1 본 앱은 시안건축과학기술대학교 iOS Club에서 개발한 캠퍼스 도우미 애플리케이션으로, 재학생에게 편리한 캠퍼스 정보 서비스를 제공하는 것을 목적으로 하며, 수업 관리, 성적 조회, 스쿨버스 시간표, 전기요금 조회, 식권 소비 기록, 캠퍼스 네트워크 사용량 조회, 교육 과정 확인 등의 기능을 포함하되 이에 국한되지 않습니다.';

  @override
  String get userAgreementSection1_2 =>
      '1.2 본 앱의 일부 기능은 학교 내부 네트워크에 연결되어야 정상적으로 사용할 수 있습니다. 당사는 네트워크 환경 제한으로 인한 기능 이용 불가에 대해 책임을 지지 않습니다.';

  @override
  String get userAgreementSection1_3 =>
      '1.3 본 앱에 표시되는 수업, 성적 등의 정보는 학교 학사 시스템에서 가져온 것으로 참고용입니다. 차이가 있을 경우 학교 공식 시스템 데이터를 기준으로 합니다.';

  @override
  String get userAgreementSection2Title => '제2조 사용자 계정 및 보안';

  @override
  String get userAgreementSection2_1 =>
      '2.1 본 앱의 학사 관련 기능에 로그인하려면 학교 학사 시스템 계정(학번 및 비밀번호)이 필요합니다. 귀하는 자신의 계정과 비밀번호의 보안에 대해 책임을 지며, 계정 정보를 안전하게 보관해야 합니다.';

  @override
  String get userAgreementSection2_2 =>
      '2.2 귀하의 로그인 자격 증명은 귀하의 기기 로컬에만 저장되며, 학교 서버와의 신원 인증에 사용됩니다. 당사는 귀하의 비밀번호를 수집하거나 제3자 서버에 업로드하지 않습니다.';

  @override
  String get userAgreementSection2_3 =>
      '2.3 계정에 보안 위험 또는 승인되지 않은 사용이 발견된 경우, 즉시 비밀번호를 변경하고 당사에 알려주시기 바랍니다.';

  @override
  String get userAgreementSection3Title => '제3조 사용자 행동 규범';

  @override
  String get userAgreementSection3_1 =>
      '3.1 귀하는 본 앱을 사용할 때 중화인민공화국 관련 법률과 규정을 준수해야 하며, 본 앱을 이용하여 위법 행위를 해서는 안 됩니다.';

  @override
  String get userAgreementSection3_2 =>
      '3.2 귀하는 본 앱에 대해 리버스 엔지니어링, 역컴파일, 디스어셈블리 또는 기타 방법으로 본 앱의 소스 코드를 획득하려고 시도해서는 안 됩니다. 다만, 본 앱은 MIT 라이선스 하의 오픈소스 프로젝트이므로 공식 코드 저장소를 통해 합법적으로 소스 코드를 획득할 수 있습니다.';

  @override
  String get userAgreementSection3_3 =>
      '3.3 귀하는 네트워크 공격, 데이터 스크래핑, 악의적 주입 등의 행위를 포함하되 이에 국한되지 않는 어떠한 기술적 수단을 이용하여 본 앱의 정상적인 운영을 방해해서는 안 됩니다.';

  @override
  String get userAgreementSection3_4 =>
      '3.4 귀하는 본 앱의 기능 취약점을 이용하여 승인되지 않은 정보를 획득하거나 불법적인 조작을 해서는 안 됩니다. 취약점을 발견한 경우 즉시 당사에 연락해 주시기 바랍니다.';

  @override
  String get userAgreementSection4Title => '제4조 지식재산권';

  @override
  String get userAgreementSection4_1 =>
      '4.1 본 앱의 소스 코드는 MIT 라이선스에 따라 오픈소스로 공개되어 있으며, 귀하는 MIT 라이선스를 준수하는 전제 하에 본 앱의 소스 코드를 자유롭게 사용, 수정 및 배포할 수 있습니다.';

  @override
  String get userAgreementSection4_2 =>
      '4.2 본 앱의 명칭, 아이콘, UI 디자인 등은 Lumaris Team에 귀속되며, 허가 없이 상업적 목적으로 사용할 수 없습니다.';

  @override
  String get userAgreementSection4_3 =>
      '4.3 본 앱에 포함된 학교 명칭, 로고 등은 시안건축과학기술대학교에 귀속됩니다.';

  @override
  String get userAgreementSection5Title => '제5조 면책 조항';

  @override
  String get userAgreementSection5_1 =>
      '5.1 본 앱은 \"있는 그대로\" 제공되며, 당사는 본 앱의 정확성, 신뢰성, 완전성, 적시성에 대해 어떠한 명시적 또는 묵시적 보증도 하지 않습니다.';

  @override
  String get userAgreementSection5_2 =>
      '5.2 네트워크 장애, 시스템 유지보수, 학교 서버 문제 또는 기타 불가항력적 요인으로 인한 서비스 중단 또는 데이터 부정확에 대해 당사는 관련 책임을 지지 않습니다.';

  @override
  String get userAgreementSection5_3 =>
      '5.3 본 앱의 수업, 성적 등의 정보는 참고용이며, 최종적으로는 학교 공식 시스템 데이터를 기준으로 합니다. 본 앱 데이터에 의존하여 발생한 직간접적 손실에 대해 당사는 책임을 지지 않습니다.';

  @override
  String get userAgreementSection5_4 =>
      '5.4 당사는 귀하의 본 앱 사용으로 인한 기기 손상, 데이터 손실 또는 기타 손해에 대해 책임을 지지 않습니다. 단, 해당 손해가 당사의 고의 또는 중대한 과실로 인한 경우는 제외됩니다.';

  @override
  String get userAgreementSection6Title => '제6조 약관의 수정 및 종료';

  @override
  String get userAgreementSection6_1 =>
      '6.1 당사는 언제든지 본 약관을 수정할 권리를 보유합니다. 수정된 약관은 앱 내에 게시되며, 중대한 변경 사항은 앱 내 알림을 통해 안내됩니다.';

  @override
  String get userAgreementSection6_2 =>
      '6.2 약관 수정 후 본 앱을 계속 사용하면 수정된 약관에 동의한 것으로 간주됩니다. 수정된 약관에 동의하지 않는 경우, 본 앱의 사용을 중단해야 합니다.';

  @override
  String get userAgreementSection6_3 =>
      '6.3 당사는 다음의 경우 귀하에 대한 서비스 제공을 종료할 권리가 있습니다: (1) 귀하가 본 약관의 관련 규정을 위반한 경우, (2) 법령 또는 정책 요구의 변경으로 인한 경우, (3) 학교 관련 시스템 정책 변경으로 인해 서비스를 계속 제공할 수 없는 경우.';

  @override
  String get userAgreementSection7Title => '제7조 기타 조항';

  @override
  String get userAgreementSection7_1 =>
      '7.1 본 약관의 어떤 조항이 어떠한 이유로든 전부 또는 일부가 무효이거나 집행 불가능하게 되더라도, 나머지 조항은 여전히 유효하며 구속력을 가집니다.';

  @override
  String get userAgreementSection7_2 =>
      '7.2 본 약관의 체결, 집행 및 해석과 분쟁 해결에는 중화인민공화국 법률이 적용됩니다.';

  @override
  String get userAgreementSection7_3 =>
      '7.3 귀하와 당사 간에 본 약관의 내용이나 그 집행에 관하여 분쟁이 발생한 경우, 우호적인 협의를 통해 해결해야 합니다. 협의가 이루어지지 않는 경우, 어느 일방이든 관할권이 있는 인민법원에 소송을 제기할 수 있습니다.';

  @override
  String get userAgreementSection8Title => '제8조 문의하기';

  @override
  String get userAgreementSection8_1 =>
      '본 약관에 관한 문의, 의견 또는 제안 사항이 있으시면 다음 방법으로 연락해 주시기 바랍니다:';

  @override
  String get userAgreementContact =>
      '개발팀: Lumaris Team\n코드 저장소: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get aboutAuthor => '개발자 정보';

  @override
  String get coreTeam => '핵심 팀';

  @override
  String get specialThanks => '특별 감사';

  @override
  String get contactUs => '문의하기';

  @override
  String get thanksTitle => '감사 인사';

  @override
  String get thanksContent =>
      '본 프로젝트에 코드를 기여하고, 제안을 주시고, 문제를 보고해 주신 모든 개발자와 사용자 여러분께 감사드립니다. 여러분의 지원이 우리가 나아가는 원동력입니다. 특히 개발 단계에서 수고해 주신 모든 테스터 분들께 특별한 감사를 드립니다.';

  @override
  String get githubRepository => 'GitHub 저장소';

  @override
  String get joinUs => '함께하기';

  @override
  String get madeWithLove => '시안에서 ❤️를 담아 만들었습니다';

  @override
  String get easterEggTitle => '🎉 이스터에그';

  @override
  String get easterEggFound => '숨겨진 이스터에그를 발견하셨습니다!';

  @override
  String get easterEggContent =>
      '당신은 이 비밀을 아는 몇 안 되는 사람 중 하나입니다!\n\nLumaris에 대한 애정과 지지에 감사드립니다.\n\n계속 탐험하세요, 더 많은 놀라움이 기다리고 있을지도 모릅니다...';

  @override
  String get fontSetting => '글꼴 설정';

  @override
  String get fontSettingSubtitle => '데스크톱 플랫폼용 글꼴 선택 (다음 실행 시 적용됨)';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get customFont => '사용자 지정';

  @override
  String get hapticFeedback => '햅틱 피드백';

  @override
  String get hapticFeedbackSubtitle => '하단 네비게이션 바 클릭 시 진동';

  @override
  String get cloudSyncTodo => '할 일을 클라우드에 저장할지 여부';

  @override
  String get servicePaused => '해당 서비스가 일시 중지되었습니다';

  @override
  String get showTomorrowCourses => '내일 수업 표시';

  @override
  String get showTomorrowCoursesSubtitle => '오늘 수업이 없을 때 내일 수업 표시';

  @override
  String get courseReminder => '수업 알림';

  @override
  String get courseReminderSubtitle => '수업 시작 전 알림';

  @override
  String get remindMinutesBefore => '몇 분 전에 알림';

  @override
  String remindMinutes(int n) {
    return '$n분 전';
  }

  @override
  String get todoReminder => '할 일 알림';

  @override
  String get todoReminderSubtitle => '할 일 마감 전 알림';

  @override
  String get schedulePage => '시간표 페이지';

  @override
  String get scorePage => '성적 페이지';

  @override
  String get profilePage => '프로필 페이지';

  @override
  String get firstPageOnLaunch => '앱 시작 시 첫 페이지';

  @override
  String get sunday => '일요일';

  @override
  String get monday => '월요일';

  @override
  String get tuesday => '화요일';

  @override
  String get wednesday => '수요일';

  @override
  String get thursday => '목요일';

  @override
  String get friday => '금요일';

  @override
  String get saturday => '토요일';

  @override
  String get sundayShort => '일';

  @override
  String get mondayShort => '월';

  @override
  String get tuesdayShort => '화';

  @override
  String get wednesdayShort => '수';

  @override
  String get thursdayShort => '목';

  @override
  String get fridayShort => '금';

  @override
  String get saturdayShort => '토';

  @override
  String get janShort => '1월';

  @override
  String get febShort => '2월';

  @override
  String get marShort => '3월';

  @override
  String get aprShort => '4월';

  @override
  String get mayShort => '5월';

  @override
  String get junShort => '6월';

  @override
  String get julShort => '7월';

  @override
  String get augShort => '8월';

  @override
  String get sepShort => '9월';

  @override
  String get octShort => '10월';

  @override
  String get novShort => '11월';

  @override
  String get decShort => '12월';

  @override
  String weekUnit(int n) {
    return '$n주차';
  }

  @override
  String currentWeek(int n) {
    return '현재 $n주차';
  }

  @override
  String weeksUntilStart(int n) {
    return '개강까지 $n주 남음';
  }

  @override
  String periodRange(int start, int end) {
    return '제$start-$end교시';
  }

  @override
  String get allSchedules => '전체 시간표';

  @override
  String get previousWeek => '이전 주';

  @override
  String get nextWeek => '다음 주';

  @override
  String get switchStyle => '스타일 전환';

  @override
  String get refreshSchedule => '시간표 새로고침';

  @override
  String get scheduleSettingsTitle => '시간표 설정';

  @override
  String get compact => '간결';

  @override
  String get standard => '표준';

  @override
  String get relaxed => '넓게';

  @override
  String get selectCourse => '조회할 수업 선택';

  @override
  String get editCourse => '수업 편집';

  @override
  String get deleteCourse => '수업 삭제';

  @override
  String get confirmDelete => '삭제 확인';

  @override
  String confirmDeleteCourseContent(String name) {
    return '\"$name\" 수업을 정말 삭제하시겠습니까?';
  }

  @override
  String get delete => '삭제';

  @override
  String get courseModified => '수업이 수정되었습니다';

  @override
  String get courseDeleted => '수업이 삭제되었습니다';

  @override
  String get deleteFailed => '삭제 실패';

  @override
  String get noLocation => '장소 없음';

  @override
  String get addCourse => '수업 추가';

  @override
  String get save => '저장';

  @override
  String get courseName => '수업명';

  @override
  String get courseRoom => '강의실';

  @override
  String get courseTeacher => '담당 교수';

  @override
  String get courseCredits => '학점';

  @override
  String get courseWeekday => '요일';

  @override
  String get courseStartUnit => '시작 교시';

  @override
  String get courseEndUnit => '종료 교시';

  @override
  String get courseWeeks => '수업 주차';

  @override
  String selectedWeeks(int count) {
    return '$count주 선택됨';
  }

  @override
  String get customCourses => '사용자 지정 수업';

  @override
  String customCoursesCount(int count) {
    return '$count개 수업';
  }

  @override
  String get noCustomCourses => '사용자 지정 수업 없음';

  @override
  String get noCustomCoursesSubtitle => '오른쪽 상단 + 버튼을 눌러 수업 추가';

  @override
  String get readingCustomCourses => '사용자 지정 수업 로딩 중';

  @override
  String get readingCustomCoursesSubtitle => '로컬에 저장된 수업 설정을 정리하는 중';

  @override
  String get courseAdded => '수업이 추가되었습니다';

  @override
  String get scoresAndGpa => '성적 및 평점';

  @override
  String get passedCourses => '이수 과목';

  @override
  String get totalCredits => '총 학점';

  @override
  String get creditInfoTitle => '설명';

  @override
  String get creditInfoContent =>
      '여기의 학점은 성적에 따라 계산됩니다. 낙제 과목이 없으면 통과입니다. 학사 시스템에서 제공하는 수치는 일반적으로 이 수치보다 작거나 같습니다';

  @override
  String get noScores => '성적 없음';

  @override
  String get noScoresSubtitle => '새로고침하거나 로그아웃 후 다시 로그인 권장';

  @override
  String get refreshDataBtn => '데이터 새로고침';

  @override
  String get goToLogin => '로그인하러 가기';

  @override
  String get minorCourse => '부전공 과목';

  @override
  String get scoreDetail => '성적 세부정보';

  @override
  String get courseCreditLabel => '학점';

  @override
  String get courseScoreLabel => '성적';

  @override
  String get courseGpaLabel => '평점';

  @override
  String get fetchingScores => '성적 데이터를 가져오는 중...';

  @override
  String get refreshFailedFallback => '새로고침 실패, 로컬 데이터로 복원됨';

  @override
  String get fetchTimeout => '데이터 가져오기 시간 초과, 네트워크 연결을 확인한 후 다시 시도해 주세요';

  @override
  String get fetchFailed => '데이터 가져오기 실패';

  @override
  String get pleaseLoginFirst => '먼저 로그인하면 성적을 확인할 수 있습니다';

  @override
  String get readingScoresSubtitle =>
      '캐시를 읽고 학사 성적을 동기화하는 중입니다. 네트워크가 느린 경우 몇 초 정도 걸릴 수 있습니다';

  @override
  String get foolishModeMessage => '네, 제 평점은 5.0입니다';

  @override
  String creditUnit(String credit) {
    return '$credit 학점';
  }

  @override
  String gradeLabel(String grade) {
    return '성적 $grade';
  }

  @override
  String gpaLabel(String gpa) {
    return '평점 $gpa';
  }

  @override
  String scheduleCourseTime(
      String weekRanges, String weekday, int start, int end) {
    return '$weekRanges주차 매주 $weekday 제$start-$end교시';
  }

  @override
  String semesterRange(String start, String end, String num) {
    return '$start~$end년도 제$num학기';
  }

  @override
  String get semesterAutumnShort => '2학기';

  @override
  String get semesterSpringShort => '1학기';

  @override
  String get year1 => '1학년';

  @override
  String get year2 => '2학년';

  @override
  String get year3 => '3학년';

  @override
  String get year4 => '4학년';

  @override
  String get year5 => '5학년';

  @override
  String get year6 => '6학년';

  @override
  String get year7 => '7학년';

  @override
  String get year8 => '8학년';

  @override
  String get year9 => '9학년';

  @override
  String get year10 => '10학년';

  @override
  String get loginTitle => '학사 시스템 로그인';

  @override
  String get loginSubtitle => '계정을 사용하여 계속 진행하세요';

  @override
  String get studentId => '학번';

  @override
  String get password => '통합 인증 비밀번호';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loggingIn => '학사 시스템에 로그인하는 중';

  @override
  String get loggingInSubtitle =>
      '계정을 확인하고 수업, 성적 등 기본 데이터를 동기화하는 중입니다. 첫 로그인 시 몇 초 정도 걸릴 수 있습니다';

  @override
  String get emptyCredentials => '사용자 이름과 비밀번호를 입력해야 합니다';

  @override
  String get loginTimeoutEdu => '학사 시스템 로그인 시간 초과, 네트워크 연결을 확인해 주세요';

  @override
  String get loginFailed => '로그인 실패, 사용자 이름과 비밀번호를 확인해 주세요';

  @override
  String get loginTimeout => '로그인 시간 초과, 네트워크 연결을 확인한 후 다시 시도해 주세요';

  @override
  String get loginSecurityStorageUnavailable =>
      '로그인 성공, 그러나 보안 저장소를 사용할 수 없어 다음 실행 시 계정 정보를 다시 입력해야 할 수 있습니다';

  @override
  String get loadingDefaultTitle => '데이터 동기화 중';

  @override
  String get loadingDefaultSubtitle =>
      '네트워크가 느린 경우 몇 초 정도 걸릴 수 있습니다. 잠시만 기다려 주세요';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get retry => '재시도';

  @override
  String get loadFailed => '로드 실패';

  @override
  String get noData => '데이터 없음';

  @override
  String get ok => '확인';

  @override
  String get classroom => '강의실';

  @override
  String get teacherLabel => '담당 교수';

  @override
  String get classTime => '수업 시간';

  @override
  String get classCampus => '수업 캠퍼스';

  @override
  String get todayScheduleLabel => '오늘의 시간표';

  @override
  String get tomorrowSchedule => '내일 시간표';

  @override
  String get noCourseToday => '오늘 수업이 없습니다';

  @override
  String get noCourseTodaySubtitle => '편히 쉬세요, 하루 종일 공부하면 피곤하니까요';

  @override
  String get showTomorrowSchedule => '내일 시간표 보기';

  @override
  String get doubleTapExit => '한 번 더 누르면 앱이 종료됩니다';

  @override
  String copySuccess(String text) {
    return '복사됨: $text';
  }

  @override
  String get copyTooltip => '텍스트 복사';

  @override
  String get pageSettings => '페이지 설정';

  @override
  String get showBusTile => '스쿨버스 타일 표시';

  @override
  String get showBusTileSubtitle => '홈에서 최근 셔틀버스 정보 표시';

  @override
  String get addToHome => '홈에 추가';

  @override
  String get showElectricityTile => '전기요금 타일 표시';

  @override
  String get electricityRecharge => '전기요금 충전';

  @override
  String get electricityRechargeSubtitle => 'WeChat으로 이동하여 전기요금 충전';

  @override
  String get showPaymentTile => '식권 타일 표시';

  @override
  String get showPaymentTileSubtitle => '홈에서 잔액 개요 표시';

  @override
  String get addTodo => '할 일 추가';

  @override
  String get todoTitle => '제목';

  @override
  String get deadline => '마감일';

  @override
  String get change => '변경';

  @override
  String get edit => '편집';

  @override
  String get done => '완료';

  @override
  String get todoListLabel => '할 일';

  @override
  String get readingTodos => '할 일 로딩 중';

  @override
  String get readingTodosSubtitle => '로컬 할 일 목록과 알림 상태를 로드하는 중';

  @override
  String get noTodos => '현재 할 일이 없습니다';

  @override
  String get noTodosSubtitle => '오른쪽 상단 버튼을 눌러 할 일 추가';

  @override
  String get todoLoadFailedSubtitle => '할 일을 불러올 수 없습니다';

  @override
  String deadlineLabel(String date) {
    return '마감일: $date';
  }

  @override
  String get noDeadline => '없음';

  @override
  String get titleRequired => '제목은 필수입니다';

  @override
  String get deadlineRequired => '마감일은 필수입니다';

  @override
  String get add => '추가';

  @override
  String get upcomingExams => '다가오는 시험';

  @override
  String get loadingExams => '시험 정보 로딩 중';

  @override
  String get loadingExamsSubtitle => '다가오는 시험 일정, 고사장 및 좌석 정보를 동기화하는 중';

  @override
  String get noExams => '최근 시험이 없습니다';

  @override
  String get noExamsSubtitle => '새로고침하면 나올지도 몰라요';

  @override
  String get examTime => '시험 시간';

  @override
  String get examLocation => '시험 장소';

  @override
  String get seatNumber => '좌석 번호';

  @override
  String seatNumberLabel(String seat) {
    return '좌석 $seat번';
  }

  @override
  String get examNotLoggedIn => '로그인되지 않음, 먼저 로그인해 주세요';

  @override
  String get examAuthFailed => '인증 실패, 다시 로그인해 주세요';

  @override
  String get examFetchFailed => '시험 정보를 가져오지 못했습니다. 눌러서 다시 시도';

  @override
  String get quickFeatures => '바로가기 기능';

  @override
  String get noQuickFeatures => '바로가기 기능 없음';

  @override
  String get noQuickFeaturesSubtitle => '편집 모드에서 추가하세요';

  @override
  String get moreFeatures => '더 많은 기능';

  @override
  String get scheduleWidgetTitle => '캘린더로 가져오기';

  @override
  String get subscriptionLink => '구독 링크';

  @override
  String get copiedSuccess => '복사 완료!';

  @override
  String get howToImport => '가져오는 방법을 모르시나요?';

  @override
  String get customCourseManage => '사용자 지정 수업 관리';

  @override
  String get showCourseGrid => '시간표 그리드 표시';

  @override
  String get noBackground => '배경 없음';

  @override
  String get customImage => '사용자 지정 이미지';

  @override
  String get noImageSelected => '이미지가 선택되지 않음';

  @override
  String get noCalendarApp => '캘린더 앱을 찾을 수 없습니다, 수동으로 가져와 주세요';

  @override
  String get cannotOpenCalendar => '캘린더 앱을 열 수 없습니다';

  @override
  String get bgImageSetSuccess => '배경 이미지가 설정되었습니다';

  @override
  String get selectImageFailed => '이미지 선택 실패';

  @override
  String get addCalendarSub => '캘린더 구독 추가';

  @override
  String get understand => '확인했습니다';

  @override
  String get calendarSubscription => '캘린더 구독';

  @override
  String get scheduleManagement => '시간표 관리';

  @override
  String get scheduleBackground => '시간표 배경';

  @override
  String get ignoreCourses => '수업 제외';

  @override
  String get loadingSchedule => '시간표 로딩 중';

  @override
  String get loadingScheduleSubtitle => '수업, 환경 설정 및 배경 설정을 읽는 중';

  @override
  String get updatingSchedule => '시간표 업데이트 중...';

  @override
  String get updateComplete => '업데이트 완료';

  @override
  String get updateTimeout => '업데이트 시간 초과, 네트워크 연결을 확인한 후 다시 시도해 주세요';

  @override
  String updateFailed(String error) {
    return '업데이트 실패: $error';
  }

  @override
  String get linkCopiedToClipboard => '링크가 클립보드에 복사되었습니다';

  @override
  String get currentWeekLabel => '이번 주';

  @override
  String periodUnit(int n) {
    return '제$n교시';
  }

  @override
  String get calendarGuidanceIntro =>
      '기기에 캘린더 구독을 직접 처리할 수 있는 앱이 없는 것 같습니다. 다음 단계에 따라 수동으로 추가하세요:';

  @override
  String get calendarGuidanceStep1 => '1. 캘린더 앱 열기';

  @override
  String get calendarGuidanceStep2 => '2. \"캘린더 추가\" 또는 \"구독\" 옵션 찾기';

  @override
  String get calendarGuidanceStep3 => '3. \"URL로 추가\" 또는 유사한 옵션 선택';

  @override
  String get calendarGuidanceStep4 => '4. 다음 링크 붙여넣기:';

  @override
  String get calendarGuidanceNote =>
      '참고: 캘린더 앱마다 추가 단계가 다를 수 있습니다. 어려움이 있는 경우 캘린더 앱의 도움말 문서를 참조하세요.';

  @override
  String get profileReading => '계정 정보 로딩 중';

  @override
  String get profileReadingSubtitle =>
      '로컬 로그인 상태와 프로필 항목을 동기화하는 중입니다. 잠시만 기다려 주세요';

  @override
  String get campusNavigation => '캠퍼스 툴박스';

  @override
  String get settingsAbout => '설정/정보';

  @override
  String get programLabel => '교육 과정';

  @override
  String get campusMap => '캠퍼스 지도';

  @override
  String get help => '도움말';

  @override
  String get academicAccount => '학사 시스템 계정';

  @override
  String get guest => '게스트';

  @override
  String get guestMode => '게스트 모드';

  @override
  String get guestModeSubtitle => '로그인하여 모든 기능을 이용하세요';

  @override
  String get syncingAcademic => '학업 정보 동기화 중';

  @override
  String get syncingAcademicSubtitle => '학점 및 개인정보 카드를 읽는 중';

  @override
  String get loginEduSystem => '학사 시스템 로그인';

  @override
  String get programLoading => '교육 과정 로딩 중';

  @override
  String get programLoadingSubtitle =>
      '학기별 수업 구조와 과목 분류를 정리하는 중입니다. 잠시만 기다려 주세요';

  @override
  String get programLoadFailed => '로드 실패';

  @override
  String get programNoData => '데이터 없음';

  @override
  String get programRefreshFailed => '새로고침 실패, 현재 표시된 것은 마지막으로 동기화된 교육 과정입니다';

  @override
  String get linkLoading => '내비게이션 링크 로딩 중';

  @override
  String get linkLoadingSubtitle => '자주 찾는 사이트와 카테고리 항목을 정리하는 중';

  @override
  String get linkLoadFailed => '로드 실패';

  @override
  String get linkNoData => '내비게이션 데이터 없음';

  @override
  String get linkNoDataSubtitle => '이 페이지를 다시 열거나 현재 네트워크를 확인해 주세요';

  @override
  String get paymentLoading => '식권 잔액 동기화 중';

  @override
  String get paymentLoadingSubtitle => '최신 거래 내역을 가져오는 중입니다. 잠시만 기다려 주세요...';

  @override
  String get paymentPasswordTitle => '식권 비밀번호';

  @override
  String get paymentPasswordSubtitle => '선택 사항입니다. 비워 두면 기본 방식으로 조회합니다.';

  @override
  String get paymentSaveAndRefresh => '저장 후 새로고침';

  @override
  String get campusCard => '캠퍼스 카드';

  @override
  String get currentBalance => '현재 잔액';

  @override
  String get recentTransactions => '최근 거래';

  @override
  String get paymentFilter => '결제';

  @override
  String get consumptionFilter => '소비';

  @override
  String get rechargeFilter => '충전';

  @override
  String get noCardData => '카드 데이터 없음';

  @override
  String get noCardDataSubtitle => '잔액 및 거래 내역을 보려면 학사 시스템 계정으로 로그인해 주세요';

  @override
  String get busLoading => '스쿨버스 시간표 로딩 중';

  @override
  String get busLoadingSubtitle => '날짜별 두 캠퍼스 간 셔틀버스 정보를 정리하는 중';

  @override
  String get noBusToday => '오늘 운행 종료';

  @override
  String get noBusTodaySubtitle => '내일 다시 확인해 주세요';

  @override
  String get departureTime => '출발 시간';

  @override
  String get destination => '도착지';

  @override
  String get estimatedArrival => '도착 예정';

  @override
  String get busInfo => '버스 정보';

  @override
  String get departure => '출발';

  @override
  String get arrival => '도착';

  @override
  String get netRefreshFailed => '새로고침 실패, 현재 캠퍼스 네트워크 데이터가 유지됨';

  @override
  String get netData => '캠퍼스 네트워크 데이터';

  @override
  String get usedTraffic => '사용한 데이터';

  @override
  String onlineDuration(String time) {
    return '온라인 시간: $time';
  }

  @override
  String get username => '사용자 이름';

  @override
  String get ipAddress => 'IP 주소';

  @override
  String get productPackage => '요금제';

  @override
  String get unknown => '알 수 없음';

  @override
  String get copiedToClipboard => '클립보드에 복사됨';

  @override
  String get netLoading => '캠퍼스 네트워크 데이터 로딩 중';

  @override
  String get netLoadingSubtitle => '데이터 사용량, 온라인 시간 및 계정 정보를 동기화하는 중';

  @override
  String get netLoadFailed => '로드 실패';

  @override
  String get netNoData => '데이터 없음';

  @override
  String get electricityBalance => '현재 잔액';

  @override
  String get electricityNoData => '데이터 없음';

  @override
  String get electricityLowBalance => '잔액 부족, 제때 충전해 주세요';

  @override
  String get electricitySufficient => '잔액 충분';

  @override
  String get electricityAddTip => '오른쪽 상단 버튼을 눌러 전기요금 데이터 추가';

  @override
  String get electricityLoading => '전기 사용 추세 새로고침 중';

  @override
  String get electricityLoadingSubtitle => '최신 전기요금 기록을 읽는 중';

  @override
  String get noUsageDetails => '전기 사용 내역 없음';

  @override
  String get noUsageDetailsSubtitle => '새로고침하면 시간별 비용이 여기에 표시됩니다';

  @override
  String get electricityCost => '전기 사용 요금';

  @override
  String lastNDays(int n) {
    return '최근 $n일';
  }

  @override
  String get totalCost => '총 비용';

  @override
  String get todayCost => '오늘 비용';

  @override
  String get avgDailyCost => '일평균 비용';

  @override
  String get peakHours => '피크 시간대';

  @override
  String get hourlyDetails => '시간별 내역';

  @override
  String get lowBalanceSub => '잔액 부족 알림';

  @override
  String get lowBalanceSubDesc => '잔액이 설정한 금액 이하일 때...';

  @override
  String get addElectricityFirst => '먼저 전기요금 페이지를 추가하세요...';

  @override
  String get noElectricityData => '아직 전기요금 데이터가 없습니다';

  @override
  String get noElectricityDataSubtitle => '먼저 본 페이지에서 기숙사 전기요금 링크를 연결하세요...';

  @override
  String get lowBalanceEnabled => '잔액 부족 알림이 켜져 있습니다';

  @override
  String get addLowBalanceAlert => '잔액 부족 알림 추가';

  @override
  String get deleteSubscription => '구독 삭제';

  @override
  String get deleteSubDesc => '현재 이메일의 잔액 부족 알림 취소...';

  @override
  String get electricityManagement => '전기요금 관리';

  @override
  String get chooseAction => '실행할 작업을 선택하세요';

  @override
  String get changeRoom => '방 변경';

  @override
  String get getElectricity => '전기요금 조회';

  @override
  String get electricityUrlPrompt =>
      '건축대학교 재무처 전기요금 상세 페이지를 열고, 페이지 URL을 복사하여 아래 입력창에 붙여넣으세요';

  @override
  String get urlPlaceholder => 'URL을 입력하세요';

  @override
  String get createLowBalanceAlert => '잔액 부족 알림 생성';

  @override
  String get lowBalanceAlertDesc =>
      '현재 연결된 기숙사 전기요금 페이지를 사용하여, 잔액이 설정한 임계값 이하로 내려갈 때 이메일로 알림을 보냅니다.';

  @override
  String get remindEmail => '알림 이메일';

  @override
  String get remindEmailPlaceholder => '알림 이메일';

  @override
  String get remindThreshold => '알림 임계값, 예: 10';

  @override
  String get remindThresholdPlaceholder => '알림 임계값, 예: 10';

  @override
  String get pleaseEnterEmail => '알림 이메일을 입력해 주세요';

  @override
  String get pleaseEnterValidEmail => '유효한 이메일 주소를 입력해 주세요';

  @override
  String get pleaseEnterThreshold => '0보다 큰 알림 임계값을 입력해 주세요';

  @override
  String get lowBalanceAlertCreated => '잔액 부족 알림이 생성되었습니다';

  @override
  String get createSubFailed => '전기요금 구독 생성 실패';

  @override
  String currentSubInfo(String email, String threshold) {
    return '현재 이메일 $email, $threshold위안 미만 시 알림';
  }

  @override
  String get subSetupHint => '임계값을 설정하면 잔액이 해당 금액 이하로 내려갈 때 이메일로 알림이 발송됩니다';

  @override
  String get remindEmailLabel => '알림 이메일';

  @override
  String get notSet => '설정되지 않음';

  @override
  String get remindThresholdLabel => '알림 임계값';

  @override
  String get gotIt => '확인';

  @override
  String get noSubToDelete => '현재 삭제할 구독이 없습니다';

  @override
  String get deleteSubTitle => '구독 삭제';

  @override
  String get deleteSubConfirmContent => '현재 잔액 부족 구독을 정말 삭제하시겠습니까?';

  @override
  String get lowBalanceAlertDeleted => '잔액 부족 알림이 삭제되었습니다';

  @override
  String get deleteSubFailed => '전기요금 구독 삭제 실패';

  @override
  String get electricitySubLoadFailed => '전기요금 구독 로딩 실패';

  @override
  String get subscriptionDetail => '구독 내용';

  @override
  String get create => '생성';

  @override
  String get webNotSupported => 'Web 버전은 지원되지 않습니다';

  @override
  String get webNotSupportedSubtitle => '다른 버전을 사용해 주세요';

  @override
  String get reorderFailed => '재정렬 실패';

  @override
  String get searchLocation => '장소 또는 건물 검색...';

  @override
  String get search => '검색...';

  @override
  String get buildingIntro => '건물 소개';

  @override
  String get specificLocation => '상세 위치';

  @override
  String get licenseTitle => '오픈소스 라이선스';

  @override
  String get licenseLoading => '라이선스 읽는 중';

  @override
  String get licenseLoadingSubtitle => '앱에 포함된 오픈소스 라이선스 텍스트를 로드하는 중';

  @override
  String get licenseLoadFailed => '라이선스 파일을 로드할 수 없습니다';

  @override
  String get helpFeaturesTab => '기능 소개';

  @override
  String get helpInstructionsTab => '사용 설명';

  @override
  String get helpNotesTab => '주의사항';

  @override
  String get helpAboutTab => '앱 정보';

  @override
  String get helpFeatureHome => '홈';

  @override
  String get helpFeatureHomeDesc => '정보 센터, 개인정보·수업·할 일 및 시험 일정 표시';

  @override
  String get helpFeatureSchedule => '시간표';

  @override
  String get helpFeatureScheduleDesc => '주간 수업 일정 관리, 캠퍼스 전환 및 알림 설정 지원';

  @override
  String get helpFeatureScore => '성적 조회';

  @override
  String get helpFeatureScoreDesc => '학기별 성적표, 평점 계산 및 분석 확인';

  @override
  String get helpFeatureProfile => '프로필';

  @override
  String get helpFeatureProfileDesc => '학번, 이름, 소속 대학 등 개인정보 표시';

  @override
  String get helpFeatureBus => '스쿨버스';

  @override
  String get helpFeatureBusDesc => '캠퍼스 간 셔틀버스 시간표 및 노선 정보 확인';

  @override
  String get helpFeatureProgram => '교육 과정';

  @override
  String get helpFeatureProgramDesc => '전공 교육 계획 및 학점 요건 표시';

  @override
  String get helpFeatureElectricity => '전기요금 조회';

  @override
  String get helpFeatureElectricityDesc => '기숙사 전력량 및 전기 사용 기록 확인';

  @override
  String get helpFeaturePayment => '식권 소비';

  @override
  String get helpFeaturePaymentDesc => '식권 잔액 및 소비 내역 확인';

  @override
  String get helpFeatureNet => '캠퍼스 네트워크';

  @override
  String get helpFeatureNetDesc => '네트워크 데이터 사용량 및 통계 확인';

  @override
  String get helpFeatureLinks => '바로가기 링크';

  @override
  String get helpFeatureLinksDesc => '학사 시스템 등 자주 사용하는 도구 링크 모음';

  @override
  String get helpInstructionLogin => '로그인 및 계정';

  @override
  String get helpInstructionLoginDesc => '처음 사용 시 학사 시스템 계정으로 로그인 필요';

  @override
  String get helpInstructionCourse => '수업 관리';

  @override
  String get helpInstructionCourseDesc =>
      '시간표에서 이번 주 수업을 확인하세요. 좌우로 스와이프하여 주차 전환, 수업을 눌러 상세 정보 확인';

  @override
  String get helpInstructionReminder => '일정 알림';

  @override
  String get helpInstructionReminderDesc => '설정에서 수업 알림을 켜면 앱이 수업 전에 알림을 보냅니다';

  @override
  String get helpInstructionSync => '데이터 동기화';

  @override
  String get helpInstructionSyncDesc =>
      '앱이 자동으로 학사 시스템 데이터를 동기화하며, 네트워크 연결이 필요합니다. 아래로 당겨 새로고침하면 수동으로 업데이트할 수 있습니다';

  @override
  String get helpInstructionWidget => '바탕화면 위젯';

  @override
  String get helpInstructionWidgetDesc =>
      '바탕화면을 길게 눌러 앱 위젯을 추가하면 수업 정보를 빠르게 확인할 수 있습니다';

  @override
  String get helpNoteNetwork => '일부 기능은 캠퍼스 네트워크에 연결되어야 정상적으로 사용할 수 있습니다';

  @override
  String get helpNoteUpdate => '최신 기능과 수정 사항을 위해 앱을 최신 버전으로 유지하세요';

  @override
  String get helpNoteData => '데이터가 정확하지 않을 때는 학사 시스템에 올바르게 로그인했는지 확인하세요';

  @override
  String get helpNoteFeedback => '문제가 발생하면 설정 페이지를 통해 피드백을 보내실 수 있습니다';

  @override
  String get helpNotePrivacy => '앱은 귀하의 개인정보를 수집하거나 업로드하지 않습니다';

  @override
  String get helpAboutPlatform => '플랫폼 지원';

  @override
  String get helpAboutPlatformDesc => '크로스 플랫폼 앱, 다음 플랫폼을 지원합니다:';

  @override
  String get helpAboutOpenSource => '오픈소스 프로젝트';

  @override
  String get helpAboutOpenSourceDesc => '본 앱은 MIT 라이선스 기반의 오픈소스입니다';

  @override
  String get helpAboutRepoLabel => '저장소 주소:';

  @override
  String get underMaintenanceTitle => '점검 중!';

  @override
  String get underMaintenanceDescription =>
      '현재 정기 점검을 진행하고 있습니다. 나중에 다시 확인해 주세요. 기다려 주셔서 감사합니다.';

  @override
  String get readingPaymentCard => '식권 정보 로딩 중';

  @override
  String get lowBalance => '잔액 부족';

  @override
  String get campusCardBalance => '식권 잔액';

  @override
  String get tapToView => '눌러서 확인';

  @override
  String get tapToSubscribe => '눌러서 구독';

  @override
  String get campusCaoTang => '초당';

  @override
  String get campusYanTa => '옌타';

  @override
  String get busRefreshStale => '새로고침 완료, 마지막 스쿨버스 데이터가 유지됨';

  @override
  String arrivalStationTime(String h, String m) {
    return '$h시간 $m분';
  }

  @override
  String get poiMainLibrary => '중앙도서관';

  @override
  String get poiMainLibraryDesc => '24시간 개방 자습실';

  @override
  String get poiCaoTangNorthGate => '초당 캠퍼스 북문';

  @override
  String get poiCaoTangNorthGateDesc => '캠퍼스 정문';

  @override
  String get poiYanTaEastGate => '옌타 캠퍼스 동문';

  @override
  String get poiYanTaEastGateDesc => '역사적인 캠퍼스 입구';

  @override
  String durationDHMS(String d, String h, String m, String s) {
    return '$d일 $h시간 $m분 $s초';
  }

  @override
  String get shortcuts => '바로가기 기능';

  @override
  String get moreFunctions => '더 많은 기능';

  @override
  String get noShortcuts => '바로가기 기능 없음';

  @override
  String get addInEditMode => '편집 모드에서 추가하세요';

  @override
  String get eduSystem => '학사 시스템';

  @override
  String get htmlImport => 'HTML 가져오기';

  @override
  String get pasteHtmlHint => '시간표 HTML 코드를 붙여넣으세요';

  @override
  String get parseAndPreview => '분석 및 미리보기';

  @override
  String get importCourses => '강의 가져오기';

  @override
  String get parseResult => '분석 결과';

  @override
  String get noCoursesParsed => '분석된 강의 없음';

  @override
  String get searchSchool => '학교 검색...';

  @override
  String get basicSupport => '기본';

  @override
  String get advancedSupport => '고급';

  @override
  String get schoolNotSupported => '현재 학교에서는 이 기능을 지원하지 않아요';

  @override
  String get switchSchool => '학교 변경';

  @override
  String get selectSchool => '학교 선택';

  @override
  String get enterCustomUrl => '또는 사용자 정의 URL 입력';

  @override
  String get urlHint => '웹사이트 URL 입력';

  @override
  String get icp => 'ICP';
}
