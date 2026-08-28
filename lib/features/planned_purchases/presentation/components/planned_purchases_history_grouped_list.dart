import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/date_time_extension.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedPurchasesHistoryGroupedList extends StatelessWidget {
  final List<PlannedPurchaseModel> items;
  final Function(PlannedPurchaseModel)? onUnmark;
  final Function(PlannedPurchaseModel)? onTap;

  const PlannedPurchasesHistoryGroupedList({
    super.key,
    required this.items,
    this.onUnmark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.primary50.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const Gap(AppSpacing.spacing16),
              Text(
                l10n.noPurchasedItemsFound,
                style: AppTextStyles.body2.copyWith(
                  color: context.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group items by purchased date (or creation date)
    final Map<DateTime, List<PlannedPurchaseModel>> groupedByDate = {};
    for (final item in items) {
      final date = item.purchasedAt ?? item.createdAt;
      final dateKey = DateTime(date.year, date.month, date.day);
      groupedByDate.putIfAbsent(dateKey, () => []).add(item);
    }

    final sortedDateKeys = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing16,
        0,
        AppSpacing.spacing16,
        AppSpacing.spacing48,
      ),
      itemCount: sortedDateKeys.length,
      separatorBuilder: (_, _) => const Gap(AppSpacing.spacing16),
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final dayItems = groupedByDate[dateKey]!;

        final double dayTotal = dayItems.fold(
          0.0,
          (sum, item) => sum + (item.actualPrice ?? item.estimatedPrice),
        );

        final String displayDate = dateKey.toRelativeDayFormatted();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.spacing12),
          decoration: BoxDecoration(
            color: context.secondaryBackground,
            border: Border.all(color: context.secondaryBorderLighter),
            borderRadius: BorderRadius.circular(AppRadius.radius16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Date & Daily Subtotal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayDate,
                    style: AppTextStyles.body3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '- ${dayTotal.toPriceFormat()} IQD',
                    style: AppTextStyles.numericMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.spacing8),
              Divider(
                color: context.secondaryBorderLighter,
                height: 1,
              ),
              const Gap(AppSpacing.spacing8),

              // Items for this day
              ...dayItems.map((item) {
                final price = item.actualPrice ?? item.estimatedPrice;
                final timeStr = item.purchasedAt != null
                    ? DateFormat('hh:mm a').format(item.purchasedAt!)
                    : '';

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spacing4,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.spacing8),
                  decoration: BoxDecoration(
                    color: context.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    border: Border.all(
                      color: context.secondaryBorderLighter.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Revert / Unmark Checkbox
                      InkWell(
                        onTap: onUnmark != null ? () => onUnmark!(item) : null,
                        borderRadius: BorderRadius.circular(AppRadius.radius4),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius4),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.spacing8),

                      // Priority Dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.priority.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(AppSpacing.spacing8),

                      // Title & Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.body3.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                if (item.category?.title != null) ...[
                                  Text(
                                    item.category!.title,
                                    style: AppTextStyles.body4.copyWith(
                                      color: context.secondaryText,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (timeStr.isNotEmpty) const Gap(AppSpacing.spacing4),
                                ],
                                if (timeStr.isNotEmpty)
                                  Text(
                                    '• $timeStr',
                                    style: AppTextStyles.body4.copyWith(
                                      color: context.secondaryText,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(AppSpacing.spacing8),

                      // Paid Price
                      Text(
                        '${price.toPriceFormat()} ${item.currency}',
                        style: AppTextStyles.numericHeading.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
