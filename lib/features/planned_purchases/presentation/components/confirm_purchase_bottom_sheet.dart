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
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';
import 'package:pockaw/features/category/data/model/category_model.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';
import 'package:pockaw/features/planned_purchases/presentation/riverpod/planned_purchases_providers.dart';
import 'package:pockaw/features/transaction/data/model/transaction_model.dart';
import 'package:pockaw/features/user_activity/data/enum/user_activity_action.dart';
import 'package:pockaw/features/user_activity/riverpod/user_activity_provider.dart';
import 'package:pockaw/features/wallet/data/model/wallet_model.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class ConfirmPurchaseBottomSheet extends ConsumerStatefulWidget {
  final PlannedPurchaseModel item;

  const ConfirmPurchaseBottomSheet({super.key, required this.item});

  @override
  ConsumerState<ConfirmPurchaseBottomSheet> createState() =>
      _ConfirmPurchaseBottomSheetState();
}

class _ConfirmPurchaseBottomSheetState
    extends ConsumerState<ConfirmPurchaseBottomSheet> {
  late TextEditingController _priceController;
  int? _selectedWalletId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.estimatedPrice.toStringAsFixed(0),
    );
    _selectedWalletId = widget.item.walletId;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final actualPrice = double.tryParse(_priceController.text.trim()) ??
        widget.item.estimatedPrice;

    final walletsAsync = ref.read(allWalletsStreamProvider);
    final wallets = walletsAsync.asData?.value ?? [];
    final wallet = (_selectedWalletId != null
            ? wallets.where((w) => w.id == _selectedWalletId).firstOrNull
            : null) ??
        wallets.firstOrNull;

    if (wallet == null || wallet.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a wallet')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final now = DateTime.now();

      // 1. Deduct actual price from the selected wallet balance
      final newBalance = wallet.balance - actualPrice;
      final updatedWallet = wallet.copyWith(balance: newBalance);
      await db.walletDao.updateWallet(updatedWallet);

      // If this wallet is active, update activeWalletProvider as well
      final activeWallet = ref.read(activeWalletProvider).asData?.value;
      if (activeWallet?.id == wallet.id) {
        ref.read(activeWalletProvider.notifier).setActiveWallet(updatedWallet);
      }

      // 2. Create standard Expense Transaction in the system
      final transaction = TransactionModel(
        title: widget.item.title,
        amount: actualPrice,
        date: now,
        transactionType: TransactionType.expense,
        category: widget.item.category ??
            CategoryModel(
              id: widget.item.categoryId ?? 1,
              title: widget.item.title,
            ),
        wallet: updatedWallet,
        notes: 'Planned Purchase executed',
      );

      final transactionId = await db.transactionDao.addTransaction(transaction);

      // 3. Mark planned purchase item as completed
      await ref.read(plannedPurchaseDaoProvider).markAsPurchased(
            id: widget.item.id,
            actualPrice: actualPrice,
            walletId: wallet.id!,
            purchasedAt: now,
            transactionId: transactionId,
          );

      // 4. Log user activity and sync widget data
      ref.read(userActivityServiceProvider).logActivity(
            action: UserActivityAction.transactionCreated,
            subjectId: transactionId,
          );
      ref.read(widgetSyncProvider).syncWidgetData();

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
    final walletsAsync = ref.watch(allWalletsStreamProvider);
    final wallets = walletsAsync.asData?.value ?? [];

    final currentSelectedId = _selectedWalletId ?? (wallets.isNotEmpty ? wallets.first.id : null);

    return CustomBottomSheet(
      title: l10n.confirmPurchase,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item Info Summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.spacing12),
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
                    color: AppColors.primary50.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppRadius.radius8),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingBag01,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const Gap(AppSpacing.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Estimated: ${widget.item.estimatedPrice.toPriceFormat()} ${widget.item.currency}',
                        style: AppTextStyles.body4.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.spacing16),

          // Actual Amount Paid
          CustomTextField(
            context: context,
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: l10n.actualAmountPaid,
            hint: '0.00',
            prefixIcon: HugeIcons.strokeRoundedMoneyBag02,
          ),
          const Gap(AppSpacing.spacing16),

          // Select Wallet to Deduct
          Text(
            l10n.selectWalletToDeduct,
            style: AppTextStyles.body3.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(AppSpacing.spacing8),
          if (wallets.isEmpty)
            Text(
              'No wallets available',
              style: AppTextStyles.body4.copyWith(color: context.secondaryText),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: context.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(color: context.secondaryBorderLighter),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: currentSelectedId != null && wallets.any((w) => w.id == currentSelectedId)
                      ? currentSelectedId
                      : (wallets.isNotEmpty ? wallets.first.id : null),
                  isExpanded: true,
                  items: wallets.map((w) {
                    return DropdownMenuItem<int>(
                      value: w.id,
                      child: Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedWallet02,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const Gap(AppSpacing.spacing8),
                          Text(w.name),
                          const Spacer(),
                          Text(
                            w.formattedBalance,
                            style: AppTextStyles.body4.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedWalletId = val);
                    }
                  },
                ),
              ),
            ),
          const Gap(AppSpacing.spacing24),

          // Confirm and Deduct Button
          PrimaryButton(
            label: l10n.confirmAndDeduct,
            isLoading: _isLoading,
            onPressed: _handleConfirm,
          ),
        ],
      ),
    );
  }
}
