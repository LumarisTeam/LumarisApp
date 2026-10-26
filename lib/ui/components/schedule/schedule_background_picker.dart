import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/image_brightness.dart';
import 'package:ios_club_app/state/settings_store.dart';

/// 选择课表背景图并写入 SettingsStore。
///
/// 课表设置页和个性化页共用，避免两处重复处理 FilePicker 与亮暗计算。
Future<bool> pickScheduleBackgroundImage(
  BuildContext context,
  WidgetRef ref, {
  required bool isDark,
}) async {
  final l10n = context.l10n;

  try {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (result == null) return false;

    final filePath = result.files.single.path ?? result.files.single.name;
    final store = ref.read(settingsStoreProvider.notifier);
    await store.setBackgroundImageFor(isDark: isDark, path: filePath);

    // 异步计算图片亮暗，完成后写入对应模式。
    unawaited(
      computeImageIsDark(filePath).then(
        (value) => store.setBackgroundIsDarkFor(isDark: isDark, value: value),
      ),
    );

    if (context.mounted) {
      McFeedback.showMessage(context, message: l10n.bgImageSetSuccess);
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      McFeedback.showMessage(context, message: l10n.selectImageFailed);
    }
    AppLogger.debug('选择背景图片失败: $e');
    return false;
  }
}

/// 清除指定模式的课表背景图，不影响另一模式。
Future<void> clearScheduleBackgroundImage(
  WidgetRef ref, {
  required bool isDark,
}) async {
  await ref
      .read(settingsStoreProvider.notifier)
      .clearBackgroundFor(isDark: isDark);
}
