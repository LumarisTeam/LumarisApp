import 'package:url_launcher/url_launcher.dart';

import '../models/electric_data.dart';
import '../models/edu_api_models.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../state/prefs_keys.dart';
import '../apis/electricity_api.dart';

typedef ElectricityBalanceReader = Future<double?> Function({String? url});
typedef ElectricityWeeklyDataReader = Future<List<ElectricData>> Function(
    {String? url});
typedef ElectricityRechargeUrlReader = Future<String?> Function({String? url});
typedef ElectricitySubscriptionCreator = Future<ElectricitySubscriptionResponse>
    Function(
  CreateElectricitySubscriptionRequest request,
);
typedef ElectricitySubscriptionQueryReader
    = Future<ElectricitySubscriptionQueryResponse> Function(String email);
typedef ElectricitySubscriptionDeleter = Future<void> Function(String id);

/// 电费数据服务
///
/// 负责封装电费 API 调用，并统一处理本地 URL 缓存与充值页跳转逻辑。
class ElectricityService {
  ElectricityService({
    ElectricityBalanceReader? balanceReader,
    ElectricityWeeklyDataReader? weeklyDataReader,
    ElectricityRechargeUrlReader? rechargeUrlReader,
    ElectricitySubscriptionCreator? subscriptionCreator,
    ElectricitySubscriptionQueryReader? subscriptionQueryReader,
    ElectricitySubscriptionDeleter? subscriptionDeleter,
  })  : _balanceReader = balanceReader ?? ElectricityApi.getCurrentBalance,
        _weeklyDataReader = weeklyDataReader ?? ElectricityApi.getWeeklyData,
        _rechargeUrlReader = rechargeUrlReader ?? ElectricityApi.getRechargeUrl,
        _subscriptionCreator =
            subscriptionCreator ?? ElectricityApi.createSubscription,
        _subscriptionQueryReader =
            subscriptionQueryReader ?? ElectricityApi.getSubscription,
        _subscriptionDeleter =
            subscriptionDeleter ?? ElectricityApi.deleteSubscription;

  final ElectricityBalanceReader _balanceReader;
  final ElectricityWeeklyDataReader _weeklyDataReader;
  final ElectricityRechargeUrlReader _rechargeUrlReader;
  final ElectricitySubscriptionCreator _subscriptionCreator;
  final ElectricitySubscriptionQueryReader _subscriptionQueryReader;
  final ElectricitySubscriptionDeleter _subscriptionDeleter;

  Future<double?> fetchCurrentBalance({String? url}) async {
    try {
      if (url != null) {
        await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_URL,
          url,
        );
      }
      final resolvedUrl = await _resolveSourceUrl();
      if (resolvedUrl.isEmpty) {
        return null;
      }

      return await _balanceReader(url: resolvedUrl);
    } catch (e) {
      AppLogger.error('获取电费余额失败: $e');
      return null;
    }
  }

  Future<bool> hasConfiguredSource() async {
    final resolvedUrl = await _resolveSourceUrl();
    return resolvedUrl.trim().isNotEmpty;
  }

  Future<List<ElectricData>> fetchWeeklyData() async {
    final resolvedUrl = await _resolveSourceUrl();
    return await _weeklyDataReader(
      url: resolvedUrl.isEmpty ? null : resolvedUrl,
    );
  }

  Future<String?> getRechargeUrl() async {
    final resolvedUrl = await _resolveSourceUrl();
    return await _rechargeUrlReader(
      url: resolvedUrl.isEmpty ? null : resolvedUrl,
    );
  }

  Future<void> openRechargePage() async {
    final rechargeUrl = await getRechargeUrl();
    if (rechargeUrl == null || rechargeUrl.isEmpty) {
      throw '无法打开 URL: $rechargeUrl';
    }

    final encodedUrl = Uri.encodeComponent(rechargeUrl);
    final wechatUrl = 'weixin://dl/business/?url=$encodedUrl';
    if (await canLaunchUrl(Uri.parse(wechatUrl))) {
      await launchUrl(
        Uri.parse(wechatUrl),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    if (await canLaunchUrl(Uri.parse(rechargeUrl))) {
      await launchUrl(
        Uri.parse(rechargeUrl),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    throw '无法打开 URL: $rechargeUrl';
  }

  Future<String> getSavedSubscriptionEmail() async {
    return PrefsService.instance
            .getString(PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL) ??
        '';
  }

  Future<void> saveSubscriptionEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      await PrefsService.instance
          .remove(PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL);
      return;
    }

    await PrefsService.instance.setString(
      PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
      trimmedEmail,
    );
  }

  Future<ElectricitySubscriptionResponse> createSubscription({
    required String email,
    required double threshold,
  }) async {
    final resolvedUrl = await _resolveSourceUrl();
    if (resolvedUrl.isEmpty) {
      throw StateError('请先添加电费页面链接');
    }

    final trimmedEmail = email.trim();
    await saveSubscriptionEmail(trimmedEmail);

    return _subscriptionCreator(
      CreateElectricitySubscriptionRequest(
        url: resolvedUrl,
        email: trimmedEmail,
        threshold: threshold,
      ),
    );
  }

  Future<ElectricitySubscriptionQueryResponse> getSubscription({
    String? email,
  }) async {
    final trimmedEmail = email?.trim() ?? '';
    final resolvedEmail = trimmedEmail.isNotEmpty
        ? trimmedEmail
        : await getSavedSubscriptionEmail();
    if (resolvedEmail.isEmpty) {
      throw StateError('请先输入订阅邮箱');
    }

    return _subscriptionQueryReader(resolvedEmail);
  }

  Future<void> deleteSubscription(String id) async {
    await _subscriptionDeleter(id);
  }

  Future<String> _resolveSourceUrl({String? url}) async {
    if (url != null) {
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        url,
      );

      return url;
    }
    return PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL) ?? '';
  }
}
