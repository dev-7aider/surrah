import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/bottom_sheets/alert_bottom_sheet.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/features/khums/data/model/khums_money_source_model.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsMoneySourceTile extends StatelessWidget {
  final KhumsMoneySourceModel source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KhumsMoneySourceTile({
    super.key,
    required this.source,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing8,
      ),
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
              icon: HugeIcons.strokeRoundedWallet02,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const Gap(AppSpacing.spacing12),
          Expanded(
            child: Text(
              source.name,
              style: AppTextStyles.body3.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(AppSpacing.spacing8),
          Text(
            source.amount.toPriceFormat(),
            style: AppTextStyles.numericHeading.copyWith(fontSize: 15),
          ),
          const Gap(AppSpacing.spacing4),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 18,
              color: context.secondaryText,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius12),
            ),
            onSelected: (val) {
              if (val == 'edit') {
                onEdit();
              } else if (val == 'delete') {
                context.openBottomSheet(
                  child: AlertBottomSheet(
                    title: l10n.confirmDelete,
                    content: Text(
                      source.name,
                      style: AppTextStyles.body3,
                    ),
                    onConfirm: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02,
                      size: 16,
                    ),
                    const Gap(AppSpacing.spacing8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? 'تعديل'
                          : 'Edit',
                      style: AppTextStyles.body3,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete02,
                      size: 16,
                      color: AppColors.red700,
                    ),
                    const Gap(AppSpacing.spacing8),
                    Text(
                      l10n.delete,
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.red700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
