import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.haider.surrah';
  static const String androidWidgetName = 'SurrahWidgetProvider';
  static const String iOSWidgetName = 'SurrahWidget';

  static const String pockawAndroidWidgetName = 'PockawWidgetProvider';

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
    required double totalBalance,
    required double todaySpent,
    required double remainingBudget,
    required double budgetLimit,
    required double budgetSpent,
    required double budgetProgress,
    required String currencySymbol,
    required String widgetTitle,
    required String remainingBudgetLabel,
    required String todaySpentLabel,
    required String quickAddLabel,
    required bool hideBalance,
    List<Map<String, dynamic>>? recentTransactions,
    Map<String, double>? walletsBalances,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      await HomeWidget.saveWidgetData<double>('total_balance', totalBalance);
      await HomeWidget.saveWidgetData<String>('total_balance_str', totalBalance.toString());
      await HomeWidget.saveWidgetData<double>('today_spent', todaySpent);
      await HomeWidget.saveWidgetData<String>('today_spent_str', todaySpent.toString());
      await HomeWidget.saveWidgetData<double>('remaining_budget', remainingBudget);
      await HomeWidget.saveWidgetData<String>('remaining_budget_str', remainingBudget.toString());
      await HomeWidget.saveWidgetData<double>('budget_limit', budgetLimit);
      await HomeWidget.saveWidgetData<String>('budget_limit_str', budgetLimit.toString());
      await HomeWidget.saveWidgetData<double>('budget_spent', budgetSpent);
      await HomeWidget.saveWidgetData<String>('budget_spent_str', budgetSpent.toString());
      await HomeWidget.saveWidgetData<double>('budget_progress', budgetProgress);
      await HomeWidget.saveWidgetData<String>('budget_progress_str', budgetProgress.toString());
      await HomeWidget.saveWidgetData<String>('currency', currencySymbol);
      await HomeWidget.saveWidgetData<bool>('hide_balance', hideBalance);

      await HomeWidget.saveWidgetData<String>('widget_title', widgetTitle);
      await HomeWidget.saveWidgetData<String>('remaining_budget_label', remainingBudgetLabel);
      await HomeWidget.saveWidgetData<String>('today_spent_label', todaySpentLabel);
      await HomeWidget.saveWidgetData<String>('quick_add_label', quickAddLabel);

      if (recentTransactions != null) {
        final jsonStr = jsonEncode(recentTransactions);
        await HomeWidget.saveWidgetData<String>('recent_transactions', jsonStr);
      }

      if (walletsBalances != null) {
        final jsonStr = jsonEncode(walletsBalances);
        await HomeWidget.saveWidgetData<String>('wallets_balances', jsonStr);
      }

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );

      await HomeWidget.updateWidget(
        androidName: pockawAndroidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating home widget data: $e');
    }
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
