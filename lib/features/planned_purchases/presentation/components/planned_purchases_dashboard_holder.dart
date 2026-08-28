import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/khums/presentation/components/khums_segmented_progress_chart.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/add_planned_item_bottom_sheet.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/confirm_purchase_bottom_sheet.dart';
import 'package:pockaw/features/planned_purchases/presentation/components/planned_purchase_item_tile.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedPurchasesDashboardHolder extends ConsumerWidget {
  const PlannedPurchasesDashboardHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(plannedPurchasesBudgetSummaryProvider);
    final activeItemsAsync = ref.watch(activePlannedPurchasesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Section Header: Title & "See All"
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.plannedPurchases, style: AppTextStyles.heading6),
                InkWell(
                  onTap: () => context.push(Routes.plannedPurchases),
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
          ),
          const Gap(AppSpacing.spacing12),

          // 2. Beautiful Statistics & Chart Card (Top Card)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.spacing16),
              decoration: BoxDecoration(
                color: context.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.radius16),
                border: Border.all(color: context.secondaryBorderLighter),
              ),
              child: Row(
                children: [
                  // Circular Segmented Progress Chart
                  KhumsSegmentedProgressChart(
                    totalSegments:
                        summary.totalCount > 0 ? summary.totalCount : 1,
                    completedSegments: summary.completedCount,
                    size: 64,
                    strokeWidth: 6.0,
                    activeColor: AppColors.primary,
                    inactiveColor: context.secondaryBorderLighter,
                    showPercentage: true,
                  ),
                  const Gap(AppSpacing.spacing16),

                  // Stats Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.totalPlannedBudget,
                              style: AppTextStyles.body4.copyWith(
                                color: context.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacing8,
                                vertical: AppSpacing.spacing2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary50.withAlpha(50),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.radius8),
                              ),
                              child: Text(
                                '${summary.completedCount}/${summary.totalCount}',
                                style: AppTextStyles.body4.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.spacing4),
                        Text(
                          summary.remainingPlannedBudget > 0
                              ? '${summary.remainingPlannedBudget.toPriceFormat()} IQD'
                              : '0 IQD',
                          style: AppTextStyles.heading5.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Gap(AppSpacing.spacing4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              summary.remainingCount > 0
                                  ? l10n.pendingItemsCount(
                                      summary.remainingCount,
                                    )
                                  : l10n.planYourPurchases,
                              style: AppTextStyles.body4.copyWith(
                                color: context.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                            if (summary.completedCount > 0) ...[
                              const Gap(AppSpacing.spacing8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: context.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                              const Gap(AppSpacing.spacing8),
                              Text(
                                l10n.completedCountLabel(
                                  summary.completedCount,
                                ),
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.spacing12),

          // 3. Top Planned Items List & Bottom Add Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
            child: activeItemsAsync.when(
              data: (items) {
                // Sort items by priority: urgentNeed first, then nonUrgent, then desire
                final sortedItems = List<PlannedPurchaseModel>.from(items)
                  ..sort((a, b) =>
                      a.priority.index.compareTo(b.priority.index));

                // Take top 3 important/urgent needs
                final topItems = sortedItems.take(3).toList();

                return Column(
                  children: [
                    if (topItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.spacing16),
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.spacing8),
                        decoration: BoxDecoration(
                          color: context.secondaryBackground,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                          border: Border.all(
                            color: context.secondaryBorderLighter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l10n.noActivePurchases,
                            style: AppTextStyles.body4.copyWith(
                              color: context.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...topItems.map((item) {
                        return PlannedPurchaseItemTile(
                          item: item,
                          onTogglePurchased: () {
                            context.openBottomSheet(
                              child: ConfirmPurchaseBottomSheet(item: item),
                            );
                          },
                          onEdit: () {
                            context.openBottomSheet(
                              child: AddPlannedItemBottomSheet(
                                existingItem: item,
                              ),
                            );
                          },
                          onDelete: () {
                            ref
                                .read(plannedPurchaseDaoProvider)
                                .deletePlannedPurchase(item.id);
                          },
                        );
                      }),

                    // Bottom Add New Planned Item Button
                    InkWell(
                      onTap: () {
                        context.openBottomSheet(
                          child: const AddPlannedItemBottomSheet(),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spacing12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                          border: Border.all(
                            color: context.secondaryBorderLighter,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedPlusSign,
                              color: AppColors.primary50,
                              size: 16,
                            ),
                            const Gap(AppSpacing.spacing8),
                            Text(
                              l10n.quickAddNewPlannedItem,
                              style: AppTextStyles.body3.copyWith(
                                color: AppColors.primary50,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.spacing16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
