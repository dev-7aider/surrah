import 'package:go_router/go_router.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_dashboard_screen.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_history_screen.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_onboarding_screen.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_payment_plan_screen.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_year_detail_screen.dart';

class KhumsRouter {
  static final List<GoRoute> routes = [
    GoRoute(
      path: Routes.khums,
      builder: (context, state) => const KhumsDashboardScreen(),
    ),
    GoRoute(
      path: Routes.khumsOnboarding,
      builder: (context, state) => const KhumsOnboardingScreen(),
    ),
    GoRoute(
      path: Routes.khumsHistory,
      builder: (context, state) => const KhumsHistoryScreen(),
    ),
    GoRoute(
      path: Routes.khumsPayment,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return KhumsPaymentPlanScreen(khumsYearId: id);
      },
    ),
    GoRoute(
      path: Routes.khumsDetail,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return KhumsYearDetailScreen(yearId: id);
      },
    ),
  ];
}
