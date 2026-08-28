import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedPurchasesHistorySummaryCard extends ConsumerWidget {
  final List<PlannedPurchaseModel> items;

  const PlannedPurchasesHistorySummaryCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final double totalPaid = items.fold(
      0.0,
      (sum, item) => sum + (item.actualPrice ?? item.estimatedPrice),
    );

    final double totalEstimated = items.fold(
      0.0,
      (sum, item) => sum + item.estimatedPrice,
    );

    final double difference = totalEstimated - totalPaid;
    final isSaved = difference >= 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        border: Border.all(color: context.secondaryBorderLighter),
        borderRadius: BorderRadius.circular(AppRadius.radius16),
      ),
      child: Column(
        children: [
          // Total Paid Amount Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalPurchasedAmount,
                    style: AppTextStyles.body4.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                  const Gap(AppSpacing.spacing4),
                  Text(
                    '${totalPaid.toPriceFormat()} IQD',
                    style: AppTextStyles.heading5.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.primary50.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppRadius.radius12),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing12),
          Divider(
            color: context.secondaryBorderLighter,
            height: 1,
          ),
          const Gap(AppSpacing.spacing12),

          // Secondary Details: Total count & estimated vs actual difference
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingBag01,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const Gap(AppSpacing.spacing4),
                  Text(
                    l10n.purchasedItemsCount(items.length),
                    style: AppTextStyles.body4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (totalEstimated > 0)
                Row(
                  children: [
                    Text(
                      isSaved ? 'وفرت: ' : 'فارق التقدير: ',
                      style: AppTextStyles.body4.copyWith(
                        color: context.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${difference.abs().toPriceFormat()} IQD',
                      style: AppTextStyles.body4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSaved ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
