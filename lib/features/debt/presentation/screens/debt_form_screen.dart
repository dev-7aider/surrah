import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/bottom_sheets/alert_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/custom_icon_button.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/date_picker/custom_date_picker.dart';
import 'package:pockaw/core/components/dialogs/toast.dart';
import 'package:pockaw/core/components/form_fields/custom_numeric_field.dart';
import 'package:pockaw/core/components/form_fields/custom_select_field.dart';
import 'package:pockaw/core/components/form_fields/custom_text_field.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/database/tables/category_table.dart';
import 'package:pockaw/core/database/tables/wallet_table.dart';
import 'package:pockaw/core/extensions/date_time_extension.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/extensions/string_extension.dart';
import 'package:pockaw/core/extensions/text_style_extensions.dart';
import 'package:pockaw/features/debt/data/enum/debt_type.dart';
import 'package:pockaw/features/debt/data/model/debt_model.dart';
import 'package:pockaw/features/debt/presentation/riverpod/debt_providers.dart';
import 'package:pockaw/features/transaction/data/model/transaction_model.dart';
import 'package:pockaw/features/wallet/data/model/wallet_model.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/features/wallet_switcher/presentation/components/wallet_picker_bottom_sheet.dart';
import 'package:pockaw/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';

class DebtFormScreen extends HookConsumerWidget {
  final int? debtId;

  const DebtFormScreen({super.key, this.debtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isEditing = debtId != null;

    final debtAsync = isEditing ? ref.watch(debtDetailsProvider(debtId!)) : null;
    final activeWallet = ref.watch(activeWalletProvider).asData?.value;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final amountController = useTextEditingController();
    final notesController = useTextEditingController();
    final dueDateController = useTextEditingController();
    final walletController = useTextEditingController();

    final debtType = useState(DebtType.iOwe);
    final dueDate = useState<DateTime?>(null);
    final selectedWallet = useState<WalletModel?>(null);
    final depositIntoAccount = useState<bool>(true);
    final deductFromAccount = useState<bool>(true);

    useEffect(() {
      if (selectedWallet.value == null && activeWallet != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedWallet.value == null) {
            selectedWallet.value = activeWallet;
            walletController.text = activeWallet.name;
          }
        });
      }
      return null;
    }, [activeWallet]);

    useEffect(() {
      if (isEditing && debtAsync is AsyncData<DebtModel?>) {
        final debt = debtAsync.value;
        if (debt != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            nameController.text = debt.personName;
            phoneController.text = debt.phoneNumber ?? '';
            amountController.text = debt.totalAmount.toPriceFormat();
            notesController.text = debt.notes ?? '';
            debtType.value = debt.debtType;
            dueDate.value = debt.dueDate;
            selectedWallet.value = debt.wallet;
            walletController.text = debt.wallet.name;
            if (debt.dueDate != null) {
              dueDateController.text = debt.dueDate!.toDayShortMonthYear(locale);
            }
          });
        }
      }
      return null;
    }, [isEditing, debtAsync]);

    void saveDebt() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final db = ref.read(databaseProvider);
      var walletToUse = selectedWallet.value ?? activeWallet;

      if (walletToUse == null) {
        final wallets = await db.walletDao.getAllWallets();
        if (wallets.isNotEmpty) {
          walletToUse = wallets.first.toModel();
        }
      }

      if (walletToUse == null) {
        Toast.show(l10n.selectAccount, type: ToastificationType.warning);
        return;
      }

      final totalAmount = amountController.text.takeNumericAsDouble();
      if (totalAmount <= 0) {
        Toast.show(l10n.amount, type: ToastificationType.warning);
        return;
      }

      final debtToSave = DebtModel(
        id: isEditing ? debtId : null,
        personName: nameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        debtType: debtType.value,
        totalAmount: totalAmount,
        paidAmount: isEditing && debtAsync?.value != null
            ? debtAsync!.value!.paidAmount
            : 0.0,
        startDate: isEditing && debtAsync?.value != null
            ? debtAsync!.value!.startDate
            : DateTime.now(),
        dueDate: dueDate.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        wallet: walletToUse,
      );

      final debtDao = ref.read(debtDaoProvider);
      try {
        if (isEditing) {
          await debtDao.updateDebt(debtToSave);
          Toast.show(l10n.debtUpdated, type: ToastificationType.success);
        } else {
          await debtDao.addDebt(debtToSave);

          // Accounting Rules Processing for NEW debts:
          final categories = await db.categoryDao.getAllCategories();
          final targetCategory = categories.firstWhere(
            (c) {
              final title = c.title.toLowerCase();
              return title == 'debts' ||
                  title.contains('debt') ||
                  c.title.contains('ديون') ||
                  c.title.contains('قرض');
            },
            orElse: () => categories.firstWhere(
              (c) => c.title.toLowerCase().contains('finance'),
              orElse: () => categories.first,
            ),
          );

          if (debtType.value == DebtType.iAmOwed && deductFromAccount.value) {
            // Rule 1 (Option A): Giving a Loan -> Deduct loan amount from selected account
            final newBalance = walletToUse.balance - totalAmount;
            final updatedWallet = walletToUse.copyWith(balance: newBalance);
            await db.walletDao.updateWallet(updatedWallet);

            if (activeWallet?.id == walletToUse.id) {
              ref.read(activeWalletProvider.notifier).setActiveWallet(updatedWallet);
            }

            // Create Expense Transaction
            await db.transactionDao.addTransaction(
              TransactionModel(
                transactionType: TransactionType.expense,
                amount: totalAmount,
                date: DateTime.now(),
                title: '${l10n.iAmOwed} - ${debtToSave.personName}',
                category: targetCategory.toModel(),
                wallet: updatedWallet,
                notes: debtToSave.notes,
              ),
            );
          } else if (debtType.value == DebtType.iOwe && depositIntoAccount.value) {
            // Rule 2 (Option A): Receiving a Loan -> Deposit amount into selected account
            final newBalance = walletToUse.balance + totalAmount;
            final updatedWallet = walletToUse.copyWith(balance: newBalance);
            await db.walletDao.updateWallet(updatedWallet);

            if (activeWallet?.id == walletToUse.id) {
              ref.read(activeWalletProvider.notifier).setActiveWallet(updatedWallet);
            }

            // Create Income Transaction
            await db.transactionDao.addTransaction(
              TransactionModel(
                transactionType: TransactionType.income,
                amount: totalAmount,
                date: DateTime.now(),
                title: '${l10n.iOwe} - ${debtToSave.personName}',
                category: targetCategory.toModel(),
                wallet: updatedWallet,
                notes: debtToSave.notes,
              ),
            );
          }
          // Option B (Both cases): Record debt only -> No balance change, no transaction created

          Toast.show(l10n.debtCreated, type: ToastificationType.success);
        }

        if (context.mounted) context.pop();
      } catch (e) {
        Toast.show('Error: $e', type: ToastificationType.error);
      }
    }

    return CustomScaffold(
      title: isEditing ? l10n.editDebt : l10n.createDebt,
      showBackButton: true,
      showBalance: false,
      actions: [
        if (isEditing)
          CustomIconButton(
            context,
            onPressed: () {
              context.openBottomSheet(
                child: AlertBottomSheet(
                  title: l10n.deleteDebt,
                  content: Text(
                    l10n.confirmDeleteDebt,
                    style: AppTextStyles.body2,
                  ),
                  onConfirm: () async {
                    context.pop();
                    context.pop();
                    context.pop();
                    await ref.read(debtDaoProvider).deleteDebt(debtId!);
                    Toast.show(l10n.debtDeleted);
                  },
                ),
              );
            },
            icon: HugeIcons.strokeRoundedDelete02,
            themeMode: context.themeMode,
          ),
      ],
      body: Stack(
        fit: StackFit.expand,
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacing16,
                AppSpacing.spacing12,
                AppSpacing.spacing16,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.spacing16,
                children: [
                  // Debt Type Selector Segment
                  Container(
                    decoration: BoxDecoration(
                      color: context.secondaryBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.spacing8),
                      border: Border.all(color: context.secondaryBorderLighter),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => debtType.value = DebtType.iOwe,
                            borderRadius: BorderRadius.circular(AppSpacing.spacing8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: debtType.value == DebtType.iOwe
                                    ? AppColors.red
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppSpacing.spacing8),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.iOwe,
                                  style: AppTextStyles.body3.bold.copyWith(
                                    color: debtType.value == DebtType.iOwe
                                        ? Colors.white
                                        : context.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => debtType.value = DebtType.iAmOwed,
                            borderRadius: BorderRadius.circular(AppSpacing.spacing8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: debtType.value == DebtType.iAmOwed
                                    ? AppColors.green200
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppSpacing.spacing8),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.iAmOwed,
                                  style: AppTextStyles.body3.bold.copyWith(
                                    color: debtType.value == DebtType.iAmOwed
                                        ? Colors.white
                                        : context.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Person Name & Amount Fields
                  CustomTextField(
                    controller: nameController,
                    label: l10n.personName,
                    hint: 'e.g. John Doe',
                    prefixIcon: HugeIcons.strokeRoundedUser,
                    isRequired: true,
                  ),
                  CustomNumericField(
                    controller: amountController,
                    label: l10n.amount,
                    hint: '1,000.00',
                    icon: HugeIcons.strokeRoundedCoins01,
                    appendCurrencySymbolToHint: true,
                    isRequired: true,
                  ),

                  // Accounting Prompt & Options based on DebtType
                  if (debtType.value == DebtType.iAmOwed) ...[
                    // Rule 1: Giving a loan prompt & options
                    Text(
                      l10n.whichAccountDeductLoanFrom,
                      style: AppTextStyles.body3.bold,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.secondaryBackground,
                        borderRadius: BorderRadius.circular(AppRadius.radius12),
                        border: Border.all(color: context.secondaryBorderLighter),
                      ),
                      child: RadioGroup<bool>(
                        groupValue: deductFromAccount.value,
                        onChanged: (val) {
                          if (val != null) deductFromAccount.value = val;
                        },
                        child: Column(
                          children: [
                            RadioListTile<bool>(
                              title: Text(
                                l10n.deductFromAccountOption,
                                style: AppTextStyles.body4.bold,
                              ),
                              value: true,
                            ),
                            const Divider(height: 1),
                            RadioListTile<bool>(
                              title: Text(
                                l10n.recordDebtOnlyLendingOption,
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                              value: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (deductFromAccount.value)
                      CustomSelectField(
                        context: context,
                        controller: walletController,
                        label: l10n.deductFromAccount,
                        hint: l10n.selectAccount,
                        prefixIcon: HugeIcons.strokeRoundedWallet01,
                        onTap: () async {
                          final picked = await context.openBottomSheet<WalletModel?>(
                            child: WalletPickerBottomSheet(
                              selectedWallet: selectedWallet.value,
                              title: l10n.whichAccountDeductLoanFrom,
                            ),
                          );
                          if (picked != null) {
                            selectedWallet.value = picked;
                            walletController.text = picked.name;
                          }
                        },
                      ),
                  ] else ...[
                    // Rule 2: Receiving a loan prompt & options
                    Text(
                      l10n.whichAccountReceiveBorrowedAmount,
                      style: AppTextStyles.body3.bold,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.secondaryBackground,
                        borderRadius: BorderRadius.circular(AppRadius.radius12),
                        border: Border.all(color: context.secondaryBorderLighter),
                      ),
                      child: RadioGroup<bool>(
                        groupValue: depositIntoAccount.value,
                        onChanged: (val) {
                          if (val != null) depositIntoAccount.value = val;
                        },
                        child: Column(
                          children: [
                            RadioListTile<bool>(
                              title: Text(
                                l10n.depositIntoAccountOption,
                                style: AppTextStyles.body4.bold,
                              ),
                              value: true,
                            ),
                            const Divider(height: 1),
                            RadioListTile<bool>(
                              title: Text(
                                l10n.recordDebtOnlyOption,
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                              value: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (depositIntoAccount.value)
                      CustomSelectField(
                        context: context,
                        controller: walletController,
                        label: l10n.selectAccount,
                        hint: l10n.selectAccount,
                        prefixIcon: HugeIcons.strokeRoundedWallet01,
                        onTap: () async {
                          final picked = await context.openBottomSheet<WalletModel?>(
                            child: WalletPickerBottomSheet(
                              selectedWallet: selectedWallet.value,
                              title: l10n.whichAccountReceiveBorrowedAmount,
                            ),
                          );
                          if (picked != null) {
                            selectedWallet.value = picked;
                            walletController.text = picked.name;
                          }
                        },
                      ),
                  ],

                  // Additional Details (Due Date, Phone, Notes)
                  CustomSelectField(
                    context: context,
                    controller: dueDateController,
                    label: l10n.dueDate,
                    hint: l10n.dueDate,
                    prefixIcon: HugeIcons.strokeRoundedCalendar01,
                    onTap: () async {
                      final picked = await CustomDatePicker.selectSingleDate(
                        context,
                        title: l10n.dueDate,
                        selectedDate: dueDate.value ?? DateTime.now(),
                      );
                      if (picked != null) {
                        dueDate.value = picked;
                        dueDateController.text = picked.toDayShortMonthYear(locale);
                      }
                    },
                  ),
                  CustomTextField(
                    controller: phoneController,
                    label: l10n.phoneNumber,
                    hint: '+964 770 000 0000',
                    prefixIcon: HugeIcons.strokeRoundedCall02,
                  ),
                  CustomTextField(
                    controller: notesController,
                    label: l10n.writeSimpleDescription,
                    hint: l10n.writeSimpleDescription,
                    prefixIcon: HugeIcons.strokeRoundedNote01,
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: l10n.confirm,
            onPressed: saveDebt,
          ).floatingBottomContained,
        ],
      ),
    );
  }
}
