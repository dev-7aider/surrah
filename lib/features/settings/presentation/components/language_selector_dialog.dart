import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/bottom_sheets/custom_bottom_sheet.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/extensions/text_style_extensions.dart';
import 'package:pockaw/core/localization/locale_provider.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context);

    final languages = [
      (
        code: null,
        title: l10n.systemDefault,
        subtitle: 'Auto / تلقائي',
        icon: HugeIcons.strokeRoundedSmartPhone01,
      ),
      (
        code: 'en',
        title: l10n.english,
        subtitle: 'English',
        icon: HugeIcons.strokeRoundedLanguageSkill,
      ),
      (
        code: 'ar',
        title: l10n.arabic,
        subtitle: 'العربية',
        icon: HugeIcons.strokeRoundedGlobal,
      ),
    ];

    return CustomBottomSheet(
      title: l10n.selectLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...languages.map((lang) {
            final bool isSelected = currentLocale?.languageCode == lang.code;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spacing12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.spacing12),
                  onTap: () {
                    final locale = lang.code != null ? Locale(lang.code!) : null;
                    ref.read(localeNotifierProvider.notifier).setLocale(locale);
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing16,
                      vertical: AppSpacing.spacing12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.purpleBackground
                          : Theme.of(context).cardColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(AppSpacing.spacing12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : context.secondaryBorderLighter,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.spacing8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withAlpha(25)
                                : AppColors.secondaryAlpha10,
                            borderRadius: BorderRadius.circular(AppSpacing.spacing8),
                          ),
                          child: HugeIcon(
                            icon: lang.icon,
                            color: isSelected
                                ? AppColors.primary
                                : context.secondaryText,
                            size: 20,
                          ),
                        ),
                        const Gap(AppSpacing.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.title,
                                style: AppTextStyles.body2.bold.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : context.secondaryText,
                                ),
                              ),
                              Text(
                                lang.subtitle,
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText.withAlpha(160),
                                ),
                              ),
                            ],
                          ),
                        ),
                        HugeIcon(
                          icon: isSelected
                              ? HugeIcons.strokeRoundedCheckmarkCircle01
                              : HugeIcons.strokeRoundedCircle,
                          color: isSelected
                              ? AppColors.primary
                              : context.secondaryText.withAlpha(100),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    context.openBottomSheet(
      child: const LanguageSelectorDialog(),
    );
  }
}
