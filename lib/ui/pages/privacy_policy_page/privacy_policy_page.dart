import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final textColor = colors.label;
    final titleColor = colors.label;

    return Scaffold(
      appBar: ClubAppBar(title: l10n.privacyPolicy),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('光序 隐私协议', titleColor),
            const SizedBox(height: 8),
            _buildSubtitle(context, '更新日期：2026年5月5日'),
            const SizedBox(height: 8),
            _buildSubtitle(context, '生效日期：2026年5月5日'),
            const SizedBox(height: 20),
            _buildBodyText(
              '欢迎使用 光序（以下简称"本应用"）。本应用由 Lumaris Team（以下简称"我们"）开发和运营。'
              '我们深知个人信息对您的重要性，将严格遵守法律法规，遵循合法、正当、必要和诚信原则，'
              '保护您的个人信息安全。本隐私协议旨在向您说明我们如何收集、使用、存储和保护您的个人信息，'
              '以及您享有的相关权利。请您在使用本应用前仔细阅读本隐私协议。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 一、信息收集
            _buildSectionTitle('一、我们收集的信息', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '1.1 账号信息：当您使用教务系统登录功能时，我们需要收集您的学号和密码，'
              '用于验证您的身份并获取教务系统数据。这些信息仅存储在您的设备本地，'
              '我们不会上传至任何服务器。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '1.2 课程与成绩信息：在您授权登录后，本应用会从学校教务系统获取您的课程表、'
              '考试成绩、培养方案等教育相关数据，并在您的设备本地进行存储和展示。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '1.3 校园生活信息：在您使用相关功能时，本应用会从学校相关系统获取您的'
              '电费余额、饭卡消费记录等信息，并在您的设备本地进行存储和展示。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '1.4 设备信息：为提供更好的服务体验，本应用可能收集您的设备型号、操作系统版本、'
              '设备标识符等信息，用于统计分析和问题排查。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '1.5 缓存数据：为提高应用响应速度，本应用会在您的设备上缓存部分数据，'
              '包括课程信息、成绩数据、网络请求响应等。您可以在设置中随时清除这些缓存。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 二、信息使用
            _buildSectionTitle('二、我们如何使用信息', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '2.1 为您提供核心服务：我们使用您的学号和密码向学校教务系统进行身份认证，'
              '以获取并展示您的课程、成绩等信息。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '2.2 改善服务质量：我们可能使用设备信息和应用使用统计数据来分析和优化应用性能，'
              '提升用户体验。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '2.3 桌面小组件：如果您使用桌面小组件功能，本应用会在设备本地存储必要的课程数据'
              '以支持小组件的正常显示。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '2.4 通知提醒：如果您开启了课程提醒功能，本应用会在您的设备上设置本地通知，'
              '以在上课前提醒您。此功能完全在设备本地完成，不涉及数据传输。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 三、信息存储
            _buildSectionTitle('三、信息的存储与安全', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '3.1 本地存储：您的个人信息（包括学号、密码、课程数据、成绩等）均存储在您的设备本地，'
              '我们不会将这些信息上传至我们的服务器。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '3.2 传输安全：本应用与学校服务器之间的数据传输采用加密通信，'
              '确保您的信息在传输过程中的安全性。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '3.3 数据清除：您可以随时在设置中清除缓存数据，或通过退出登录来清除账号相关数据。'
              '卸载应用将删除本应用存储在您设备上的所有数据。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 四、第三方服务
            _buildSectionTitle('四、第三方服务', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '4.1 学校教务系统：本应用需要与西安建筑科技大学教务系统进行数据交互，'
              '以获取课程、成绩等信息。您的登录凭据仅在您的设备与学校服务器之间传输。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '4.2 应用更新服务：本应用通过 Downloader 平台检查版本更新信息，'
              '此过程中不会传输您的个人信息。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '4.3 本应用不会将您的个人信息分享、出售或出租给任何第三方。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 五、用户权利
            _buildSectionTitle('五、您的权利', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '5.1 访问和更正：您可以在应用内直接查看和更正您的个人信息。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '5.2 删除数据：您可以通过退出登录、清除缓存或卸载应用来删除您的数据。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '5.3 撤回同意：您可以通过退出登录或卸载应用来撤回对本隐私协议的同意。'
              '但撤回同意不影响撤回前基于您同意已进行的个人信息处理活动的效力。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 六、未成年人保护
            _buildSectionTitle('六、未成年人保护', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '6.1 本应用主要面向高等院校在校学生。如果您是未满18周岁的未成年人，'
              '请在监护人指导下使用本应用。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '6.2 我们不会主动收集未成年人的个人信息。如您发现我们在未获监护人同意的情况下'
              '收集了未成年人的个人信息，请联系我们进行删除。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 七、协议更新
            _buildSectionTitle('七、隐私协议的更新', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '7.1 我们可能会适时更新本隐私协议。更新后的协议将在应用内发布，'
              '并在重大变更时通过应用内通知提醒您。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '7.2 请您定期查看本隐私协议，以了解我们如何保护您的信息。'
              '如您在协议更新后继续使用本应用，即视为您同意更新后的隐私协议。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 八、联系我们
            _buildSectionTitle('八、联系我们', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '如果您对本隐私协议或个人信息保护有任何疑问、意见或建议，请通过以下方式联系我们：',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '开发团队：Lumaris Team\n'
              '代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile',
              textColor,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, String text) {
    final colors = context.clubColors;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: colors.secondaryLabel,
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildBodyText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: color,
        height: 1.8,
      ),
    );
  }
}
