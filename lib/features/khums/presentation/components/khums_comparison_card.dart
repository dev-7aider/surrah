import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsComparisonCard extends StatelessWidget {
  final KhumsComparisonData comparison;

  const KhumsComparisonCard({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    if (!comparison.hasPrevious) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isIncrease = comparison.difference > 0;
    final isDecrease = comparison.difference < 0;

    Color diffColor = context.secondaryText;
    IconData diffIcon = Icons.remove;
    if (isIncrease) {
      diffColor = AppColors.green700;
      diffIcon = Icons.arrow_upward;
    } else if (isDecrease) {
      diffColor = AppColors.red700;
      diffIcon = Icons.arrow_downward;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing12),
      padding: const EdgeInsets.all(AppSpacing.spacing12),
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: context.secondaryBorderLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedAnalytics01,
                color: AppColors.primary,
                size: 18,
              ),
              const Gap(AppSpacing.spacing8),
              Text(
                l10n.khumsYearlyComparison,
                style: AppTextStyles.body3.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.khumsPreviousYear,
                      style: AppTextStyles.body4.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                    const Gap(AppSpacing.spacing4),
                    Text(
                      comparison.previousAmount.toPriceFormat(),
                      style: AppTextStyles.numericHeading.copyWith(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.khumsDifference,
                      style: AppTextStyles.body4.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                    const Gap(AppSpacing.spacing4),
                    Row(
                      children: [
                        Icon(diffIcon, size: 14, color: diffColor),
                        const Gap(AppSpacing.spacing2),
                        Text(
                          comparison.difference.abs().toPriceFormat(),
                          style: AppTextStyles.numericHeading.copyWith(
                            fontSize: 15,
                            color: diffColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comparison.percentageChange.abs() > 0.01) ...[
            const Gap(AppSpacing.spacing8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing8,
                vertical: AppSpacing.spacing4,
              ),
              decoration: BoxDecoration(
                color: diffColor.withAlpha(25),
                borderRadius: BorderRadius.circular(AppRadius.radius8),
              ),
              child: Text(
                '${comparison.percentageChange.toStringAsFixed(1)}%',
                style: AppTextStyles.body4.copyWith(
                  color: diffColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
