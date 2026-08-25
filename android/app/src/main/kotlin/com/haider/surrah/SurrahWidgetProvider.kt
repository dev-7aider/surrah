package com.haider.surrah

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class SurrahWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)

            // Select layout based on widget dimensions
            val layoutId = when {
                minHeight >= 180 -> R.layout.surrah_widget_large
                minWidth >= 180 || minHeight >= 100 -> R.layout.surrah_widget_medium
                else -> R.layout.surrah_widget_small
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                val hasActiveWallet = widgetData.getBoolean("has_active_wallet", true)
                val walletName = widgetData.getString("wallet_name", "Main Wallet") ?: "Main Wallet"
                val balanceFormatted = widgetData.getString("wallet_balance_formatted", "0 IQD") ?: "0 IQD"
                val todayIncomeFormatted = widgetData.getString("today_income_formatted", "+0 IQD") ?: "+0 IQD"
                val todayExpensesFormatted = widgetData.getString("today_expenses_formatted", "-0 IQD") ?: "-0 IQD"

                val incomeTodayLabel = widgetData.getString("income_today_label", "Income today") ?: "Income today"
                val expensesTodayLabel = widgetData.getString("expenses_today_label", "Expenses today") ?: "Expenses today"
                val recentTransactionsLabel = widgetData.getString("recent_transactions_label", "Recent Transactions") ?: "Recent Transactions"
                val noActiveWalletLabel = widgetData.getString("no_active_wallet_label", "No active wallet") ?: "No active wallet"

                val noRecentTransactionsLabel = widgetData.getString("no_recent_transactions_label", "No recent transactions") ?: "No recent transactions"

                // Bind Common Values
                setTextViewText(R.id.widget_wallet_name, if (hasActiveWallet) walletName else noActiveWalletLabel)
                setTextViewText(R.id.widget_balance, balanceFormatted)

                // Optional Medium & Large fields
                try {
                    setTextViewText(R.id.widget_income_label, incomeTodayLabel)
                    setTextViewText(R.id.widget_today_income, todayIncomeFormatted)
                    setTextViewText(R.id.widget_expenses_label, expensesTodayLabel)
                    setTextViewText(R.id.widget_today_expenses, todayExpensesFormatted)
                    setTextViewText(R.id.widget_recent_label, recentTransactionsLabel)
                } catch (e: Exception) {
                    // Ignore views not present in smaller layouts
                }

                // Bind Recent Transactions for Large Layout
                if (layoutId == R.layout.surrah_widget_large) {
                    val rawJson = widgetData.getString("recent_transactions", "[]") ?: "[]"
                    try {
                        val txArray = JSONArray(rawJson)
                        val count = txArray.length()

                        if (count == 0) {
                            setViewVisibility(R.id.widget_tx_empty, View.VISIBLE)
                            setTextViewText(R.id.widget_tx_empty, noRecentTransactionsLabel)
                            setViewVisibility(R.id.widget_tx_1, View.GONE)
                            setViewVisibility(R.id.widget_tx_2, View.GONE)
                            setViewVisibility(R.id.widget_tx_3, View.GONE)
                        } else {
                            setViewVisibility(R.id.widget_tx_empty, View.GONE)

                            // Item 1
                            if (count >= 1) {
                                val tx1 = txArray.getJSONObject(0)
                                setViewVisibility(R.id.widget_tx_1, View.VISIBLE)
                                setTextViewText(R.id.widget_tx_1_title, tx1.optString("title", "Transaction"))
                                setTextViewText(R.id.widget_tx_1_category, tx1.optString("category", ""))
                                setTextViewText(R.id.widget_tx_1_amount, tx1.optString("amount_formatted", ""))
                                val isExpense = tx1.optString("type", "expense").lowercase() == "expense"
                                setImageViewResource(
                                    R.id.widget_tx_1_icon_bg,
                                    if (isExpense) R.drawable.widget_icon_expense_bg else R.drawable.widget_icon_income_bg
                                )

                                val tx1Id = tx1.optInt("id", 0)
                                val tx1Intent = HomeWidgetLaunchIntent.getActivity(
                                    context,
                                    MainActivity::class.java,
                                    Uri.parse("pockaw://transaction/$tx1Id")
                                )
                                setOnClickPendingIntent(R.id.widget_tx_1, tx1Intent)
                            } else {
                                setViewVisibility(R.id.widget_tx_1, View.GONE)
                            }

                            // Item 2
                            if (count >= 2) {
                                val tx2 = txArray.getJSONObject(1)
                                setViewVisibility(R.id.widget_tx_2, View.VISIBLE)
                                setTextViewText(R.id.widget_tx_2_title, tx2.optString("title", "Transaction"))
                                setTextViewText(R.id.widget_tx_2_category, tx2.optString("category", ""))
                                setTextViewText(R.id.widget_tx_2_amount, tx2.optString("amount_formatted", ""))
                                val isExpense = tx2.optString("type", "expense").lowercase() == "expense"
                                setImageViewResource(
                                    R.id.widget_tx_2_icon_bg,
                                    if (isExpense) R.drawable.widget_icon_expense_bg else R.drawable.widget_icon_income_bg
                                )

                                val tx2Id = tx2.optInt("id", 0)
                                val tx2Intent = HomeWidgetLaunchIntent.getActivity(
                                    context,
                                    MainActivity::class.java,
                                    Uri.parse("pockaw://transaction/$tx2Id")
                                )
                                setOnClickPendingIntent(R.id.widget_tx_2, tx2Intent)
                            } else {
                                setViewVisibility(R.id.widget_tx_2, View.GONE)
                            }

                            // Item 3
                            if (count >= 3) {
                                val tx3 = txArray.getJSONObject(2)
                                setViewVisibility(R.id.widget_tx_3, View.VISIBLE)
                                setTextViewText(R.id.widget_tx_3_title, tx3.optString("title", "Transaction"))
                                setTextViewText(R.id.widget_tx_3_category, tx3.optString("category", ""))
                                setTextViewText(R.id.widget_tx_3_amount, tx3.optString("amount_formatted", ""))
                                val isExpense = tx3.optString("type", "expense").lowercase() == "expense"
                                setImageViewResource(
                                    R.id.widget_tx_3_icon_bg,
                                    if (isExpense) R.drawable.widget_icon_expense_bg else R.drawable.widget_icon_income_bg
                                )

                                val tx3Id = tx3.optInt("id", 0)
                                val tx3Intent = HomeWidgetLaunchIntent.getActivity(
                                    context,
                                    MainActivity::class.java,
                                    Uri.parse("pockaw://transaction/$tx3Id")
                                )
                                setOnClickPendingIntent(R.id.widget_tx_3, tx3Intent)
                            } else {
                                setViewVisibility(R.id.widget_tx_3, View.GONE)
                            }
                        }
                    } catch (e: Exception) {
                        setViewVisibility(R.id.widget_tx_empty, View.VISIBLE)
                        setTextViewText(R.id.widget_tx_empty, noRecentTransactionsLabel)
                    }
                }

                // Deep link intents
                val expenseIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("pockaw://add_transaction?type=expense")
                )
                val incomeIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("pockaw://add_transaction?type=income")
                )
                val transferIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("pockaw://add_transaction?type=transfer")
                )
                val openWalletsIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("pockaw://manage-wallets")
                )

                try {
                    setOnClickPendingIntent(R.id.widget_btn_expense, expenseIntent)
                } catch (e: Exception) {}
                try {
                    setOnClickPendingIntent(R.id.widget_btn_income, incomeIntent)
                } catch (e: Exception) {}
                try {
                    setOnClickPendingIntent(R.id.widget_btn_transfer, transferIntent)
                } catch (e: Exception) {}

                setOnClickPendingIntent(R.id.widget_container, openWalletsIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), getSharedPreferences(context))
    }

    private fun getSharedPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences("group.com.haider.surrah", Context.MODE_PRIVATE)
    }
}
