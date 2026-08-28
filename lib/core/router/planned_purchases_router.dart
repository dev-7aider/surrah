import 'package:go_router/go_router.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/planned_purchases/presentation/screens/planned_purchases_history_screen.dart';
import 'package:pockaw/features/planned_purchases/presentation/screens/planned_purchases_screen.dart';

class PlannedPurchasesRouter {
  static List<RouteBase> get routes => [
        GoRoute(
          path: Routes.plannedPurchases,
          builder: (context, state) => const PlannedPurchasesScreen(),
        ),
        GoRoute(
          path: Routes.plannedPurchasesHistory,
          builder: (context, state) => const PlannedPurchasesHistoryScreen(),
        ),
      ];
}
