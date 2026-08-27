import 'package:flutter/material.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_status.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsStatusBadge extends StatelessWidget {
  final KhumsPaymentStatus status;

  const KhumsStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Color bg;
    Color fg;
    String label;

    switch (status) {
      case KhumsPaymentStatus.paid:
        bg = AppColors.greenAlpha10;
        fg = AppColors.green700;
        label = '✓ ${l10n.khumsPaid}';
        break;
      case KhumsPaymentStatus.partiallyPaid:
        bg = AppColors.tertiaryAlpha10;
        fg = AppColors.tertiary700;
        label = '○ ${l10n.khumsPartiallyPaid}';
        break;
      case KhumsPaymentStatus.notPaid:
        bg = AppColors.red50;
        fg = AppColors.red700;
        label = '✕ ${l10n.khumsNotPaid}';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.body4.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
