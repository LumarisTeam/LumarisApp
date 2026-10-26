import 'package:flutter/services.dart';

enum WidgetSetupType { today, tomorrow }

enum WidgetSetupLaunchResult {
  widgetPickerOpened,
  appSettingsOpened,
  unavailable,
  failed,
}

class WidgetSettingsService {
  static const MethodChannel _channel = MethodChannel(
    'ios_club_app/widget_settings',
  );

  static Future<WidgetSetupLaunchResult> openWidgetSetup({
    WidgetSetupType type = WidgetSetupType.today,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('openWidgetSetup', {
        'type': type.name,
      });
      return switch (result) {
        'widgetPickerOpened' => WidgetSetupLaunchResult.widgetPickerOpened,
        'appSettingsOpened' => WidgetSetupLaunchResult.appSettingsOpened,
        'unavailable' => WidgetSetupLaunchResult.unavailable,
        _ => WidgetSetupLaunchResult.failed,
      };
    } catch (_) {
      return WidgetSetupLaunchResult.failed;
    }
  }
}
