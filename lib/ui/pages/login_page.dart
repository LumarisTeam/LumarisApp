import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/school_selector.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  bool _hasAcceptedAgreement = false;
  late School _selectedSchool;

  @override
  void initState() {
    super.initState();
    _selectedSchool = ref.read(settingsStoreProvider.notifier).currentSchool ??
        School.fallbackList.first;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showClubSnackBar(
        context,
        Text(context.l10n.emptyCredentials),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.debug('[LoginPage] 开始登录');

      // 登录教务系统账号（添加超时保护：最多20秒）
      AppLogger.debug('[LoginPage] 登录教务系统');
      final eduLoginSuccess = await _loginToEduSystem().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          AppLogger.warning('[LoginPage] 教务系统登录超时');
          if (mounted) {
            showClubSnackBar(context, Text(context.l10n.loginTimeoutEdu));
          }
          return false;
        },
      );

      // 检查登录结果
      if (!eduLoginSuccess) {
        return;
      }

      // 保存登录信息
      final saveLoginInfoSuccess = await _saveLoginInfo();

      if (!saveLoginInfoSuccess && mounted) {
        showClubSnackBar(
          context,
          Text(context.l10n.loginSecurityStorageUnavailable),
        );
      }

      // 登录成功同时记录协议已同意
      await ref
          .read(settingsStoreProvider.notifier)
          .setHasAcceptedAgreement(true);

      // 登录成功，返回上一页并传递成功标志
      if (mounted) {
        AppRouter.pop(true);
      }

      AppLogger.debug('[LoginPage] 登录成功');
    } on TimeoutException catch (e) {
      AppLogger.warning('[LoginPage] 登录超时: $e');
      if (mounted) {
        showClubSnackBar(context, Text(context.l10n.loginTimeout));
      }
    } catch (e, stackTrace) {
      AppLogger.error('[LoginPage] 登录失败', error: e, stackTrace: stackTrace);
      if (mounted) {
        showClubSnackBar(
            context, Text('${context.l10n.loginFailed}: ${e.toString()}'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 登录教务系统
  /// 返回 true 表示登录 API 调用成功（数据刷新失败不影响登录状态）
  Future<bool> _loginToEduSystem() async {
    final result = await ref.read(educationSessionCoordinatorProvider).login(
          school: _selectedSchool,
          username: _usernameController.text,
          password: _passwordController.text,
        );
    if (!result.isSuccess) {
      if (mounted) {
        showClubSnackBar(
          context,
          Text(result.error.userMessage),
        );
      }
      return false;
    }
    return true;
  }

  /// 保存登录信息
  Future<bool> _saveLoginInfo() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    var saveSuccess = true;

    await prefs.setString(PrefsKeys.USERNAME, _usernameController.text);
    saveSuccess = await secureStorage.write(
          key: PrefsKeys.USERNAME,
          value: _usernameController.text,
        ) &&
        saveSuccess;
    saveSuccess = await secureStorage.write(
          key: PrefsKeys.PASSWORD,
          value: _passwordController.text,
        ) &&
        saveSuccess;

    // Read before setSchoolId() clears school-related prefs data
    final userDataString = prefs.getString(PrefsKeys.USER_DATA);

    if (userDataString != null) {
      // Re-save because setSchoolId() → _clearSchoolRelatedData() removes USER_DATA
      // await prefs.setString(PrefsKeys.USER_DATA, userDataString);
      final userData = jsonDecode(userDataString);
      await ref
          .read(userStoreProvider.notifier)
          .setUserData(UserData.fromJson(userData));
    }

    return saveSuccess;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final groupBackgroundColor = colors.cardBackground;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingStateView(
            title: l10n.loggingIn,
            subtitle: l10n.loggingInSubtitle,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => AppRouter.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo
            ClubSmoothCorners.clip(
              borderRadius: ClubRadii.tile,
              child: LazyLoadImage.assets(
                'assets/icon.webp',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              l10n.loginTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginSubtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 40),

            // School Selector
            Container(
              decoration: BoxDecoration(
                color: groupBackgroundColor,
                borderRadius: ClubRadii.navigation,
              ),
              child: SchoolSelector(
                selectedSchool: _selectedSchool,
                onChanged: (school) {
                  setState(() => _selectedSchool = school);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Grouped Inputs
            Container(
              decoration: BoxDecoration(
                color: groupBackgroundColor,
                borderRadius: ClubRadii.navigation,
              ),
              child: Column(
                children: [
                  _buildCupertinoLikeTextField(
                    context,
                    controller: _usernameController,
                    hintText: l10n.studentId,
                    icon: Icons.person_outline,
                    isFirst: true,
                    isLast: false,
                  ),
                  _buildCupertinoLikeTextField(
                    context,
                    controller: _passwordController,
                    hintText: l10n.password,
                    icon: Icons.lock_outline,
                    obscureText: _obscureText,
                    isPassword: true,
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _hasAcceptedAgreement,
                        onChanged: (v) =>
                            setState(() => _hasAcceptedAgreement = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.6),
                          ),
                          children: [
                            TextSpan(text: l10n.loginAgreementPrefix),
                            TextSpan(
                              text: '《${l10n.userAgreement}》',
                              style: TextStyle(color: colors.primary),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    AppRouter.push(AppRoutes.userAgreement),
                            ),
                            const TextSpan(text: ' 和 '),
                            TextSpan(
                              text: '《${l10n.privacyPolicy}》',
                              style: TextStyle(color: colors.primary),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    AppRouter.push(AppRoutes.privacyPolicy),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              TextButton(
                onPressed: () async {
                  const url =
                      'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Text(l10n.forgotPassword),
              )
            ]),

            const SizedBox(height: 24),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CupertinoButton.filled(
                onPressed: _hasAcceptedAgreement ? _login : null,
                child: Text(
                  l10n.loginTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoLikeTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.5),
          size: 22,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        isDense: true,
      ),
    );
  }
}
