import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/bottom_sheets/custom_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/form_fields/custom_text_field.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/database/pockaw_database.dart';
import 'package:pockaw/features/category/data/model/category_model.dart';
import 'package:pockaw/features/category_picker/presentation/screens/category_picker_screen.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class AddPlannedItemBottomSheet extends ConsumerStatefulWidget {
  final PlannedPurchaseModel? existingItem;

  const AddPlannedItemBottomSheet({super.key, this.existingItem});

  @override
  ConsumerState<AddPlannedItemBottomSheet> createState() =>
      _AddPlannedItemBottomSheetState();
}

class _AddPlannedItemBottomSheetState
    extends ConsumerState<AddPlannedItemBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;

  PurchasePriority _priority = PurchasePriority.urgentNeed;
  CategoryModel? _selectedCategory;
  int? _selectedWalletId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingItem?.title ?? '');
    _priceController = TextEditingController(
      text: widget.existingItem != null
          ? widget.existingItem!.estimatedPrice.toStringAsFixed(0)
          : '',
    );
    _notesController =
        TextEditingController(text: widget.existingItem?.notes ?? '');

    if (widget.existingItem != null) {
      _priority = widget.existingItem!.priority;
      _selectedCategory = widget.existingItem!.category;
      _selectedWalletId = widget.existingItem!.walletId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (title.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid title and amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dao = ref.read(plannedPurchaseDaoProvider);

      if (widget.existingItem == null) {
        // Create
        await dao.insertPlannedPurchase(
          PlannedPurchasesCompanion(
            title: drift.Value(title),
            estimatedPrice: drift.Value(price),
            currency: const drift.Value('IQD'),
            categoryId: drift.Value(_selectedCategory?.id),
            walletId: drift.Value(_selectedWalletId),
            priority: drift.Value(_priority.dbValue),
            notes: drift.Value(_notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      } else {
        // Update
        await dao.updatePlannedPurchase(
          PlannedPurchasesCompanion(
            id: drift.Value(widget.existingItem!.id),
            title: drift.Value(title),
            estimatedPrice: drift.Value(price),
            currency: drift.Value(widget.existingItem!.currency),
            categoryId: drift.Value(_selectedCategory?.id ?? widget.existingItem!.categoryId),
            walletId: drift.Value(_selectedWalletId ?? widget.existingItem!.walletId),
            priority: drift.Value(_priority.dbValue),
            isPurchased: drift.Value(widget.existingItem!.isPurchased),
            actualPrice: drift.Value(widget.existingItem!.actualPrice),
            purchasedAt: drift.Value(widget.existingItem!.purchasedAt),
            transactionId: drift.Value(widget.existingItem!.transactionId),
            targetDate: drift.Value(widget.existingItem!.targetDate),
            notes: drift.Value(_notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null),
            createdAt: drift.Value(widget.existingItem!.createdAt),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final walletsAsync = ref.watch(allWalletsStreamProvider);
    final wallets = walletsAsync.asData?.value ?? [];

    return CustomBottomSheet(
      title: widget.existingItem == null
          ? l10n.addNewItem
          : l10n.editPlannedItem,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item Name
          CustomTextField(
            context: context,
            controller: _titleController,
            label: l10n.itemName,
            hint: isArabic
                ? 'مثال: ساعة ذكية، مسواك البيت...'
                : 'e.g. Smart Watch, Groceries...',
            prefixIcon: HugeIcons.strokeRoundedShoppingBag01,
          ),
          const Gap(AppSpacing.spacing12),

          // Estimated Price
          CustomTextField(
            context: context,
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: l10n.estimatedPrice,
            hint: '0.00 IQD',
            prefixIcon: HugeIcons.strokeRoundedMoneyBag02,
          ),
          const Gap(AppSpacing.spacing16),

          // Priority Selection (Need vs Want)
          Text(
            l10n.priority,
            style: AppTextStyles.body3.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(AppSpacing.spacing8),
          Row(
            children: PurchasePriority.values.map((priority) {
              final isSelected = _priority == priority;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = priority),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.spacing8,
                      horizontal: AppSpacing.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? priority.color.withAlpha(30)
                          : context.secondaryBackground,
                      borderRadius: BorderRadius.circular(AppRadius.radius8),
                      border: Border.all(
                        color: isSelected
                            ? priority.color
                            : context.secondaryBorderLighter,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: priority.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(AppSpacing.spacing4),
                        Text(
                          priority.getLabel(context, isArabic),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body4.copyWith(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? priority.color : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Gap(AppSpacing.spacing16),

          // Category Picker Button
          Text(
            l10n.selectCategory,
            style: AppTextStyles.body3.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(AppSpacing.spacing8),
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
                  Text(
                    _selectedCategory?.title ?? l10n.selectCategory,
                    style: AppTextStyles.body3.copyWith(
                      color: _selectedCategory == null
                          ? context.secondaryText
                          : null,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.spacing16),

          // Wallet Selection (Optional)
          if (wallets.isNotEmpty) ...[
            Text(
              l10n.selectWalletOptional,
              style:
                  AppTextStyles.body3.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(AppSpacing.spacing8),
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
                  value: _selectedWalletId != null && wallets.any((w) => w.id == _selectedWalletId)
                      ? _selectedWalletId
                      : null,
                  isExpanded: true,
                  hint: Text(
                    'None',
                    style: AppTextStyles.body3.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None'),
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

          // Notes Optional
          CustomTextField(
            context: context,
            controller: _notesController,
            label: l10n.notesOptional,
            hint: 'Notes...',
            prefixIcon: HugeIcons.strokeRoundedNote01,
          ),
          const Gap(AppSpacing.spacing24),

          // Save Button
          PrimaryButton(
            label: l10n.save,
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
