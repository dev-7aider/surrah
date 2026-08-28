import 'package:drift/drift.dart';
import 'package:pockaw/core/database/pockaw_database.dart';
import 'package:pockaw/core/database/tables/category_table.dart';
import 'package:pockaw/core/database/tables/planned_purchases_table.dart';
import 'package:pockaw/core/database/tables/wallet_table.dart';
import 'package:pockaw/features/planned_purchases/data/enum/purchase_priority.dart';
import 'package:pockaw/features/planned_purchases/data/model/planned_purchase_model.dart';

part 'planned_purchase_dao.g.dart';

@DriftAccessor(tables: [PlannedPurchases, Categories, Wallets])
class PlannedPurchaseDao extends DatabaseAccessor<AppDatabase>
    with _$PlannedPurchaseDaoMixin {
  PlannedPurchaseDao(super.db);

  PlannedPurchaseModel _mapToModel(
    PlannedPurchase entry, {
    Category? categoryEntry,
    Wallet? walletEntry,
  }) {
    return PlannedPurchaseModel(
      id: entry.id,
      title: entry.title,
      estimatedPrice: entry.estimatedPrice,
      actualPrice: entry.actualPrice,
      currency: entry.currency,
      categoryId: entry.categoryId,
      walletId: entry.walletId,
      priority: PurchasePriorityExtension.fromDbValue(entry.priority),
      isPurchased: entry.isPurchased,
      targetDate: entry.targetDate,
      purchasedAt: entry.purchasedAt,
      transactionId: entry.transactionId,
      notes: entry.notes,
      createdAt: entry.createdAt,
      category: categoryEntry?.toModel(),
      wallet: walletEntry?.toModel(),
    );
  }

  Stream<List<PlannedPurchaseModel>> watchActivePurchases() {
    final query = select(plannedPurchases).join([
      leftOuterJoin(categories, categories.id.equalsExp(plannedPurchases.categoryId)),
      leftOuterJoin(db.wallets, db.wallets.id.equalsExp(plannedPurchases.walletId)),
    ])
      ..where(plannedPurchases.isPurchased.equals(false))
      ..orderBy([
        OrderingTerm.asc(plannedPurchases.priority),
        OrderingTerm.desc(plannedPurchases.createdAt),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final entry = row.readTable(plannedPurchases);
        final cat = row.readTableOrNull(categories);
        final wal = row.readTableOrNull(db.wallets);
        return _mapToModel(entry, categoryEntry: cat, walletEntry: wal);
      }).toList();
    });
  }

  Stream<List<PlannedPurchaseModel>> watchPurchasedHistory() {
    final query = select(plannedPurchases).join([
      leftOuterJoin(categories, categories.id.equalsExp(plannedPurchases.categoryId)),
      leftOuterJoin(db.wallets, db.wallets.id.equalsExp(plannedPurchases.walletId)),
    ])
      ..where(plannedPurchases.isPurchased.equals(true))
      ..orderBy([
        OrderingTerm.desc(plannedPurchases.purchasedAt),
        OrderingTerm.desc(plannedPurchases.createdAt),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final entry = row.readTable(plannedPurchases);
        final cat = row.readTableOrNull(categories);
        final wal = row.readTableOrNull(db.wallets);
        return _mapToModel(entry, categoryEntry: cat, walletEntry: wal);
      }).toList();
    });
  }

  Stream<List<PlannedPurchaseModel>> watchAllPlannedPurchases() {
    final query = select(plannedPurchases).join([
      leftOuterJoin(categories, categories.id.equalsExp(plannedPurchases.categoryId)),
      leftOuterJoin(db.wallets, db.wallets.id.equalsExp(plannedPurchases.walletId)),
    ])..orderBy([OrderingTerm.desc(plannedPurchases.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final entry = row.readTable(plannedPurchases);
        final cat = row.readTableOrNull(categories);
        final wal = row.readTableOrNull(db.wallets);
        return _mapToModel(entry, categoryEntry: cat, walletEntry: wal);
      }).toList();
    });
  }

  Future<int> insertPlannedPurchase(PlannedPurchasesCompanion companion) {
    return into(plannedPurchases).insert(companion);
  }

  Future<bool> updatePlannedPurchase(PlannedPurchasesCompanion companion) {
    return update(plannedPurchases).replace(companion);
  }

  Future<int> markAsPurchased({
    required int id,
    required double actualPrice,
    required int walletId,
    required DateTime purchasedAt,
    int? transactionId,
  }) {
    return (update(plannedPurchases)..where((tbl) => tbl.id.equals(id))).write(
      PlannedPurchasesCompanion(
        isPurchased: const Value(true),
        actualPrice: Value(actualPrice),
        walletId: Value(walletId),
        purchasedAt: Value(purchasedAt),
        transactionId: Value(transactionId),
      ),
    );
  }

  Future<int> unmarkAsPurchased(int id) {
    return (update(plannedPurchases)..where((tbl) => tbl.id.equals(id))).write(
      const PlannedPurchasesCompanion(
        isPurchased: Value(false),
        actualPrice: Value(null),
        purchasedAt: Value(null),
        transactionId: Value(null),
      ),
    );
  }

  Future<int> deletePlannedPurchase(int id) {
    return (delete(plannedPurchases)..where((tbl) => tbl.id.equals(id))).go();
  }
}
