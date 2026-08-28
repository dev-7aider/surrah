import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockaw/core/database/daos/planned_purchase_dao.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
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
