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

                    // Colors
                    val incomeColor = context.getColor(R.color.widget_income_green)
                    val expenseColor = context.getColor(R.color.widget_expense_red)
                    val transferColor = context.getColor(R.color.widget_transfer_blue)

                    // Action buttons: - for Expense (RED), + for Income (GREEN), ⇄ for Transfer
                    try {
                        setTextViewText(R.id.widget_btn_expense, "- $expenseLabel")
                        setTextColor(R.id.widget_btn_expense, expenseColor)
                    } catch (e: Exception) {}

                    try {
                        setTextViewText(R.id.widget_btn_income, "+ $incomeLabel")
                        setTextColor(R.id.widget_btn_income, incomeColor)
                    } catch (e: Exception) {}

                    try {
                        setTextViewText(R.id.widget_btn_transfer, "⇄ $transferLabel")
                        setTextColor(R.id.widget_btn_transfer, transferColor)
                    } catch (e: Exception) {}

                    // Daily cashflow: Income (GREEN) & Expenses (RED)
                    try {
                        setTextViewText(R.id.widget_income_label, incomeTodayLabel)
                        setTextViewText(R.id.widget_today_income, todayIncomeFormatted)
                        setTextColor(R.id.widget_today_income, incomeColor)
                    } catch (e: Exception) {}

                    try {
                        setTextViewText(R.id.widget_expenses_label, expensesTodayLabel)
                        setTextViewText(R.id.widget_today_expenses, todayExpensesFormatted)
                        setTextColor(R.id.widget_today_expenses, expenseColor)
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

                                val rows = listOf(
                                    listOf(R.id.widget_tx_1, R.id.widget_tx_1_icon, R.id.widget_tx_1_title, R.id.widget_tx_1_category, R.id.widget_tx_1_amount),
                                    listOf(R.id.widget_tx_2, R.id.widget_tx_2_icon, R.id.widget_tx_2_title, R.id.widget_tx_2_category, R.id.widget_tx_2_amount),
                                    listOf(R.id.widget_tx_3, R.id.widget_tx_3_icon, R.id.widget_tx_3_title, R.id.widget_tx_3_category, R.id.widget_tx_3_amount)
                                )

                                for (i in rows.indices) {
                                    val row = rows[i]
                                    val rowId = row[0]
                                    val iconId = row[1]
                                    val titleId = row[2]
                                    val categoryId = row[3]
                                    val amountId = row[4]

                                    if (i < count) {
                                        val tx = txArray.getJSONObject(i)
                                        setViewVisibility(rowId, View.VISIBLE)
                                        setTextViewText(titleId, tx.optString("title", "Transaction"))
                                        setTextViewText(categoryId, tx.optString("category", ""))
                                        setTextViewText(amountId, tx.optString("amount_formatted", ""))

                                        val type = tx.optString("type", "expense").lowercase()
                                        val isIncome = type == "income"
                                        val isTransfer = type == "transfer"

                                        val (textColor, iconRes, bgRes) = when {
                                            isIncome -> Triple(
                                                incomeColor,
                                                R.drawable.ic_widget_income_cash,
                                                R.drawable.widget_icon_income_bg
                                            )
                                            isTransfer -> Triple(
                                                transferColor,
                                                R.drawable.ic_widget_transfer,
                                                R.drawable.widget_icon_transfer_bg
                                            )
                                            else -> Triple(
                                                expenseColor,
                                                R.drawable.ic_widget_cart,
                                                R.drawable.widget_icon_expense_bg
                                            )
                                        }

                                        setTextColor(amountId, textColor)
                                        setImageViewResource(iconId, iconRes)
                                        try {
                                            setInt(iconId, "setBackgroundResource", bgRes)
                                        } catch (e: Exception) {}

                                        val txId = tx.optInt("id", 0)
                                        val txIntent = HomeWidgetLaunchIntent.getActivity(
                                            context,
                                            MainActivity::class.java,
                                            Uri.parse("surrah://transaction/$txId")
                                        )
                                        setOnClickPendingIntent(rowId, txIntent)
                                    } else {
                                        setViewVisibility(rowId, View.GONE)
                                    }
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
                        Uri.parse("surrah://add_transaction?type=expense")
                    )
                    val incomeIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("surrah://add_transaction?type=income")
                    )
                    val transferIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("surrah://add_transaction?type=transfer")
                    )
                    val openWalletsIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("surrah://manage-wallets")
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
