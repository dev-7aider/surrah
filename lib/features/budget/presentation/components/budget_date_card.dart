import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/custom_icon_button.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/date_time_extension.dart';
import 'package:pockaw/core/extensions/text_style_extensions.dart';
import 'package:pockaw/features/budget/data/model/budget_model.dart';

import 'package:pockaw/l10n/app_localizations.dart';

class BudgetDateCard extends StatelessWidget {
  final BudgetModel budget;
  const BudgetDateCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing8),
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        border: Border.all(color: context.secondaryBorderLighter),
        borderRadius: BorderRadius.circular(AppRadius.radius8),
      ),
      child: Row(
        spacing: AppSpacing.spacing2,
        children: [
          CustomIconButton(
            context,
            onPressed: () {},
            icon: HugeIcons.strokeRoundedCalendar01,
            backgroundColor: context.purpleBackground,
            borderColor: context.purpleBorder,
            color: context.purpleIcon,
          ),
          const Gap(AppSpacing.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.budgetPeriod,
                  style: AppTextStyles.body5.copyWith(color: context.purpleText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${budget.startDate.toDayShortMonth(locale)} - ${budget.endDate.toDayShortMonthYear(locale)}',
                  style: AppTextStyles.body5.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
