import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PurchasedHistoryTile extends StatelessWidget {
  final PlannedPurchaseModel item;
  final VoidCallback? onTap;
  final VoidCallback? onUnmark;

  const PurchasedHistoryTile({
    super.key,
    required this.item,
    this.onTap,
    this.onUnmark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateStr = item.purchasedAt != null
        ? DateFormat('dd/MM/yyyy').format(item.purchasedAt!)
        : 'Date';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing8,
      ),
      decoration: BoxDecoration(
        color: context.secondaryBackground.withAlpha(160),
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: context.secondaryBorderLighter),
      ),
      child: Row(
        children: [
          // Disabled/Checked Square Box
          InkWell(
            onTap: onUnmark,
            borderRadius: BorderRadius.circular(AppRadius.radius4),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.grey.shade400.withAlpha(100),
                borderRadius: BorderRadius.circular(AppRadius.radius4),
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const Gap(AppSpacing.spacing12),

          // Title & Last Purchased Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.body3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(AppSpacing.spacing2),
                Text(
                  l10n.lastPurchasedDate(dateStr),
                  style: AppTextStyles.body4.copyWith(
                    color: context.secondaryText.withAlpha(150),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Price & Arrow
          Text(
            (item.actualPrice ?? item.estimatedPrice).toPriceFormat(),
            style: AppTextStyles.numericHeading.copyWith(
              fontSize: 13,
              color: context.secondaryText,
            ),
          ),
          const Gap(AppSpacing.spacing8),
          HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            size: 16,
            color: context.secondaryText.withAlpha(150),
          ),
        ],
      ),
    );
  }
}
