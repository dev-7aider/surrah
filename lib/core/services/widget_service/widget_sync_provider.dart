import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/database/pockaw_database.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/localization/locale_provider.dart';
import 'package:pockaw/core/services/widget_service/widget_service.dart';
import 'package:pockaw/features/transaction/data/model/transaction_model.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';

final widgetSyncProvider = Provider<WidgetSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return WidgetSyncService(db, ref);
});

/// Reactive provider that automatically triggers widget sync on data/locale changes
final autoWidgetSyncProvider = Provider<void>((ref) {
  final syncService = ref.watch(widgetSyncProvider);

  // Listen to locale changes
  ref.listen(localeNotifierProvider, (previous, next) {
    syncService.syncWidgetData();
  });

  // Listen to active wallet & visibility changes
  ref.listen(activeWalletProvider, (previous, next) {
    syncService.syncWidgetData();
  });
  ref.listen(walletAmountVisibilityProvider, (previous, next) {
    syncService.syncWidgetData();
  });

  // Listen to transaction & budget stream updates from database
  final db = ref.watch(databaseProvider);
  final sub1 = db.transactionDao.watchAllTransactionsWithDetails().listen((_) {
    syncService.syncWidgetData();
  });
  final sub2 = db.budgetDao.watchAllBudgets().listen((_) {
    syncService.syncWidgetData();
  });
  final sub3 = db.walletDao.watchAllWallets().listen((_) {
    syncService.syncWidgetData();
  });

  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    sub3.cancel();
  });

  // Defer initial sync to next microtask so build phase completes first
  Future.microtask(() => syncService.syncWidgetData());
});

class WidgetSyncService {
  final AppDatabase db;
  final Ref ref;

  WidgetSyncService(this.db, this.ref);

  /// Synchronize app active wallet, cash flow & transaction data with native Android & iOS Widgets
  Future<void> syncWidgetData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // 1. Fetch Active Wallet (or fallback to first wallet in DB)
      var activeWallet = ref.read(activeWalletProvider).asData?.value;
      if (activeWallet == null) {
        final wallets = await db.walletDao.watchAllWallets().first;
        if (wallets.isNotEmpty) {
          activeWallet = wallets.first;
        }
      }

      final bool hasActiveWallet = activeWallet != null;
      final String walletName = activeWallet?.name ?? 'Main Wallet';
      final double walletBalance = activeWallet?.balance ?? 0.0;
      final String walletCurrency = activeWallet?.currency ?? 'IQD';

      final locale = ref.read(localeNotifierProvider);
      final String effectiveLang = locale?.languageCode ??
          PlatformDispatcher.instance.locale.languageCode;
      final bool isArabic = effectiveLang == 'ar';
      final bool isRtl = isArabic;

      final String currencySymbol = (walletCurrency == 'IQD' || walletCurrency == 'د.ع')
          ? (isArabic ? 'د.ع' : 'IQD')
          : walletCurrency;

      final bool isVisible = ref.read(walletAmountVisibilityProvider);
      final bool hideBalance = !isVisible;

      // 2. Fetch transactions for the active wallet
      List<TransactionModel> transactions = [];
      if (activeWallet?.id != null) {
        transactions = await db.transactionDao
            .watchTransactionsByWalletIdWithDetails(activeWallet!.id!)
            .first;
      } else {
        transactions = await db.transactionDao
            .watchAllTransactionsWithDetails()
            .first;
      }

      // Sort newest first
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // 3. Compute today's Income and Expenses for the active wallet
      double todayIncome = 0.0;
      double todayExpenses = 0.0;

      for (final tx in transactions) {
        final isToday = !tx.date.isBefore(startOfDay) && !tx.date.isAfter(endOfDay);
        if (isToday) {
          if (tx.transactionType == TransactionType.income) {
            todayIncome += tx.amount;
          } else if (tx.transactionType == TransactionType.expense) {
            todayExpenses += tx.amount;
          }
        }
      }

      // 4. Format strings
      final String walletBalanceFormatted = hideBalance
          ? '•••• $currencySymbol'
          : '${walletBalance.toPriceFormat()} $currencySymbol';

      final String todayIncomeFormatted =
          '+${todayIncome.toPriceFormat()} $currencySymbol';

      final String todayExpensesFormatted =
          '-${todayExpenses.toPriceFormat()} $currencySymbol';

      // 5. Build recent 2-3 transactions payload
      final List<Map<String, dynamic>> recentTransactionsList = [];
      for (final tx in transactions.take(3)) {
        final bool isExpense = tx.transactionType == TransactionType.expense;
        final String sign = isExpense ? '-' : '+';
        final String formattedAmount =
            '$sign${tx.amount.toPriceFormat()} $currencySymbol';

        recentTransactionsList.add({
          'id': tx.id ?? 0,
          'title': tx.title.isNotEmpty ? tx.title : tx.category.title,
          'amount': tx.amount,
          'amount_formatted': formattedAmount,
          'type': tx.transactionType.name,
          'category': tx.category.title,
          'date': tx.date.toIso8601String(),
        });
      }

      // 6. Localized Labels
      final String incomeTodayLabel = isArabic ? 'دخل اليوم' : 'Income today';
      final String expensesTodayLabel = isArabic ? 'مصاريف اليوم' : 'Expenses today';
      final String recentTransactionsLabel = isArabic ? 'أحدث المعاملات' : 'Recent Transactions';
      final String addTransactionLabel = isArabic ? '+ إضافة معاملة' : '+ Add Transaction';
      final String noActiveWalletLabel = isArabic ? 'لا توجد محفظة نشطة' : 'No active wallet';
      final String noTransactionsTodayLabel = isArabic ? 'لا توجد معاملات اليوم' : 'No transactions today';
      final String noRecentTransactionsLabel = isArabic ? 'لا توجد معاملات مؤخراً' : 'No recent transactions';
      final String openAppLabel = isArabic ? 'فتح صُـرّة' : 'Open Pockaw';

      // Legacy budget calculation for backwards compatibility
      final budgetModels = await db.budgetDao.watchAllBudgets().first;
      double totalBudgetLimit = 0;
      double totalBudgetSpent = 0;
      for (final b in budgetModels) {
        totalBudgetLimit += b.amount;
        final spent = await db.budgetDao.getSpentAmountForBudget(b);
        totalBudgetSpent += spent;
      }
      double remainingBudget = totalBudgetLimit - totalBudgetSpent;
      if (remainingBudget < 0) remainingBudget = 0;
      final budgetProgress = totalBudgetLimit > 0
          ? (totalBudgetSpent / totalBudgetLimit).clamp(0.0, 1.0)
          : 0.0;

      await WidgetService.updateWidgetData(
        hasActiveWallet: hasActiveWallet,
        walletName: walletName,
        walletBalance: walletBalance,
        walletBalanceFormatted: walletBalanceFormatted,
        currencySymbol: currencySymbol,
        todayIncome: todayIncome,
        todayIncomeFormatted: todayIncomeFormatted,
        todayExpenses: todayExpenses,
        todayExpensesFormatted: todayExpensesFormatted,
        incomeTodayLabel: incomeTodayLabel,
        expensesTodayLabel: expensesTodayLabel,
        recentTransactionsLabel: recentTransactionsLabel,
        addTransactionLabel: addTransactionLabel,
        noActiveWalletLabel: noActiveWalletLabel,
        noTransactionsTodayLabel: noTransactionsTodayLabel,
        noRecentTransactionsLabel: noRecentTransactionsLabel,
        openAppLabel: openAppLabel,
        isRtl: isRtl,
        hideBalance: hideBalance,
        recentTransactions: recentTransactionsList,
        totalBalance: walletBalance,
        remainingBudget: remainingBudget,
        budgetLimit: totalBudgetLimit,
        budgetSpent: totalBudgetSpent,
        budgetProgress: budgetProgress,
        widgetTitle: walletName,
        remainingBudgetLabel: isArabic ? 'الميزانية المتبقية' : 'Remaining Budget',
      );
    } catch (e, st) {
      debugPrint('Error syncing widget data: $e\n$st');
    }
  }
}
