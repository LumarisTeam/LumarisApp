import 'dart:io';

import 'package:flutter/foundation.dart';

/// 清理未使用的导入脚本
void main() async {
  // 需要清理的文件列表
  final filesToClean = [
    'lib/core/services/data_service.dart',
    'lib/core/services/exam_service.dart',
    'lib/core/services/xauat_login.dart',
    'lib/core/utils/animations/animated_button.dart',
    'lib/core/utils/animations/animated_card.dart',
    'lib/core/utils/request_cache.dart',
    'lib/features/education/services/edu_http_client.dart',
    'lib/features/system/notifications/task_executor.dart',
    'lib/features/system/update/check_update_manager.dart',
    'lib/features/system/widget_service.dart',
    'lib/state/schedule_store.dart',
    'lib/ui/components/modal_components.dart',
  ];

  // 需要移除的导入映射
  final importsToRemove = {
    'lib/core/services/data_service.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/core/services/exam_service.dart': [
      "import 'package:flutter/material.dart';",
    ],
    'lib/core/services/xauat_login.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/core/utils/animations/animated_button.dart': [
      "import 'package:ios_club_app/core/utils/app_logger.dart';",
    ],
    'lib/core/utils/animations/animated_card.dart': [
      "import 'package:ios_club_app/core/utils/app_logger.dart';",
    ],
    'lib/core/utils/request_cache.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/features/education/services/edu_http_client.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/features/system/notifications/task_executor.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/features/system/update/check_update_manager.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/features/system/widget_service.dart': [
      "import 'package:flutter/cupertino.dart';",
      "import 'package:flutter/material.dart';",
    ],
    'lib/state/schedule_store.dart': [
      "import 'package:flutter/foundation.dart';",
    ],
    'lib/ui/components/modal_components.dart': [
      "import 'package:ios_club_app/core/utils/app_logger.dart';",
    ],
  };

  int totalCleaned = 0;

  for (final filePath in filesToClean) {
    final file = File(filePath);
    if (!await file.exists()) {
      if (kDebugMode) {
        print('⚠ 文件不存在: $filePath');
      }
      continue;
    }

    String content = await file.readAsString();
    final originalContent = content;
    final imports = importsToRemove[filePath] ?? [];

    for (final import in imports) {
      content = content.replaceAll('$import\n', '');
      content = content.replaceAll(import, '');
    }

    if (content != originalContent) {
      await file.writeAsString(content);
      totalCleaned++;
      if (kDebugMode) {
        print('✓ $filePath: 已清理 ${imports.length} 个导入');
      }
    }
  }

  if (kDebugMode) {
    print('\n完成！清理了 $totalCleaned 个文件');
  }
}
