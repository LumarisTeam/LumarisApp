package com.example.ios_club_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.RemoteViews
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlin.math.roundToInt
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"

        /** today / tomorrow 使用不同的 requestCode，避免 PendingIntent 互相覆盖。 */
        private const val PIN_REQUEST_CODE_TODAY = 0x1001
        private const val PIN_REQUEST_CODE_TOMORROW = 0x1002

        /** 预览位图的目标尺寸（dp），与 res/xml 里的 targetCellWidth/Height 对齐。 */
        private const val PREVIEW_TODAY_WIDTH_DP = 220
        private const val PREVIEW_TODAY_HEIGHT_DP = 220
        private const val PREVIEW_TOMORROW_WIDTH_DP = 250
        private const val PREVIEW_TOMORROW_HEIGHT_DP = 110

        /**
         * Binder 单次事务约 1MB，而 Bitmap 是整块像素走 Parcel（ARGB_8888 → w*h*4 字节）。
         * 高密度屏按 dp 换算后轻易超限（220dp@3x ≈ 1.7MB），会抛 TransactionTooLargeException
         * 把固定请求整个搞挂。预览图只是缩略图，用等比缩小换取绝对安全。
         */
        private const val PREVIEW_MAX_SIDE_PX = 512
        private const val PREVIEW_MAX_PIXELS = 100_000L
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        WidgetSettingsChannel.register(flutterEngine, this)
    }

    override fun onResume() {
        super.onResume()
        // 固定弹窗会把我们压到后台；回到前台后继续用实例数量判定真实结果。
        PinOutcomeDetector.onHostResumed(this)
    }

    override fun onPause() {
        // 有弹框盖上来时先停掉「超时即失败」的计时，避免用户在弹框里犹豫就被判失败。
        PinOutcomeDetector.onHostPaused(this)
        super.onPause()
    }

    override fun onDestroy() {
        // Activity 销毁后既没法再判定，也没法向 Dart 投递事件：静默放弃（不发事件）。
        PinOutcomeDetector.cancel()
        // 引擎可能在配置变更 / 缓存场景下复用，但 Activity 销毁后渠道已无法投递事件，
        // 这里主动释放引用，避免回调时对着失效引擎打印错误。
        WidgetSettingsChannel.release()
        super.onDestroy()
    }

    /**
     * 请求系统把小组件固定到桌面。
     *
     * 返回值只说明「请求是否发出去了」，**不代表添加成功**：
     * `requestPinAppWidget` 的布尔值几乎永远为 true，而小米 / 红米 不弹框直接加桌面、
     * vivo / iQOO 不弹框也可能完全无效、华为 / 荣耀 弹框但永不回调。
     * 真实结果由 [PinOutcomeDetector] 通过 `getAppWidgetIds` 的实例数量变化判定后，
     * 以 `onWidgetPinned` / `onWidgetPinUnavailable` 事件上报。
     *
     * 返回 [WidgetSettingsChannel.RESULT_PICKER_SHOWN] /
     * [WidgetSettingsChannel.RESULT_UNSUPPORTED] /
     * [WidgetSettingsChannel.RESULT_FAILED]。
     *
     * 全程不抛异常，最坏情况返回 failed。
     */
    fun openWidgetSetup(type: String?): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            Log.i(TAG, "openWidgetSetup: 系统低于 Android 8.0，不支持程序化固定小组件")
            return WidgetSettingsChannel.RESULT_UNSUPPORTED
        }

        return try {
            // 用 API 1 就存在的字符串服务名取实例，避免 getSystemService(Class)（API 23+）的兼容坑。
            val appWidgetManager =
                getSystemService(Context.APPWIDGET_SERVICE) as? AppWidgetManager
                    ?: run {
                        Log.i(TAG, "openWidgetSetup: AppWidgetManager 不可用")
                        return WidgetSettingsChannel.RESULT_UNSUPPORTED
                    }

            // isRequestPinAppWidgetSupported 只作为诊断信号随失败事件上报，不作为判据：
            // 部分国产 ROM（MIUI / HyperOS、荣耀等）会误报 false，但直接调用 requestPinAppWidget
            // 仍能正常添加。该 getter 在个别 ROM 上还可能抛异常，因此单独兜底。
            val isSupported = try {
                appWidgetManager.isRequestPinAppWidgetSupported
            } catch (e: Exception) {
                Log.w(TAG, "读取 isRequestPinAppWidgetSupported 失败，忽略该信号", e)
                false
            }

            val safeType = WidgetSettingsChannel.normalizeType(type)
            val providerClass = if (safeType == WidgetSettingsChannel.TYPE_TOMORROW) {
                TomorrowCoursesWidgetProvider::class.java
            } else {
                TodayCoursesWidgetProvider::class.java
            }
            val provider = ComponentName(this, providerClass)

            // 关键：请求前先记录已固定的实例数量，作为「有没有真的加上」的唯一基线。
            val baseline = widgetCount(appWidgetManager, provider)
            val successCallback = createPinSuccessCallback(safeType)

            // 带一张预览位图：ColorOS 等桌面会把「没有预览」的 pin 请求直接吞掉
            // （不弹框、不添加、也不 onPause），带图才有机会让它正常走弹框流程。
            // 构造失败会自动降级为 null（等价于上一版行为），绝不影响固定请求本身。
            val extras = buildPinExtras(safeType)

            // 带 extras 的调用本身也可能被个别 ROM 拒绝（例如 extras 无法跨 Binder 传递）：
            // 一旦抛异常就退回上一版的 null extras 再试一次，保证「带预览」只是加分项。
            val requested = try {
                appWidgetManager.requestPinAppWidget(provider, extras, successCallback)
            } catch (e: Exception) {
                if (extras == null) throw e
                Log.w(TAG, "带预览 extras 的 requestPinAppWidget 失败，退回 null extras 重试", e)
                appWidgetManager.requestPinAppWidget(provider, null, successCallback)
            }

            // 系统直接拒绝了请求：不进入判定，也不发事件，Dart 收到 unsupported 后走图文引导。
            if (!requested) {
                PinOutcomeDetector.cancel()
                Log.i(
                    TAG,
                    "openWidgetSetup: requestPinAppWidget 返回 false（type=$safeType, " +
                        "isSupported=$isSupported, baseline=$baseline）→ unsupported"
                )
                return WidgetSettingsChannel.RESULT_UNSUPPORTED
            }

            PinOutcomeDetector.start(this, safeType, provider, baseline, isSupported)
            Log.i(
                TAG,
                "openWidgetSetup: 请求已发出，开始计数判定（type=$safeType, " +
                    "isSupported=$isSupported, baseline=$baseline, " +
                    "preview=${extras?.containsKey(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW) == true}）"
            )
            WidgetSettingsChannel.RESULT_PICKER_SHOWN
        } catch (e: Exception) {
            Log.w(TAG, "openWidgetSetup 异常", e)
            PinOutcomeDetector.cancel()
            WidgetSettingsChannel.RESULT_FAILED
        }
    }

    /**
     * 打开系统桌面（图文引导里的「去桌面手动添加」按钮）。
     *
     * 返回 Boolean：true 表示已成功拉起桌面；找不到 / 异常返回 false。
     * 无参数，全 try/catch，绝不崩。
     */
    fun openHomeScreen(): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_HOME)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            Log.i(TAG, "openHomeScreen: 已拉起系统桌面")
            true
        } catch (e: Exception) {
            Log.w(TAG, "openHomeScreen 失败", e)
            false
        }
    }

    /** 当前已固定在桌面上的该小组件实例数量；读取失败按 0 处理（会退化成 timeout 判定）。 */
    private fun widgetCount(manager: AppWidgetManager, provider: ComponentName): Int {
        return try {
            manager.getAppWidgetIds(provider)?.size ?: 0
        } catch (e: Exception) {
            Log.w(TAG, "读取已固定的小组件数量失败，按 0 处理", e)
            0
        }
    }

    /**
     * 构造 `requestPinAppWidget` 的 extras：塞一张 `EXTRA_APPWIDGET_PREVIEW` 位图。
     *
     * 目的：ColorOS 等桌面会把「没有预览图」的 pin 请求直接吞掉（不弹框、不添加实例、
     * 也不产生 onPause），带一张预览图才有机会让它正常走系统弹框流程。
     *
     * 降级路径（一律返回 null，等价于上一版行为）：
     * - RemoteViews inflate / measure / draw 抛异常；
     * - 渲染时 OOM（预览图纯装饰，绝不能让固定请求跟着挂）；
     * - 任何其它异常。
     *
     * 返回值只用于诊断日志，`requestPinAppWidget` 本身接受 null extras。
     */
    private fun buildPinExtras(type: String): Bundle? {
        return try {
            val preview = renderWidgetPreview(type) ?: return null
            Bundle().apply {
                putParcelable(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW, preview)
            }
        } catch (e: Exception) {
            Log.w(TAG, "构造固定预览 extras 失败，降级为 null extras", e)
            null
        } catch (e: OutOfMemoryError) {
            Log.w(TAG, "渲染预览图时 OOM，降级为 null extras", e)
            null
        }
    }

    /**
     * 用预览布局离屏渲染一张位图（不依赖真实数据，也不依赖 RemoteViewsService 适配器）。
     *
     * 渲染失败返回 null；成功时位图已按 [PREVIEW_MAX_PIXELS] 等比缩小，
     * 保证走 Binder 时不会抛 TransactionTooLargeException。
     */
    private fun renderWidgetPreview(type: String): Bitmap? {
        val isTomorrow = type == WidgetSettingsChannel.TYPE_TOMORROW
        val layoutRes = if (isTomorrow) {
            R.layout.tomorrow_courses_widget_preview
        } else {
            R.layout.today_courses_widget_preview
        }
        val widthDp = if (isTomorrow) PREVIEW_TOMORROW_WIDTH_DP else PREVIEW_TODAY_WIDTH_DP
        val heightDp = if (isTomorrow) PREVIEW_TOMORROW_HEIGHT_DP else PREVIEW_TODAY_HEIGHT_DP

        val density = resources.displayMetrics.density.takeIf { it > 0f } ?: 1f
        val (widthPx, heightPx) = clampPreviewSize(
            (widthDp * density).roundToInt(),
            (heightDp * density).roundToInt()
        )

        val remoteViews = RemoteViews(packageName, layoutRes)
        // 需要一个 parent 才能正确套用 layout 参数；用不 attach 的 FrameLayout 即可。
        val host = FrameLayout(this)
        val view = remoteViews.apply(this, host)

        view.measure(
            View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(heightPx, View.MeasureSpec.EXACTLY)
        )
        view.layout(0, 0, widthPx, heightPx)

        val bitmap = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
        bitmap.density = resources.displayMetrics.densityDpi

        try {
            view.draw(Canvas(bitmap))
        } catch (e: Exception) {
            Log.w(TAG, "绘制预览位图失败，跳过预览", e)
            bitmap.recycle()
            return null
        }

        Log.i(TAG, "预览位图渲染成功：${widthPx}x$heightPx, 约 ${widthPx.toLong() * heightPx * 4 / 1024}KB")
        return bitmap
    }

    /** 把 dp 换算出来的像素尺寸压到 Binder 安全范围内（等比缩放，不改变宽高比）。 */
    private fun clampPreviewSize(widthPx: Int, heightPx: Int): Pair<Int, Int> {
        var width = widthPx.coerceAtLeast(1)
        var height = heightPx.coerceAtLeast(1)

        val longestSide = maxOf(width, height)
        if (longestSide > PREVIEW_MAX_SIDE_PX) {
            val scale = PREVIEW_MAX_SIDE_PX.toFloat() / longestSide.toFloat()
            width = (width * scale).roundToInt().coerceAtLeast(1)
            height = (height * scale).roundToInt().coerceAtLeast(1)
        }

        val pixels = width.toLong() * height.toLong()
        if (pixels > PREVIEW_MAX_PIXELS) {
            val scale = sqrt(PREVIEW_MAX_PIXELS.toDouble() / pixels.toDouble()).toFloat()
            width = (width * scale).roundToInt().coerceAtLeast(1)
            height = (height * scale).roundToInt().coerceAtLeast(1)
        }

        return width to height
    }

    /**
     * 构造「用户确认固定成功」的回调广播 Intent（由系统在固定成功后发出，投递给 [WidgetPinReceiver]）。
     *
     * 注意这个回调在华为 / 荣耀上永远不会触发，所以它只用于「提前确认成功」，
     * 不能当作唯一判据（真实判据见 [PinOutcomeDetector]）。
     *
     * 失败时返回 null：requestPinAppWidget 允许 successCallback 为空，
     * 此时仍会发起请求，只是少一路确认，属于可接受的降级。
     */
    private fun createPinSuccessCallback(type: String): PendingIntent? {
        return try {
            val requestCode = if (type == WidgetSettingsChannel.TYPE_TOMORROW) {
                PIN_REQUEST_CODE_TOMORROW
            } else {
                PIN_REQUEST_CODE_TODAY
            }

            val intent = Intent(this, WidgetPinReceiver::class.java).apply {
                action = WidgetPinReceiver.ACTION_WIDGET_PINNED
                putExtra(WidgetPinReceiver.EXTRA_WIDGET_TYPE, type)
                // 显式组件 + 独立 data，保证 today / tomorrow 两个 PendingIntent 不会被 FLAG_UPDATE_CURRENT 合并。
                data = Uri.parse("ios_club_app://widget_pin/$type")
            }

            PendingIntent.getBroadcast(
                this,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } catch (e: Exception) {
            Log.w(TAG, "createPinSuccessCallback 失败，降级为无回调固定", e)
            null
        }
    }
}
