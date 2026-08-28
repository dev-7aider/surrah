import 'package:pockaw/features/category/data/model/category_model.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';

class PlannedPurchasesFilterModel {
  final String? keyword;
  final double? minAmount;
  final double? maxAmount;
  final CategoryModel? category;
  final PurchasePriority? priority;
  final int? walletId;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  const PlannedPurchasesFilterModel({
    this.keyword,
    this.minAmount,
    this.maxAmount,
    this.category,
    this.priority,
    this.walletId,
    this.dateStart,
    this.dateEnd,
  });

  bool get isActive =>
      (keyword != null && keyword!.trim().isNotEmpty) ||
      minAmount != null ||
      maxAmount != null ||
      category != null ||
      priority != null ||
      walletId != null ||
      dateStart != null ||
      dateEnd != null;

  PlannedPurchasesFilterModel copyWith({
    String? keyword,
    double? minAmount,
    double? maxAmount,
    CategoryModel? category,
    PurchasePriority? priority,
    int? walletId,
    DateTime? dateStart,
    DateTime? dateEnd,
    bool clearKeyword = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearCategory = false,
    bool clearPriority = false,
    bool clearWallet = false,
    bool clearDateStart = false,
    bool clearDateEnd = false,
  }) {
    return PlannedPurchasesFilterModel(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      dateStart: clearDateStart ? null : (dateStart ?? this.dateStart),
      dateEnd: clearDateEnd ? null : (dateEnd ?? this.dateEnd),
    );
  }
}
