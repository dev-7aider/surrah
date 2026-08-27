import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/database/pockaw_database.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/core/utils/hijri_calendar_helper.dart';
import 'package:pockaw/features/khums/presentation/components/hijri_date_picker_dialog.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsOnboardingScreen extends ConsumerStatefulWidget {
  const KhumsOnboardingScreen({super.key});

  @override
  ConsumerState<KhumsOnboardingScreen> createState() =>
      _KhumsOnboardingScreenState();
}

class _KhumsOnboardingScreenState extends ConsumerState<KhumsOnboardingScreen> {
  HijriDate? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = HijriDate.fromGregorian(DateTime.now());
  }

  Future<void> _pickHijriDate() async {
    final picked = await context.openBottomSheet<HijriDate>(
      child: HijriDatePickerDialog(initialDate: _selectedDate),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createKhumsYear() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);
    final dao = ref.read(khumsDaoProvider);

    final gregorianStart = _selectedDate!.toGregorian();
    final gregorianEnd = DateTime(
      gregorianStart.year + 1,
      gregorianStart.month,
      gregorianStart.day,
    );

    final companion = KhumsYearsCompanion(
      hijriStartDay: drift.Value(_selectedDate!.day),
      hijriStartMonth: drift.Value(_selectedDate!.month),
      hijriStartYear: drift.Value(_selectedDate!.year),
      gregorianStartDate: drift.Value(gregorianStart),
      gregorianEndDate: drift.Value(gregorianEnd),
      totalAmount: const drift.Value(0.0),
      khumsAmount: const drift.Value(0.0),
      paymentType: const drift.Value('none'),
      paymentStatus: const drift.Value('notPaid'),
      isArchived: const drift.Value(false),
      createdAt: drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
    );

    await dao.insertKhumsYear(companion);

    if (mounted) {
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.khumsYearCreatedSuccess),
          backgroundColor: AppColors.green700,
        ),
      );
      context.go(Routes.khums);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return CustomScaffold(
      title: l10n.khums,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(AppSpacing.spacing12),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(AppRadius.radius16),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSafe,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.spacing16),
            Text(
              l10n.khumsSetupTitle,
              style: AppTextStyles.heading5,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.spacing8),
            Text(
              l10n.khumsSetupDesc,
              style: AppTextStyles.body4.copyWith(
                color: context.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.spacing24),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: context.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(color: context.secondaryBorderLighter),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.khumsDoYouHaveYear,
                    style: AppTextStyles.body3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.spacing12),
                  InkWell(
                    onTap: _pickHijriDate,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.spacing12),
                      decoration: BoxDecoration(
                        color: context.secondaryBackground,
                        borderRadius: BorderRadius.circular(AppRadius.radius12),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const Gap(AppSpacing.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.khumsSelectStartDate,
                                  style: AppTextStyles.body4.copyWith(
                                    color: context.secondaryText,
                                  ),
                                ),
                                const Gap(AppSpacing.spacing2),
                                Text(
                                  _selectedDate?.format(locale) ?? '',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          HugeIcon(
                            icon: Directionality.of(context) == TextDirection.rtl
                                ? HugeIcons.strokeRoundedArrowLeft01
                                : HugeIcons.strokeRoundedArrowRight01,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.spacing16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: context.secondaryBackground.withAlpha(120),
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(color: context.secondaryBorderLighter),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const Gap(AppSpacing.spacing8),
                  Expanded(
                    child: Text(
                      l10n.khumsDisclaimer,
                      style: AppTextStyles.body4.copyWith(
                        color: context.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.spacing24),
            PrimaryButton(
              label: l10n.save,
              isLoading: _isLoading,
              onPressed: _createKhumsYear,
            ),
          ],
        ),
      ),
    );
  }
}
