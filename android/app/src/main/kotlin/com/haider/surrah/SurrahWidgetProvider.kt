package com.haider.surrah

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SurrahWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.surrah_widget_small).apply {
                val hideBalance = widgetData.getBoolean("hide_balance", false)
                
                val todaySpentStr = widgetData.getString("today_spent_str", null)
                val todaySpent = todaySpentStr?.toDoubleOrNull() ?: try { widgetData.getFloat("today_spent", 0f).toDouble() } catch (e: Exception) { 0.0 }
                
                val remainingBudgetStr = widgetData.getString("remaining_budget_str", null)
                val remainingBudget = remainingBudgetStr?.toDoubleOrNull() ?: try { widgetData.getFloat("remaining_budget", 0f).toDouble() } catch (e: Exception) { 0.0 }
                
                val budgetProgressStr = widgetData.getString("budget_progress_str", null)
                val budgetProgress = budgetProgressStr?.toDoubleOrNull() ?: try { widgetData.getFloat("budget_progress", 0f).toDouble() } catch (e: Exception) { 0.0 }
                
                val currency = widgetData.getString("currency", "د.ع") ?: "د.ع"

                val title = widgetData.getString("widget_title", "صُـرّة") ?: "صُـرّة"
                val remainingLabel = widgetData.getString("remaining_budget_label", "الميزانية المتبقية") ?: "الميزانية المتبقية"
                val todaySpentLabel = widgetData.getString("today_spent_label", "مصاريف اليوم") ?: "مصاريف اليوم"

                val spentText = if (hideBalance) "•••• $currency" else String.format("%.0f %s", todaySpent, currency)
                val remainingText = if (hideBalance) "•••• $currency" else String.format("%.0f %s", remainingBudget, currency)

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_remaining_label, remainingLabel)
                setTextViewText(R.id.widget_today_spent_label, todaySpentLabel)

                setTextViewText(R.id.widget_today_spent, spentText)
                setTextViewText(R.id.widget_remaining_budget, remainingText)

                val progressInt = (budgetProgress * 100).toInt().coerceIn(0, 100)
                setProgressBar(R.id.widget_budget_progress, 100, progressInt, false)

                // PendingIntent to launch app on transaction form route
                val addPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("pockaw://add_transaction")
                )
                val openAppPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_add_button, addPendingIntent)
                setOnClickPendingIntent(R.id.widget_container, openAppPendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
