import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/dialogs/toast.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/add_planned_item_bottom_sheet.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/confirm_purchase_bottom_sheet.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/planned_budget_header_card.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/planned_purchase_item_tile.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/priority_matrix_card.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/purchased_history_tile.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/features/user_activity/data/enum/user_activity_action.dart';
import 'package:pockaw/features/user_activity/riverpod/user_activity_provider.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';

class PlannedPurchasesScreen extends ConsumerStatefulWidget {
  const PlannedPurchasesScreen({super.key});

  @override
  ConsumerState<PlannedPurchasesScreen> createState() =>
      _PlannedPurchasesScreenState();
}

class _PlannedPurchasesScreenState
    extends ConsumerState<PlannedPurchasesScreen> {
  void _openAddItemModal([PlannedPurchaseModel? existingItem]) {
    context.openBottomSheet(
      child: AddPlannedItemBottomSheet(existingItem: existingItem),
    );
  }

  void _openConfirmPurchaseModal(PlannedPurchaseModel item) {
    context.openBottomSheet(
      child: ConfirmPurchaseBottomSheet(item: item),
    ).then((completed) {
      if (completed == true && mounted) {
        final l10n = AppLocalizations.of(context);
        Toast.show(
          l10n.purchaseSuccessDeducted,
          type: ToastificationType.success,
        );
      }
    });
  }

  Future<void> _unmarkItem(PlannedPurchaseModel item) async {
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

  void _deleteItem(PlannedPurchaseModel item) {
    ref.read(plannedPurchaseDaoProvider).deletePlannedPurchase(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(plannedPurchasesBudgetSummaryProvider);
    final activeItemsAsync = ref.watch(activePlannedPurchasesProvider);
    final historyItemsAsync = ref.watch(purchasedHistoryProvider);

    return CustomScaffold(
      title: l10n.smartShoppingAndFuturePurchases,
      showBackButton: true,
      // actions: [
      //   CustomIconButton(
      //     context,
      //     onPressed: () {
      //       // Can scroll to history or toggle view
      //     },
      //     icon: HugeIcons.strokeRoundedClock01,
      //     themeMode: context.themeMode,
      //   ),
      // ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Total Planned Budget Header Card
            PlannedBudgetHeaderCard(summary: summary),
            const Gap(AppSpacing.spacing16),

            // 2. Active Purchases (To Buy) Header
            Text(
              l10n.activePurchasesToBuy,
              style: AppTextStyles.heading6,
            ),
            const Gap(AppSpacing.spacing8),

            // Active Purchases List
            activeItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.spacing16),
                    decoration: BoxDecoration(
                      color: context.secondaryBackground,
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                      border: Border.all(color: context.secondaryBorderLighter),
                    ),
                    child: Center(
                      child: Text(
                        l10n.noActivePurchases,
                        style: AppTextStyles.body3.copyWith(
                          color: context.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: items.map((item) {
                    return PlannedPurchaseItemTile(
                      item: item,
                      onTogglePurchased: () => _openConfirmPurchaseModal(item),
                      onEdit: () => _openAddItemModal(item),
                      onDelete: () => _deleteItem(item),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.spacing16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => Text('Error: $e'),
            ),
            const Gap(AppSpacing.spacing16),

            // 4. Quick Add New Planned Item Button
            PrimaryButton(
              label: l10n.quickAddNewPlannedItem,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              borderRadius: BorderRadius.circular(AppRadius.radius8),
              onPressed: () => _openAddItemModal(),
            ),
            const Gap(AppSpacing.spacing24),

            // 5. Purchased History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.purchasedHistory,
                  style: AppTextStyles.heading6,
                ),
                InkWell(
                  onTap: () => context.push(Routes.plannedPurchasesHistory),
                  borderRadius: BorderRadius.circular(AppRadius.radius4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing4,
                      vertical: AppSpacing.spacing4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.seeAll,
                          style: AppTextStyles.body4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const Gap(AppSpacing.spacing4),
                        HugeIcon(
                          icon: Directionality.of(context) == TextDirection.rtl
                              ? HugeIcons.strokeRoundedArrowLeft01
                              : HugeIcons.strokeRoundedArrowRight01,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.spacing8),

            // Purchased History List
            historyItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.spacing16),
                    decoration: BoxDecoration(
                      color: context.secondaryBackground,
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                      border: Border.all(color: context.secondaryBorderLighter),
                    ),
                    child: Center(
                      child: Text(
                        l10n.noPurchasedHistory,
                        style: AppTextStyles.body3.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: items.take(4).map((item) {
                    return PurchasedHistoryTile(
                      item: item,
                      onUnmark: () => _unmarkItem(item),
                      onTap: () => context.push(Routes.plannedPurchasesHistory),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.spacing16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => Text('Error: $e'),
            ),
            const Gap(AppSpacing.spacing20),

            // 6. Priority Matrix Card (Refined & Placed at bottom)
            const PriorityMatrixCard(),
            const Gap(AppSpacing.spacing20),
          ],
        ),
      ),
    );
  }
}
