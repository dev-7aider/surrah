/// A data model to hold all database records for backup and restore operations.
/// Each list contains maps representing rows from a specific database table.
class BackupData {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> wallets;
  final List<Map<String, dynamic>> budgets;
  final List<Map<String, dynamic>> goals;
  final List<Map<String, dynamic>> checklistItems;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> debts;
  final List<Map<String, dynamic>> debtPayments;
  final List<Map<String, dynamic>> khumsYears;
  final List<Map<String, dynamic>> khumsMoneySources;
  final List<Map<String, dynamic>> khumsInstallments;
  final List<Map<String, dynamic>> plannedPurchases;
  final List<Map<String, dynamic>> userActivities;

  BackupData({
    required this.users,
    required this.categories,
    required this.wallets,
    required this.budgets,
    required this.goals,
    required this.checklistItems,
    required this.transactions,
    this.debts = const [],
    this.debtPayments = const [],
    this.khumsYears = const [],
    this.khumsMoneySources = const [],
    this.khumsInstallments = const [],
    this.plannedPurchases = const [],
    this.userActivities = const [],
  });

  /// Converts this [BackupData] instance into a JSON-serializable map.
  Map<String, dynamic> toJson() => {
    'users': users,
    'categories': categories,
    'wallets': wallets,
    'budgets': budgets,
    'goals': goals,
    'checklistItems': checklistItems,
    'transactions': transactions,
    'debts': debts,
    'debtPayments': debtPayments,
    'khumsYears': khumsYears,
    'khumsMoneySources': khumsMoneySources,
    'khumsInstallments': khumsInstallments,
    'plannedPurchases': plannedPurchases,
    'userActivities': userActivities,
  };

  /// Creates a [BackupData] instance from a JSON map with safe defaults for backward compatibility.
  factory BackupData.fromJson(Map<String, dynamic> json) => BackupData(
    users: (json['users'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    categories: (json['categories'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    wallets: (json['wallets'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    budgets: (json['budgets'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    goals: (json['goals'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    checklistItems:
        (json['checklistItems'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    transactions:
        (json['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    debts: (json['debts'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    debtPayments:
        (json['debtPayments'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    khumsYears:
        (json['khumsYears'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    khumsMoneySources:
        (json['khumsMoneySources'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    khumsInstallments:
        (json['khumsInstallments'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    plannedPurchases:
        (json['plannedPurchases'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    userActivities:
        (json['userActivities'] as List?)?.cast<Map<String, dynamic>>() ?? [],
  );
}
