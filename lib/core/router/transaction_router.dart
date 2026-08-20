import 'package:go_router/go_router.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/transaction/data/model/transaction_model.dart';
import 'package:pockaw/features/transaction/presentation/screens/transaction_form.dart';

class TransactionRouter {
  static final routes = <GoRoute>[
    GoRoute(
      path: Routes.transactionForm,
      builder: (context, state) {
        final rawType = state.uri.queryParameters['type']?.toLowerCase();
        TransactionType? initialType;
        if (rawType == 'income') {
          initialType = TransactionType.income;
        } else if (rawType == 'transfer') {
          initialType = TransactionType.transfer;
        } else if (rawType == 'expense') {
          initialType = TransactionType.expense;
        }
        return TransactionForm(initialTransactionType: initialType);
      },
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) {
        final int? transactionId = int.tryParse(
          state.pathParameters['id'] ?? '',
        );
        return TransactionForm(transactionId: transactionId);
      },
    ),
  ];
}
