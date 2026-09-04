import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/bottom_sheets/alert_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/menu_tile_button.dart';
import 'package:pockaw/core/components/chips/custom_currency_chip.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/core/services/package_info/package_info_provider.dart';
import 'package:pockaw/features/authentication/presentation/riverpod/auth_provider.dart';
import 'package:pockaw/features/main/presentation/components/profile_picture.dart';
import 'package:pockaw/features/settings/presentation/components/report_log_file_dialog.dart';
import 'package:pockaw/features/settings/presentation/components/settings_group_holder.dart';
import 'package:pockaw/features/theme_switcher/presentation/components/theme_mode_switcher.dart';
import 'package:pockaw/features/user_activity/riverpod/user_activity_provider.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/localization/locale_provider.dart';
import 'package:pockaw/core/services/widget_service/presentation/add_widget_prompt_bottom_sheet.dart';
import 'package:pockaw/features/currency_picker/data/models/currency.dart';
import 'package:pockaw/features/currency_picker/presentation/riverpod/currency_picker_provider.dart';
import 'package:pockaw/l10n/app_localizations.dart';
import 'package:pockaw/features/settings/presentation/components/language_selector_dialog.dart';
import 'package:pockaw/features/wallet/data/model/wallet_model.dart';
import 'package:pockaw/features/wallet/data/repositories/wallet_repo.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';

part '../components/app_version_info.dart';
part '../components/profile_card.dart';
part '../components/settings_app_info_group.dart';
part '../components/settings_data_group.dart';
part '../components/settings_finance_group.dart';
part '../components/settings_preferences_group.dart';
part '../components/settings_profile_group.dart';
part '../components/settings_session_group.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return CustomScaffold(
      title: l10n.settings,
      showBackButton: true,
      actions: [ThemeModeSwitcher()],
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
        child: Column(
          children: [
            ProfileCard(),
            SettingsProfileGroup(),
            SettingsPreferencesGroup(),
            SettingsFinanceGroup(),
            SettingsDataGroup(),
            SettingsAppInfoGroup(),
            SettingsSessionGroup(),
            AppVersionInfo(),
          ],
        ),
      ),
    );
  }
}
