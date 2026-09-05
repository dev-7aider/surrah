import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/khums/presentation/components/khums_status_badge.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsYearDetailScreen extends ConsumerWidget {
  final int yearId;

  const KhumsYearDetailScreen({super.key, required this.yearId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final yearAsync = ref.watch(khumsYearDetailProvider(yearId));
    final sourcesAsync = ref.watch(khumsMoneySourcesProvider(yearId));
    final installmentsAsync = ref.watch(khumsInstallmentsProvider(yearId));

    return CustomScaffold(
      title: l10n.khumsYear,
      showBackButton: true,
      body: yearAsync.when(
        data: (year) {
          if (year == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${year.hijriStartYear} AH',
                            style: AppTextStyles.heading6.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          KhumsStatusBadge(status: year.paymentStatus),
                        ],
                      ),
                      const Gap(AppSpacing.spacing4),
                      Text(
                        year.formatHijriRange(locale), 
                        style: AppTextStyles.body4.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                      const Gap(AppSpacing.spacing12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.khumsTotalMoney,
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                              const Gap(AppSpacing.spacing2),
                              Text(
                                year.totalAmount.toPriceFormat(),
                                style: AppTextStyles.numericHeading.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.khumsAmount,
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                              const Gap(AppSpacing.spacing2),
                              Text(
                                year.khumsAmount.toPriceFormat(),
                                style: AppTextStyles.numericHeading.copyWith(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.spacing20),

                // Sources Section
                Text(l10n.khumsMyMoney, style: AppTextStyles.heading6),
                const Gap(AppSpacing.spacing8),
                sourcesAsync.when(
                  data: (sources) {
                    if (sources.isEmpty) {
                      return Text(
                        l10n.noData,
                        style: AppTextStyles.body3.copyWith(
                          color: context.secondaryText,
                        ),
                      );
                    }
                    return Column(
                      children: sources.map((s) {
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppSpacing.spacing8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spacing12,
                            vertical: AppSpacing.spacing8,
                          ),
                          decoration: BoxDecoration(
                            color: context.secondaryBackground,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius12),
                            border: Border.all(
                              color: context.secondaryBorderLighter,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.name, style: AppTextStyles.body3),
                              Text(
                                s.amount.toPriceFormat(),
                                style: AppTextStyles.numericHeading.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, st) => Text('Error: $e'),
                ),
                const Gap(AppSpacing.spacing20),

                // Installments / Payments if any
                installmentsAsync.when(
                  data: (installments) {
                    if (installments.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.khumsInstallments,
                          style: AppTextStyles.heading6,
                        ),
                        const Gap(AppSpacing.spacing8),
                        ...installments.map((inst) {
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.spacing8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacing12,
                              vertical: AppSpacing.spacing8,
                            ),
                            decoration: BoxDecoration(
                              color: inst.isPaid
                                  ? AppColors.greenAlpha10
                                  : context.secondaryBackground,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.radius12),
                              border: Border.all(
                                color: inst.isPaid
                                    ? AppColors.green700.withAlpha(40)
                                    : context.secondaryBorderLighter,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      inst.isPaid
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: inst.isPaid
                                          ? AppColors.green700
                                          : context.secondaryText,
                                      size: 16,
                                    ),
                                    const Gap(AppSpacing.spacing8),
                                    Text(
                                      l10n.khumsMonthN(inst.installmentNumber),
                                      style: AppTextStyles.body3,
                                    ),
                                  ],
                                ),
                                Text(
                                  inst.amount.toPriceFormat(),
                                  style: AppTextStyles.numericHeading.copyWith(
                                    fontSize: 14,
                                    color: inst.isPaid ? AppColors.green700 : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
