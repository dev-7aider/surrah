package com.haider.surrah

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PockawWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.pockaw_widget_medium).apply {
                val hideBalance = widgetData.getBoolean("hide_balance", false)

                val budgetLimitStr = widgetData.getString("budget_limit_str", null)
                val budgetLimit = budgetLimitStr?.toDoubleOrNull() ?: widgetData.getFloat("budget_limit", 0f).toDouble()

                val budgetSpentStr = widgetData.getString("budget_spent_str", null)
                val budgetSpent = budgetSpentStr?.toDoubleOrNull() ?: widgetData.getFloat("budget_spent", 0f).toDouble()

                val currency = widgetData.getString("currency", "د.ع") ?: "د.ع"
                val title = widgetData.getString("widget_title", "ميزانية الشهر") ?: "ميزانية الشهر"

                val percent = if (budgetLimit > 0) ((budgetSpent / budgetLimit) * 100).toInt() else 0

                setTextViewText(R.id.widget_title, title)
                setProgressBar(R.id.widget_progress, 100, percent.coerceIn(0, 100), false)

                val summaryText = if (hideBalance) {
                    "مستهلك •••• من •••• $currency"
                } else {
                    "مستهلك ${budgetSpent.toInt()} من ${budgetLimit.toInt()} $currency"
                }
                setTextViewText(R.id.widget_summary, summaryText)

                val addUri = Uri.parse("pockaw://add_transaction")
                val addPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    addUri
                )
                setOnClickPendingIntent(R.id.widget_add_button, addPendingIntent)

                val openAppIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, openAppIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
