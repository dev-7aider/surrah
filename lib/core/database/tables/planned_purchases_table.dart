import 'package:drift/drift.dart';

@DataClassName('PlannedPurchase')
class PlannedPurchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  RealColumn get estimatedPrice => real()();
  RealColumn get actualPrice => real().nullable()();
  TextColumn get currency => text().withDefault(const Constant('IQD'))();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get walletId => integer().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))(); // 0: urgentNeed, 1: nonUrgentImportant, 2: desireWant
  BoolColumn get isPurchased => boolean().withDefault(const Constant(false))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get purchasedAt => dateTime().nullable()();
  IntColumn get transactionId => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
