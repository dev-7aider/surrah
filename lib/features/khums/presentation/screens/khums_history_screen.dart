import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/khums/presentation/components/khums_status_badge.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsHistoryScreen extends ConsumerWidget {
  const KhumsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final allYearsAsync = ref.watch(allKhumsYearsProvider);

    return CustomScaffold(
      title: l10n.khumsHistory,
      showBackButton: true,
      body: allYearsAsync.when(
        data: (years) {
          if (years.isEmpty) {
            return Center(
              child: Text(l10n.noData, style: AppTextStyles.body2),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            itemCount: years.length,
            separatorBuilder: (context, index) =>
                const Gap(AppSpacing.spacing12),
            itemBuilder: (context, index) {
              final year = years[index];

              return InkWell(
                onTap: () {
                  context.push(
                    '${Routes.khums}/detail/${year.id}',
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                child: Container(
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
                      const Gap(AppSpacing.spacing8),
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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
