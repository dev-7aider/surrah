import 'package:drift/drift.dart';
import 'package:pockaw/core/database/pockaw_database.dart';
import 'package:pockaw/core/database/tables/khums_installments_table.dart';
import 'package:pockaw/core/database/tables/khums_money_sources_table.dart';
import 'package:pockaw/core/database/tables/khums_years_table.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_status.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_type.dart';
import 'package:pockaw/features/khums/data/model/khums_installment_model.dart';
import 'package:pockaw/features/khums/data/model/khums_money_source_model.dart';
import 'package:pockaw/features/khums/data/model/khums_year_model.dart';

part 'khums_dao.g.dart';

@DriftAccessor(tables: [KhumsYears, KhumsMoneySources, KhumsInstallments])
class KhumsDao extends DatabaseAccessor<AppDatabase> with _$KhumsDaoMixin {
  KhumsDao(super.db);

  // --- Khums Year Operations ---

  Stream<KhumsYearModel?> watchActiveKhumsYear() {
    final query = select(khumsYears)
      ..where((tbl) => tbl.isArchived.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(1);

    return query.watchSingleOrNull().map((entry) {
      if (entry == null) return null;
      return _mapYearEntryToModel(entry);
    });
  }

  Future<KhumsYearModel?> getActiveKhumsYear() async {
    final query = select(khumsYears)
      ..where((tbl) => tbl.isArchived.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(1);

    final entry = await query.getSingleOrNull();
    if (entry == null) return null;
    return _mapYearEntryToModel(entry);
  }

  Stream<List<KhumsYearModel>> watchAllKhumsYears() {
    final query = select(khumsYears)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch().map((entries) {
      return entries.map(_mapYearEntryToModel).toList();
    });
  }

  Stream<KhumsYearModel?> watchKhumsYearById(int id) {
    final query = select(khumsYears)..where((tbl) => tbl.id.equals(id));
    return query.watchSingleOrNull().map((entry) {
      if (entry == null) return null;
      return _mapYearEntryToModel(entry);
    });
  }

  Future<int> insertKhumsYear(KhumsYearsCompanion companion) {
    return into(khumsYears).insert(companion);
  }

  Future<bool> updateKhumsYear(KhumsYearsCompanion companion) {
    return update(khumsYears).replace(companion);
  }

  Future<int> updateKhumsYearTotals({
    required int yearId,
    required double totalAmount,
    required double khumsAmount,
  }) {
    return (update(khumsYears)..where((tbl) => tbl.id.equals(yearId))).write(
      KhumsYearsCompanion(
        totalAmount: Value(totalAmount),
        khumsAmount: Value(khumsAmount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> updatePaymentStatus({
    required int yearId,
    required KhumsPaymentType paymentType,
    required KhumsPaymentStatus paymentStatus,
    DateTime? paidAt,
  }) {
    return (update(khumsYears)..where((tbl) => tbl.id.equals(yearId))).write(
      KhumsYearsCompanion(
        paymentType: Value(paymentType.name),
        paymentStatus: Value(paymentStatus.name),
        paidAt: Value(paidAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> archiveKhumsYear(int yearId) {
    return (update(khumsYears)..where((tbl) => tbl.id.equals(yearId))).write(
      KhumsYearsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteKhumsYear(int id) {
    return (delete(khumsYears)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Money Sources Operations ---

  Stream<List<KhumsMoneySourceModel>> watchMoneySources(int khumsYearId) {
    final query = select(khumsMoneySources)
      ..where((tbl) => tbl.khumsYearId.equals(khumsYearId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]);

    return query.watch().map((entries) {
      return entries.map(_mapSourceEntryToModel).toList();
    });
  }

  Future<List<KhumsMoneySourceModel>> getMoneySources(int khumsYearId) async {
    final query = select(khumsMoneySources)
      ..where((tbl) => tbl.khumsYearId.equals(khumsYearId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]);

    final entries = await query.get();
    return entries.map(_mapSourceEntryToModel).toList();
  }

  Future<int> insertMoneySource(KhumsMoneySourcesCompanion companion) async {
    final id = await into(khumsMoneySources).insert(companion);
    await _recalculateYear(companion.khumsYearId.value);
    return id;
  }

  Future<bool> updateMoneySource(KhumsMoneySourcesCompanion companion) async {
    final result = await update(khumsMoneySources).replace(companion);
    await _recalculateYear(companion.khumsYearId.value);
    return result;
  }

  Future<int> deleteMoneySource(int id, int khumsYearId) async {
    final result =
        await (delete(khumsMoneySources)..where((tbl) => tbl.id.equals(id))).go();
    await _recalculateYear(khumsYearId);
    return result;
  }

  Future<void> _recalculateYear(int khumsYearId) async {
    final sources = await getMoneySources(khumsYearId);
    final total = sources.fold<double>(0.0, (sum, item) => sum + item.amount);
    final khums = total / 5.0;
    await updateKhumsYearTotals(
      yearId: khumsYearId,
      totalAmount: total,
      khumsAmount: khums,
    );
  }

  // --- Installments Operations ---

  Stream<List<KhumsInstallmentModel>> watchInstallments(int khumsYearId) {
    final query = select(khumsInstallments)
      ..where((tbl) => tbl.khumsYearId.equals(khumsYearId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.installmentNumber)]);

    return query.watch().map((entries) {
      return entries.map(_mapInstallmentEntryToModel).toList();
    });
  }

  Future<List<KhumsInstallmentModel>> getInstallments(int khumsYearId) async {
    final query = select(khumsInstallments)
      ..where((tbl) => tbl.khumsYearId.equals(khumsYearId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.installmentNumber)]);

    final entries = await query.get();
    return entries.map(_mapInstallmentEntryToModel).toList();
  }

  Future<void> setInstallmentsPlan({
    required int khumsYearId,
    required int months,
    required double khumsAmount,
    required DateTime startDate,
  }) async {
    await transaction(() async {
      await (delete(khumsInstallments)
            ..where((tbl) => tbl.khumsYearId.equals(khumsYearId)))
          .go();

      if (months <= 0 || khumsAmount <= 0) return;

      final monthlyAmount = (khumsAmount / months).roundToDouble();
      final remainder = khumsAmount - (monthlyAmount * (months - 1));

      for (int i = 1; i <= months; i++) {
        final amount = (i == months) ? remainder : monthlyAmount;
        final dueDate = DateTime(
          startDate.year,
          startDate.month + (i - 1),
          startDate.day,
        );

        await into(khumsInstallments).insert(
          KhumsInstallmentsCompanion(
            khumsYearId: Value(khumsYearId),
            installmentNumber: Value(i),
            amount: Value(amount),
            dueDate: Value(dueDate),
            isPaid: const Value(false),
          ),
        );
      }

      await updatePaymentStatus(
        yearId: khumsYearId,
        paymentType: KhumsPaymentType.installments,
        paymentStatus: KhumsPaymentStatus.notPaid,
      );
    });
  }

  Future<void> toggleInstallmentPaid({
    required int installmentId,
    required int khumsYearId,
    required bool isPaid,
  }) async {
    await (update(khumsInstallments)..where((tbl) => tbl.id.equals(installmentId)))
        .write(
      KhumsInstallmentsCompanion(
        isPaid: Value(isPaid),
        paidAt: Value(isPaid ? DateTime.now() : null),
      ),
    );

    final all = await getInstallments(khumsYearId);
    final paidCount = all.where((i) => i.isPaid).length;

    KhumsPaymentStatus status = KhumsPaymentStatus.notPaid;
    if (paidCount == all.length && all.isNotEmpty) {
      status = KhumsPaymentStatus.paid;
    } else if (paidCount > 0) {
      status = KhumsPaymentStatus.partiallyPaid;
    }

    await updatePaymentStatus(
      yearId: khumsYearId,
      paymentType: KhumsPaymentType.installments,
      paymentStatus: status,
      paidAt: status == KhumsPaymentStatus.paid ? DateTime.now() : null,
    );
  }

  // --- Mappers ---

  KhumsYearModel _mapYearEntryToModel(KhumsYearEntry entry) {
    KhumsPaymentType paymentType = KhumsPaymentType.none;
    try {
      paymentType = KhumsPaymentType.values.byName(entry.paymentType);
    } catch (_) {}

    KhumsPaymentStatus paymentStatus = KhumsPaymentStatus.notPaid;
    try {
      paymentStatus = KhumsPaymentStatus.values.byName(entry.paymentStatus);
    } catch (_) {}

    return KhumsYearModel(
      id: entry.id,
      hijriStartDay: entry.hijriStartDay,
      hijriStartMonth: entry.hijriStartMonth,
      hijriStartYear: entry.hijriStartYear,
      gregorianStartDate: entry.gregorianStartDate,
      gregorianEndDate: entry.gregorianEndDate,
      totalAmount: entry.totalAmount,
      khumsAmount: entry.khumsAmount,
      paymentType: paymentType,
      paymentStatus: paymentStatus,
      isArchived: entry.isArchived,
      paidAt: entry.paidAt,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  KhumsMoneySourceModel _mapSourceEntryToModel(KhumsMoneySourceEntry entry) {
    return KhumsMoneySourceModel(
      id: entry.id,
      khumsYearId: entry.khumsYearId,
      name: entry.name,
      amount: entry.amount,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  KhumsInstallmentModel _mapInstallmentEntryToModel(
    KhumsInstallmentEntry entry,
  ) {
    return KhumsInstallmentModel(
      id: entry.id,
      khumsYearId: entry.khumsYearId,
      installmentNumber: entry.installmentNumber,
      amount: entry.amount,
      dueDate: entry.dueDate,
      paidAt: entry.paidAt,
      isPaid: entry.isPaid,
    );
  }
}
