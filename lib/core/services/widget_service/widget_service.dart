import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.haider.surrah';
  static const String androidWidgetName = 'SurrahWidgetProvider';
  static const String iOSWidgetName = 'SurrahWidget';

  /// Initialize HomeWidget settings
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('Error initializing HomeWidget: $e');
    }
  }

  /// Update home widget data from app state
  static Future<void> updateWidgetData({
    required bool hasActiveWallet,
    required String walletName,
    required double walletBalance,
    required String walletBalanceFormatted,
    required String currencySymbol,
    required double todayIncome,
    required String todayIncomeFormatted,
    required double todayExpenses,
    required String todayExpensesFormatted,
    required String incomeTodayLabel,
    required String expensesTodayLabel,
    required String recentTransactionsLabel,
    required String addTransactionLabel,
    required String noActiveWalletLabel,
    required String noTransactionsTodayLabel,
    required String noRecentTransactionsLabel,
    required String openAppLabel,
    required bool isRtl,
    required bool hideBalance,
    List<Map<String, dynamic>>? recentTransactions,
    // Legacy support keys
    double? totalBalance,
    double? remainingBudget,
    double? budgetLimit,
    double? budgetSpent,
    double? budgetProgress,
    String? widgetTitle,
    String? remainingBudgetLabel,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      // Active wallet info
      await HomeWidget.saveWidgetData<bool>('has_active_wallet', hasActiveWallet);
      await HomeWidget.saveWidgetData<String>('wallet_name', walletName);
      await HomeWidget.saveWidgetData<double>('wallet_balance', walletBalance);
      await HomeWidget.saveWidgetData<String>('wallet_balance_formatted', walletBalanceFormatted);
      await HomeWidget.saveWidgetData<String>('currency', currencySymbol);

      // Cash flow today
      await HomeWidget.saveWidgetData<double>('today_income', todayIncome);
      await HomeWidget.saveWidgetData<String>('today_income_formatted', todayIncomeFormatted);
      await HomeWidget.saveWidgetData<double>('today_expenses', todayExpenses);
      await HomeWidget.saveWidgetData<String>('today_expenses_formatted', todayExpensesFormatted);

      // Localized strings
      await HomeWidget.saveWidgetData<String>('income_today_label', incomeTodayLabel);
      await HomeWidget.saveWidgetData<String>('expenses_today_label', expensesTodayLabel);
      await HomeWidget.saveWidgetData<String>('recent_transactions_label', recentTransactionsLabel);
      await HomeWidget.saveWidgetData<String>('add_transaction_label', addTransactionLabel);
      await HomeWidget.saveWidgetData<String>('no_active_wallet_label', noActiveWalletLabel);
      await HomeWidget.saveWidgetData<String>('no_transactions_today_label', noTransactionsTodayLabel);
      await HomeWidget.saveWidgetData<String>('no_recent_transactions_label', noRecentTransactionsLabel);
      await HomeWidget.saveWidgetData<String>('open_app_label', openAppLabel);
      await HomeWidget.saveWidgetData<bool>('is_rtl', isRtl);
      await HomeWidget.saveWidgetData<bool>('hide_balance', hideBalance);

      // Legacy compatibility
      await HomeWidget.saveWidgetData<double>('total_balance', totalBalance ?? walletBalance);
      await HomeWidget.saveWidgetData<String>('total_balance_str', (totalBalance ?? walletBalance).toString());
      await HomeWidget.saveWidgetData<double>('today_spent', todayExpenses);
      await HomeWidget.saveWidgetData<String>('today_spent_str', todayExpenses.toString());
      await HomeWidget.saveWidgetData<double>('remaining_budget', remainingBudget ?? 0.0);
      await HomeWidget.saveWidgetData<String>('remaining_budget_str', (remainingBudget ?? 0.0).toString());
      await HomeWidget.saveWidgetData<double>('budget_limit', budgetLimit ?? 0.0);
      await HomeWidget.saveWidgetData<String>('budget_limit_str', (budgetLimit ?? 0.0).toString());
      await HomeWidget.saveWidgetData<double>('budget_spent', budgetSpent ?? 0.0);
      await HomeWidget.saveWidgetData<String>('budget_spent_str', (budgetSpent ?? 0.0).toString());
      await HomeWidget.saveWidgetData<double>('budget_progress', budgetProgress ?? 0.0);
      await HomeWidget.saveWidgetData<String>('budget_progress_str', (budgetProgress ?? 0.0).toString());
      await HomeWidget.saveWidgetData<String>('widget_title', widgetTitle ?? walletName);
      await HomeWidget.saveWidgetData<String>('remaining_budget_label', remainingBudgetLabel ?? '');
      await HomeWidget.saveWidgetData<String>('today_spent_label', expensesTodayLabel);
      await HomeWidget.saveWidgetData<String>('quick_add_label', addTransactionLabel);

      if (recentTransactions != null) {
        final jsonStr = jsonEncode(recentTransactions);
        await HomeWidget.saveWidgetData<String>('recent_transactions', jsonStr);
      } else {
        await HomeWidget.saveWidgetData<String>('recent_transactions', '[]');
      }

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating home widget data: $e');
    }
  }

  static Uri? _pendingUri;

  /// Store pending widget URI when launched from widget
  static void setPendingUri(Uri? uri) {
    if (uri != null) {
      _pendingUri = uri;
    }
  }

  /// Consume pending widget URI after app/session initialization
  static Uri? consumePendingUri() {
    final uri = _pendingUri;
    _pendingUri = null;
    return uri;
  }

  /// Register callback for background widget actions or deep links
  static Future<Uri?> getInitiallyLaunchedUrl() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (e) {
      debugPrint('Error fetching initially launched widget URL: $e');
      return null;
    }
  }

  /// Register interactivity callback for interactive home widget buttons
  static Future<void> registerInteractivityCallback(
    Future<void> Function(Uri? uri) callback,
  ) async {
    try {
      await HomeWidget.registerInteractivityCallback(callback);
    } catch (e) {
      debugPrint('Error registering interactivity callback: $e');
    }
  }
}
