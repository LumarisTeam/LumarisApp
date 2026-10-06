import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/pages/protocol_page/protocol_page.dart';

class AgreementPage extends ConsumerStatefulWidget {
  const AgreementPage({super.key});

  @override
  ConsumerState<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends ConsumerState<AgreementPage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Future<void> _onAgree(BuildContext context, WidgetRef ref) async {
    await ref
        .read(settingsStoreProvider.notifier)
        .setHasAcceptedAgreement(true);
  }

  void _onDisagree() {
    exit(0);
  }

  void _viewProtocol(ProtocolDocument document) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProtocolPage(document: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (_) {
        return MaterialPageRoute<void>(
          builder: (context) => _AgreementHomeView(
            onAgree: () => _onAgree(context, ref),
            onDisagree: _onDisagree,
            onViewPrivacyPolicy: () =>
                _viewProtocol(ProtocolDocument.privacyPolicy),
            onViewUserAgreement: () =>
                _viewProtocol(ProtocolDocument.userAgreement),
          ),
        );
      },
    );
  }
}

class _AgreementHomeView extends StatelessWidget {
  const _AgreementHomeView({
    required this.onAgree,
    required this.onDisagree,
    required this.onViewPrivacyPolicy,
    required this.onViewUserAgreement,
  });

  final Future<void> Function() onAgree;
  final VoidCallback onDisagree;
  final VoidCallback onViewPrivacyPolicy;
  final VoidCallback onViewUserAgreement;

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = PlatformUtils.isDesktop;
            final isTablet = constraints.maxWidth > 600 && !isDesktop;
            final isWide = isDesktop || isTablet;

            // 桌面端内容区最大宽度
            final contentMaxWidth =
                isDesktop ? 520.0 : (isTablet ? 480.0 : double.infinity);
            // 水平内边距
            final horizontalPadding =
                isDesktop ? 48.0 : (isTablet ? 40.0 : 28.0);
            // 顶部间距
            final topSpacing = isDesktop ? 48.0 : (isTablet ? 64.0 : 60.0);

            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: topSpacing),
                      // App 图标
                      _buildAppIcon(context, isWide),
                      const SizedBox(height: 24),
                      // 标题
                      Text(
                        context.l10n.appName,
                        style: TextStyle(
                          fontSize: isWide ? 30 : 26,
                          fontWeight: FontWeight.bold,
                          color: colors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.agreementWelcomeTitle,
                        style: TextStyle(
                          fontSize: isWide ? 17 : 16,
                          color: colors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 说明文字
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          context.l10n.agreementDescription,
                          style: TextStyle(
                            fontSize: isWide ? 16 : 15,
                            color: colors.label,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // 协议卡片区域
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildAgreementCard(
                          context: context,
                          isWide: isWide,
                          icon: CupertinoIcons.shield_fill,
                          iconColor: colors.primary,
                          title: context.l10n.privacyPolicy,
                          description: context.l10n.agreementPrivacyDescription,
                          onTap: onViewPrivacyPolicy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildAgreementCard(
                          context: context,
                          isWide: isWide,
                          icon: CupertinoIcons.doc_text_fill,
                          iconColor: colors.purple,
                          title: context.l10n.userAgreement,
                          description: context.l10n.agreementUserDescription,
                          onTap: onViewUserAgreement,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 提示文字
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          context.l10n.agreementReadTip,
                          style: TextStyle(
                            fontSize: isWide ? 14 : 13,
                            color: colors.secondaryLabel,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // 按钮区域
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildButtons(context, isWide),
                      ),
                      SizedBox(height: isDesktop ? 40 : 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context, bool isWide) {
    final colors = context.clubColors;
    final size = isWide ? 100.0 : 90.0;
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        shape: ClubSmoothCorners.shape(
          isWide ? ClubRadii.tile : ClubRadii.card,
        ),
        shadows: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClubSmoothCorners.clip(
        borderRadius: isWide ? ClubRadii.tile : ClubRadii.card,
        child: const Image(
          image: AssetImage('assets/icon.webp'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    bool isWide,
  ) {
    final colors = context.clubColors;
    final buttonHeight = isWide ? 52.0 : 50.0;
    final fontSize = isWide ? 18.0 : 17.0;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: CupertinoButton.filled(
            onPressed: onAgree,
            child: Text(
              context.l10n.agreeAndContinue,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: CupertinoButton(
            onPressed: onDisagree,
            color: colors.surfaceRaised,
            child: Text(
              context.l10n.disagree,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCard({
    required BuildContext context,
    required bool isWide,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colors = context.clubColors;
    return Material(
      color: colors.surfaceRaised,
      shape: ClubSmoothCorners.shape(ClubRadii.panel),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: ClubRadii.panel,
        customBorder: ClubSmoothCorners.shape(ClubRadii.panel),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isWide ? 20 : 18),
          child: Row(
            children: [
              Container(
                width: isWide ? 46 : 42,
                height: isWide ? 46 : 42,
                decoration: ShapeDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: ClubSmoothCorners.shape(ClubRadii.navigation),
                ),
                child: Icon(icon, size: isWide ? 24 : 22, color: iconColor),
              ),
              SizedBox(width: isWide ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isWide ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: colors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isWide ? 14 : 13,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: isWide ? 20 : 18,
                color: colors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
