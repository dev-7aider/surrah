import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/dialogs/toast.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/khums/data/model/khums_installment_model.dart';
import 'package:pockaw/features/khums/data/model/khums_year_model.dart';
import 'package:pockaw/features/khums/presentation/components/khums_status_badge.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';

class KhumsDashboardHolder extends ConsumerWidget {
  const KhumsDashboardHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final activeYearAsync = ref.watch(activeKhumsYearProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.khums, style: AppTextStyles.heading6),
                InkWell(
                  onTap: () => context.push(Routes.khums),
                  borderRadius: BorderRadius.circular(AppRadius.radius4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing8,
                      vertical: AppSpacing.spacing4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.seeAll,
                          style: AppTextStyles.body4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const Gap(AppSpacing.spacing4),
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
          const Gap(AppSpacing.spacing8),
          activeYearAsync.when(
            data: (year) {
              if (year == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing16,
                  ),
                  child: InkWell(
                    onTap: () => context.push(Routes.khums),
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.spacing12),
                      decoration: BoxDecoration(
                        color: context.secondaryBackground,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius12),
                        border: Border.all(
                          color: context.secondaryBorderLighter,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.spacing8),
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.radius8),
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSafe,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const Gap(AppSpacing.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.khumsSetupTitle,
                                  style: AppTextStyles.body3.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(AppSpacing.spacing2),
                                Text(
                                  l10n.khumsSetupDesc,
                                  style: AppTextStyles.body4.copyWith(
                                    color: context.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final installmentsAsync =
                  ref.watch(khumsInstallmentsProvider(year.id));

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing16,
                ),
                child: installmentsAsync.when(
                  data: (installments) {
                    final unpaidInstallments =
                        installments.where((i) => !i.isPaid).toList();
                    final nextInstallment = unpaidInstallments.isNotEmpty
                        ? unpaidInstallments.first
                        : null;

                    return _buildConnectedKhumsCard(
                      context: context,
                      ref: ref,
                      year: year,
                      locale: locale,
                      l10n: l10n,
                      nextInstallment: nextInstallment,
                    );
                  },
                  loading: () => _buildConnectedKhumsCard(
                    context: context,
                    ref: ref,
                    year: year,
                    locale: locale,
                    l10n: l10n,
                    nextInstallment: null,
                  ),
                  error: (e, st) => _buildConnectedKhumsCard(
                    context: context,
                    ref: ref,
                    year: year,
                    locale: locale,
                    l10n: l10n,
                    nextInstallment: null,
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedKhumsCard({
    required BuildContext context,
    required WidgetRef ref,
    required KhumsYearModel year,
    required Locale locale,
    required AppLocalizations l10n,
    required KhumsInstallmentModel? nextInstallment,
  }) {
    final hasNextInstallment = nextInstallment != null;

    return Container(
      decoration: BoxDecoration(
        color: context.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(
          color: context.secondaryBorderLighter,
        ),
      ),
      child: Column(
        children: [
          // Main Khums Year Card (Top)
          InkWell(
            onTap: () => context.push(Routes.khums),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppRadius.radius12),
              bottom: Radius.circular(
                hasNextInstallment ? 0 : AppRadius.radius12,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.spacing4),
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.radius8),
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedSafe,
                                color: AppColors.primary,
                                size: 15,
                              ),
                            ),
                            const Gap(AppSpacing.spacing8),
                            Text(
                              '${year.hijriStartYear} AH',
                              style: AppTextStyles.body3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(AppSpacing.spacing4),
                            Expanded(
                              child: Text(
                                '• ${year.formatHijriRange(locale)}',
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(AppSpacing.spacing8),
                      KhumsStatusBadge(status: year.paymentStatus),
                    ],
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
                              fontSize: 11,
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
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
          ),

          // Attached Ticket-style Next Installment Card (Bottom)
          if (hasNextInstallment) ...[
            _buildTicketDivider(context),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary50.withAlpha(45),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.radius12),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing12,
                vertical: AppSpacing.spacing8,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spacing4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadius.radius8),
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                  const Gap(AppSpacing.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.khumsNextInstallment,
                              style: AppTextStyles.body4.copyWith(
                                color: context.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              '(${l10n.khumsMonthN(nextInstallment.installmentNumber)})',
                              style: AppTextStyles.body4.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.spacing2),
                        Text(
                          nextInstallment.amount.toPriceFormat(),
                          style: AppTextStyles.numericHeading.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(khumsDaoProvider).toggleInstallmentPaid(
                            installmentId: nextInstallment.id,
                            khumsYearId: year.id,
                            isPaid: true,
                          );
                      Toast.show(
                        '${l10n.khumsInstallmentPaidSuccess} (${l10n.khumsMonthN(nextInstallment.installmentNumber)})',
                        type: ToastificationType.success,
                      );
                    },
                    borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing8,
                        vertical: AppSpacing.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenAlpha10,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusFull),
                        border: Border.all(
                          color: AppColors.green700.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: AppColors.green700,
                          ),
                          const Gap(AppSpacing.spacing4),
                          Text(
                            l10n.khumsMarkAsPaidShort,
                            style: AppTextStyles.body4.copyWith(
                              color: AppColors.green700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketDivider(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dashed / solid thin separator line
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing8),
          height: 1,
          color: context.secondaryBorderLighter,
        ),
        // Left notch
        Positioned(
          left: -6,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Right notch
        Positioned(
          right: -6,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
