import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/extensions/screen_utils_extensions.dart';
import 'package:pockaw/features/budget/presentation/screens/budget_screen.dart';
import 'package:pockaw/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:pockaw/features/goal/presentation/screens/goal_screen.dart';
import 'package:pockaw/features/main/presentation/components/custom_bottom_app_bar.dart';
import 'package:pockaw/features/main/presentation/riverpod/main_page_view_riverpod.dart';
import 'package:pockaw/core/app.dart';
import 'package:pockaw/core/services/widget_service/widget_service.dart';
import 'package:pockaw/features/transaction/presentation/screens/transaction_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(pageControllerProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingUri = WidgetService.consumePendingUri();
      if (pendingUri != null && mounted) {
        handleWidgetUri(pendingUri);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(pageControllerProvider);
    if (_pageController.hasClients && _pageController.page?.round() != currentPage) {
      _pageController.jumpToPage(currentPage);
    }

    final Widget pageViewWidget = PageView.builder(
      controller: _pageController,
      itemCount: 4,
      onPageChanged: (value) {
        ref.read(pageControllerProvider.notifier).setPage(value);
      },
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return const DashboardScreen();
          case 1:
            return const TransactionScreen();
          case 2:
            return const GoalScreen();
          case 3:
            return const BudgetScreen();
          default:
            return const SizedBox.shrink();
        }
      },
    );

    final Widget navigationControls = CustomBottomAppBar(
      pageController: _pageController,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Material(
        child: context.isDesktopLayout
            ? Row(
                children: [
                  navigationControls, // This will render as a sidebar
                  Expanded(child: pageViewWidget),
                ],
              )
            : SafeArea(
                top: false,
                child: Stack(
                  children: [
                    pageViewWidget,
                    Positioned(
                      bottom: AppSpacing.spacing8,
                      left: AppSpacing.spacing16,
                      right: AppSpacing.spacing16,
                      child: navigationControls,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
