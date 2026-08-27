import 'package:drift/drift.dart';

@DataClassName('KhumsYearEntry')
class KhumsYears extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hijriStartDay => integer()();
  IntColumn get hijriStartMonth => integer()();
  IntColumn get hijriStartYear => integer()();
  DateTimeColumn get gregorianStartDate => dateTime()();
  DateTimeColumn get gregorianEndDate => dateTime()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  RealColumn get khumsAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentType =>
      text().withDefault(const Constant('none'))(); // none, full, installments
  TextColumn get paymentStatus =>
      text().withDefault(const Constant('notPaid'))(); // notPaid, partiallyPaid, paid
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
