import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/basic/services/app_api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class AppService {
  static Future<ReleaseModel> getReleases() async {
    final prefs = PrefsService.instance;

    try {
      final releases = await AppApi.getAppInfo();

      if (releases.isNotEmpty) {
        final reInfo = releases.first;
        final re = ReleaseModel.fromReleaseInfo(reInfo);

        if (re.body.contains('[强制更新]')) {
          return re;
        }

        final bool? updateIgnored = prefs.getBool(PrefsKeys.UPDATE_IGNORED);

        if (updateIgnored != null && updateIgnored == true) {
          return const ReleaseModel(name: '0.0.0', body: '0.0.0');
        }

        return re;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching releases: $e');
      }
    }

    return const ReleaseModel(name: '0.0.0', body: '0.0.0');
  }

  static Future<(bool, ReleaseModel)> isNeedUpdate() async {
    final result = await getReleases();
    final packageInfo = await PackageInfo.fromPlatform();
    if (result.name == '0.0.0') {
      return (false, result);
    }

    final resultList = result.name.split('.').map((e) => int.parse(e)).toList();
    final currentList =
        packageInfo.version.split('.').map((e) => int.parse(e)).toList();

    final len = resultList.length > currentList.length
        ? currentList.length
        : resultList.length;

    for (int i = 0; i < len; i++) {
      if (resultList[i] > currentList[i]) {
        return (true, result);
      } else if (resultList[i] < currentList[i]) {
        return (false, result);
      }
    }

    return (resultList.length > currentList.length, result);
  }

  static String getReleaseDownloadUrl(ReleaseModel release) {
    final assetUrl = release.downloadUrl?.trim();
    if (assetUrl != null && assetUrl.isNotEmpty) {
      return assetUrl;
    }

    return 'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/'
        'releases/download/${release.name}/app-release.apk';
  }

  static Future<void> updateApp(ReleaseModel release) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (release.name != packageInfo.version) {
      final url = getReleaseDownloadUrl(release);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw '无法在浏览器中打开更新链接';
        }

        if (kDebugMode) {
          AppLogger.debug('已在浏览器中打开更新链接: $url');
        }
      } else {
        throw '无法打开更新链接';
      }
    }
  }
}

class ReleaseModel {
  final String name;
  final String body;
  final String? downloadUrl;

  const ReleaseModel({
    required this.name,
    required this.body,
    this.downloadUrl,
  });

  factory ReleaseModel.fromReleaseInfo(ReleaseInfo releaseInfo) {
    return ReleaseModel(
      name: releaseInfo.name ?? '0.0.0',
      body: releaseInfo.body ?? '',
      downloadUrl: releaseInfo.assets
          ?.map((asset) => asset.browserDownloadUrl?.trim())
          .whereType<String>()
          .firstWhere(
            (url) => url.isNotEmpty && url.toLowerCase().contains('apk'),
            orElse: () => '',
          ),
    );
  }

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      name: json['name'],
      body: json['body'],
      downloadUrl: json['downloadUrl'],
    );
  }
}
