import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/custom_icon_button.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/khums/presentation/components/add_money_source_bottom_sheet.dart';
import 'package:pockaw/features/khums/presentation/components/khums_comparison_card.dart';
import 'package:pockaw/features/khums/presentation/components/khums_money_source_tile.dart';
import 'package:pockaw/features/khums/presentation/components/khums_status_badge.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_onboarding_screen.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsDashboardScreen extends ConsumerWidget {
  const KhumsDashboardScreen({super.key});

  void _showAddSourceModal(BuildContext context, int yearId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMoneySourceBottomSheet(khumsYearId: yearId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final activeYearAsync = ref.watch(activeKhumsYearProvider);
    final comparison = ref.watch(khumsComparisonProvider);

    return activeYearAsync.when(
      data: (year) {
        if (year == null) {
          return const KhumsOnboardingScreen();
        }

        return CustomScaffold(
          title: l10n.khums,
          showBackButton: true,
          actions: [
            CustomIconButton(
              context,
              onPressed: () => context.push(Routes.khumsHistory),
              icon: HugeIcons.strokeRoundedClock01,
              themeMode: context.themeMode,
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Khums Year Header Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing16),
                  decoration: BoxDecoration(
                    color: context.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppRadius.radius16),
                    border: Border.all(color: context.secondaryBorderLighter),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.khumsCurrentYear,
                            style: AppTextStyles.body4.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                          KhumsStatusBadge(status: year.paymentStatus),
                        ],
                      ),
                      const Gap(AppSpacing.spacing4),
                      Text(
                        year.formatHijriRange(locale),
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(AppSpacing.spacing12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing8,
                          vertical: AppSpacing.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedHourglass,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              l10n.khumsDaysRemaining(year.daysRemaining),
                              style: AppTextStyles.body4.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.spacing16),

                // Yearly Financial Comparison (if any previous years exist)
                KhumsComparisonCard(comparison: comparison),

                // Financial Overview (Total & Khums)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.spacing12),
                        decoration: BoxDecoration(
                          color: context.secondaryBackground,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                          border:
                              Border.all(color: context.secondaryBorderLighter),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.khumsTotalMoney,
                              style: AppTextStyles.body4.copyWith(
                                color: context.secondaryText,
                              ),
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              year.totalAmount.toPriceFormat(),
                              style: AppTextStyles.numericHeading.copyWith(
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.spacing8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.spacing12),
                        decoration: BoxDecoration(
                          color: context.secondaryBackground,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(50),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.khumsAmount,
                              style: AppTextStyles.body4.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              year.khumsAmount.toPriceFormat(),
                              style: AppTextStyles.numericHeading.copyWith(
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.spacing16),

                // Calculate / Track Payment Button
                PrimaryButton(
                  label: l10n.khumsCalculateKhums,
                  onPressed: () {
                    context.push('${Routes.khums}/payment/${year.id}');
                  },
                ),
                const Gap(AppSpacing.spacing20),

                // Manage Money Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.khumsMyMoney,
                      style: AppTextStyles.heading6,
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddSourceModal(context, year.id),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedPlusSign,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      label: Text(
                        l10n.khumsAddMoney,
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.spacing8),

                // Money Sources List
                Consumer(
                  builder: (context, ref, child) {
                    final sourcesAsync =
                        ref.watch(khumsMoneySourcesProvider(year.id));

                    return sourcesAsync.when(
                      data: (sources) {
                        if (sources.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.spacing20),
                            decoration: BoxDecoration(
                              color: context.secondaryBackground,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.radius12),
                              border: Border.all(
                                color: context.secondaryBorderLighter,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                l10n.khumsNoMoneySources,
                                style: AppTextStyles.body3.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: sources.map((source) {
                            return KhumsMoneySourceTile(
                              source: source,
                              onEdit: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      AddMoneySourceBottomSheet(
                                    khumsYearId: year.id,
                                    existingSource: source,
                                  ),
                                );
                              },
                              onDelete: () {
                                ref.read(khumsDaoProvider).deleteMoneySource(
                                      source.id,
                                      year.id,
                                    );
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, st) => Text('Error: $e'),
                    );
                  },
                ),
                const Gap(AppSpacing.spacing20),

                // Religious Disclaimer
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
                const Gap(AppSpacing.spacing40),
              ],
            ),
          ),
        );
      },
      loading: () => const CustomScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => CustomScaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
