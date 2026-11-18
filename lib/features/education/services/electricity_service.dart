import 'package:url_launcher/url_launcher.dart';

import '../models/electric_data.dart';
import '../models/edu_api_models.dart';
import '../../../core/services/network_exception.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../state/prefs_keys.dart';
import '../apis/electricity_api.dart';

typedef ElectricityBalanceReader = Future<double?> Function({String? url});
typedef ElectricityWeeklyDataReader =
    Future<List<ElectricData>> Function({String? url});
typedef ElectricityRechargeUrlReader = Future<String?> Function({String? url});
typedef ElectricitySubscriptionCreator =
    Future<ElectricitySubscriptionResponse> Function(
      CreateElectricitySubscriptionRequest request,
    );
typedef ElectricitySubscriptionQueryReader =
    Future<ElectricitySubscriptionQueryResponse> Function(String email);
typedef ElectricitySubscriptionDeleter = Future<void> Function(String id);

enum ElectricitySourceError implements Exception { invalidUrl, expired }

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
  }) : _balanceReader = balanceReader ?? ElectricityApi.getCurrentBalance,
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
        return await bindSource(url);
      }
      final String savedUrl = _savedSourceUrl;
      return savedUrl.isEmpty
          ? null
          : await _readSource(
              () => _balanceReader(url: _validateSourceUrl(savedUrl)),
            );
    } on ElectricitySourceError {
      if (url == null) rethrow;
      return null;
    } catch (_) {
      AppLogger.error('获取电费余额失败');
      return null;
    }
  }

  Future<double?> bindSource(String url) async {
    final String source = _validateSourceUrl(url);
    final double? balance = await _readSource(
      () => _balanceReader(url: source),
    );
    if (balance != null) {
      _validateSourceUrl(source);
      final bool saved = await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        source,
      );
      if (!saved) throw StateError('无法保存电费链接');
    }
    return balance;
  }

  Future<T> _readSource<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on NetworkException catch (error) {
      if (error.apiCode == 30002 || error.statusCode == 410) {
        throw ElectricitySourceError.expired;
      }
      if (error.apiCode == 10001) throw ElectricitySourceError.invalidUrl;
      rethrow;
    }
  }

  Future<bool> hasConfiguredSource() async => _savedSourceUrl.isNotEmpty;

  Future<List<ElectricData>> fetchWeeklyData() async {
    final String? source = _validatedSavedSource;
    return await _readSource(() => _weeklyDataReader(url: source));
  }

  Future<String?> getRechargeUrl() async {
    final String? source = _validatedSavedSource;
    return await _readSource(() => _rechargeUrlReader(url: source));
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
    return PrefsService.instance.getString(
          PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
        ) ??
        '';
  }

  Future<void> saveSubscriptionEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      await PrefsService.instance.remove(
        PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
      );
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
    final String? resolvedUrl = _validatedSavedSource;
    if (resolvedUrl == null) {
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

  String get _savedSourceUrl =>
      PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL)?.trim() ?? '';

  String? get _validatedSavedSource {
    final String source = _savedSourceUrl;
    return source.isEmpty ? null : _validateSourceUrl(source);
  }

  static String _validateSourceUrl(String url) {
    final String source = url.trim();
    final Uri? uri = Uri.tryParse(source);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        RegExp(r'[\s\x00-\x1f\x7f]').hasMatch(source) ||
        source.contains(r'\')) {
      throw ElectricitySourceError.invalidUrl;
    }

    final List<String> values;
    try {
      values = uri.queryParametersAll.entries
          .where((entry) => entry.key.toLowerCase() == 'exp')
          .expand((entry) => entry.value)
          .toList();
    } on FormatException {
      throw ElectricitySourceError.invalidUrl;
    }
    if (values.isNotEmpty) {
      final int? expiration =
          values.length == 1 && RegExp(r'^[0-9]+$').hasMatch(values.single)
          ? int.tryParse(values.single)
          : null;
      if (expiration == null) throw ElectricitySourceError.invalidUrl;
      if (expiration <= DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        throw ElectricitySourceError.expired;
      }
    }
    return source;
  }
}
