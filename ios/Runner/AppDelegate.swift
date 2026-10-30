import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Dart 侧约定的通道名，见 `lib/features/system/widget_settings_service.dart`。
  private static let widgetSettingsChannelName = "ios_club_app/widget_settings"

  /// 用同一个 key 向 registry 索要 registrar，registry 会据此去重，
  /// 因此即使 `didInitializeImplicitFlutterEngine` 被多次调用也不会重复注册。
  private static let widgetSettingsPluginKey = "WidgetSettingsChannelPlugin"

  private static let methodOpenWidgetSetup = "openWidgetSetup"

  /// iOS 不允许 App 以编程方式往桌面添加小组件，原生侧固定回该值，
  /// 由 Dart 展示 iOS 专用的图文引导。
  private static let unsupportedResult = "unsupported"

  /// 持有通道对象，避免 method call handler 随通道提前释放。
  private var widgetSettingsChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 13.0, *) {
      WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "widgetUpdate",
        frequency: NSNumber(value: 30 * 60)
      )
      WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "courseReminder",
        frequency: NSNumber(value: 2 * 60 * 60)
      )
    }

    // 注意：本工程使用 UIApplicationSceneManifest + FlutterSceneDelegate，
    // 走隐式引擎（FlutterImplicitEngineDelegate）。此处 window 尚未由
    // FlutterAppDelegate 装配完成，`window?.rootViewController` 为 nil，
    // 所以 widget_settings 通道统一在 didInitializeImplicitFlutterEngine 中注册。
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerWidgetSettingsChannel(with: engineBridge.pluginRegistry)
  }

  /// 在隐式引擎初始化完成后注册 method channel。
  ///
  /// `pluginRegistry.registrar(forPlugin:)` 返回的 registrar 自带
  /// `messenger()`（就是根引擎的 FlutterBinaryMessenger），无需等待
  /// FlutterViewController 就绪，因此不会出现通道从未注册、
  /// Dart 侧 invokeMethod 抛 MissingPluginException 的问题。
  private func registerWidgetSettingsChannel(with registry: FlutterPluginRegistry) {
    guard !registry.hasPlugin(Self.widgetSettingsPluginKey) else {
      return
    }

    guard let registrar = registry.registrar(forPlugin: Self.widgetSettingsPluginKey) else {
      NSLog("[WidgetSettings] 无法获取 registrar，通道未注册")
      return
    }

    let channel = FlutterMethodChannel(
      name: Self.widgetSettingsChannelName,
      binaryMessenger: registrar.messenger()
    )

    // 用弱引用避免 channel -> handler -> AppDelegate 的循环持有。
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(Self.unsupportedResult)
        return
      }

      self.handleWidgetSettingsCall(call, result: result)
    }

    widgetSettingsChannel = channel
  }

  /// 处理 Dart 侧发来的调用。
  private func handleWidgetSettingsCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard call.method == Self.methodOpenWidgetSetup else {
      respondOnMain(result, with: FlutterMethodNotImplemented)
      return
    }

    // 参数约定：{"type": "today" | "tomorrow"}；当前仅用于日志，不影响返回。
    let type = Self.widgetSetupType(from: call.arguments)
    NSLog("[WidgetSettings] openWidgetSetup(type: %@) -> %@", type, Self.unsupportedResult)

    respondOnMain(result, with: Self.unsupportedResult)
  }

  /// Flutter 回调必须回到主线程执行。
  private func respondOnMain(_ result: @escaping FlutterResult, with value: Any?) {
    if Thread.isMainThread {
      result(value)
    } else {
      DispatchQueue.main.async {
        result(value)
      }
    }
  }

  private static func widgetSetupType(from arguments: Any?) -> String {
    let rawType: String?
    if let arguments = arguments as? [String: Any] {
      rawType = arguments["type"] as? String
    } else if let arguments = arguments as? String {
      rawType = arguments
    } else {
      rawType = nil
    }

    return rawType == "tomorrow" ? "tomorrow" : "today"
  }
}
