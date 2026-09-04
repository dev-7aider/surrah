import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_constants.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/router/app_router.dart';
import 'package:pockaw/features/theme_switcher/presentation/riverpod/theme_mode_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pockaw/core/localization/locale_provider.dart';
import 'package:pockaw/l10n/app_localizations.dart';

import 'package:home_widget/home_widget.dart';
import 'package:pockaw/core/constants/app_font_families.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/core/services/widget_service/widget_service.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';

void handleWidgetUri(Uri uri) {
  final host = uri.host.toLowerCase();
  final path = uri.path;
  final type = uri.queryParameters['type'];

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final currentPath = router.state.uri.toString();
    // If currently on splash or onboarding, store as pending to open once main screen is reached
    if (currentPath == Routes.splash || currentPath == Routes.onboarding) {
      WidgetService.setPendingUri(uri);
      return;
    }

    if (host == 'add_transaction' ||
        host == 'transaction-form' ||
        path.contains('add_transaction') ||
        path.contains('transaction-form')) {
      if (type != null && type.isNotEmpty) {
        router.push('${Routes.transactionForm}?type=$type');
      } else {
        router.push(Routes.transactionForm);
      }
    } else if (host == 'wallets' ||
        host == 'manage-wallets' ||
        path.contains('manage-wallets')) {
      router.push(Routes.manageWallets);
    } else if (host == 'transaction' || path.startsWith('/transaction/') || path.startsWith('transaction/')) {
      String txIdStr = '';
      if (host == 'transaction' && path.isNotEmpty) {
        txIdStr = path.replaceAll('/', '');
      } else if (path.contains('/transaction/')) {
        txIdStr = path.split('/transaction/').last;
      } else if (path.startsWith('/')) {
        txIdStr = path.substring(1);
      }
      final txId = int.tryParse(txIdStr);
      if (txId != null) {
        router.push('/transaction/$txId');
      }
    }
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<Uri?>? _widgetSubscription;

  @override
  void initState() {
    super.initState();
    _initHomeWidgetDeepLinks();
  }

  Future<void> _initHomeWidgetDeepLinks() async {
    _widgetSubscription = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        handleWidgetUri(uri);
      }
    });

    final initialUri = await WidgetService.getInitiallyLaunchedUrl();
    if (initialUri != null) {
      WidgetService.setPendingUri(initialUri);
      handleWidgetUri(initialUri);
    }
  }

  @override
  void dispose() {
    _widgetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(autoWidgetSyncProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeNotifierProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        onGenerateTitle: (context) =>
            AppLocalizations.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light, locale: locale),
        darkTheme: _buildTheme(Brightness.dark, locale: locale),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(
                context,
              ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
            ),
            child: child!,
          ),
          breakpoints: [
            const Breakpoint(
              start: 0,
              end: AppConstants.mobileBreakpointEnd,
              name: MOBILE,
            ),
            const Breakpoint(
              start: AppConstants.tabletBreakpointStart,
              end: AppConstants.tabletBreakpointEnd,
              name: TABLET,
            ),
            const Breakpoint(
              start: AppConstants.desktopBreakpointStart,
              end: AppConstants.desktopBreakpointEnd,
              name: DESKTOP,
            ),
            const Breakpoint(
              start: AppConstants.fourKBreakpointStart,
              end: double.infinity,
              name: '4K',
            ),
          ],
        ),
        routerConfig: router,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness, {Locale? locale}) {
    final isArabic = locale?.languageCode == 'ar';
    final activeFontFamily =
        isArabic ? AppFontFamilies.tajawal : AppConstants.fontFamilyPrimary;

    final colorScheme = brightness == Brightness.light
        ? const ColorScheme.light(
            primary: AppColors.primary,
            primaryContainer: AppColors.primary100,
            secondary: AppColors.secondary,
            secondaryContainer: AppColors.secondaryAlpha10,
            tertiary: AppColors.tertiary,
            tertiaryContainer: AppColors.tertiary100,
            error: AppColors.red,
            surface: AppColors.light,
          )
        : const ColorScheme.dark(
            primary: AppColors.primary400,
            primaryContainer: AppColors.primary900,
            secondary: AppColors.secondary400,
            secondaryContainer: AppColors.secondaryAlpha25,
            tertiary: AppColors.tertiary400,
            tertiaryContainer: AppColors.tertiary900,
            error: AppColors.red400,
            surface: AppColors.dark,
          );

    // Use FlexThemeData.dark for the dark theme.
    final baseTheme = brightness == Brightness.light
        ? FlexThemeData.light(
            colorScheme: colorScheme,
            useMaterial3: true,
            fontFamily: activeFontFamily,
            fontFamilyFallback: const [AppFontFamilies.tajawal],
          )
        : FlexThemeData.dark(
            colorScheme: colorScheme,
            useMaterial3: true,
            fontFamily: activeFontFamily,
            fontFamilyFallback: const [AppFontFamilies.tajawal],
          );

    return baseTheme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        hintStyle: AppTextStyles.body3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBarrierColor: colorScheme.shadow.withAlpha(180),
      ),
    );
  }
}
