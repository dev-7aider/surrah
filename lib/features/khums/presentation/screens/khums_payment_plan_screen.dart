import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/chips/custom_chip.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_status.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_type.dart';
import 'package:pockaw/features/khums/data/model/khums_year_model.dart';
import 'package:pockaw/features/khums/presentation/components/khums_status_badge.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';

class KhumsPaymentPlanScreen extends ConsumerStatefulWidget {
  final int khumsYearId;

  const KhumsPaymentPlanScreen({super.key, required this.khumsYearId});

  @override
  ConsumerState<KhumsPaymentPlanScreen> createState() =>
      _KhumsPaymentPlanScreenState();
}

class _KhumsPaymentPlanScreenState
    extends ConsumerState<KhumsPaymentPlanScreen> {
  int _selectedMonths = 12;
  bool _isLoading = false;

  final List<int> _monthOptions = [3, 6, 12, 18, 24];

  Future<void> _payInFull(KhumsYearModel year) async {
    setState(() => _isLoading = true);
    final dao = ref.read(khumsDaoProvider);

    await dao.updatePaymentStatus(
      yearId: year.id,
      paymentType: KhumsPaymentType.full,
      paymentStatus: KhumsPaymentStatus.paid,
      paidAt: DateTime.now(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _createInstallments(KhumsYearModel year) async {
    setState(() => _isLoading = true);
    final dao = ref.read(khumsDaoProvider);

    await dao.setInstallmentsPlan(
      khumsYearId: year.id,
      months: _selectedMonths,
      khumsAmount: year.khumsAmount,
      startDate: DateTime.now(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final yearAsync = ref.watch(khumsYearDetailProvider(widget.khumsYearId));
    final installmentsAsync =
        ref.watch(khumsInstallmentsProvider(widget.khumsYearId));

    return CustomScaffold(
      title: l10n.khumsAmount,
      showBackButton: true,
      body: yearAsync.when(
        data: (year) {
          if (year == null) return const SizedBox.shrink();

          final isFullPaid = year.paymentType == KhumsPaymentType.full &&
              year.paymentStatus == KhumsPaymentStatus.paid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Khums Amount Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing16),
                  decoration: BoxDecoration(
                    color: context.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppRadius.radius16),
                    border: Border.all(color: context.secondaryBorderLighter),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.khumsAmount,
                            style: AppTextStyles.body4.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                          KhumsStatusBadge(status: year.paymentStatus),
                        ],
                      ),
                      const Gap(AppSpacing.spacing8),
                      Text(
                        year.khumsAmount.toPriceFormat(),
                        style: AppTextStyles.numericHeading.copyWith(
                          fontSize: 26,
                          color: AppColors.primary,
                        ),
                      ),
                      if (isFullPaid && year.paidAt != null) ...[
                        const Gap(AppSpacing.spacing4),
                        Text(
                          '${l10n.khumsPaid} ${year.paidAt!.day}/${year.paidAt!.month}/${year.paidAt!.year}',
                          style: AppTextStyles.body4.copyWith(
                            color: AppColors.green700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(AppSpacing.spacing20),

                Text(
                  l10n.khumsHowTrackPayment,
                  style: AppTextStyles.heading6,
                ),
                const Gap(AppSpacing.spacing12),

                // Pay in Full Option
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
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const Gap(AppSpacing.spacing8),
                          Text(
                            l10n.khumsPayInFull,
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.spacing12),
                      PrimaryButton(
                        label: isFullPaid ? '✓ ${l10n.khumsPaid}' : l10n.khumsMarkAsPaid,
                        isLoading: _isLoading,
                        onPressed: isFullPaid ? null : () => _payInFull(year),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.spacing12),

                // Installments Option
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
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const Gap(AppSpacing.spacing8),
                          Text(
                            l10n.khumsInstallments,
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.spacing12),

                      // Month Chips
                      Text(
                        isArabic ? 'اختر عدد الأشهر للتقسيط:' : 'Select installment period:',
                        style: AppTextStyles.body4.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                      const Gap(AppSpacing.spacing8),
                      Wrap(
                        spacing: AppSpacing.spacing8,
                        runSpacing: AppSpacing.spacing8,
                        children: _monthOptions.map((m) {
                          final isSelected = _selectedMonths == m;
                          return CustomChip(
                            label: l10n.khumsMonthCount(m),
                            background: isSelected ? AppColors.primary : AppColors.primary50,
                            foreground: isSelected ? Colors.white : AppColors.primary,
                            onTap: () {
                              setState(() => _selectedMonths = m);
                            },
                          );
                        }).toList(),
                      ),
                      const Gap(AppSpacing.spacing12),

                      PrimaryButton(
                        label: isArabic
                            ? 'توزيع الأقساط على $_selectedMonths شهر'
                            : 'Generate Plan ($_selectedMonths Months)',
                        isLoading: _isLoading,
                        onPressed: () => _createInstallments(year),
                      ),
                      const Gap(AppSpacing.spacing16),

                      // Installments List
                      installmentsAsync.when(
                        data: (installments) {
                          if (installments.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final paidAmount = installments
                              .where((i) => i.isPaid)
                              .fold<double>(0.0, (sum, i) => sum + i.amount);
                          final remainingAmount =
                              year.khumsAmount - paidAmount;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${paidAmount.toPriceFormat()} / ${year.khumsAmount.toPriceFormat()}',
                                    style: AppTextStyles.body3.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    l10n.khumsRemaining(
                                      remainingAmount.toPriceFormat(),
                                    ),
                                    style: AppTextStyles.body4.copyWith(
                                      color: context.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.spacing12),
                              ...installments.map((inst) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.spacing8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacing8,
                                    vertical: AppSpacing.spacing4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inst.isPaid
                                        ? AppColors.greenAlpha10
                                        : context.secondaryBackground,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.radius8,
                                    ),
                                    border: Border.all(
                                      color: inst.isPaid
                                          ? AppColors.green700.withAlpha(50)
                                          : context.secondaryBorderLighter,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          value: inst.isPaid,
                                          activeColor: AppColors.green700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.radius4),
                                          ),
                                          onChanged: (val) {
                                            ref
                                                .read(khumsDaoProvider)
                                                .toggleInstallmentPaid(
                                                  installmentId: inst.id,
                                                  khumsYearId: year.id,
                                                  isPaid: val ?? false,
                                                );
                                          },
                                        ),
                                      ),
                                      const Gap(AppSpacing.spacing4),
                                      Expanded(
                                        child: Text(
                                          l10n.khumsMonthN(
                                            inst.installmentNumber,
                                          ),
                                          style: AppTextStyles.body3.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        inst.amount.toPriceFormat(),
                                        style: AppTextStyles.numericHeading.copyWith(
                                          fontSize: 14,
                                          color: inst.isPaid
                                              ? AppColors.green700
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, st) => Text('Error: $e'),
                      ),
                    ],
                  ),
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
