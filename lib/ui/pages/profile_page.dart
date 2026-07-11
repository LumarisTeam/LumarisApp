import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';

import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/study_credit_card.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = true;
  String _username = '';
  int _dataRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 检查是否已有登录信息
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    final username = await secureStorage.read(key: PrefsKeys.USERNAME) ??
        prefs.getString(PrefsKeys.USERNAME);

    // 重置 _username
    _username = '';

    if (username != null && username.isNotEmpty) {
      _username = username;
    }

    if (!ref.read(userStoreProvider).isLogin) {
      // 没有登录信息，进入游客模式
      // await _enterGuestMode(); // 其实这里不需要做什么，只是确认状态
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enterLoginMode({bool isOnlyLoginMember = false}) async {
    final result = await AppRouter.push<bool>(
      AppRoutes.login,
      extra: {'isOnlyLoginMember': isOnlyLoginMember},
    );
    // 如果登录成功返回 true
    if (result == true) {
      await _checkLoginStatus();
      // 强制刷新数据
      if (mounted) {
        setState(() {
          _dataRefreshKey++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingStateView(
            title: l10n.profileReading,
            subtitle: l10n.profileReadingSubtitle,
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildProfileContent(),
    );
  }

  List<ProfileButtonItem> getProfileButtonItems(BuildContext context) {
    final l10n = context.l10n;
    final isLogin = ref.watch(userStoreProvider).isLogin;
    return [
      if (isLogin)
        ProfileButtonItem(
            icon: CupertinoIcons.link_circle,
            title: l10n.campusNavigation,
            route: AppRoutes.link),
      ProfileButtonItem(
          icon: Icons.settings,
          title: l10n.settingsAbout,
          route: AppRoutes.about),
      if (isLogin)
        ProfileButtonItem(
            title: l10n.schoolBus,
            icon: Icons.directions_bus_rounded,
            route: AppRoutes.schoolBus),
      if (!kIsWeb && isLogin)
        ProfileButtonItem(
            icon: CupertinoIcons.bolt_fill,
            title: l10n.electricity,
            route: AppRoutes.electricity),
      if (isLogin)
        ProfileButtonItem(
            icon: Icons.toc,
            title: l10n.programLabel,
            route: AppRoutes.program),
      if (isLogin)
        ProfileButtonItem(
            icon: Icons.monetization_on_outlined,
            title: l10n.payment,
            route: AppRoutes.payment),
      // if (!kIsWeb)
      //   ProfileButtonItem(
      //       icon: Icons.wifi_outlined, title: '校园网', route: AppRoutes.net),
      if (!isLogin)
        ProfileButtonItem(
            icon: Icons.login,
            title: l10n.loginEduSystem,
            onPressed: () {
              _enterLoginMode(isOnlyLoginMember: false);
            }),
      if (isLogin)
        ProfileButtonItem(
            icon: CupertinoIcons.map,
            title: l10n.campusMap,
            route: AppRoutes.campusMap),
      ProfileButtonItem(
          icon: Icons.help_outline, title: l10n.help, route: AppRoutes.helper),
    ];
  }

  Widget _buildProfileContent() {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLogin = ref.watch(userStoreProvider).isLogin;
    final school = ref.watch(schoolStoreProvider).school;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    LazyLoadImage.assets(
                      'assets/icon.webp',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username.isNotEmpty ? _username : l10n.notLoggedIn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          isLogin
                              ? '${school?.name ?? ""} ${l10n.academicAccount}'
                              : l10n.guest,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.secondaryLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          AnimatedCard(
            delay: const Duration(milliseconds: 100),
            child: ClubCard(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 6 : 3,
                    ),
                    itemBuilder: (context, index) {
                      return AnimatedCard(
                        delay: Duration(milliseconds: 50 * index),
                        child: Center(
                          child: getProfileButtonItems(context)[index]
                              .build(context),
                        ),
                      );
                    },
                    itemCount: getProfileButtonItems(context).length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  )),
            ),
          ),
          if (isLogin) const SizedBox(height: 16),
          if (isLogin &&
              (ref
                      .watch(schoolStoreProvider)
                      .school
                      ?.supports(Feature.studyProgress) ??
                  true))
            FutureBuilder(
                key: ValueKey('info_data_$_dataRefreshKey'),
                // 添加超时保护：最多10秒
                future: ref
                    .read(infoRepositoryProvider)
                    .getInfo()
                    .then(
                      (result) =>
                          result.isSuccess ? result.data : <InfoModel>[],
                    )
                    .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    AppLogger.warning('[ProfilePage] 获取信息列表超时');
                    return <InfoModel>[];
                  },
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LoadingStateView(
                        title: l10n.syncingAcademic,
                        subtitle: l10n.syncingAcademicSubtitle,
                        compact: true,
                        showCard: true,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('${l10n.loadFailed}: ${snapshot.error}'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) =>
                        StudyCreditCard(data: snapshot.data![index]),
                  );
                }),
        ],
      ),
    );
  }
}

class ProfileButtonItem {
  final String title;
  final IconData icon;
  String route = '';
  Function? onPressed;

  ProfileButtonItem(
      {required this.title,
      required this.icon,
      this.route = '',
      this.onPressed});

  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final shape = ClubSmoothCorners.shape(ClubRadii.panel);
    return Material(
        shape: shape,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ClubRadii.panel,
          customBorder: shape,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: CourseColorManager.generateSoftColor(
                    title,
                    isDark: true,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: colors.secondaryLabel),
                )
              ],
            ),
          ),
          onTap: () {
            if (route.isEmpty) {
              onPressed?.call();
            } else {
              AppRouter.push(route);
            }
          },
        ));
  }
}
