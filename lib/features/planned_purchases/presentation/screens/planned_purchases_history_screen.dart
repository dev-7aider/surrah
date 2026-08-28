import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/custom_icon_button.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/planned_purchases_filter_bottom_sheet.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/planned_purchases_history_grouped_list.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/planned_purchases_history_summary_card.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/features/transaction/presentation/components/transaction_tab_bar.dart';
import 'package:pockaw/features/user_activity/data/enum/user_activity_action.dart';
import 'package:pockaw/features/user_activity/riverpod/user_activity_provider.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedPurchasesHistoryScreen extends ConsumerWidget {
  const PlannedPurchasesHistoryScreen({super.key});

  Future<void> _unmarkItem(
    BuildContext context,
    WidgetRef ref,
    PlannedPurchaseModel item,
  ) async {
    final db = ref.read(databaseProvider);

    // If there was a recorded transaction, delete it and refund the wallet
    if (item.transactionId != null) {
      await db.transactionDao.deleteTransaction(item.transactionId!);
      ref.read(userActivityServiceProvider).logActivity(
            action: UserActivityAction.transactionDeleted,
            subjectId: item.transactionId,
          );
    }

    if (item.walletId != null && item.actualPrice != null) {
      final wallet = await db.walletDao.watchWalletById(item.walletId!).first;
      if (wallet != null) {
        final refundedBalance = wallet.balance + item.actualPrice!;
        final updatedWallet = wallet.copyWith(balance: refundedBalance);
        await db.walletDao.updateWallet(updatedWallet);

        final activeWallet = ref.read(activeWalletProvider).asData?.value;
        if (activeWallet?.id == wallet.id) {
          ref.read(activeWalletProvider.notifier).setActiveWallet(updatedWallet);
        }
      }
    }

    await ref.read(plannedPurchaseDaoProvider).unmarkAsPurchased(item.id);
    ref.read(widgetSyncProvider).syncWidgetData();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(filteredPurchasedHistoryProvider);
    final activeFilter = ref.watch(plannedPurchasesFilterProvider);

    return CustomScaffold(
      title: l10n.plannedPurchasesHistory,
      showBackButton: true,
      actions: [
        // Filter Action Button with badge
        CustomIconButton(
          context,
          onPressed: () {
            context.openBottomSheet(
              child: PlannedPurchasesFilterBottomSheet(
                initialFilter: activeFilter,
              ),
            );
          },
          icon: HugeIcons.strokeRoundedFilter,
          showBadge: activeFilter != null && activeFilter.isActive,
          themeMode: context.themeMode,
        ),
      ],
      body: historyAsync.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            return Center(
              child: Text(
                activeFilter != null && activeFilter.isActive
                    ? l10n.noPurchasedItemsFound
                    : l10n.noPurchasedHistory,
              ),
            );
          }

          // 1. Extract unique month-years from purchased items
          final uniqueMonthYears = allItems.map((item) {
            final date = item.purchasedAt ?? item.createdAt;
            return DateTime(date.year, date.month, 1);
          }).toSet().toList();

          // 2. Sort months descending (most recent first)
          uniqueMonthYears.sort((a, b) => b.compareTo(a));

          final now = DateTime.now();
          final currentMonthDate = DateTime(now.year, now.month, 1);
          int initialTabIndex = uniqueMonthYears.indexOf(currentMonthDate);
          if (initialTabIndex == -1) {
            initialTabIndex = 0;
          }

          return DefaultTabController(
            length: uniqueMonthYears.length,
            initialIndex: initialTabIndex,
            child: Column(
              children: [
                // Month Tabs
                TransactionTabBar(
                  monthsForTabs: uniqueMonthYears,
                ),
                const Gap(AppSpacing.spacing16),

                // Month Tab Views
                Expanded(
                  child: TabBarView(
                    children: uniqueMonthYears.map((tabMonthDate) {
                      final monthItems = allItems.where((item) {
                        final date = item.purchasedAt ?? item.createdAt;
                        return date.year == tabMonthDate.year &&
                            date.month == tabMonthDate.month;
                      }).toList();

                      return Column(
                        children: [
                          PlannedPurchasesHistorySummaryCard(
                            items: monthItems,
                          ),
                          const Gap(AppSpacing.spacing16),
                          Expanded(
                            child: PlannedPurchasesHistoryGroupedList(
                              items: monthItems,
                              onUnmark: (item) =>
                                  _unmarkItem(context, ref, item),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
