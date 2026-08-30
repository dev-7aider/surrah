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
        val sp = getWidgetSharedPreferences(context, widgetData)

        appWidgetIds.forEach { widgetId ->
            try {
                val options = appWidgetManager.getAppWidgetOptions(widgetId)
                val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
                val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)

                // Dynamic responsive layout selection based on cell sizes:
                // minHeight >= 140 -> Large (shows transactions)
                // minHeight < 80 && minWidth < 160 -> Small
                // otherwise -> Medium (balanced card)
                val layoutId = when {
                    minHeight >= 140 -> R.layout.surrah_widget_large
                    minHeight in 1..79 && minWidth in 1..159 -> R.layout.surrah_widget_small
                    else -> R.layout.surrah_widget_medium
                }

                val views = RemoteViews(context.packageName, layoutId).apply {
                    val hasActiveWallet = sp.getBoolean("has_active_wallet", true)
                    val walletName = sp.getString("wallet_name", "Main Wallet") ?: "Main Wallet"
                    val balanceFormatted = sp.getString("wallet_balance_formatted", "0 IQD") ?: "0 IQD"
                    val todayIncomeFormatted = sp.getString("today_income_formatted", "+0 IQD") ?: "+0 IQD"
                    val todayExpensesFormatted = sp.getString("today_expenses_formatted", "-0 IQD") ?: "-0 IQD"

                    val incomeTodayLabel = sp.getString("income_today_label", "Income today") ?: "Income today"
                    val expensesTodayLabel = sp.getString("expenses_today_label", "Expenses today") ?: "Expenses today"
                    val recentTransactionsLabel = sp.getString("recent_transactions_label", "Recent Transactions") ?: "Recent Transactions"
                    val noActiveWalletLabel = sp.getString("no_active_wallet_label", "No active wallet") ?: "No active wallet"
                    val noRecentTransactionsLabel = sp.getString("no_recent_transactions_label", "No recent transactions") ?: "No recent transactions"

                    val isRtl = sp.getBoolean("is_rtl", false)
                    val balanceLabel = if (isRtl) "الرصيد الحالي" else "Current Balance"
                    val expenseLabel = if (isRtl) "مصروف" else "Expense"
                    val incomeLabel = if (isRtl) "دخل" else "Income"
                    val transferLabel = if (isRtl) "تحويل" else "Transfer"

                    // Bind Header & Balance
                    setTextViewText(R.id.widget_wallet_name, if (hasActiveWallet) walletName else noActiveWalletLabel)
                    setTextViewText(R.id.widget_balance, balanceFormatted)

                    try {
                        setTextViewText(R.id.widget_balance_label, balanceLabel)
                    } catch (e: Exception) {}

                    // Action buttons: - for Expense (RED), + for Income (GREEN), ⇄ for Transfer
                    try {
                        setTextViewText(R.id.widget_btn_expense, "- $expenseLabel")
                    } catch (e: Exception) {}

                    try {
                        setTextViewText(R.id.widget_btn_income, "+ $incomeLabel")
                    } catch (e: Exception) {}

                    try {
                        setTextViewText(R.id.widget_btn_transfer, "⇄ $transferLabel")
                    } catch (e: Exception) {}

                    // Daily cashflow: Income (GREEN) & Expenses (RED)
                    try {
                        setTextViewText(R.id.widget_income_label, incomeTodayLabel)
                        setTextViewText(R.id.widget_today_income, todayIncomeFormatted)
                    } catch (e: Exception) {}

                    try {
                        setTextViewText(R.id.widget_expenses_label, expensesTodayLabel)
                        setTextViewText(R.id.widget_today_expenses, todayExpensesFormatted)
                    } catch (e: Exception) {}

                    // Large widget: Recent transactions list
                    if (layoutId == R.layout.surrah_widget_large) {
                        try {
                            setTextViewText(R.id.widget_recent_label, recentTransactionsLabel)
                            val rawJson = sp.getString("recent_transactions", "[]") ?: "[]"
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

                                // Tx 1
                                if (count >= 1) {
                                    val tx1 = txArray.getJSONObject(0)
                                    setViewVisibility(R.id.widget_tx_1, View.VISIBLE)
                                    setTextViewText(R.id.widget_tx_1_title, tx1.optString("title", "Transaction"))
                                    setTextViewText(R.id.widget_tx_1_category, tx1.optString("category", ""))
                                    setTextViewText(R.id.widget_tx_1_amount, tx1.optString("amount_formatted", ""))
                                    val isExpense = tx1.optString("type", "expense").lowercase() == "expense"
                                    setImageViewResource(
                                        R.id.widget_tx_1_icon,
                                        if (isExpense) R.drawable.ic_widget_cart else R.drawable.ic_widget_income_cash
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

                                // Tx 2
                                if (count >= 2) {
                                    val tx2 = txArray.getJSONObject(1)
                                    setViewVisibility(R.id.widget_tx_2, View.VISIBLE)
                                    setTextViewText(R.id.widget_tx_2_title, tx2.optString("title", "Transaction"))
                                    setTextViewText(R.id.widget_tx_2_category, tx2.optString("category", ""))
                                    setTextViewText(R.id.widget_tx_2_amount, tx2.optString("amount_formatted", ""))
                                    val isExpense = tx2.optString("type", "expense").lowercase() == "expense"
                                    setImageViewResource(
                                        R.id.widget_tx_2_icon,
                                        if (isExpense) R.drawable.ic_widget_cart else R.drawable.ic_widget_income_cash
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

                                // Tx 3
                                if (count >= 3) {
                                    val tx3 = txArray.getJSONObject(2)
                                    setViewVisibility(R.id.widget_tx_3, View.VISIBLE)
                                    setTextViewText(R.id.widget_tx_3_title, tx3.optString("title", "Transaction"))
                                    setTextViewText(R.id.widget_tx_3_category, tx3.optString("category", ""))
                                    setTextViewText(R.id.widget_tx_3_amount, tx3.optString("amount_formatted", ""))
                                    val isExpense = tx3.optString("type", "expense").lowercase() == "expense"
                                    setImageViewResource(
                                        R.id.widget_tx_3_icon,
                                        if (isExpense) R.drawable.ic_widget_cart else R.drawable.ic_widget_income_cash
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
                            try {
                                setViewVisibility(R.id.widget_tx_empty, View.VISIBLE)
                                setTextViewText(R.id.widget_tx_empty, noRecentTransactionsLabel)
                            } catch (e2: Exception) {}
                        }
                    }

                    // Deep Link Intents
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
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val sp = getWidgetSharedPreferences(context, null)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), sp)
    }

    private fun getWidgetSharedPreferences(context: Context, fallback: SharedPreferences?): SharedPreferences {
        // Priority 1: HomeWidgetPreferences (actual file where home_widget plugin saves data on Android)
        val homeWidgetSp = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        if (homeWidgetSp.contains("wallet_name") || homeWidgetSp.contains("wallet_balance_formatted")) {
            return homeWidgetSp
        }

        // Priority 2: Fallback from HomeWidgetProvider
        if (fallback != null && (fallback.contains("wallet_name") || fallback.contains("wallet_balance_formatted"))) {
            return fallback
        }

        // Priority 3: group.com.haider.surrah
        val groupSp = context.getSharedPreferences("group.com.haider.surrah", Context.MODE_PRIVATE)
        if (groupSp.contains("wallet_name") || groupSp.contains("wallet_balance_formatted")) {
            return groupSp
        }

        // Priority 4: Default SharedPreferences
        val defaultSp = context.getSharedPreferences("${context.packageName}_preferences", Context.MODE_PRIVATE)
        if (defaultSp.contains("wallet_name") || defaultSp.contains("wallet_balance_formatted")) {
            return defaultSp
        }

        return homeWidgetSp
    }
}
