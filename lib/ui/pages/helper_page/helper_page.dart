import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelperPage extends StatefulWidget {
  const HelperPage({super.key});

  @override
  State<HelperPage> createState() => _HelperPageState();
}

class _HelperPageState extends State<HelperPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  List<String> _getTabs(BuildContext context) => [
        context.l10n.helpFeaturesTab,
        context.l10n.helpInstructionsTab,
        context.l10n.helpNotesTab,
        context.l10n.helpAboutTab,
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();

    // 监听 TabController 变化
    _tabController.addListener(_handleTabChange);

    // 获取版本信息
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    // 加载版本信息，以便在需要时使用
    await PackageInfo.fromPlatform();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.help,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: _getTabs(context).map((tab) => Tab(text: tab)).toList(),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        children: [
          _buildFeaturesPage(),
          _buildInstructionsPage(),
          _buildNotesPage(),
          _buildAboutPage(),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final colors = context.clubColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: CupertinoIcons.home,
                  title: context.l10n.helpFeatureHome,
                  description: context.l10n.helpFeatureHomeDesc,
                  color: colors.primary,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.calendar,
                  title: context.l10n.helpFeatureSchedule,
                  description: context.l10n.helpFeatureScheduleDesc,
                  color: colors.success,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.chart_bar,
                  title: context.l10n.helpFeatureScore,
                  description: context.l10n.helpFeatureScoreDesc,
                  color: colors.warning,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.person,
                  title: context.l10n.helpFeatureProfile,
                  description: context.l10n.helpFeatureProfileDesc,
                  color: colors.indigo,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: CupertinoIcons.bus,
                  title: context.l10n.helpFeatureBus,
                  description: context.l10n.helpFeatureBusDesc,
                  color: colors.danger,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.book,
                  title: context.l10n.helpFeatureProgram,
                  description: context.l10n.helpFeatureProgramDesc,
                  color: colors.purple,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: CupertinoIcons.bolt,
                  title: context.l10n.helpFeatureElectricity,
                  description: context.l10n.helpFeatureElectricityDesc,
                  color: colors.yellow,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.creditcard,
                  title: context.l10n.helpFeaturePayment,
                  description: context.l10n.helpFeaturePaymentDesc,
                  color: colors.pink,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.link,
                  title: context.l10n.helpFeatureLinks,
                  description: context.l10n.helpFeatureLinksDesc,
                  color: colors.primary,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final colors = context.clubColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInstructionItem(
                  icon: CupertinoIcons.person_circle,
                  title: context.l10n.helpInstructionLogin,
                  description: context.l10n.helpInstructionLoginDesc,
                  color: colors.primary,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.calendar_badge_plus,
                  title: context.l10n.helpInstructionCourse,
                  description: context.l10n.helpInstructionCourseDesc,
                  color: colors.success,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.bell,
                  title: context.l10n.helpInstructionReminder,
                  description: context.l10n.helpInstructionReminderDesc,
                  color: colors.warning,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.arrow_2_circlepath,
                  title: context.l10n.helpInstructionSync,
                  description: context.l10n.helpInstructionSyncDesc,
                  color: colors.cyan,
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.square_grid_2x2,
                  title: context.l10n.helpInstructionWidget,
                  description: context.l10n.helpInstructionWidgetDesc,
                  color: colors.purple,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPage() {
    final colors = context.clubColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ClubCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildNoteItem(
                  icon: CupertinoIcons.arrow_clockwise,
                  text: context.l10n.helpNoteUpdate,
                  color: colors.success,
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  text: context.l10n.helpNoteData,
                  color: colors.warning,
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.chat_bubble_text,
                  text: context.l10n.helpNoteFeedback,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.lock_shield,
                  text: context.l10n.helpNotePrivacy,
                  color: colors.indigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    final colors = context.clubColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // 应用信息卡片
          const SizedBox(height: 16),
          // 平台支持卡片
          ClubCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: ShapeDecoration(
                        color: colors.successSoft,
                        shape: ClubSmoothCorners.shape(ClubRadii.control),
                      ),
                      child: Icon(
                        CupertinoIcons.device_phone_portrait,
                        size: 20,
                        color: colors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.helpAboutPlatform,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.helpAboutPlatformDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  'iOS（iPhone、iPad）',
                  'Android',
                  'Windows',
                  'macOS',
                  'Linux',
                  'Web',
                  '微信小程序',
                ].map((platform) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 18,
                            color: colors.success,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            platform,
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.label,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 开源信息卡片
          ClubCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: ShapeDecoration(
                        color: colors.warningSoft,
                        shape: ClubSmoothCorners.shape(ClubRadii.control),
                      ),
                      child: Icon(
                        CupertinoIcons.heart,
                        size: 20,
                        color: colors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.helpAboutOpenSource,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.helpAboutOpenSourceDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.helpAboutRepoLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'gitee.com/luckyfishisdashen/iOSClub.AppMobile',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isTablet,
  }) {
    final colors = context.clubColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(
              color: color.withValues(alpha: 0.12),
              shape: ClubSmoothCorners.shape(ClubRadii.control),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: colors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isTablet,
  }) {
    final colors = context.clubColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(
              color: color.withValues(alpha: 0.12),
              shape: ClubSmoothCorners.shape(ClubRadii.control),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: colors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final colors = context.clubColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.12),
            shape: ClubSmoothCorners.shape(ClubRadii.control),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: colors.label,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    final colors = context.clubColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: colors.separator,
      ),
    );
  }
}
