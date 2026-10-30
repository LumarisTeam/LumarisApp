import 'dart:async';

import 'package:flutter/services.dart';

import 'package:ios_club_app/core/utils/app_logger.dart';

/// 桌面小组件类型，对应原生侧的 [WidgetSetupType.name]。
enum WidgetSetupType {
  /// 今日课表小组件。
  today,

  /// 近日（今日 + 明日）课表小组件。
  tomorrow;

  static WidgetSetupType fromName(Object? name) {
    return name == tomorrow.name ? tomorrow : today;
  }
}

/// 调起「添加小组件到桌面」的结果。
enum WidgetSetupLaunchResult {
  /// 请求已发给系统。
  ///
  /// **不代表添加成功**：`requestPinAppWidget` 的返回值只表示系统接受了请求，
  /// 小米 / 红米 / vivo 等机型既不弹确认框，也可能静默失败。真正的结果由
  /// [WidgetSettingsService.onPinOutcome] 上报。
  pickerShown,

  /// 当前系统 / 桌面不支持由 App 直接添加，只能手动添加。
  ///
  /// iOS 一直返回该值：系统不提供程序化添加小组件的接口。
  unsupported,

  /// 原生调用异常（通道未注册、参数错误等）。
  failed,
}

/// 一次「添加到桌面」尝试的最终结果。
///
/// 由原生侧在判定完成后发出：原生通过对比
/// `AppWidgetManager.getAppWidgetIds()` 的实例数量变化来判断是否真的加上了，
/// 而不是相信 `requestPinAppWidget` 的返回值。
class WidgetPinOutcome {
  const WidgetPinOutcome({
    required this.type,
    required this.installed,
    this.alreadyInstalled = false,
    this.reason = '',
    this.supported = false,
    this.brand = '',
    this.launcher = '',
  });

  /// 尝试添加的小组件类型。
  final WidgetSetupType type;

  /// 是否真的把小组件加到了桌面。
  final bool installed;

  /// 添加前桌面上是否已经有该小组件。
  final bool alreadyInstalled;

  /// 未添加成功的原因：`timeout`（系统没有响应）或 `rejected`（系统拒绝）。
  final String reason;

  /// 桌面启动器是否声明支持程序化固定，仅用于诊断。
  final bool supported;

  /// 设备品牌，形如 `Redmi/Xiaomi`，仅用于权限提示与诊断。
  final String brand;

  /// 默认桌面启动器的包名，仅用于诊断。
  final String launcher;

  /// 小米 / 红米 / POCO 的桌面在缺少「创建桌面快捷方式」权限时会静默失败，
  /// 需要给出针对性的授权提示。
  bool get needsShortcutPermissionHint {
    final value = brand.toLowerCase();

    return value.contains('xiaomi') ||
        value.contains('redmi') ||
        value.contains('poco');
  }

  static WidgetPinOutcome fromCall(MethodCall call) {
    final arguments = call.arguments;
    final map = arguments is Map ? arguments : const <Object?, Object>{};

    return WidgetPinOutcome(
      type: WidgetSetupType.fromName(map['type']),
      installed: call.method == WidgetSettingsService.eventWidgetPinned,
      alreadyInstalled: map['alreadyInstalled'] == true,
      reason: map['reason']?.toString() ?? '',
      supported: map['supported'] == true,
      brand: map['brand']?.toString() ?? '',
      launcher: map['launcher']?.toString() ?? '',
    );
  }
}

/// 桌面小组件设置入口。
///
/// 与原生侧的约定：
/// - 通道 `ios_club_app/widget_settings`
/// - 方法 [methodOpenWidgetSetup]，参数 `{'type': 'today' | 'tomorrow'}`，
///   返回 `'pickerShown'` / `'unsupported'` / 其它（视为失败）
/// - 原生 -> Dart 事件：
///   - [eventWidgetPinned] `{type, alreadyInstalled}`：真的加到了桌面
///   - [eventWidgetPinUnavailable] `{type, reason, supported, brand, launcher}`：
///     没有加上，需要引导用户手动添加
class WidgetSettingsService {
  WidgetSettingsService._();

  static const String channelName = 'ios_club_app/widget_settings';

  /// 请求系统把小组件固定到桌面。
  static const String methodOpenWidgetSetup = 'openWidgetSetup';

  /// 小组件已经真正添加到桌面。
  static const String eventWidgetPinned = 'onWidgetPinned';

  /// 尝试结束但没有添加到桌面，需要回退到手动引导。
  static const String eventWidgetPinUnavailable = 'onWidgetPinUnavailable';

  /// 打开系统桌面，供「去桌面手动添加」使用（部分桌面会吞掉固定请求）。
  static const String methodOpenHomeScreen = 'openHomeScreen';

  static const MethodChannel _channel = MethodChannel(channelName);

  static final StreamController<WidgetPinOutcome> _outcomeController =
      StreamController<WidgetPinOutcome>.broadcast();

  static bool _handlerAttached = false;

  /// 「添加到桌面」的最终结果（成功 / 失败都会上报一次）。
  static Stream<WidgetPinOutcome> get onPinOutcome => _outcomeController.stream;

  /// 调起「添加小组件到桌面」。
  static Future<WidgetSetupLaunchResult> openWidgetSetup({
    WidgetSetupType type = WidgetSetupType.today,
  }) async {
    _attachHandler();

    try {
      final result = await _channel.invokeMethod<String>(
        methodOpenWidgetSetup,
        <String, String>{'type': type.name},
      );

      return switch (result) {
        'pickerShown' => WidgetSetupLaunchResult.pickerShown,
        'unsupported' => WidgetSetupLaunchResult.unsupported,
        _ => WidgetSetupLaunchResult.failed,
      };
    } on MissingPluginException catch (error) {
      AppLogger.warning('小组件设置通道未注册', error: error);
      return WidgetSetupLaunchResult.failed;
    } catch (error, stackTrace) {
      AppLogger.error('调起小组件设置失败', error: error, stackTrace: stackTrace);
      return WidgetSetupLaunchResult.failed;
    }
  }

  /// 打开系统桌面。
  ///
  /// 部分桌面（如 OPPO ColorOS）会吞掉固定请求：既不弹确认框也不添加实例。
  /// 此时引导用户到桌面手动长按添加，比让用户自己去找桌面更顺。
  static Future<bool> openHomeScreen() async {
    try {
      final result = await _channel.invokeMethod<bool>(methodOpenHomeScreen);
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('打开系统桌面失败', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// 仅供测试使用：重置内部状态，避免静态状态跨用例泄漏。
  static void resetForTesting() {
    _handlerAttached = false;
    _channel.setMethodCallHandler(null);
  }

  static void _attachHandler() {
    if (_handlerAttached) {
      return;
    }

    _channel.setMethodCallHandler(_handleNativeCall);
    _handlerAttached = true;
  }

  static Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method != eventWidgetPinned &&
        call.method != eventWidgetPinUnavailable) {
      return;
    }

    if (_outcomeController.isClosed) {
      return;
    }

    _outcomeController.add(WidgetPinOutcome.fromCall(call));
  }
}
