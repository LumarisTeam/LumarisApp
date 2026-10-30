package com.example.ios_club_app

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 「桌面小组件」设置入口的 MethodChannel 封装。
 *
 * 与 Dart 侧 `WidgetSettingsService`（lib/features/system/widget_settings_service.dart）
 * 严格对齐，以下契约一个字都不能改：
 * - channel 名：[CHANNEL_NAME]
 * - Dart -> 原生：[METHOD_OPEN_WIDGET_SETUP]，参数 `{"type": "today" | "tomorrow"}`
 * - Dart -> 原生：[METHOD_OPEN_HOME_SCREEN]，无参数，返回 Boolean（是否成功拉起桌面）
 * - 原生 -> Dart 事件：
 *   - [EVENT_WIDGET_PINNED] `{type, alreadyInstalled}`：确实加到了桌面
 *   - [EVENT_WIDGET_PIN_UNAVAILABLE] `{type, reason, supported, brand, launcher}`：
 *     没加上，需要回退到手动引导
 * - `openWidgetSetup` 返回字符串：[RESULT_PICKER_SHOWN] / [RESULT_UNSUPPORTED] / [RESULT_FAILED]
 *
 * 该类的所有公开方法都保证不抛异常：渠道尚未注册（Activity 已销毁、引擎已分离）时安全忽略。
 */
class WidgetSettingsChannel private constructor() {

    companion object {
        private const val TAG = "WidgetSettingsChannel"

        // ==================== Dart 契约常量（禁止改动）====================
        const val CHANNEL_NAME = "ios_club_app/widget_settings"
        const val METHOD_OPEN_WIDGET_SETUP = "openWidgetSetup"

        /** 打开系统桌面（图文引导里的「去桌面手动添加」按钮），无参数，返回 Boolean。 */
        const val METHOD_OPEN_HOME_SCREEN = "openHomeScreen"

        /** 小组件确实加到了桌面。payload: {type, alreadyInstalled} */
        const val EVENT_WIDGET_PINNED = "onWidgetPinned"

        /** 尝试结束但没加到桌面。payload: {type, reason, supported, brand, launcher} */
        const val EVENT_WIDGET_PIN_UNAVAILABLE = "onWidgetPinUnavailable"

        const val ARG_TYPE = "type"
        const val ARG_ALREADY_INSTALLED = "alreadyInstalled"
        const val ARG_REASON = "reason"
        const val ARG_SUPPORTED = "supported"
        const val ARG_BRAND = "brand"
        const val ARG_LAUNCHER = "launcher"

        /** 未添加成功的原因：等待超时（小米 / vivo 静默失败的典型路径）。 */
        const val REASON_TIMEOUT = "timeout"

        /** 未添加成功的原因：系统拒绝了这次固定。 */
        const val REASON_REJECTED = "rejected"

        /** 请求已发给系统。**不代表添加成功**，真实结果由事件上报。 */
        const val RESULT_PICKER_SHOWN = "pickerShown"

        /** SDK < 26、AppWidgetManager 不可用、或 requestPinAppWidget 返回 false。 */
        const val RESULT_UNSUPPORTED = "unsupported"

        /** 调用系统 API 过程中出现异常。 */
        const val RESULT_FAILED = "failed"
        // =================================================================

        /** 小组件类型：今日课表。 */
        const val TYPE_TODAY = "today"

        /** 小组件类型：近日（今日 + 明日）课表。 */
        const val TYPE_TOMORROW = "tomorrow"

        private val mainHandler = Handler(Looper.getMainLooper())

        @Volatile
        private var channel: MethodChannel? = null

        /**
         * 把任意输入归一化为契约内的类型字符串，默认按今日课表处理。
         */
        fun normalizeType(type: String?): String =
            if (type == TYPE_TOMORROW) TYPE_TOMORROW else TYPE_TODAY

        /**
         * 注册 Dart -> 原生的方法调用处理器。
         * 每次 [MainActivity.configureFlutterEngine] 都会调用一次，覆盖旧引用是预期行为。
         */
        fun register(flutterEngine: FlutterEngine, activity: MainActivity) {
            val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL_NAME
            )

            methodChannel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    METHOD_OPEN_WIDGET_SETUP -> {
                        val type = normalizeType(call.argument<String>(ARG_TYPE))
                        // openWidgetSetup 内部已做完整异常兜底，不会向外抛。
                        result.success(activity.openWidgetSetup(type))
                    }

                    METHOD_OPEN_HOME_SCREEN -> {
                        // 返回 Boolean；实现内部全 try/catch，找不到桌面也只返回 false。
                        result.success(activity.openHomeScreen())
                    }

                    else -> result.notImplemented()
                }
            }

            channel = methodChannel
        }

        /**
         * 释放渠道引用。Activity 销毁后引擎（可能被缓存复用）已无法再向 Dart 投递事件，
         * 保留旧引用只会在回调时打印无意义的错误日志。
         */
        fun release() {
            try {
                channel?.setMethodCallHandler(null)
            } catch (e: Exception) {
                Log.w(TAG, "释放 MethodChannel 失败", e)
            } finally {
                channel = null
            }
        }

        /**
         * 反向通知 Dart：小组件确实加到了桌面。
         *
         * @param alreadyInstalled 添加前桌面上是否已经有该小组件（本次没有新增实例）。
         */
        fun notifyWidgetPinned(type: String?, alreadyInstalled: Boolean = false) {
            deliverEvent(
                EVENT_WIDGET_PINNED,
                mapOf(
                    ARG_TYPE to normalizeType(type),
                    ARG_ALREADY_INSTALLED to alreadyInstalled
                )
            )
        }

        /**
         * 反向通知 Dart：这次尝试没有把小组件加到桌面，需要回退到手动引导。
         *
         * @param reason [REASON_TIMEOUT] / [REASON_REJECTED]
         * @param supported 启动器是否「声明」支持程序化固定，仅用于诊断（部分国产 ROM 会误报）。
         * @param brand 形如 `Redmi/Xiaomi`，Dart 侧做小写包含匹配。
         * @param launcher 默认桌面启动器包名，取不到时为空字符串。
         */
        fun notifyWidgetPinUnavailable(
            type: String?,
            reason: String,
            supported: Boolean,
            brand: String,
            launcher: String
        ) {
            deliverEvent(
                EVENT_WIDGET_PIN_UNAVAILABLE,
                mapOf(
                    ARG_TYPE to normalizeType(type),
                    ARG_REASON to reason,
                    ARG_SUPPORTED to supported,
                    ARG_BRAND to brand,
                    ARG_LAUNCHER to launcher
                )
            )
        }

        /**
         * 统一事件出口：强制主线程投递，渠道为空时安全忽略，绝不抛异常。
         */
        private fun deliverEvent(event: String, payload: Map<String, Any?>) {
            try {
                if (Looper.myLooper() == Looper.getMainLooper()) {
                    deliverEventOnMain(event, payload)
                } else {
                    mainHandler.post { deliverEventOnMain(event, payload) }
                }
            } catch (e: Exception) {
                Log.w(TAG, "投递事件 $event 失败", e)
            }
        }

        private fun deliverEventOnMain(event: String, payload: Map<String, Any?>) {
            val activeChannel = channel
            if (activeChannel == null) {
                // Activity / 引擎已销毁：按契约安全忽略（不向 Dart 发事件）。
                Log.i(TAG, "$event 已忽略：MethodChannel 未注册，payload=$payload")
                return
            }

            try {
                activeChannel.invokeMethod(event, payload)
            } catch (e: Exception) {
                Log.w(TAG, "事件 $event 回调 Dart 失败，payload=$payload", e)
            }
        }
    }
}
