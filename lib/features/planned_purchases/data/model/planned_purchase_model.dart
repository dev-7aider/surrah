import 'package:pockaw/features/category/data/model/category_model.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';
import 'package:pockaw/features/wallet/data/model/wallet_model.dart';

class PlannedPurchaseModel {
  final int id;
  final String title;
  final double estimatedPrice;
  final double? actualPrice;
  final String currency;
  final int? categoryId;
  final int? walletId;
  final PurchasePriority priority;
  final bool isPurchased;
  final DateTime? targetDate;
  final DateTime? purchasedAt;
  final int? transactionId;
  final String? notes;
  final DateTime createdAt;

  // Joined/populated relations
  final CategoryModel? category;
  final WalletModel? wallet;

  const PlannedPurchaseModel({
    required this.id,
    required this.title,
    required this.estimatedPrice,
    this.actualPrice,
    required this.currency,
    this.categoryId,
    this.walletId,
    this.priority = PurchasePriority.urgentNeed,
    this.isPurchased = false,
    this.targetDate,
    this.purchasedAt,
    this.transactionId,
    this.notes,
    required this.createdAt,
    this.category,
    this.wallet,
  });

  PlannedPurchaseModel copyWith({
    int? id,
    String? title,
    double? estimatedPrice,
    double? actualPrice,
    String? currency,
    int? categoryId,
    int? walletId,
    PurchasePriority? priority,
    bool? isPurchased,
    DateTime? targetDate,
    DateTime? purchasedAt,
    int? transactionId,
    String? notes,
    DateTime? createdAt,
    CategoryModel? category,
    WalletModel? wallet,
  }) {
    return PlannedPurchaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      priority: priority ?? this.priority,
      isPurchased: isPurchased ?? this.isPurchased,
      targetDate: targetDate ?? this.targetDate,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      wallet: wallet ?? this.wallet,
    );
  }
}
