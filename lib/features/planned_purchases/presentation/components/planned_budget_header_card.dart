import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedBudgetHeaderCard extends StatelessWidget {
  final PlannedPurchasesBudgetSummary summary;
  final String currency;

  const PlannedBudgetHeaderCard({
    super.key,
    required this.summary,
    this.currency = 'IQD',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Calculate progress ratio (completed items / total items)
    final double progress = summary.totalCount > 0
        ? (summary.completedCount / summary.totalCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        border: Border.all(color: context.secondaryBorderLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalPlannedBudget,
                style: AppTextStyles.body3.copyWith(
                  color: context.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing8,
                  vertical: AppSpacing.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary50.withAlpha(80),
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                ),
                child: Text(
                  l10n.statusTracking,
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing8),

          // Row 2: Total Planned Budget Big Highlighted Text
          Text(
            '${summary.totalEstimatedBudget.toPriceFormat()} $currency',
            style: AppTextStyles.numericHeading.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Gap(AppSpacing.spacing12),

          // Row 3: Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            child: Container(
              height: 6,
              width: double.infinity,
              color: context.secondaryBorderLighter,
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: progress > 0 ? progress : 0.05,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.spacing8),

          // Row 4: Total/Remaining stats & Remaining Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalItemsRemaining(summary.totalCount, summary.remainingCount),
                style: AppTextStyles.body4.copyWith(
                  color: context.secondaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                l10n.remainingBalance(summary.remainingPlannedBudget.toPriceFormat()),
                style: AppTextStyles.body4.copyWith(
                  color: context.secondaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
