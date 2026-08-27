import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/custom_icon_button.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/dialogs/toast.dart';
import 'package:pockaw/core/components/scaffolds/custom_scaffold.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/router/routes.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_status.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_type.dart';
import 'package:pockaw/features/khums/data/model/khums_year_model.dart';
import 'package:pockaw/features/khums/presentation/components/add_money_source_bottom_sheet.dart';
import 'package:pockaw/features/khums/presentation/components/khums_money_source_tile.dart';
import 'package:pockaw/features/khums/presentation/components/khums_segmented_progress_chart.dart';
import 'package:pockaw/features/khums/presentation/components/khums_status_badge.dart';
import 'package:pockaw/features/khums/presentation/riverpod/khums_providers.dart';
import 'package:pockaw/features/khums/presentation/screens/khums_onboarding_screen.dart';
import 'package:pockaw/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';

class KhumsDashboardScreen extends ConsumerStatefulWidget {
  const KhumsDashboardScreen({super.key});

  @override
  ConsumerState<KhumsDashboardScreen> createState() =>
      _KhumsDashboardScreenState();
}

class _KhumsDashboardScreenState extends ConsumerState<KhumsDashboardScreen> {
  int _selectedMonths = 12;
  final List<int> _monthOptions = [3, 6, 12, 18, 24];

  void _showAddSourceModal(BuildContext context, int yearId) {
    context.openBottomSheet(
      child: AddMoneySourceBottomSheet(khumsYearId: yearId),
    );
  }

  Future<void> _payInFull(KhumsYearModel year) async {
    final dao = ref.read(khumsDaoProvider);

    await dao.updatePaymentStatus(
      yearId: year.id,
      paymentType: KhumsPaymentType.full,
      paymentStatus: KhumsPaymentStatus.paid,
      paidAt: DateTime.now(),
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      Toast.show(
        l10n.khumsPaid,
        type: ToastificationType.success,
      );
    }
  }

  Future<void> _createInstallments(KhumsYearModel year) async {
    final dao = ref.read(khumsDaoProvider);

    await dao.setInstallmentsPlan(
      khumsYearId: year.id,
      months: _selectedMonths,
      khumsAmount: year.khumsAmount,
      startDate: DateTime.now(),
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      Toast.show(
        l10n.khumsInstallments,
        type: ToastificationType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final activeYearAsync = ref.watch(activeKhumsYearProvider);

    return activeYearAsync.when(
      data: (year) {
        if (year == null) {
          return const KhumsOnboardingScreen();
        }

        final installmentsAsync = ref.watch(khumsInstallmentsProvider(year.id));
        final isFullPaid =
            year.paymentType == KhumsPaymentType.full &&
            year.paymentStatus == KhumsPaymentStatus.paid;

        return CustomScaffold(
          title: l10n.khumsOverviewAndPayment,
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
                // 1. Current Khums Year Header Card with Primary/Secondary Theme accents & Segmented Chart
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
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(AppSpacing.spacing8),
                              Text(
                                l10n.khumsCurrentYear,
                                style: AppTextStyles.body4.copyWith(
                                  color: context.secondaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          KhumsStatusBadge(status: year.paymentStatus),
                        ],
                      ),
                      const Gap(AppSpacing.spacing12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  year.formatHijriRange(locale),
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                                const Gap(AppSpacing.spacing8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacing8,
                                    vertical: AppSpacing.spacing4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.radiusFull,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const HugeIcon(
                                        icon: HugeIcons.strokeRoundedCalendar03,
                                        color: AppColors.primary,
                                        size: 14,
                                      ),
                                      const Gap(AppSpacing.spacing4),
                                      Text(
                                        l10n.khumsDaysRemaining(
                                          year.daysRemaining,
                                        ),
                                        style: AppTextStyles.body4.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(AppSpacing.spacing12),
                          // Beautiful Segmented Circular Progress Chart based on months / installments
                          installmentsAsync.when(
                            data: (installments) {
                              final total = installments.isNotEmpty
                                  ? installments.length
                                  : (isFullPaid ? 1 : _selectedMonths);
                              final completed = isFullPaid
                                  ? total
                                  : installments.where((i) => i.isPaid).length;

                              return KhumsSegmentedProgressChart(
                                totalSegments: total,
                                completedSegments: completed,
                                size: 54,
                                strokeWidth: 5,
                                activeColor: AppColors.primary,
                                inactiveColor: context.secondaryBorderLighter,
                              );
                            },
                            loading: () => const SizedBox(
                              width: 54,
                              height: 54,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (e, st) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.spacing12),

                // 2. Financial Summary Card (Total Money & Khums Due) with Primary/Secondary Highlights
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing12),
                  decoration: BoxDecoration(
                    color: context.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    border: Border.all(
                      color: context.secondaryBorderLighter,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
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
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: AppColors.primary.withAlpha(40),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.khumsDue,
                              style: AppTextStyles.body4.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              year.khumsAmount.toPriceFormat(),
                              style: AppTextStyles.numericHeading.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
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
                const Gap(AppSpacing.spacing12),

                // 3. Recalculate and Plan Action Button
                PrimaryButton(
                  label: l10n.khumsRecalculateAndPlan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.radius8),
                  onPressed: () {
                    _createInstallments(year);
                  },
                ),
                const Gap(AppSpacing.spacing24),

                // 4. My Money Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.khumsMyMoney,
                      style: AppTextStyles.heading6,
                    ),
                    InkWell(
                      onTap: () => _showAddSourceModal(context, year.id),
                      borderRadius: BorderRadius.circular(AppRadius.radius4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing4,
                          vertical: AppSpacing.spacing4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedPlusSign,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const Gap(AppSpacing.spacing4),
                            Text(
                              l10n.khumsAddMoney,
                              style: AppTextStyles.body3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.spacing8),

                // Money Sources List
                Consumer(
                  builder: (context, ref, child) {
                    final sourcesAsync = ref.watch(
                      khumsMoneySourcesProvider(year.id),
                    );

                    return sourcesAsync.when(
                      data: (sources) {
                        if (sources.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.spacing16),
                            decoration: BoxDecoration(
                              color: context.secondaryBackground,
                              borderRadius: BorderRadius.circular(
                                AppRadius.radius12,
                              ),
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
                                context.openBottomSheet(
                                  child: AddMoneySourceBottomSheet(
                                    khumsYearId: year.id,
                                    existingSource: source,
                                  ),
                                );
                              },
                              onDelete: () {
                                ref
                                    .read(khumsDaoProvider)
                                    .deleteMoneySource(
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
                const Gap(AppSpacing.spacing24),

                // 5. Payment Tracking Section
                Text(
                  l10n.khumsPaymentTracking,
                  style: AppTextStyles.heading6,
                ),
                const Gap(AppSpacing.spacing4),
                Text(
                  l10n.khumsHowTrackPayment,
                  style: AppTextStyles.body3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpacing.spacing12),

                // Side-by-side Pay in Full & Installment Plan Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pay in Full Option
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.spacing12),
                        decoration: BoxDecoration(
                          color: context.secondaryBackground,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius12,
                          ),
                          border: Border.all(
                            color: context.secondaryBorderLighter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.khumsPayInFull,
                              style: AppTextStyles.body3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(AppSpacing.spacing12),
                            InkWell(
                              onTap: isFullPaid ? null : () => _payInFull(year),
                              borderRadius: BorderRadius.circular(
                                AppRadius.radius8,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.spacing8,
                                  vertical: AppSpacing.spacing8,
                                ),
                                decoration: BoxDecoration(
                                  color: isFullPaid
                                      ? AppColors.greenAlpha10
                                      : AppColors.primary50.withAlpha(50),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.radius8,
                                  ),
                                  border: Border.all(
                                    color: isFullPaid
                                        ? AppColors.green700.withAlpha(60)
                                        : AppColors.primary.withAlpha(40),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isFullPaid
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      size: 16,
                                      color: isFullPaid
                                          ? AppColors.green700
                                          : AppColors.primary,
                                    ),
                                    const Gap(AppSpacing.spacing4),
                                    Flexible(
                                      child: Text(
                                        isFullPaid
                                            ? l10n.khumsPaid
                                            : l10n.khumsMarkAsFullyPaid,
                                        style: AppTextStyles.body4.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isFullPaid
                                              ? AppColors.green700
                                              : AppColors.primary,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.spacing8),

                    // Installment Plan Option
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.spacing12),
                        decoration: BoxDecoration(
                          color: context.secondaryBackground,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius12,
                          ),
                          border: Border.all(
                            color: context.secondaryBorderLighter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.khumsInstallmentPlan,
                              style: AppTextStyles.body3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(AppSpacing.spacing8),
                            // Months Selection Chips
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _monthOptions.map((m) {
                                final isSelected = _selectedMonths == m;
                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedMonths = m);
                                  },
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.radiusFull,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.spacing4,
                                      vertical: AppSpacing.spacing2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.radiusFull,
                                      ),
                                    ),
                                    child: Text(
                                      '$m',
                                      style: AppTextStyles.body4.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const Gap(AppSpacing.spacing8),
                            InkWell(
                              onTap: () => _createInstallments(year),
                              borderRadius: BorderRadius.circular(
                                AppRadius.radius8,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.spacing8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.radius8,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.khumsGeneratePlanMonth(
                                      _selectedMonths,
                                    ),
                                    style: AppTextStyles.body4.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.spacing12),

                // Installments Progress & Remaining Amount
                installmentsAsync.when(
                  data: (installments) {
                    final paidAmount = isFullPaid
                        ? year.khumsAmount
                        : installments
                              .where((i) => i.isPaid)
                              .fold<double>(0.0, (sum, i) => sum + i.amount);
                    final remainingAmount = (year.khumsAmount - paidAmount)
                        .clamp(0.0, double.infinity);
                    final progress = year.khumsAmount > 0
                        ? (paidAmount / year.khumsAmount).clamp(0.0, 1.0)
                        : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadius.radiusFull,
                          ),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: context.secondaryBorderLighter,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.spacing8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const Gap(AppSpacing.spacing24),

                        // 6. Installment List (Horizontal Cards as shown in the design)
                        if (installments.isNotEmpty) ...[
                          Text(
                            l10n.khumsInstallmentList,
                            style: AppTextStyles.heading6,
                          ),
                          const Gap(AppSpacing.spacing12),
                          SizedBox(
                            height: 76,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: installments.length,
                              separatorBuilder: (context, index) =>
                                  const Gap(AppSpacing.spacing8),
                              itemBuilder: (context, index) {
                                final inst = installments[index];
                                return InkWell(
                                  onTap: () {
                                    ref
                                        .read(khumsDaoProvider)
                                        .toggleInstallmentPaid(
                                          installmentId: inst.id,
                                          khumsYearId: year.id,
                                          isPaid: !inst.isPaid,
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.radius12,
                                  ),
                                  child: Container(
                                    width: 120,
                                    padding: const EdgeInsets.all(
                                      AppSpacing.spacing8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: inst.isPaid
                                          ? AppColors.primary50.withAlpha(50)
                                          : context.secondaryBackground,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.radius12,
                                      ),
                                      border: Border.all(
                                        color: inst.isPaid
                                            ? AppColors.primary.withAlpha(60)
                                            : context.secondaryBorderLighter,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          inst.isPaid
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          size: 20,
                                          color: inst.isPaid
                                              ? AppColors.green700
                                              : context.secondaryText,
                                        ),
                                        const Gap(AppSpacing.spacing8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.khumsMonthN(
                                                  inst.installmentNumber,
                                                ),
                                                style: AppTextStyles.body4
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Gap(AppSpacing.spacing2),
                                              Text(
                                                inst.amount.toPriceFormat(),
                                                style: AppTextStyles
                                                    .numericHeading
                                                    .copyWith(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap(AppSpacing.spacing24),
                        ],
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                ),

                // 7. Religious Disclaimer (Card at bottom)
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
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        color: context.secondaryText,
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
                const Gap(AppSpacing.spacing32),
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
