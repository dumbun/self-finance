package com.dumbun.self_finance

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class SelfFinanceWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId, widgetData, null)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = getWidgetData(context)
        updateWidget(context, appWidgetManager, appWidgetId, widgetData, newOptions)
    }

    private fun getWidgetData(context: Context): SharedPreferences {
        return try {
            HomeWidgetPlugin.getData(context)
        } catch (_: Throwable) {
            context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences,
        options: Bundle?
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val fresh = widgetData.getString("date", "") == today

        val currency = widgetData.getString("currency", "₹") ?: "₹"
        val rawReceived = if (fresh) widgetData.getString("today_received", "0") ?: "0" else "0"
        val rawDisbursed = if (fresh) widgetData.getString("today_disbursed", "0") ?: "0" else "0"
        val rawOutstanding = widgetData.getString("outstanding", "0") ?: "0"
        val activeLoans = widgetData.getString("active_loans", "0") ?: "0"
        val updated = widgetData.getString("updated", "--:--") ?: "--:--"

        fun formatMoney(raw: String): String {
            return if (raw.startsWith("•")) raw else "$currency$raw"
        }

        val displayReceived = formatMoney(rawReceived)
        val displayDisbursed = formatMoney(rawDisbursed)
        val displayOutstanding = formatMoney(rawOutstanding)

        // Raw numerical amounts for cashflow calculations
        val recNum = widgetData.getString("today_received_raw", "0")?.toFloatOrNull() ?: 0f
        val disbNum = widgetData.getString("today_disbursed_raw", "0")?.toFloatOrNull() ?: 0f
        val total = recNum + disbNum
        val progress = if (total > 0f) {
            ((recNum / total) * 100).toInt().coerceIn(5, 95)
        } else {
            100
        }

        val cashflowBadgeText = when {
            recNum > 0f && disbNum == 0f -> "100% In"
            recNum == 0f && disbNum > 0f -> "100% Out"
            total > 0f -> "${((recNum / total) * 100).toInt()}% In"
            else -> "Balanced"
        }

        // Parse weekly series
        val weeklyRecStr = widgetData.getString("weekly_received", "") ?: ""
        val weeklyDisbStr = widgetData.getString("weekly_disbursed", "") ?: ""
        val weeklyDaysStr = widgetData.getString("weekly_days", "") ?: ""

        val recList = if (weeklyRecStr.isNotEmpty()) {
            weeklyRecStr.split(",").mapNotNull { it.toFloatOrNull() }
        } else {
            listOf(0f, 0f, 0f, 0f, 0f, 0f, recNum)
        }

        val disbList = if (weeklyDisbStr.isNotEmpty()) {
            weeklyDisbStr.split(",").mapNotNull { it.toFloatOrNull() }
        } else {
            listOf(0f, 0f, 0f, 0f, 0f, 0f, disbNum)
        }

        val dayLabels = if (weeklyDaysStr.isNotEmpty()) {
            weeklyDaysStr.split(",")
        } else {
            val list = mutableListOf<String>()
            for (i in 6 downTo 0) {
                val c = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -i) }
                val dayName = SimpleDateFormat("E", Locale.US).format(c.time)
                list.add(dayName.first().toString())
            }
            list
        }

        val chartBitmap = drawTrendChart(context, recList, disbList, dayLabels)

        // Build mini layout (2x1: narrow & short)
        val miniViews = RemoteViews(context.packageName, R.layout.self_finance_widget_mini).apply {
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            setTextViewText(R.id.tv_received, displayReceived)
            setTextViewText(R.id.tv_outstanding, displayOutstanding)
            setTextViewText(R.id.tv_updated, updated)
        }

        // Build compact layout (4x1, 3x1: wide & short)
        val compactViews = RemoteViews(context.packageName, R.layout.self_finance_widget_compact).apply {
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            setTextViewText(R.id.tv_received, displayReceived)
            setTextViewText(R.id.tv_disbursed, displayDisbursed)
            setTextViewText(R.id.tv_outstanding, displayOutstanding)
            setTextViewText(R.id.tv_active, activeLoans)
            setTextViewText(R.id.tv_updated, updated)
        }

        // Build square layout (2x2: narrow & tall)
        val squareViews = RemoteViews(context.packageName, R.layout.self_finance_widget_square).apply {
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            setTextViewText(R.id.tv_received, displayReceived)
            setTextViewText(R.id.tv_disbursed, displayDisbursed)
            setTextViewText(R.id.tv_outstanding, displayOutstanding)
            setTextViewText(R.id.tv_active, activeLoans)
            setTextViewText(R.id.tv_updated, updated)
        }

        // Build standard layout (4x2, 4x3, 4x4: full dashboard)
        val standardViews = RemoteViews(context.packageName, R.layout.self_finance_widget).apply {
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            setTextViewText(R.id.tv_received, displayReceived)
            setTextViewText(R.id.tv_disbursed, displayDisbursed)
            setTextViewText(R.id.tv_outstanding, displayOutstanding)
            setTextViewText(R.id.tv_active, activeLoans)
            setTextViewText(R.id.tv_updated, updated)
            setTextViewText(R.id.tv_cashflow_badge, cashflowBadgeText)
            setProgressBar(R.id.pb_cashflow, 100, progress, false)
            setImageViewBitmap(R.id.iv_trend_chart, chartBitmap)
        }

        // Android 12+ multi-size responsive layout support
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val multiSizeViews = RemoteViews(
                mapOf(
                    SizeF(100f, 40f) to miniViews,
                    SizeF(220f, 40f) to compactViews,
                    SizeF(100f, 110f) to squareViews,
                    SizeF(220f, 110f) to standardViews
                )
            )
            appWidgetManager.updateAppWidget(widgetId, multiSizeViews)
        } else {
            val opt = options ?: appWidgetManager.getAppWidgetOptions(widgetId)
            val minHeight = opt.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
            val minWidth = opt.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
            val views = when {
                minHeight < 100 && minWidth < 200 -> miniViews
                minHeight < 100 -> compactViews
                minWidth < 200 -> squareViews
                else -> standardViews
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun drawTrendChart(
        context: Context,
        recList: List<Float>,
        disbList: List<Float>,
        dayLabels: List<String>
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val width = (160 * density).toInt().coerceAtLeast(200)
        val height = (72 * density).toInt().coerceAtLeast(90)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val nightMode = (context.resources.configuration.uiMode and
                Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

        val greenColor = if (nightMode) Color.parseColor("#34D399") else Color.parseColor("#10B981")
        val redColor = if (nightMode) Color.parseColor("#FB7185") else Color.parseColor("#F43F5E")
        val axisColor = if (nightMode) Color.parseColor("#334155") else Color.parseColor("#E2E8F0")
        val mutedTextColor = if (nightMode) Color.parseColor("#94A3B8") else Color.parseColor("#64748B")
        val accentTextColor = if (nightMode) Color.parseColor("#38A0FF") else Color.parseColor("#027DFC")
        val inactiveColor = if (nightMode) Color.parseColor("#334155") else Color.parseColor("#E2E8F0")

        val greenPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = greenColor
            style = Paint.Style.FILL
        }
        val redPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = redColor
            style = Paint.Style.FILL
        }
        val inactivePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = inactiveColor
            style = Paint.Style.FILL
        }
        val axisPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = axisColor
            strokeWidth = 1f * density
            style = Paint.Style.STROKE
        }

        val maxVal = maxOf(
            (recList + disbList).maxOrNull() ?: 0f,
            1f
        )

        val daysCount = 7
        val bottomPad = 2f * density
        val dayTextSize = 9.5f * density
        val labelBaselineY = height - bottomPad
        val axisY = height - bottomPad - dayTextSize - 5f * density
        val topPad = 4f * density
        val maxBarHeight = (axisY - topPad).coerceAtLeast(10f * density)

        // Draw baseline axis
        canvas.drawLine(2f * density, axisY, width - 2f * density, axisY, axisPaint)

        val colWidth = width.toFloat() / daysCount
        val barWidth = 4.5f * density
        val barGap = 2f * density
        val barRadius = barWidth / 2f
        val pairWidth = barWidth * 2 + barGap

        for (i in 0 until daysCount) {
            val colCenter = (i + 0.5f) * colWidth
            val isToday = (i == daysCount - 1)

            // Draw day label text
            val dayText = dayLabels.getOrNull(i)?.take(1)?.uppercase(Locale.US) ?: ""
            val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                textSize = dayTextSize
                textAlign = Paint.Align.CENTER
                color = if (isToday) accentTextColor else mutedTextColor
                typeface = if (isToday) Typeface.create(Typeface.DEFAULT, Typeface.BOLD) else Typeface.DEFAULT
            }
            canvas.drawText(dayText, colCenter, labelBaselineY, textPaint)

            // Positions for dual bars
            val startX = colCenter - (pairWidth / 2f)
            val inflowX = startX
            val outflowX = startX + barWidth + barGap

            val rec = recList.getOrNull(i) ?: 0f
            val disb = disbList.getOrNull(i) ?: 0f

            // Inflow bar
            if (rec > 0f) {
                val h = (rec / maxVal * maxBarHeight).coerceAtLeast(barWidth)
                canvas.drawRoundRect(
                    inflowX,
                    axisY - h,
                    inflowX + barWidth,
                    axisY,
                    barRadius,
                    barRadius,
                    greenPaint
                )
            } else {
                // Subtle 2.5dp baseline rounded dot
                canvas.drawRoundRect(
                    inflowX,
                    axisY - 2.5f * density,
                    inflowX + barWidth,
                    axisY,
                    barRadius,
                    barRadius,
                    inactivePaint
                )
            }

            // Outflow bar
            if (disb > 0f) {
                val h = (disb / maxVal * maxBarHeight).coerceAtLeast(barWidth)
                canvas.drawRoundRect(
                    outflowX,
                    axisY - h,
                    outflowX + barWidth,
                    axisY,
                    barRadius,
                    barRadius,
                    redPaint
                )
            } else {
                // Subtle 2.5dp baseline rounded dot
                canvas.drawRoundRect(
                    outflowX,
                    axisY - 2.5f * density,
                    outflowX + barWidth,
                    axisY,
                    barRadius,
                    barRadius,
                    inactivePaint
                )
            }
        }

        return bitmap
    }
}