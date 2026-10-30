package com.example.ios_club_app

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log

/**
 * 「小组件固定成功」广播接收器。
 *
 * 触发链路：
 * 1. 设置页点「添加到桌面」→ Dart 调 `openWidgetSetup`。
 * 2. [MainActivity.openWidgetSetup] 调 `AppWidgetManager.requestPinAppWidget`，
 *    并把本接收器的 PendingIntent 作为 successCallback 交给系统。
 * 3. 用户在系统弹窗里点「添加」→ 系统以本 App 身份发出本 Intent → 这里收到。
 *
 * 但注意：**这个回调不可靠**——华为 / 荣耀会弹框却从不回调，小米 / vivo 干脆不弹框。
 * 所以它只是「真实结果」的**补充**证据，最终结论始终由 [PinOutcomeDetector]
 * 通过 `getAppWidgetIds` 的实例数量变化来判定。
 *
 * 收到回调后做两件事：
 * - 交给 [PinOutcomeDetector]：取消正在进行的轮询，用计数确认后再上报成功，
 *   保证同一次尝试只发一个结果事件；
 * - 顺手请求一次小组件刷新，避免新固定的小组件一直展示 XML 里的静态预览内容。
 *
 * 全流程必须零崩溃：任何异常都只记录日志。前台没有 Flutter 引擎时（进程被回收后重新拉起）
 * 通知 Dart 一步会被安全忽略。
 *
 * 关于 `android:exported="false"`（AndroidManifest.xml 里声明）：
 * successCallback 的 PendingIntent 由本 App 用 `PendingIntent.getBroadcast` 创建，
 * 系统只是执行 `PendingIntent.send()`。PendingIntent 是按创建者身份（UID）执行的令牌，
 * 所以这条广播的发送方 UID 就是我们自己，属于「自收自发」的显式广播，
 * 非导出的 receiver 完全可以收到；不需要 exported="true"，也就不给外部伪造
 * 「已添加成功」事件的机会。
 */
class WidgetPinReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "WidgetPinReceiver"

        /** 固定成功回调的 Action（只在应用内部使用，不导出）。 */
        const val ACTION_WIDGET_PINNED = "com.example.ios_club_app.action.WIDGET_PINNED"

        /** 小组件类型：today / tomorrow。 */
        const val EXTRA_WIDGET_TYPE = "type"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        try {
            handlePinResult(context, intent)
        } catch (e: Exception) {
            Log.w(TAG, "处理小组件固定回调失败", e)
        }
    }

    private fun handlePinResult(context: Context?, intent: Intent?) {
        if (intent == null) {
            Log.i(TAG, "收到空 Intent，忽略")
            return
        }

        if (intent.action != null && intent.action != ACTION_WIDGET_PINNED) {
            // 不认识的广播直接忽略，避免误报「添加成功」。
            Log.i(TAG, "忽略未知 action=${intent.action}")
            return
        }

        val type = WidgetSettingsChannel.normalizeType(
            intent.getStringExtra(EXTRA_WIDGET_TYPE)
        )
        Log.i(TAG, "收到系统固定成功回调（type=$type）")

        // 1) 交给判定器：取消轮询 + 计数确认，保证同一次尝试只发一个结果事件。
        PinOutcomeDetector.onPinCallbackReceived(type)

        // 2) 尽力刷新刚固定的小组件（拿不到 appWidgetId 时由系统随后的 onUpdate 兜底）。
        if (context != null) {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                requestWidgetUpdate(context, type, appWidgetId)
            } else {
                Log.i(TAG, "固定回调未携带 appWidgetId，跳过主动刷新")
            }
        }
    }

    /**
     * 以显式广播通知对应 Provider 用 HomeWidget 里的真实数据重绘一次。
     * Provider 的 onReceive 已经处理 ACTION_APPWIDGET_UPDATE。
     */
    private fun requestWidgetUpdate(context: Context, type: String, appWidgetId: Int) {
        try {
            val providerClass = if (type == WidgetSettingsChannel.TYPE_TOMORROW) {
                TomorrowCoursesWidgetProvider::class.java
            } else {
                TodayCoursesWidgetProvider::class.java
            }

            val updateIntent = Intent(context, providerClass).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            context.sendBroadcast(updateIntent)
        } catch (e: Exception) {
            Log.w(TAG, "请求小组件刷新失败（appWidgetId=$appWidgetId）", e)
        }
    }
}

/**
 * 「小组件是否真的加到了桌面」判定器。
 *
 * 为什么不能用 `requestPinAppWidget` 的返回值：它只代表「系统接受了请求」，
 * 官方实现里几乎永远返回 true，与是否真的添加成功无关：
 * - 小米 / 红米：不弹确认框直接加桌面；缺「创建桌面快捷方式」权限时静默什么都不发生；
 * - vivo / iQOO：不弹框，未接厂商原子组件平台时完全无效；
 * - 华为 / 荣耀：会弹框，但 successCallback 的 PendingIntent 永远不会被触发。
 * 业界唯一可靠的判据只有 `AppWidgetManager.getAppWidgetIds(provider)` 的实例数量变化。
 *
 * 判定时序（全部跑在主线程 Handler 上，同一时刻只允许一个进行中的判定）：
 * ```
 * openWidgetSetup 前: baseline = getAppWidgetIds(provider).size
 * requestPinAppWidget() == true → start()
 *   ├─ T0           baseline，进入 POLLING
 *   ├─ 每 500ms      count > baseline ? → onWidgetPinned{alreadyInstalled:false}
 *   │               到 +5s 仍无变化 → 「窗口结算」
 *   ├─ Activity onPause（有弹框盖上来）→ WAITING_RESUME，停掉超时计时
 *   ├─ Activity onResume → CONFIRMING：+400ms 起每 400ms 查一次，1.2s 内无变化 → 结算
 *   └─ 收到系统固定成功回调 → 取消轮询，+300ms 用计数确认后结算
 * ```
 *
 * 「窗口结算」：
 * - baseline == 0 且计数没变化 → `onWidgetPinUnavailable{reason:"timeout"}`
 *   （小米缺权限 / vivo 未接平台的典型路径，Dart 走图文引导）；
 * - baseline > 0 且计数没变化 → 桌面上本来就有这个小组件，报
 *   `onWidgetPinned{alreadyInstalled:true}`，不要拿「失败」吓用户。
 *
 * 去重：所有终态都先 `current = null` 再发事件，竞态方因 `current !== attempt` 直接退出，
 * 因此**每次尝试恰好发一个结果事件**。系统回调晚于判定结束（用户确认晚于 5 秒窗口）时，
 * 只有此前没报过成功才补发，避免重复提示。
 */
internal object PinOutcomeDetector {

    private const val TAG = "PinOutcomeDetector"

    /** 首轮轮询：每 500ms 一次，最多 5 秒（小米 / vivo 静默成功或静默失败都在这个窗口内见分晓）。 */
    private const val POLL_INTERVAL_MS = 500L
    private const val POLL_WINDOW_MS = 5_000L

    /** 看到 onPause 之后：回到前台再等 400ms，然后在 1.2 秒内判定。 */
    private const val RESUME_DELAY_MS = 400L
    private const val RESUME_POLL_MS = 400L
    private const val RESUME_WINDOW_MS = 1_200L

    /** 收到系统回调后，给系统一点时间把新实例登记进 AppWidgetManager。 */
    private const val CALLBACK_SETTLE_MS = 300L

    /** 已上报成功的去重窗口，用于「迟到回调」。 */
    private const val DEDUPE_WINDOW_MS = 60_000L

    private enum class Phase {
        /** 首轮 5 秒窗口轮询。 */
        POLLING,

        /** 出现过 onPause（有弹框盖上来），等 onResume 再判定。 */
        WAITING_RESUME,

        /** onResume 之后的 1.2 秒回前台判定窗口。 */
        CONFIRMING,

        /** 收到系统固定成功回调，等待短暂 settle 后用计数确认。 */
        CALLBACK_SETTLE
    }

    private class Attempt(
        val activity: MainActivity,
        val type: String,
        val provider: ComponentName,
        /** 请求发出前的实例数量。 */
        val baseline: Int,
        /** 启动器是否「声明」支持程序化固定，仅用于诊断上报。 */
        val supported: Boolean,
        var phase: Phase
    )

    private val mainHandler = Handler(Looper.getMainLooper())

    /** 同一时刻只允许一个进行中的判定（新请求会静默覆盖并取消旧的）。 */
    private var current: Attempt? = null

    // 已上报结果的去重信息（只服务「迟到回调」这一条路径）。
    private var lastOutcomeType: String? = null
    private var lastOutcomeInstalled = false
    private var lastOutcomeAt = 0L

    // ==================== 供 MainActivity 调用 ====================

    /**
     * `requestPinAppWidget` 返回 true 后开始判定。
     * 会先静默取消上一个进行中的判定（同一个时间只允许一个）。
     */
    fun start(
        activity: MainActivity,
        type: String,
        provider: ComponentName,
        baseline: Int,
        supported: Boolean
    ) = onMain {
        cancelInternal("被新请求覆盖")
        val attempt = Attempt(activity, type, provider, baseline, supported, Phase.POLLING)
        current = attempt

        Log.i(TAG, "开始判定：type=$type, baseline=$baseline, supported=$supported")

        val deadlineAt = SystemClock.elapsedRealtime() + POLL_WINDOW_MS
        poll(attempt, POLL_INTERVAL_MS, deadlineAt, POLL_INTERVAL_MS)
    }

    /** Activity 进入后台（通常是固定弹窗盖到了我们的界面上）：先停掉「超时即失败」的计时。 */
    fun onHostPaused(activity: MainActivity) = onMain {
        val attempt = current ?: return@onMain
        if (attempt.activity !== activity) return@onMain
        // 已经收到系统回调、正在等 settle 的情况不受前后台影响，别把这次确认打断。
        if (attempt.phase == Phase.CALLBACK_SETTLE) return@onMain

        attempt.phase = Phase.WAITING_RESUME
        clearCallbacks()
        Log.i(TAG, "onPause：暂停超时计时，等回前台再判定（type=${attempt.type}）")
    }

    /** Activity 回到前台：给一个短暂窗口确认最终结果。 */
    fun onHostResumed(activity: MainActivity) = onMain {
        val attempt = current ?: return@onMain
        if (attempt.activity !== activity) return@onMain
        if (attempt.phase != Phase.WAITING_RESUME) return@onMain

        attempt.phase = Phase.CONFIRMING
        val deadlineAt = SystemClock.elapsedRealtime() + RESUME_DELAY_MS + RESUME_WINDOW_MS
        Log.i(TAG, "onResume：开始回前台判定（type=${attempt.type}）")
        poll(attempt, RESUME_DELAY_MS, deadlineAt, RESUME_POLL_MS)
    }

    /** 静默取消（不发事件）：Activity 销毁、或请求被系统拒绝时使用。 */
    fun cancel() = onMain { cancelInternal("主动取消") }

    // ==================== 供 WidgetPinReceiver 调用 ====================

    /** 收到系统固定成功回调：取消轮询，用计数确认后只发一个结果事件。 */
    fun onPinCallbackReceived(type: String?) = onMain {
        val safeType = WidgetSettingsChannel.normalizeType(type)
        val attempt = current

        if (attempt == null) {
            handleLateCallback(safeType)
            return@onMain
        }

        if (attempt.type != safeType) {
            Log.i(TAG, "回调类型与进行中的判定不一致（pending=${attempt.type}, cb=$safeType），忽略")
            return@onMain
        }

        clearCallbacks()
        attempt.phase = Phase.CALLBACK_SETTLE
        Log.i(TAG, "收到固定成功回调：已取消轮询，${CALLBACK_SETTLE_MS}ms 后用计数确认（type=$safeType）")
        mainHandler.postDelayed({ confirmAfterCallback(attempt) }, CALLBACK_SETTLE_MS)
    }

    // ==================== 内部实现 ====================

    private fun poll(attempt: Attempt, delayMs: Long, deadlineAt: Long, intervalMs: Long) {
        mainHandler.postDelayed(
            object : Runnable {
                override fun run() {
                    if (current !== attempt) return

                    val count = widgetCount(attempt)
                    if (current !== attempt) return // widgetCount 可能已经触发取消

                    if (count > attempt.baseline) {
                        finishPinned(attempt, alreadyInstalled = false, source = "计数增加($count)")
                        return
                    }

                    if (SystemClock.elapsedRealtime() >= deadlineAt) {
                        finishNotIncreased(attempt, source = "窗口结束($count)")
                        return
                    }

                    poll(attempt, intervalMs, deadlineAt, intervalMs)
                }
            },
            delayMs
        )
    }

    private fun confirmAfterCallback(attempt: Attempt) {
        if (current !== attempt) return

        val count = widgetCount(attempt)
        if (current !== attempt) return

        when {
            count > attempt.baseline -> finishPinned(
                attempt,
                alreadyInstalled = false,
                source = "回调+计数增加($count)"
            )

            // 回调说成功但没新增实例：桌面上本来就有一个，按「已有」上报。
            attempt.baseline > 0 -> finishPinned(
                attempt,
                alreadyInstalled = true,
                source = "回调+已有实例($count)"
            )

            // 系统自称成功、计数却没变：如实上报拒绝，绝不谎报成功。
            else -> finishUnavailable(
                attempt,
                WidgetSettingsChannel.REASON_REJECTED,
                source = "回调但计数未变($count)"
            )
        }
    }

    /** 轮询窗口走完、计数仍等于 baseline 时的结算。 */
    private fun finishNotIncreased(attempt: Attempt, source: String) {
        if (attempt.baseline > 0) {
            // 桌面上早就有一个该小组件，本次没有再新增：这不是失败。
            finishPinned(attempt, alreadyInstalled = true, source = "已有实例+$source")
        } else {
            finishUnavailable(attempt, WidgetSettingsChannel.REASON_TIMEOUT, source = source)
        }
    }

    private fun finishPinned(attempt: Attempt, alreadyInstalled: Boolean, source: String) {
        if (current !== attempt) return
        current = null
        clearCallbacks()
        rememberOutcome(attempt.type, installed = true)

        Log.i(
            TAG,
            "判定完成：已添加（type=${attempt.type}, alreadyInstalled=$alreadyInstalled, " +
                "supported=${attempt.supported}, source=$source）"
        )
        WidgetSettingsChannel.notifyWidgetPinned(attempt.type, alreadyInstalled)
    }

    private fun finishUnavailable(attempt: Attempt, reason: String, source: String) {
        if (current !== attempt) return
        current = null
        clearCallbacks()
        rememberOutcome(attempt.type, installed = false)

        val brand = deviceBrand()
        val launcher = defaultLauncherPackage(attempt.activity)
        Log.i(
            TAG,
            "判定完成：未添加（type=${attempt.type}, reason=$reason, " +
                "supported=${attempt.supported}, brand=$brand, launcher=$launcher, source=$source）"
        )
        WidgetSettingsChannel.notifyWidgetPinUnavailable(
            attempt.type,
            reason,
            attempt.supported,
            brand,
            launcher
        )
    }

    /**
     * 系统回调晚于判定结束（用户确认得比 5 秒窗口更晚）。
     * 只有此前没报过成功时才补发，避免同一个动作提示两次。
     */
    private fun handleLateCallback(type: String) {
        val alreadyReportedSuccess = type == lastOutcomeType &&
            lastOutcomeInstalled &&
            SystemClock.elapsedRealtime() - lastOutcomeAt < DEDUPE_WINDOW_MS

        if (alreadyReportedSuccess) {
            Log.i(TAG, "迟到回调（type=$type）：此前已上报过成功，忽略")
            return
        }

        Log.i(TAG, "迟到回调（type=$type）：没有进行中的判定，直接上报成功")
        rememberOutcome(type, installed = true)
        WidgetSettingsChannel.notifyWidgetPinned(type, alreadyInstalled = false)
    }

    private fun rememberOutcome(type: String, installed: Boolean) {
        lastOutcomeType = type
        lastOutcomeInstalled = installed
        lastOutcomeAt = SystemClock.elapsedRealtime()
    }

    private fun cancelInternal(reason: String) {
        val attempt = current
        if (attempt != null) {
            Log.i(TAG, "取消进行中的判定（不发事件）：type=${attempt.type}, 原因=$reason")
        }
        current = null
        clearCallbacks()
    }

    private fun clearCallbacks() {
        try {
            mainHandler.removeCallbacksAndMessages(null)
        } catch (e: Exception) {
            Log.w(TAG, "清理定时任务失败", e)
        }
    }

    /**
     * 读取当前实例数量。
     *
     * 任何异常（含 Activity 已销毁）都退化成 baseline，即「没有变化」，
     * 绝不会因为读取失败而谎报成功。
     */
    private fun widgetCount(attempt: Attempt): Int {
        return try {
            if (attempt.activity.isFinishing || attempt.activity.isDestroyed) {
                // Activity 已销毁：按契约安全放弃（不发事件）。
                cancelInternal("Activity 已销毁")
                return -1
            }

            val manager = attempt.activity.getSystemService(Context.APPWIDGET_SERVICE)
                as? AppWidgetManager

            if (manager == null) {
                Log.w(TAG, "AppWidgetManager 不可用，按未变化处理")
                attempt.baseline
            } else {
                manager.getAppWidgetIds(attempt.provider)?.size ?: attempt.baseline
            }
        } catch (e: Exception) {
            Log.w(TAG, "读取小组件实例数量失败，按未变化处理", e)
            attempt.baseline
        }
    }

    /** 形如 `Redmi/Xiaomi`；两端都空时为 `""`。Dart 侧做小写包含匹配。 */
    private fun deviceBrand(): String {
        return try {
            val brand = Build.BRAND?.trim().orEmpty()
            val manufacturer = Build.MANUFACTURER?.trim().orEmpty()
            when {
                brand.isEmpty() && manufacturer.isEmpty() -> ""
                brand.isEmpty() -> manufacturer
                manufacturer.isEmpty() -> brand
                else -> "$brand/$manufacturer"
            }
        } catch (e: Exception) {
            Log.w(TAG, "读取设备品牌失败", e)
            ""
        }
    }

    /** 默认桌面包名；取不到（含 Android 11+ 包可见性限制）时返回空字符串。 */
    private fun defaultLauncherPackage(activity: Activity): String {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            @Suppress("DEPRECATION")
            val resolved = activity.packageManager
                .resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            resolved?.activityInfo?.packageName ?: ""
        } catch (e: Exception) {
            Log.w(TAG, "解析默认桌面失败", e)
            ""
        }
    }

    /**
     * 保证所有状态读写都在主线程：判定依赖单线程顺序来保证「只发一个事件」。
     */
    private fun onMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            try {
                block()
            } catch (e: Exception) {
                Log.w(TAG, "判定逻辑异常（主线程直接执行）", e)
            }
        } else {
            mainHandler.post {
                try {
                    block()
                } catch (e: Exception) {
                    Log.w(TAG, "判定逻辑异常（post 到主线程）", e)
                }
            }
        }
    }
}
