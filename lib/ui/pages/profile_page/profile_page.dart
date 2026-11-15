import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../features/basic/models/school.dart';
import '../../../features/education/models/info_model.dart';
import '../../../features/education/services/info_service.dart';
import '../../../routes/router.dart';
import '../../../state/prefs_keys.dart';
import '../../../state/school_store.dart';
import '../../../state/user_store.dart';
import '../../components/loading_state_view.dart';
import '../../components/page_app_bar.dart';
import '../../components/settings_group.dart';
import '../../components/study_credit_card.dart';

final _studyProgressProvider = FutureProvider.autoDispose
    .family<List<InfoModel>, String?>((ref, schoolCode) async {
      try {
        return await InfoService.getInfoList().timeout(
          const Duration(seconds: 10),
        );
      } on TimeoutException {
        AppLogger.warning('[ProfilePage] 获取信息列表超时');
        return <InfoModel>[];
      } catch (error, stackTrace) {
        AppLogger.error('获取学生信息列表失败', error: error, stackTrace: stackTrace);
        rethrow;
      }
    });

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    unawaited(_readUsername());
  }

  Future<void> _readUsername() async {
    final String username =
        await SecureStorageService.instance.read(key: PrefsKeys.USERNAME) ??
        PrefsService.instance.getString(PrefsKeys.USERNAME) ??
        '';
    if (!mounted) return;

    setState(() {
      _username = username;
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    final bool? result = await AppRouter.push<bool>(
      AppRoutes.login,
      extra: {'isOnlyLoginMember': false},
    );
    if (!mounted || result != true) return;

    await _readUsername();
    if (mounted) ref.invalidate(_studyProgressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool isLogin = ref.watch(
      userStoreProvider.select((state) => state.isLogin),
    );
    final School? school = ref.watch(
      schoolStoreProvider.select((state) => state.school),
    );

    // IndexedStack 保留页面时，重新登录后也要读取最新的账号。
    ref.listen<bool>(userStoreProvider.select((state) => state.isLogin), (
      previous,
      next,
    ) {
      if (next) {
        unawaited(_readUsername());
      } else {
        setState(() => _username = '');
      }
    });

    final PageAppBar appBar = PageAppBar(title: l10n.profile);
    if (_isLoading) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: LoadingStateView(
            title: l10n.profileReading,
            subtitle: l10n.profileReadingSubtitle,
          ),
        ),
      );
    }

    final String accountDescription = [
      if (school != null && school.name.isNotEmpty) school.name,
      l10n.academicAccount,
    ].join(' · ');

    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      appBar: isMobile ? appBar : null,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _ProfileAccount(
                  title: isLogin
                      ? (_username.isEmpty ? l10n.academicAccount : _username)
                      : l10n.loginEduSystem,
                  subtitle: isLogin ? accountDescription : l10n.guest,
                  onTap: isLogin ? null : _login,
                ),
                if (isLogin) ...[
                  const SizedBox(height: 24),
                  _ProfileSection(
                    title: l10n.profileCampusServices,
                    entries: [
                      _ProfileLink(
                        CupertinoIcons.bus,
                        l10n.schoolBus,
                        AppRoutes.schoolBus,
                      ),
                      _ProfileLink(
                        CupertinoIcons.map,
                        l10n.campusMap,
                        AppRoutes.campusMap,
                      ),
                      _ProfileLink(
                        CupertinoIcons.creditcard,
                        l10n.payment,
                        AppRoutes.payment,
                      ),
                      if (!kIsWeb)
                        _ProfileLink(
                          CupertinoIcons.bolt,
                          l10n.electricity,
                          AppRoutes.electricity,
                        ),
                      _ProfileLink(
                        CupertinoIcons.link,
                        l10n.campusNavigation,
                        AppRoutes.link,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ProfileSection(
                    title: l10n.profileAcademics,
                    entries: [
                      _ProfileLink(
                        CupertinoIcons.list_bullet,
                        l10n.programLabel,
                        AppRoutes.program,
                      ),
                    ],
                    footer: (school?.supports(Feature.studyProgress) ?? true)
                        ? _StudyProgress(schoolCode: school?.code)
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
                _ProfileSection(
                  title: l10n.profileSettingsAndSupport,
                  entries: [
                    _ProfileLink(
                      CupertinoIcons.gear_solid,
                      l10n.settingsAbout,
                      AppRoutes.about,
                    ),
                    _ProfileLink(
                      CupertinoIcons.question_circle,
                      l10n.help,
                      AppRoutes.helper,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAccount extends StatelessWidget {
  const _ProfileAccount({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      children: [
        McListTile(
          leading: ExcludeSemantics(
            child: SizedBox(
              width: 24,
              height: 24,
              child: McSmoothCorners.clip(
                borderRadius: McRadii.xsBorder,
                child: const Image(
                  image: AssetImage('assets/icon.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          showChevron: onTap != null,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.entries,
    this.footer,
  });

  final String title;
  final List<_ProfileLink> entries;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(title: title),
        const SizedBox(height: 12),
        SettingsGroup(children: entries),
        ?footer,
      ],
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink(this.icon, this.title, this.route);

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return McListTile(
      leading: ExcludeSemantics(
        child: Icon(
          icon,
          size: 20,
          color: CourseColorManager.generateSoftColor(title, isDark: true),
        ),
      ),
      title: Text(title),
      showChevron: true,
      onTap: () => AppRouter.push<void>(route),
    );
  }
}

class _StudyProgress extends ConsumerWidget {
  const _StudyProgress({required this.schoolCode});

  final String? schoolCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final AsyncValue<List<InfoModel>> progress = ref.watch(
      _studyProgressProvider(schoolCode),
    );

    return progress.when(
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final InfoModel item in items)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: StudyCreditCard(data: item),
            ),
        ],
      ),
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: LoadingStateView(
          title: l10n.syncingAcademic,
          subtitle: l10n.syncingAcademicSubtitle,
          compact: true,
          showCard: true,
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(l10n.loadFailed, textAlign: TextAlign.center),
      ),
    );
  }
}
