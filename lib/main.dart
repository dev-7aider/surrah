import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockaw/core/app.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/router/app_router.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/core/services/device_info/device_info.dart';
import 'package:pockaw/core/services/package_info/package_info_provider.dart';
import 'package:pockaw/core/services/widget_service/widget_service.dart';
import 'package:pockaw/core/utils/logger.dart';
import 'package:pockaw/features/authentication/presentation/riverpod/auth_provider.dart';
import 'package:pockaw/features/user_activity/data/enum/user_activity_action.dart';
import 'package:pockaw/features/user_activity/riverpod/user_activity_provider.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Instant session check via SharedPreferences cache
  final auth = container.read(authStateProvider.notifier);
  final user = await auth.getSession();
  final initialLocation = user == null ? Routes.onboarding : Routes.main;

  // Initialize router immediately with the correct destination
  initRouter(initialLocation: initialLocation);

  // Mount Flutter UI immediately so native splash disappears without delay
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  debugPrint('⚡ [STARTUP OPTIMIZED] UI mounted and runApp called in: ${sw.elapsedMilliseconds}ms');

  // Defer background tasks until initial frame rendering has completely settled
  Future.delayed(const Duration(milliseconds: 1500), () async {
    // 1. Initialize Home Widget settings
    await WidgetService.initialize();

    // 2. Warm up DB and essential services
    container.read(databaseProvider);
    container.read(deviceInfoUtilProvider);
    await container.read(packageInfoServiceProvider).init();

    // 3. Log launch activities
    final activityService = container.read(userActivityServiceProvider);
    await activityService.logActivity(
      action: UserActivityAction.appLaunched,
    );
    if (user != null) {
      await activityService.logActivity(
        action: UserActivityAction.signInWithSession,
      );
    }

    // 4. Clean up log file on mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final file = await Log.getLogFile();
      file?.delete();
    }
  });
}
