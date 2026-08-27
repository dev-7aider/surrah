class KhumsMoneySourceModel {
  final int id;
  final int khumsYearId;
  final String name;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KhumsMoneySourceModel({
    required this.id,
    required this.khumsYearId,
    required this.name,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  KhumsMoneySourceModel copyWith({
    int? id,
    int? khumsYearId,
    String? name,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KhumsMoneySourceModel(
      id: id ?? this.id,
      khumsYearId: khumsYearId ?? this.khumsYearId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
