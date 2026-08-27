import 'package:drift/drift.dart';
import 'package:pockaw/core/database/tables/khums_years_table.dart';

@DataClassName('KhumsMoneySourceEntry')
class KhumsMoneySources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get khumsYearId =>
      integer().references(KhumsYears, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
