import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockaw/core/database/daos/khums_dao.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/features/khums/data/model/khums_installment_model.dart';
import 'package:pockaw/features/khums/data/model/khums_money_source_model.dart';
import 'package:pockaw/features/khums/data/model/khums_year_model.dart';

final khumsDaoProvider = Provider<KhumsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.khumsDao;
});

final activeKhumsYearProvider =
    StreamProvider.autoDispose<KhumsYearModel?>((ref) {
  final khumsDao = ref.watch(khumsDaoProvider);
  return khumsDao.watchActiveKhumsYear();
});

final allKhumsYearsProvider =
    StreamProvider.autoDispose<List<KhumsYearModel>>((ref) {
  final khumsDao = ref.watch(khumsDaoProvider);
  return khumsDao.watchAllKhumsYears();
});

final khumsYearDetailProvider =
    StreamProvider.autoDispose.family<KhumsYearModel?, int>((ref, yearId) {
  final khumsDao = ref.watch(khumsDaoProvider);
  return khumsDao.watchKhumsYearById(yearId);
});

final khumsMoneySourcesProvider = StreamProvider.autoDispose
    .family<List<KhumsMoneySourceModel>, int>((ref, yearId) {
  final khumsDao = ref.watch(khumsDaoProvider);
  return khumsDao.watchMoneySources(yearId);
});

final khumsInstallmentsProvider = StreamProvider.autoDispose
    .family<List<KhumsInstallmentModel>, int>((ref, yearId) {
  final khumsDao = ref.watch(khumsDaoProvider);
  return khumsDao.watchInstallments(yearId);
});

class KhumsComparisonData {
  final double currentAmount;
  final double previousAmount;
  final double difference;
  final double percentageChange;
  final bool hasPrevious;

  const KhumsComparisonData({
    required this.currentAmount,
    required this.previousAmount,
    required this.difference,
    required this.percentageChange,
    required this.hasPrevious,
  });
}

final khumsComparisonProvider =
    Provider.autoDispose<KhumsComparisonData>((ref) {
  final allYearsAsync = ref.watch(allKhumsYearsProvider);

  return allYearsAsync.maybeWhen(
    data: (years) {
      if (years.isEmpty) {
        return const KhumsComparisonData(
          currentAmount: 0.0,
          previousAmount: 0.0,
          difference: 0.0,
          percentageChange: 0.0,
          hasPrevious: false,
        );
      }

      final currentYear = years.first;
      if (years.length == 1) {
        return KhumsComparisonData(
          currentAmount: currentYear.totalAmount,
          previousAmount: 0.0,
          difference: currentYear.totalAmount,
          percentageChange: 0.0,
          hasPrevious: false,
        );
      }

      final previousYear = years[1];
      final diff = currentYear.totalAmount - previousYear.totalAmount;
      final pct = previousYear.totalAmount > 0
          ? (diff / previousYear.totalAmount) * 100
          : 0.0;

      return KhumsComparisonData(
        currentAmount: currentYear.totalAmount,
        previousAmount: previousYear.totalAmount,
        difference: diff,
        percentageChange: pct,
        hasPrevious: true,
      );
    },
    orElse: () => const KhumsComparisonData(
      currentAmount: 0.0,
      previousAmount: 0.0,
      difference: 0.0,
      percentageChange: 0.0,
      hasPrevious: false,
    ),
  );
});
