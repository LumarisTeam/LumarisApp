import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final textColor = colors.label;
    final titleColor = colors.label;

    return Scaffold(
      appBar: ClubAppBar(title: l10n.userAgreement),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('光序 用户协议', titleColor),
            const SizedBox(height: 8),
            _buildSubtitle(context, '更新日期：2026年5月5日'),
            const SizedBox(height: 8),
            _buildSubtitle(context, '生效日期：2026年5月5日'),
            const SizedBox(height: 20),
            _buildBodyText(
              '欢迎使用 光序（以下简称"本应用"）。本应用由 Lumaris Team'
              '（以下简称"我们"）开发和运营。请您在使用本应用前仔细阅读本用户协议'
              '（以下简称"本协议"）。您使用本应用即表示您已阅读、理解并同意接受本协议的全部内容。'
              '如果您不同意本协议的任何条款，请停止使用本应用。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 一、服务说明
            _buildSectionTitle('一、服务说明', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '1.1 本应用是 Lumaris Team 开发的校园助手应用，旨在为在校学生提供'
              '便捷的校园信息服务，包括但不限于课程管理、成绩查询、校车时刻、电费查询、'
              '饭卡消费记录、培养方案查看等功能。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '1.2 本应用的部分功能需要连接学校内部网络才能正常使用。我们不对因网络环境限制'
              '导致的功能不可用承担责任。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '1.3 本应用显示的课程、成绩等信息来源于学校教务系统，仅供参考。'
              '如有差异，以学校官方系统数据为准。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 二、用户账号
            _buildSectionTitle('二、用户账号与安全', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '2.1 您需要使用学校教务系统账号（学号和密码）登录本应用的教务相关功能。'
              '您应对自己的账号和密码的安全性负责，妥善保管账号信息。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '2.2 您的登录凭据仅存储在您的设备本地，用于与学校服务器进行身份认证。'
              '我们不会收集或上传您的密码至任何第三方服务器。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '2.3 如您发现账号存在安全风险或未经授权的使用，应及时修改密码并通知我们。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 三、使用规则
            _buildSectionTitle('三、用户行为规范', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '3.1 您在使用本应用时应遵守中华人民共和国相关法律法规，'
              '不得利用本应用从事违法违规活动。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '3.2 您不得对本应用进行反向工程、反向编译、反汇编或以其他方式试图获取本应用的源代码。'
              '但本应用作为 MIT 许可证下的开源项目，您可以通过官方代码仓库合法获取源代码。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '3.3 您不得利用任何技术手段干扰本应用的正常运行，'
              '包括但不限于网络攻击、数据抓取、恶意注入等行为。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '3.4 您不得利用本应用的功能漏洞获取未经授权的信息或进行非法操作。'
              '如发现漏洞，请及时联系我们。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 四、知识产权
            _buildSectionTitle('四、知识产权', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '4.1 本应用的源代码基于 MIT 许可证开源发布，您可以在遵守 MIT 许可证的前提下'
              '自由使用、修改和分发本应用的源代码。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '4.2 本应用的名称、图标、UI 设计等归 Lumaris Team 所有，'
              '未经授权不得用于商业目的。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '4.3 本应用中涉及的学校名称、标识等归西安建筑科技大学所有。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 五、免责声明
            _buildSectionTitle('五、免责声明', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '5.1 本应用按"现状"提供，我们不对本应用的准确性、可靠性、完整性、'
              '及时性做任何明示或暗示的保证。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '5.2 由于网络故障、系统维护、学校服务器问题或其他不可抗力因素导致的服务中断'
              '或数据不准确，我们不承担相关责任。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '5.3 本应用中的课程、成绩等信息仅供参考，最终以获得学校官方系统数据为准。'
              '因依赖本应用数据而产生的任何直接或间接损失，我们不承担责任。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '5.4 我们不对因您使用本应用而导致的设备损坏、数据丢失或其他损害承担责任，'
              '除非该等损害是由我们的故意或重大过失造成的。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 六、协议修改
            _buildSectionTitle('六、协议的修改与终止', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '6.1 我们保留随时修改本协议的权利。修改后的协议将在应用内发布，'
              '重大变更将通过应用内通知告知。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '6.2 如您在协议修改后继续使用本应用，即视为您同意修改后的协议。'
              '如您不同意修改后的协议，应停止使用本应用。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '6.3 我们有权在以下情况下终止向您提供服务：'
              '（1）您违反本协议的相关约定；'
              '（2）因法律法规或政策要求的变更；'
              '（3）因学校相关系统政策变更导致无法继续提供服务。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 七、其他
            _buildSectionTitle('七、其他条款', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '7.1 本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，'
              '其余条款仍应有效并具有约束力。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '7.2 本协议的订立、执行和解释及争议的解决均适用中华人民共和国法律。',
              textColor,
            ),
            const SizedBox(height: 8),
            _buildBodyText(
              '7.3 如您和我们就本协议内容或其执行发生任何争议，'
              '应通过友好协商解决；协商不成的，任何一方均可向有管辖权的人民法院提起诉讼。',
              textColor,
            ),
            const SizedBox(height: 24),

            // 八、联系我们
            _buildSectionTitle('八、联系我们', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
              '如果您对本协议有任何疑问、意见或建议，请通过以下方式联系我们：',
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
