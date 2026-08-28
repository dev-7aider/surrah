import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:pockaw/core/components/bottom_sheets/alert_bottom_sheet.dart';
import 'package:pockaw/core/components/bottom_sheets/custom_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/button_chip.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/date_picker/custom_date_picker.dart';
import 'package:pockaw/core/components/form_fields/custom_numeric_field.dart';
import 'package:pockaw/core/components/form_fields/custom_select_field.dart';
import 'package:pockaw/core/components/form_fields/custom_text_field.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/extensions/string_extension.dart';
import 'package:pockaw/features/category/data/model/category_model.dart';
import 'package:pockaw/features/category_picker/presentation/screens/category_picker_screen.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchases_filter_model.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class PlannedPurchasesFilterBottomSheet extends ConsumerStatefulWidget {
  final PlannedPurchasesFilterModel? initialFilter;

  const PlannedPurchasesFilterBottomSheet({super.key, this.initialFilter});

  @override
  ConsumerState<PlannedPurchasesFilterBottomSheet> createState() =>
      _PlannedPurchasesFilterBottomSheetState();
}

class _PlannedPurchasesFilterBottomSheetState
    extends ConsumerState<PlannedPurchasesFilterBottomSheet> {
  late TextEditingController _keywordController;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;
  late TextEditingController _dateFieldController;

  PurchasePriority? _selectedPriority;
  CategoryModel? _selectedCategory;
  int? _selectedWalletId;
  DateTime? _dateStart;
  DateTime? _dateEnd;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _keywordController = TextEditingController(text: f?.keyword ?? '');
    _minAmountController = TextEditingController(
      text: f?.minAmount != null ? f!.minAmount!.toStringAsFixed(0) : '',
    );
    _maxAmountController = TextEditingController(
      text: f?.maxAmount != null ? f!.maxAmount!.toStringAsFixed(0) : '',
    );
    _dateFieldController = TextEditingController();

    _selectedPriority = f?.priority;
    _selectedCategory = f?.category;
    _selectedWalletId = f?.walletId;
    _dateStart = f?.dateStart;
    _dateEnd = f?.dateEnd;

    _updateDateText();
  }

  void _updateDateText() {
    if (_dateStart != null && _dateEnd != null) {
      final f = DateFormat('dd/MM/yyyy');
      _dateFieldController.text =
          '${f.format(_dateStart!)} - ${f.format(_dateEnd!)}';
    } else {
      _dateFieldController.text = '';
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _dateFieldController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final filter = PlannedPurchasesFilterModel(
      keyword: _keywordController.text.trim().isNotEmpty
          ? _keywordController.text.trim()
          : null,
      minAmount: _minAmountController.text.trim().isNotEmpty
          ? _minAmountController.text.trim().takeNumericAsDouble()
          : null,
      maxAmount: _maxAmountController.text.trim().isNotEmpty
          ? _maxAmountController.text.trim().takeNumericAsDouble()
          : null,
      category: _selectedCategory,
      priority: _selectedPriority,
      walletId: _selectedWalletId,
      dateStart: _dateStart,
      dateEnd: _dateEnd,
    );

    ref.read(plannedPurchasesFilterProvider.notifier).setFilter(
          filter.isActive ? filter : null,
        );
    Navigator.of(context).pop();
  }

  void _resetFilter() {
    context.openBottomSheet(
      child: AlertBottomSheet(
        title: AppLocalizations.of(context).resetFilters,
        content: Text(
          AppLocalizations.of(context).actionCannotBeUndone,
          style: AppTextStyles.body2,
        ),
        onConfirm: () {
          ref.read(plannedPurchasesFilterProvider.notifier).clear();
          context.pop(); // close alert
          context.pop(); // close filter sheet
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final walletsAsync = ref.watch(allWalletsStreamProvider);
    final wallets = walletsAsync.asData?.value ?? [];

    return CustomBottomSheet(
      title: l10n.filterPlannedPurchases,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Priority Selector Filter
          Text(
            l10n.priority,
            style: AppTextStyles.body3.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(AppSpacing.spacing8),
          Row(
            children: [
              Expanded(
                child: ButtonChip(
                  label: isArabic ? 'الكل' : 'All',
                  active: _selectedPriority == null,
                  onTap: () => setState(() => _selectedPriority = null),
                ),
              ),
              const Gap(AppSpacing.spacing4),
              Expanded(
                child: ButtonChip(
                  label: isArabic ? 'عاجلة' : 'Urgent',
                  active: _selectedPriority == PurchasePriority.urgentNeed,
                  onTap: () => setState(
                    () => _selectedPriority = PurchasePriority.urgentNeed,
                  ),
                ),
              ),
              const Gap(AppSpacing.spacing4),
              Expanded(
                child: ButtonChip(
                  label: isArabic ? 'مهمة' : 'Important',
                  active: _selectedPriority ==
                      PurchasePriority.nonUrgentImportant,
                  onTap: () => setState(
                    () => _selectedPriority =
                        PurchasePriority.nonUrgentImportant,
                  ),
                ),
              ),
              const Gap(AppSpacing.spacing4),
              Expanded(
                child: ButtonChip(
                  label: isArabic ? 'رغبة' : 'Desire',
                  active: _selectedPriority == PurchasePriority.desireWant,
                  onTap: () => setState(
                    () => _selectedPriority = PurchasePriority.desireWant,
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing16),

          // 2. Keyword Search
          CustomTextField(
            context: context,
            controller: _keywordController,
            hint: l10n.search,
            label: l10n.search,
            prefixIcon: HugeIcons.strokeRoundedSearch01,
          ),
          const Gap(AppSpacing.spacing16),

          // 3. Category Selector
          InkWell(
            onTap: () async {
              final selected = await Navigator.of(context).push<CategoryModel>(
                MaterialPageRoute(
                  builder: (context) => const CategoryPickerScreen(),
                ),
              );
              if (selected != null) {
                setState(() => _selectedCategory = selected);
              }
            },
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: context.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(color: context.secondaryBorderLighter),
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedTag01,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const Gap(AppSpacing.spacing8),
                  Expanded(
                    child: Text(
                      _selectedCategory?.title ?? l10n.selectCategory,
                      style: AppTextStyles.body3.copyWith(
                        color: _selectedCategory == null
                            ? context.secondaryText
                            : null,
                      ),
                    ),
                  ),
                  if (_selectedCategory != null)
                    InkWell(
                      onTap: () => setState(() => _selectedCategory = null),
                      child: const Icon(Icons.close, size: 16),
                    )
                  else
                    const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.spacing16),

          // 4. Wallet Selector (Optional Filter)
          if (wallets.isNotEmpty) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: context.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(color: context.secondaryBorderLighter),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedWalletId != null &&
                          wallets.any((w) => w.id == _selectedWalletId)
                      ? _selectedWalletId
                      : null,
                  isExpanded: true,
                  hint: Text(
                    isArabic ? 'تصفية حسب المحفظة (الكل)' : 'Filter by Wallet (All)',
                    style: AppTextStyles.body3.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(isArabic ? 'جميع المحافظ' : 'All Wallets'),
                    ),
                    ...wallets.map((w) {
                      return DropdownMenuItem<int?>(
                        value: w.id,
                        child: Text(w.name),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedWalletId = val);
                  },
                ),
              ),
            ),
            const Gap(AppSpacing.spacing16),
          ],

          // 5. Date Range Selector
          CustomSelectField(
            context: context,
            controller: _dateFieldController,
            label: isArabic ? 'تاريخ الشراء' : 'Purchase Date Range',
            hint: isArabic ? 'اختر نطاق التاريخ' : 'Select Date Range',
            prefixIcon: HugeIcons.strokeRoundedCalendar03,
            onTap: () async {
              final range = await CustomDatePicker.selectDateRange(
                context,
                [_dateStart, _dateEnd],
              );
              if (range != null && range.length == 2) {
                setState(() {
                  _dateStart = range.first;
                  _dateEnd = range.last;
                  _updateDateText();
                });
              }
            },
          ),
          const Gap(AppSpacing.spacing16),

          // 6. Min & Max Amount
          Row(
            children: [
              Expanded(
                child: CustomNumericField(
                  label: l10n.minAmount,
                  hint: '0',
                  appendCurrencySymbolToHint: true,
                  controller: _minAmountController,
                ),
              ),
              const Gap(AppSpacing.spacing8),
              Expanded(
                child: CustomNumericField(
                  label: l10n.maxAmount,
                  hint: '10,000,000',
                  appendCurrencySymbolToHint: true,
                  controller: _maxAmountController,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.spacing24),

          // 7. Apply & Reset Buttons
          PrimaryButton(
            label: l10n.applyFilters,
            onPressed: _applyFilter,
          ),
          const Gap(AppSpacing.spacing8),
          TextButton(
            onPressed: _resetFilter,
            child: Text(
              l10n.resetFilters,
              style: AppTextStyles.body2.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
