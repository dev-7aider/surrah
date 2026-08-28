import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';

class PlannedPurchaseItemTile extends ConsumerWidget {
  final PlannedPurchaseModel item;
  final VoidCallback onTogglePurchased;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlannedPurchaseItemTile({
    super.key,
    required this.item,
    required this.onTogglePurchased,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing8),
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: context.secondaryBorderLighter),
      ),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F),
            borderRadius: BorderRadius.circular(AppRadius.radius12),
          ),
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedDelete02,
            color: Colors.white,
            size: 20,
          ),
        ),
        onDismissed: (_) => onDelete(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing12,
            vertical: AppSpacing.spacing8,
          ),
          child: Row(
            children: [
              // Custom Checkbox
              InkWell(
                onTap: onTogglePurchased,
                borderRadius: BorderRadius.circular(AppRadius.radius4),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.isPurchased
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.radius4),
                    border: Border.all(
                      color: item.isPurchased
                          ? AppColors.primary
                          : context.secondaryBorder,
                      width: 1.5,
                    ),
                  ),
                  child: item.isPurchased
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const Gap(AppSpacing.spacing8),

              // Wallet / Category Icon box
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacing4),
                decoration: BoxDecoration(
                  color: AppColors.primary50.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppRadius.radius4),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedWallet02,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const Gap(AppSpacing.spacing8),

              // Priority Indicator Dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.priority.color,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(AppSpacing.spacing8),

              // Title and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.body3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.category?.title != null)
                      Text(
                        item.category!.title,
                        style: AppTextStyles.body4.copyWith(
                          color: context.secondaryText,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Gap(AppSpacing.spacing8),

              // Price with currency
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.estimatedPrice.toPriceFormat(),
                    style: AppTextStyles.numericHeading.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.spacing4),
                  Text(
                    item.currency,
                    style: AppTextStyles.body4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD32F2F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.spacing4),

              // More Options Menu / Popup
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: context.secondaryText,
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedEdit02,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        Gap(8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          size: 16,
                          color: Color(0xFFD32F2F),
                        ),
                        Gap(8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
