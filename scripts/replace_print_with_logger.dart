import 'dart:io';

import 'package:flutter/foundation.dart';

/// 批量替换 print/debugPrint 为 AppLogger 的脚本
void main() async {
  final libDir = Directory('lib');

  if (!await libDir.exists()) {
    if (kDebugMode) {
      print('错误: lib 目录不存在');
    }
    exit(1);
  }

  int totalFiles = 0;
  int totalReplacements = 0;

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final result = await processFile(entity);
      if (result > 0) {
        totalFiles++;
        totalReplacements += result;
        if (kDebugMode) {
          print('✓ ${entity.path}: $result 处替换');
        }
      }
    }
  }

  if (kDebugMode) {
    print('\n完成！');
    print('处理文件数: $totalFiles');
    print('总替换数: $totalReplacements');
  }
}

Future<int> processFile(File file) async {
  String content = await file.readAsString();
  final originalContent = content;
  int replacements = 0;

  // 检查是否已经导入 AppLogger
  final hasAppLoggerImport =
      content.contains(
        "import 'package:ios_club_app/core/utils/app_logger.dart'",
      ) ||
      content.contains(
        'import "package:ios_club_app/core/utils/app_logger.dart"',
      );

  // 跳过 app_logger.dart 本身
  if (file.path.contains('app_logger.dart')) {
    return 0;
  }

  // 跳过 Markdown 文件
  if (file.path.endsWith('.md')) {
    return 0;
  }

  // 替换 debugPrint 为 AppLogger.debug
  final debugPrintPattern = RegExp(
    r'debugPrint\((.*?)\);',
    multiLine: true,
    dotAll: true,
  );
  content = content.replaceAllMapped(debugPrintPattern, (match) {
    replacements++;
    return 'AppLogger.debug(${match.group(1)});';
  });

  // 替换 print 为 AppLogger（根据内容判断级别）
  final printPattern = RegExp(
    r'\bprint\((.*?)\);',
    multiLine: true,
    dotAll: true,
  );
  content = content.replaceAllMapped(printPattern, (match) {
    final arg = match.group(1)!;
    // 判断是否是错误信息
    if (arg.contains('错误') ||
        arg.contains('Error') ||
        arg.contains('error') ||
        arg.contains('失败') ||
        arg.contains('Failed') ||
        arg.contains('failed')) {
      replacements++;
      return 'AppLogger.error($arg);';
    } else if (arg.contains('警告') ||
        arg.contains('Warning') ||
        arg.contains('warning')) {
      replacements++;
      return 'AppLogger.warning($arg);';
    } else {
      replacements++;
      return 'AppLogger.debug($arg);';
    }
  });

  // 如果有替换且没有导入 AppLogger，则添加导入
  if (replacements > 0 && !hasAppLoggerImport) {
    // 使用简单的字符串匹配找到最后一个 import
    final lines = content.split('\n');
    int lastImportIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('import ')) {
        lastImportIndex = i;
      }
    }

    if (lastImportIndex >= 0) {
      // 在最后一个 import 后面插入
      lines.insert(
        lastImportIndex + 1,
        "import 'package:ios_club_app/core/utils/app_logger.dart';",
      );
      content = lines.join('\n');
    } else {
      // 如果没有找到 import，在文件开头添加
      content =
          "import 'package:ios_club_app/core/utils/app_logger.dart';\n\n$content";
    }
  }

  // 只有在内容发生变化时才写入文件
  if (content != originalContent) {
    await file.writeAsString(content);
    return replacements;
  }

  return 0;
}
