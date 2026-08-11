import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pockaw/core/components/bottom_sheets/alert_bottom_sheet.dart';
import 'package:pockaw/core/components/bottom_sheets/custom_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/form_fields/custom_numeric_field.dart';
import 'package:pockaw/core/components/form_fields/custom_text_field.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/features/transaction/data/model/transaction_filter_model.dart';
import 'package:pockaw/features/transaction/presentation/components/filter_form/transaction_filter_category_selector.dart';
import 'package:pockaw/features/transaction/presentation/components/filter_form/transaction_filter_type_selector.dart';
import 'package:pockaw/features/transaction/presentation/components/filter_form/transaction_filter_date_picker.dart';
import 'package:pockaw/features/transaction/presentation/riverpod/transaction_filter_form_state.dart';
import 'package:pockaw/features/transaction/presentation/riverpod/transaction_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class TransactionFilterFormDialog extends HookConsumerWidget {
  final TransactionFilter? initialFilter;
  const TransactionFilterFormDialog({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = useTransactionFilterFormState(
      ref: ref,
      initialFilter: initialFilter ?? ref.watch(transactionFilterProvider),
    );
    final l10n = AppLocalizations.of(context);

    return CustomBottomSheet(
      title: l10n.filterTransactions,
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.spacing16,
          children: [
            TransactionFilterTypeSelector(
              selectedType: formState.selectedTransactionType.value,
              onTypeSelected: formState.onTypeSelected,
            ),
            CustomTextField(
              context: context,
              controller: formState.keywordController,
              hint: '...',
              label: l10n.search,
            ),
            TransactionFilterCategorySelector(
              controller:
                  formState.categoryController, // For displaying the text
              onCategorySelected: (category) {
                formState.selectedCategory.value = category;
                formState.categoryController.text = formState.getCategoryText(context);
              },
            ),
            TransactionFilterDatePicker(
              controller: formState.dateFieldController,
            ),
            Row(
              spacing: AppSpacing.spacing8,
              children: [
                Expanded(
                  child: CustomNumericField(
                    label: l10n.minAmount,
                    hint: '100,000',
                    appendCurrencySymbolToHint: true,
                    controller: formState.minAmountController,
                  ),
                ),
                Expanded(
                  child: CustomNumericField(
                    label: l10n.maxAmount,
                    hint: '2,500,000',
                    appendCurrencySymbolToHint: true,
                    controller: formState.maxAmountController,
                  ),
                ),
              ],
            ),
            PrimaryButton(
              label: l10n.applyFilters,
              onPressed: () => formState.applyFilter(ref, context),
            ),
            TextButton(
              child: Text(
                l10n.resetFilters,
                style: AppTextStyles.body2.copyWith(color: AppColors.red),
              ),
              onPressed: () {
                context.openBottomSheet(
                  child: AlertBottomSheet(
                    title: l10n.resetFilters,
                    content: Text(
                      l10n.actionCannotBeUndone,
                      style: AppTextStyles.body2,
                    ),
                    onConfirm: () {
                      formState.reset(ref);
                      ref.read(transactionFilterProvider.notifier).clear();
                      context.pop();
                      context.pop();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
