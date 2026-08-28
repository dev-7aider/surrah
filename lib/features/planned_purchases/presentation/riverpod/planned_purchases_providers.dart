import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockaw/core/database/daos/planned_purchase_dao.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchases_filter_model.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';

final plannedPurchaseDaoProvider = Provider<PlannedPurchaseDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.plannedPurchaseDao;
});

final activePlannedPurchasesProvider =
    StreamProvider<List<PlannedPurchaseModel>>((ref) {
  final dao = ref.watch(plannedPurchaseDaoProvider);
  return dao.watchActivePurchases();
});

final purchasedHistoryProvider =
    StreamProvider<List<PlannedPurchaseModel>>((ref) {
  final dao = ref.watch(plannedPurchaseDaoProvider);
  return dao.watchPurchasedHistory();
});

class PlannedPurchasesFilterNotifier
    extends Notifier<PlannedPurchasesFilterModel?> {
  @override
  PlannedPurchasesFilterModel? build() => null;

  void setFilter(PlannedPurchasesFilterModel? filter) => state = filter;
  void clear() => state = null;
}

final plannedPurchasesFilterProvider =
    NotifierProvider<PlannedPurchasesFilterNotifier, PlannedPurchasesFilterModel?>(
  PlannedPurchasesFilterNotifier.new,
);

// Filtered History Provider
final filteredPurchasedHistoryProvider =
    Provider<AsyncValue<List<PlannedPurchaseModel>>>((ref) {
  final historyAsync = ref.watch(purchasedHistoryProvider);
  final filter = ref.watch(plannedPurchasesFilterProvider);

  return historyAsync.whenData((items) {
    if (filter == null || !filter.isActive) {
      return items;
    }

    return items.where((item) {
      // 1. Keyword search (in title or notes)
      if (filter.keyword != null && filter.keyword!.trim().isNotEmpty) {
        final kw = filter.keyword!.trim().toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(kw);
        final matchNotes = item.notes?.toLowerCase().contains(kw) ?? false;
        if (!matchTitle && !matchNotes) return false;
      }

      // 2. Amount range
      final price = item.actualPrice ?? item.estimatedPrice;
      if (filter.minAmount != null && price < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && price > filter.maxAmount!) {
        return false;
      }

      // 3. Category
      if (filter.category != null && item.categoryId != filter.category!.id) {
        return false;
      }

      // 4. Priority
      if (filter.priority != null && item.priority != filter.priority) {
        return false;
      }

      // 5. Wallet
      if (filter.walletId != null && item.walletId != filter.walletId) {
        return false;
      }

      // 6. Date Range
      final date = item.purchasedAt ?? item.createdAt;
      if (filter.dateStart != null) {
        final start = DateTime(
          filter.dateStart!.year,
          filter.dateStart!.month,
          filter.dateStart!.day,
        );
        if (date.isBefore(start)) return false;
      }
      if (filter.dateEnd != null) {
        final end = DateTime(
          filter.dateEnd!.year,
          filter.dateEnd!.month,
          filter.dateEnd!.day,
          23,
          59,
          59,
        );
        if (date.isAfter(end)) return false;
      }

      return true;
    }).toList();
  });
});

class PlannedPurchasesBudgetSummary {
  final double totalEstimatedBudget;
  final double remainingPlannedBudget;
  final int totalCount;
  final int remainingCount;
  final int completedCount;
  final double totalWalletsBalance;

  const PlannedPurchasesBudgetSummary({
    required this.totalEstimatedBudget,
    required this.remainingPlannedBudget,
    required this.totalCount,
    required this.remainingCount,
    required this.completedCount,
    required this.totalWalletsBalance,
  });
}

final plannedPurchasesBudgetSummaryProvider =
    Provider<PlannedPurchasesBudgetSummary>((ref) {
  final activeAsync = ref.watch(activePlannedPurchasesProvider);
  final historyAsync = ref.watch(purchasedHistoryProvider);
  final walletsAsync = ref.watch(allWalletsStreamProvider);

  final activeList = activeAsync.asData?.value ?? [];
  final historyList = historyAsync.asData?.value ?? [];
  final walletsList = walletsAsync.asData?.value ?? [];

  final double totalWalletsBalance =
      walletsList.fold<double>(0.0, (sum, w) => sum + w.balance);

  final double remainingPlannedBudget =
      activeList.fold<double>(0.0, (sum, item) => sum + item.estimatedPrice);

  final double completedPurchasedBudget = historyList.fold<double>(
    0.0,
    (sum, item) => sum + (item.actualPrice ?? item.estimatedPrice),
  );

  final double totalEstimatedBudget =
      remainingPlannedBudget + completedPurchasedBudget;

  final int remainingCount = activeList.length;
  final int completedCount = historyList.length;
  final int totalCount = remainingCount + completedCount;

  return PlannedPurchasesBudgetSummary(
    totalEstimatedBudget: totalEstimatedBudget,
    remainingPlannedBudget: remainingPlannedBudget,
    totalCount: totalCount,
    remainingCount: remainingCount,
    completedCount: completedCount,
    totalWalletsBalance: totalWalletsBalance,
  );
});
