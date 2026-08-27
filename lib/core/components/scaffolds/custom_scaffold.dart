import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/custom_icon_button.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/text_style_extensions.dart';
import 'package:pockaw/features/wallet/data/model/wallet_model.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';

import 'package:pockaw/l10n/app_localizations.dart';

part 'balance_status_bar.dart';
part 'balance_status_bar_content.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final bool showBalance;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;

  const CustomScaffold({
    super.key,
    required this.body,
    this.title = '',
    this.showBackButton = true,
    this.showBalance = true,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          backgroundColor: context.colors.surface,
          titleSpacing: showBackButton ? 0 : AppSpacing.spacing20,
          toolbarHeight: 60,
          elevation: 0,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          leading: !showBackButton
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: CustomIconButton(
                    context,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    icon: Directionality.of(context) == TextDirection.rtl
                        ? HugeIcons.strokeRoundedArrowRight01
                        : HugeIcons.strokeRoundedArrowLeft01,
                    themeMode: context.themeMode,
                  ),
                ),
          title: title.isEmpty
              ? null
              : Text(title, style: AppTextStyles.heading6),
          actions: [...?actions, const Gap(AppSpacing.spacing16)],
          //  bottom: !showBalance ? null : BalanceStatusBar(),
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
