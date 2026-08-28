import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PriorityMatrixCard extends StatelessWidget {
  const PriorityMatrixCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      _MatrixItem(
        color: const Color(0xFFD32F2F),
        label: l10n.urgentAndImportantNeed.replaceAll('\n', ' '),
      ),
      _MatrixItem(
        color: const Color(0xFFFBC02D),
        label: l10n.nonUrgentImportant.replaceAll('\n', ' '),
      ),
      _MatrixItem(
        color: const Color(0xFF4CAF50),
        label: l10n.desireWant.replaceAll('\n', ' '),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      ),
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        border: Border.all(color: context.secondaryBorderLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.priorityMatrix,
                style: AppTextStyles.body3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.needVsWant,
                style: AppTextStyles.body4.copyWith(
                  color: context.secondaryText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing12),
          Row(
            children: items.map((item) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spacing8,
                    horizontal: AppSpacing.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppRadius.radius8),
                    border: Border.all(
                      color: item.color.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(AppSpacing.spacing4),
                      Flexible(
                        child: Text(
                          item.label,
                          style: AppTextStyles.body4.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MatrixItem {
  final Color color;
  final String label;

  const _MatrixItem({
    required this.color,
    required this.label,
  });
}
