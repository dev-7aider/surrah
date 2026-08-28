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
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedPurchasesDashboardHolder extends ConsumerWidget {
  const PlannedPurchasesDashboardHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(plannedPurchasesBudgetSummaryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      horizontal: AppSpacing.spacing8,
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
          const Gap(AppSpacing.spacing8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
            child: InkWell(
              onTap: () => context.push(Routes.plannedPurchases),
              borderRadius: BorderRadius.circular(AppRadius.radius12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.spacing12),
                decoration: BoxDecoration(
                  color: context.secondaryBackground,
                  borderRadius: BorderRadius.circular(AppRadius.radius12),
                  border: Border.all(color: context.secondaryBorderLighter),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.spacing8),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedShoppingBag01,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const Gap(AppSpacing.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.smartShoppingAndFuturePurchases,
                            style: AppTextStyles.body3.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(AppSpacing.spacing2),
                          Text(
                            summary.remainingCount > 0
                                ? '${summary.remainingCount} items pending (${summary.remainingPlannedBudget.toPriceFormat()} IQD)'
                                : 'Plan and track your next purchases',
                            style: AppTextStyles.body4.copyWith(
                              color: context.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
