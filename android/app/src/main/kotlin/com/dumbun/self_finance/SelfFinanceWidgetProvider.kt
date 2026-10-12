package com.dumbun.self_finance

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class SelfFinanceWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        // If the app has not refreshed since yesterday, don't show stale "today" numbers.
        val fresh = widgetData.getString("date", "") == today

        val currency = widgetData.getString("currency", "") ?: ""
        val received = if (fresh) widgetData.getString("today_received", "0") else "0"
        val disbursed = if (fresh) widgetData.getString("today_disbursed", "0") else "0"
        val outstanding = widgetData.getString("outstanding", "0")
        val activeLoans = widgetData.getString("active_loans", "0")
        val updated = widgetData.getString("updated", "--:--")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.self_finance_widget).apply {
                // Tap anywhere -> open the app (it will ask for PIN / biometrics)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                )
                setTextViewText(R.id.tv_received, "$currency$received")
                setTextViewText(R.id.tv_disbursed, "$currency$disbursed")
                setTextViewText(R.id.tv_outstanding, "$currency$outstanding")
                setTextViewText(R.id.tv_active, activeLoans)
                setTextViewText(R.id.tv_updated, updated)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}