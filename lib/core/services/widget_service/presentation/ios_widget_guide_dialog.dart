import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class IosWidgetGuideDialog extends StatelessWidget {
  final VoidCallback? onDismiss;

  const IosWidgetGuideDialog({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;

    final steps = [
      (
        icon: HugeIcons.strokeRoundedTouch01,
        stepNum: '1',
        title: l10n.iosStep1,
      ),
      (
        icon: HugeIcons.strokeRoundedAddCircle,
        stepNum: '2',
        title: l10n.iosStep2,
      ),
      (
        icon: HugeIcons.strokeRoundedLayers01,
        stepNum: '3',
        title: l10n.iosStep3,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing20,
        vertical: AppSpacing.spacing16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.howToAddWidgetTitle,
                style: AppTextStyles.heading5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
                icon: const Icon(Icons.close_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.neutralAlpha25
                      : AppColors.neutral100,
                  foregroundColor: isDark
                      ? AppColors.neutral100
                      : AppColors.neutral800,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing20),
          ...steps.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.spacing12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGrey : AppColors.neutral100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkGreyBorder
                      : AppColors.neutral200,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryAlpha25,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s.stepNum,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.primary400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.spacing12),
                  Expanded(
                    child: Text(
                      s.title,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.spacing8),
                  HugeIcon(
                    icon: s.icon,
                    size: 20,
                    color: AppColors.primary400,
                  ),
                ],
              ),
            );
          }),
          const Gap(AppSpacing.spacing16),
          PrimaryButton(
            label: l10n.gotIt,
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
          ),
          const Gap(AppSpacing.spacing12),
        ],
      ),
    );
  }
}
