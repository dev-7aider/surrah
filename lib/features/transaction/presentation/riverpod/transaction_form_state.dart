import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pockaw/core/components/bottom_sheets/alert_bottom_sheet.dart';
import 'package:pockaw/core/components/dialogs/toast.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/extensions/date_time_extension.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/extensions/string_extension.dart';
import 'package:pockaw/core/services/image_service/riverpod/image_notifier.dart';
import 'package:pockaw/core/utils/logger.dart';
import 'package:pockaw/features/category/data/model/category_model.dart';
import 'package:pockaw/features/transaction/data/model/transaction_model.dart';
import 'package:pockaw/features/transaction/presentation/riverpod/date_picker_provider.dart';
import 'package:pockaw/features/user_activity/data/enum/user_activity_action.dart';
import 'package:pockaw/features/user_activity/riverpod/user_activity_provider.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';
import 'package:toastification/toastification.dart';

class TransactionFormState {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final TextEditingController categoryController;
  final TextEditingController dateFieldController;
  final ValueNotifier<TransactionType> selectedTransactionType;
  final ValueNotifier<CategoryModel?> selectedCategory;
  final String defaultCurrency;
  final bool isEditing;
  final TransactionModel? initialTransaction;

  TransactionFormState({
    required this.titleController,
    required this.amountController,
    required this.notesController,
    required this.categoryController,
    required this.selectedTransactionType,
    required this.selectedCategory,
    required this.dateFieldController,
    required this.defaultCurrency,
    required this.isEditing,
    this.initialTransaction,
  });

  String getCategoryText(BuildContext context, {CategoryModel? parentCategory}) {
    final category = selectedCategory.value;
    if (category == null) return '';

    if (parentCategory != null) {
      // It's a subcategory, find its parent to display "Parent • Sub"
      return '${parentCategory.getLocalizedTitle(context)} • ${category.getLocalizedTitle(context)}';
    } else {
      // It's a parent category
      return category.getLocalizedTitle(context);
    }
  }

  Future<void> saveTransaction(WidgetRef ref, BuildContext context) async {
    if (titleController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedCategory.value == null) {
      Toast.show(
        'Please fill all required fields.',
        type: ToastificationType.error,
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final imagePickerState = ref.read(imageProvider);
    final activeWallet = ref.read(activeWalletProvider).asData?.value;

    if (activeWallet == null || activeWallet.id == null) {
      Toast.show(
        'No active wallet selected.',
        type: ToastificationType.warning,
      );
      return;
    }

    String imagePath = '';
    if (await File(imagePickerState.savedPath ?? '').exists()) {
      imagePath = imagePickerState.savedPath ?? '';
    }

    // --- FIX: Use datePickerProvider instead of parsing human-readable localized text ---
    final dateToSave = ref.read(datePickerProvider);

    final transactionToSave = TransactionModel(
      id: isEditing ? initialTransaction?.id : null,
      transactionType: selectedTransactionType.value,
      amount: amountController.text.takeNumericAsDouble(),
      date: dateToSave,
      title: titleController.text,
      category: selectedCategory.value!,
      wallet: activeWallet,
      notes: notesController.text.isNotEmpty ? notesController.text : null,
      imagePath: imagePath,
      isRecurring: false,
    );

    Log.d(
      transactionToSave.toJson(),
      label: isEditing ? 'Updating transaction' : 'Saving new transaction',
    );

    try {
      int? savedTransactionId;
      if (!isEditing) {
        savedTransactionId = await db.transactionDao.addTransaction(
          transactionToSave,
        );

        if (savedTransactionId > 0) {
          await _adjustWalletBalance(ref, null, transactionToSave);
        }
      } else {
        // This is the update case
        // For updates, the ID is already in transactionToSave.id
        if (transactionToSave.id == null) {
          Log.e('Error: Attempting to update transaction without an ID.');
          toastification.show(
            description: Text('Error updating transaction: Missing ID.'),
          );
          return;
        }
        await db.transactionDao.updateTransaction(transactionToSave);
        savedTransactionId = transactionToSave.id;
        await _adjustWalletBalance(ref, initialTransaction, transactionToSave);
      }

      ref
          .read(userActivityServiceProvider)
          .logActivity(
            action: isEditing
                ? UserActivityAction.transactionUpdated
                : UserActivityAction.transactionCreated,
            subjectId: savedTransactionId,
          );

      // Sync updated data with Home Screen Widget
      ref.read(widgetSyncProvider).syncWidgetData();

      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      Log.e('Error saving transaction: $e');
      if (context.mounted) {
        Toast.show(
          'Failed to save transaction: $e',
          type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> deleteTransaction(WidgetRef ref, BuildContext context) async {
    // Skip if not editing just in case
    if (!isEditing) return;

    context.openBottomSheet(
      child: AlertBottomSheet(
        context: context,
        title: 'Delete Transaction',
        content: Text(
          'Continue to delete this transaction?',
          style: AppTextStyles.body2,
        ),
        onConfirm: () async {
          if (context.mounted) {
            context.pop(); // close dialog
          }

          await _adjustWalletBalance(
            ref,
            initialTransaction!,
            null,
          ); // Pass null for newTransaction to indicate deletion

          final db = ref.read(databaseProvider);
          final id = await db.transactionDao.deleteTransaction(
            initialTransaction!.id!,
          );

          ref
              .read(userActivityServiceProvider)
              .logActivity(
                action: UserActivityAction.transactionDeleted,
                subjectId: id,
              );

          ref.read(widgetSyncProvider).syncWidgetData();

          Log.d(id, label: 'deleted transaction id');

          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.pop(); // close form
              }
            });
          }
        },
      ),
    );
  }

  // This function will handle all balance adjustments: add, update, delete
  Future<void> _adjustWalletBalance(
    WidgetRef ref,
    TransactionModel?
    oldTransaction, // The original transaction (null for new additions)
    TransactionModel?
    newTransaction, // The new transaction (null for deletions)
  ) async {
    final db = ref.read(databaseProvider);
    final activeWallet = ref.read(activeWalletProvider).asData?.value;

    if (activeWallet == null || activeWallet.id == null) {
      Log.i(
        'No active wallet or wallet ID found to adjust balance.',
        label: 'wallet adjustment',
      );
      return;
    }

    double balanceChange = 0.0;

    // 1. Reverse the effect of the old transaction (if it exists)
    if (oldTransaction != null) {
      if (oldTransaction.transactionType == TransactionType.income) {
        balanceChange -= oldTransaction.amount;
      } else if (oldTransaction.transactionType == TransactionType.expense) {
        balanceChange += oldTransaction.amount;
      }
      // Transfers are ignored for single wallet balance adjustment
    }

    // 2. Apply the effect of the new transaction (if it exists)
    if (newTransaction != null) {
      if (newTransaction.transactionType == TransactionType.income) {
        balanceChange += newTransaction.amount;
      } else if (newTransaction.transactionType == TransactionType.expense) {
        balanceChange -= newTransaction.amount;
      }
      // Transfers are ignored
    }

    double newWalletBalance = activeWallet.balance + balanceChange;

    final updatedWallet = activeWallet.copyWith(balance: newWalletBalance);
    await db.walletDao.updateWallet(updatedWallet);
    ref.read(activeWalletProvider.notifier).setActiveWallet(updatedWallet);
    Log.d(
      'Wallet balance updated for ${activeWallet.name}. Old balance: ${activeWallet.balance}, Change: $balanceChange, New balance: $newWalletBalance',
      label: 'wallet adjustment',
    );
  }

  void dispose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    categoryController.dispose();
    selectedTransactionType.dispose();
    selectedCategory.dispose();
  }
}

TransactionFormState useTransactionFormState({
  required WidgetRef ref,
  required String defaultCurrency,
  required bool isEditing,
  TransactionModel? transaction,
}) {
  final context = useContext();
  final titleController = useTextEditingController(
    text: isEditing ? transaction?.title : '',
  );
  final amountController = useTextEditingController(
    text: isEditing && transaction != null
        ? '$defaultCurrency ${transaction.amount.toPriceFormat()}'
        : '',
  );
  final notesController = useTextEditingController(
    text: isEditing ? transaction?.notes ?? '' : '',
  );
  final categoryController = useTextEditingController();
  final dateFieldController = useTextEditingController();

  final selectedTransactionType = useState<TransactionType>(
    isEditing && transaction != null
        ? transaction.transactionType
        : TransactionType.expense,
  );
  final selectedCategory = useState<CategoryModel?>(
    isEditing ? transaction?.category : null,
  );

  final formState = useMemoized(
    () => TransactionFormState(
      titleController: titleController,
      amountController: amountController,
      notesController: notesController,
      categoryController: categoryController,
      selectedTransactionType: selectedTransactionType,
      selectedCategory: selectedCategory,
      dateFieldController: dateFieldController,
      defaultCurrency: defaultCurrency,
      isEditing: isEditing,
      initialTransaction: transaction,
    ),
    [defaultCurrency, isEditing, transaction],
  );

  useEffect(
    () {
      void initializeForm() {
        if (isEditing && transaction != null) {
          if (titleController.text != transaction.title) {
            titleController.text = transaction.title;
          }
          if (amountController.text !=
              '$defaultCurrency ${transaction.amount.toPriceFormat()}') {
            amountController.text =
                '$defaultCurrency ${transaction.amount.toPriceFormat()}';
          }
          if (notesController.text != (transaction.notes ?? '')) {
            notesController.text = transaction.notes ?? '';
          }
          if (selectedTransactionType.value != transaction.transactionType) {
            selectedTransactionType.value = transaction.transactionType;
          }
          if (selectedCategory.value != transaction.category) {
            selectedCategory.value = transaction.category;
          }

          dateFieldController.text = transaction.date.toRelativeDayFormatted(
            showTime: true,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(datePickerProvider.notifier).setDate(transaction.date);
            final imagePath = transaction.imagePath;
            if (imagePath != null && imagePath.isNotEmpty) {
              ref.read(imageProvider.notifier).loadImagePath(imagePath);
            } else {
              ref.read(imageProvider.notifier).clearImage();
            }
          });
        } else if (!isEditing) {
          titleController.clear();
          amountController.clear();
          notesController.clear();
          selectedTransactionType.value = TransactionType.expense;
          selectedCategory.value = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(datePickerProvider.notifier).setDate(DateTime.now());
            ref.read(imageProvider.notifier).clearImage();
          });
        }
      }

      initializeForm();
      return null;
    },
    [
      isEditing,
      transaction,
      defaultCurrency,
      ref,
      titleController,
      amountController,
      notesController,
      selectedTransactionType,
      selectedCategory,
    ],
  );

  useEffect(
    () {
      Future.microtask(() {
        selectedCategory.value?.getParentCategory(ref).then((parentCategory) {
          if (!context.mounted) return;
          categoryController.text = formState.getCategoryText(
            context,
            parentCategory: parentCategory,
          );
        });
      });
      return null;
    },
    [selectedCategory.value, formState],
  ); // formState is stable due to useMemoized

  // The main dispose for controllers created by useTextEditingController
  // and ValueNotifiers from useState is handled automatically by flutter_hooks.
  // The custom `formState.dispose()` might be redundant if it only disposes these.
  // If it has other specific cleanup, it should be called.
  // For now, assuming standard hook cleanup is sufficient.

  return formState;
}
