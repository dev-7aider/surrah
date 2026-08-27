import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/bottom_sheets/custom_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/chips/custom_chip.dart';
import 'package:pockaw/core/components/form_fields/custom_numeric_field.dart';
import 'package:pockaw/core/components/form_fields/custom_text_field.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/database/pockaw_database.dart';
import 'package:pockaw/features/khums/data/model/khums_money_source_model.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class AddMoneySourceBottomSheet extends ConsumerStatefulWidget {
  final int khumsYearId;
  final KhumsMoneySourceModel? existingSource;

  const AddMoneySourceBottomSheet({
    super.key,
    required this.khumsYearId,
    this.existingSource,
  });

  @override
  ConsumerState<AddMoneySourceBottomSheet> createState() =>
      _AddMoneySourceBottomSheetState();
}

class _AddMoneySourceBottomSheetState
    extends ConsumerState<AddMoneySourceBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingSource?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existingSource != null
          ? widget.existingSource!.amount.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (name.isEmpty || amount <= 0) return;

    setState(() => _isLoading = true);
    final dao = ref.read(khumsDaoProvider);

    if (widget.existingSource != null) {
      final companion = KhumsMoneySourcesCompanion(
        id: drift.Value(widget.existingSource!.id),
        khumsYearId: drift.Value(widget.khumsYearId),
        name: drift.Value(name),
        amount: drift.Value(amount),
        updatedAt: drift.Value(DateTime.now()),
      );
      await dao.updateMoneySource(companion);
    } else {
      final companion = KhumsMoneySourcesCompanion(
        khumsYearId: drift.Value(widget.khumsYearId),
        name: drift.Value(name),
        amount: drift.Value(amount),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      );
      await dao.insertMoneySource(companion);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existingSource != null;

    final quickSuggestions = [
      l10n.khumsWallet,
      l10n.khumsBank,
      l10n.khumsCashBox,
      l10n.khumsSavings,
      l10n.khumsOther,
    ];

    return CustomBottomSheet(
      title: isEditing ? l10n.khumsEditMoney : l10n.khumsAddMoney,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.spacing8,
            runSpacing: AppSpacing.spacing8,
            children: quickSuggestions.map((suggestion) {
              final isSelected = _nameController.text == suggestion;
              return CustomChip(
                label: suggestion,
                background: isSelected ? AppColors.primary : AppColors.primary50,
                foreground: isSelected ? Colors.white : AppColors.primary,
                onTap: () {
                  setState(() => _nameController.text = suggestion);
                },
              );
            }).toList(),
          ),
          const Gap(AppSpacing.spacing16),
          CustomTextField(
            context: context,
            controller: _nameController,
            label: l10n.khumsSourceName,
            hint: l10n.khumsWallet,
            prefixIcon: HugeIcons.strokeRoundedFolder01,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing12,
              vertical: AppSpacing.spacing12,
            ),
          ),
          const Gap(AppSpacing.spacing12),
          CustomNumericField(
            controller: _amountController,
            label: l10n.amount,
            hint: '500,000',
            icon: HugeIcons.strokeRoundedMoney03,
            appendCurrencySymbolToHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing12,
              vertical: AppSpacing.spacing12,
            ),
          ),
          const Gap(AppSpacing.spacing24),
          PrimaryButton(
            label: l10n.save,
            isLoading: _isLoading,
            borderRadius: BorderRadius.circular(AppRadius.radius8),
            padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing16,
      ),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
