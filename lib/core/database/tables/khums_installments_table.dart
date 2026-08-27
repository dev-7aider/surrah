import 'package:drift/drift.dart';
import 'package:pockaw/core/database/tables/khums_years_table.dart';

@DataClassName('KhumsInstallmentEntry')
class KhumsInstallments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get khumsYearId =>
      integer().references(KhumsYears, #id, onDelete: KeyAction.cascade)();
  IntColumn get installmentNumber => integer()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get paidAt => dateTime().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
}
