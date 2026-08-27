class KhumsInstallmentModel {
  final int id;
  final int khumsYearId;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidAt;
  final bool isPaid;

  const KhumsInstallmentModel({
    required this.id,
    required this.khumsYearId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    this.paidAt,
    required this.isPaid,
  });

  KhumsInstallmentModel copyWith({
    int? id,
    int? khumsYearId,
    int? installmentNumber,
    double? amount,
    DateTime? dueDate,
    DateTime? paidAt,
    bool? isPaid,
  }) {
    return KhumsInstallmentModel(
      id: id ?? this.id,
      khumsYearId: khumsYearId ?? this.khumsYearId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
