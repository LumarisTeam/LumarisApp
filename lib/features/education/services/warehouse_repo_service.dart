import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:curriculum/warehouse.dart';
import 'package:dio/dio.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';

/// 拾光适配仓库的下载、缓存与脚本读取。
///
/// 索引来自 `index-pb-release` 分支的 `school_index.pb`，脚本来自 `main`
/// 分支的源码压缩包。两份资源都先落到临时目录，校验通过后再替换正式缓存，
/// 避免半截下载把已可用的仓库弄坏。
///
/// 当前策略：
/// 1. 有缓存且未要求刷新时直接返回缓存；
/// 2. 否则依次尝试 GitHub / Gitee 下载索引；
/// 3. 索引版本变化或本地缺脚本时下载压缩包并解压；
/// 4. 压缩包失败但本地已有脚本时，降级为「新索引 + 旧脚本」并记录日志。
class WarehouseRepoService {
  WarehouseRepoService._();

  /// 全局单例。
  static final WarehouseRepoService instance = WarehouseRepoService._();

  static const List<String> _indexUrls = <String>[
    'https://raw.githubusercontent.com/XingHeYuZhuan/shiguang_warehouse/index-pb-release/school_index.pb',
    'https://gitee.com/XingHeYuZhuan-gh/shiguang_warehouse/raw/index-pb-release/school_index.pb',
  ];

  static const List<String> _archiveUrls = <String>[
    'https://github.com/XingHeYuZhuan/shiguang_warehouse/archive/refs/heads/main.zip',
    'https://gitee.com/XingHeYuZhuan-gh/shiguang_warehouse/repository/archive/main.zip',
  ];

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 2),
      followRedirects: true,
      headers: const <String, String>{'User-Agent': 'ios_club_app'},
    ),
  );

  WarehouseRegistry? _registry;
  Directory? _repoDir;
  Future<WarehouseRegistry>? _inFlight;

  /// 已加载的仓库索引；尚未加载时为 null。
  WarehouseRegistry? get registry => _registry;

  /// 加载仓库索引，必要时下载。
  ///
  /// [forceRefresh] 为 true 时忽略内存缓存并重新检查远端版本。
  Future<WarehouseRegistry> load({bool forceRefresh = false}) async {
    final cached = _registry;
    if (!forceRefresh && cached != null) return cached;

    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _load(forceRefresh: forceRefresh);
    _inFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight, future)) _inFlight = null;
    }
  }

  /// 强制重新拉取索引和脚本。
  Future<WarehouseRegistry> refresh() => load(forceRefresh: true);

  /// 读取某个适配器的 JS 源码。
  ///
  /// 路径是 `resources/<resource_folder>/<asset_js_path>`；`resource_folder`
  /// 可能和学校 id 不同，所以优先从索引里的学校条目取。
  Future<String> loadScript(WarehouseAdapter adapter) async {
    if (_registry == null || _repoDir == null) {
      await load();
    }

    final repo = _repoDir;
    final registry = _registry;
    if (repo == null || registry == null) {
      throw StateError('适配仓库尚未加载。');
    }

    final school = registry.schoolById(adapter.schoolId);
    final folder = school?.resourceFolder ?? adapter.schoolId;
    final file = File('${repo.path}/resources/$folder/${adapter.assetJsPath}');
    if (!await file.exists()) {
      throw StateError('适配器脚本不存在：${file.path}');
    }

    final source = await file.readAsString();
    if (source.trim().isEmpty) {
      throw StateError('适配器脚本为空：${adapter.adapterId}');
    }
    return source;
  }

  Future<WarehouseRegistry> _load({required bool forceRefresh}) async {
    final support = await getApplicationSupportDirectory();
    final root = Directory('${support.path}/warehouse');
    await root.create(recursive: true);

    final indexFile = File('${root.path}/index/school_index.pb');
    final repoDir = Directory('${root.path}/repo');

    final cachedCatalog = await _readCachedIndex(indexFile);
    if (!forceRefresh &&
        cachedCatalog != null &&
        await _hasScripts(repoDir)) {
      return _install(cachedCatalog, repoDir);
    }

    final downloaded = await _downloadIndex();
    if (downloaded == null) {
      if (cachedCatalog != null && await _hasScripts(repoDir)) {
        AppLogger.warning('[Warehouse] 索引下载失败，使用本地缓存。');
        return _install(cachedCatalog, repoDir);
      }
      throw StateError('适配仓库暂不可用，请检查网络后重试。');
    }

    final (remoteCatalog, indexBytes) = downloaded;
    final versionChanged =
        cachedCatalog == null || cachedCatalog.versionId != remoteCatalog.versionId;

    if (!forceRefresh && !versionChanged && await _hasScripts(repoDir)) {
      await _writeIndex(indexFile, indexBytes);
      return _install(remoteCatalog, repoDir);
    }

    final archiveBytes = await _downloadArchive();
    if (archiveBytes != null) {
      try {
        final tempDir = Directory('${root.path}/repo.tmp');
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
        await tempDir.create(recursive: true);
        await _extractResources(archiveBytes, tempDir);

        if (await repoDir.exists()) {
          await repoDir.delete(recursive: true);
        }
        await tempDir.rename(repoDir.path);
        await _writeIndex(indexFile, indexBytes);
        AppLogger.info(
          '[Warehouse] 已更新到 ${remoteCatalog.versionId}，'
          '${remoteCatalog.schools.length} 所学校。',
        );
        return _install(remoteCatalog, repoDir);
      } catch (error, stackTrace) {
        AppLogger.error(
          '[Warehouse] 解压适配仓库失败',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedCatalog != null && await _hasScripts(repoDir)) {
      AppLogger.warning('[Warehouse] 脚本下载失败，使用本地缓存脚本。');
      await _writeIndex(indexFile, indexBytes);
      return _install(remoteCatalog, repoDir);
    }

    throw StateError('适配仓库脚本下载失败，请检查网络后重试。');
  }

  WarehouseRegistry _install(WarehouseCatalog catalog, Directory repoDir) {
    _repoDir = repoDir;
    final registry = WarehouseRegistry(catalog);
    _registry = registry;
    return registry;
  }

  Future<WarehouseCatalog?> _readCachedIndex(File indexFile) async {
    if (!await indexFile.exists()) return null;
    try {
      return WarehouseCatalog.fromPbBytes(await indexFile.readAsBytes());
    } catch (error, stackTrace) {
      AppLogger.warning(
        '[Warehouse] 本地索引损坏，将重新下载',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<(WarehouseCatalog, Uint8List)?> _downloadIndex() async {
    for (final url in _indexUrls) {
      try {
        final bytes = await _downloadBytes(url);
        final catalog = WarehouseCatalog.fromPbBytes(bytes);
        if (catalog.isEmpty) continue;
        return (catalog, bytes);
      } catch (error, stackTrace) {
        AppLogger.warning(
          '[Warehouse] 下载索引失败：$url',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return null;
  }

  Future<Uint8List?> _downloadArchive() async {
    for (final url in _archiveUrls) {
      try {
        return await _downloadBytes(url);
      } catch (error, stackTrace) {
        AppLogger.warning(
          '[Warehouse] 下载脚本包失败：$url',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return null;
  }

  Future<Uint8List> _downloadBytes(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('空响应：$url');
    }
    return Uint8List.fromList(data);
  }

  Future<void> _writeIndex(File indexFile, Uint8List bytes) async {
    await indexFile.parent.create(recursive: true);
    final temp = File('${indexFile.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    if (await indexFile.exists()) {
      await indexFile.delete();
    }
    await temp.rename(indexFile.path);
  }

  Future<bool> _hasScripts(Directory repoDir) async {
    final resources = Directory('${repoDir.path}/resources');
    if (!await resources.exists()) return false;

    var count = 0;
    await for (final folder in resources.list(followLinks: false)) {
      if (folder is! Directory) continue;
      await for (final entity in folder.list(followLinks: false)) {
        if (entity is File && entity.path.endsWith('.js')) {
          count++;
          if (count >= 10) return true;
        }
      }
    }
    return false;
  }

  Future<void> _extractResources(Uint8List zipBytes, Directory targetDir) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    var extracted = 0;

    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name.replaceAll('\\', '/');
      final relative = _resourceRelativePath(name);
      if (relative == null || relative.isEmpty) continue;
      if (relative.split('/').any((segment) => segment == '..')) continue;

      final data = file.readBytes();
      if (data == null) continue;

      final target = File('${targetDir.path}/resources/$relative');
      await target.parent.create(recursive: true);
      await target.writeAsBytes(data, flush: false);
      extracted++;
    }

    if (extracted == 0) {
      throw StateError('压缩包里没有 resources/ 文件。');
    }
  }

  String? _resourceRelativePath(String name) {
    const marker = '/resources/';
    if (name.startsWith('resources/')) {
      return name.substring('resources/'.length);
    }
    final index = name.indexOf(marker);
    if (index < 0) return null;
    return name.substring(index + marker.length);
  }
}
