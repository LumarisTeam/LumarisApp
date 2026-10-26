import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/basic/services/app_api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/target_abi.dart';

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

    return (
      isVersionNewer(
        releaseName: result.name,
        currentVersion: packageInfo.version,
        currentBuildNumber: packageInfo.buildNumber,
      ),
      result,
    );
  }

  /// Compares an API version (`major.minor.patch.build`) with the installed
  /// package version and build number.
  ///
  /// The build number is only considered after the semantic version parts
  /// match. Invalid version strings are treated as not newer.
  static bool isVersionNewer({
    required String releaseName,
    required String currentVersion,
    required String currentBuildNumber,
  }) {
    final releaseParts = _parseVersion(releaseName);
    final currentParts = _parseVersion(currentVersion);
    final currentBuild = int.tryParse(currentBuildNumber.trim());

    if (releaseParts == null || currentParts == null || currentBuild == null) {
      return false;
    }

    final releaseVersion = releaseParts.length > 3
        ? releaseParts.sublist(0, 3)
        : releaseParts;
    final releaseBuild = releaseParts.length > 3 ? releaseParts[3] : 0;
    final versionLength = releaseVersion.length > currentParts.length
        ? releaseVersion.length
        : currentParts.length;

    for (var i = 0; i < versionLength; i++) {
      final releasePart = i < releaseVersion.length ? releaseVersion[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (releasePart != currentPart) {
        return releasePart > currentPart;
      }
    }

    return releaseBuild > currentBuild;
  }

  static List<int>? _parseVersion(String value) {
    final normalized = value.trim().replaceFirst(
      RegExp(r'^v', caseSensitive: false),
      '',
    );
    if (normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split('.');
    final parsed = parts.map((part) => int.tryParse(part)).toList();
    return parsed.every((part) => part != null) ? parsed.cast<int>() : null;
  }

  static String getReleaseDownloadUrl(ReleaseModel release) {
    final assetUrl = release.downloadUrl?.trim();
    if (assetUrl != null && assetUrl.isNotEmpty) {
      return assetUrl;
    }

    return 'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/'
        '${release.name}/app-release.apk';
  }

  static Future<void> updateApp(ReleaseModel release) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (isVersionNewer(
      releaseName: release.name,
      currentVersion: packageInfo.version,
      currentBuildNumber: packageInfo.buildNumber,
    )) {
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
      downloadUrl: _selectDownloadUrl(releaseInfo.assets),
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

/// 服务端没有指定 ABI 时的兜底顺序；arm64 覆盖绝大多数真机。
const _abiFallback = ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86'];

/// 从平台返回的 assets 里挑出适合当前设备的 APK。
///
/// 服务端已经把 arm64 排在前面（老版本只会取第一条），这里再按设备 ABI
/// 精确匹配一次，避免 armeabi-v7a 或 x86 设备拿到装不上的包。
String? _selectDownloadUrl(List<AssetInfo>? assets) {
  final candidates = <_ApkAsset>[];
  for (final asset in assets ?? const <AssetInfo>[]) {
    final url = asset.browserDownloadUrl?.trim() ?? '';
    if (url.isEmpty || !url.toLowerCase().contains('apk')) {
      continue;
    }
    candidates.add(_ApkAsset(name: asset.name ?? '', url: url));
  }
  if (candidates.isEmpty) {
    return null;
  }

  final deviceAbi = currentTargetAbi();
  if (deviceAbi != null) {
    for (final candidate in candidates) {
      if (_matchesAbi(candidate.haystack, deviceAbi)) {
        return candidate.url;
      }
    }
  }
  for (final abi in _abiFallback) {
    for (final candidate in candidates) {
      if (_matchesAbi(candidate.haystack, abi)) {
        return candidate.url;
      }
    }
  }
  return candidates.first.url;
}

bool _matchesAbi(String haystack, String abi) {
  if (abi == 'x86') {
    // x86_64 也包含 "x86"，必须先排除掉 64 位包。
    return haystack.contains('x86') &&
        !haystack.contains('x86_64') &&
        !haystack.contains('x86-64');
  }
  return haystack.contains(abi);
}

class _ApkAsset {
  _ApkAsset({required String name, required this.url})
    : haystack = '$name $url'.toLowerCase();

  final String url;
  final String haystack;
}
