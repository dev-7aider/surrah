import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:pockaw/core/components/bottom_sheets/custom_bottom_sheet.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_radius.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/utils/hijri_calendar_helper.dart';

class HijriDatePickerDialog extends StatefulWidget {
  final HijriDate? initialDate;

  const HijriDatePickerDialog({super.key, this.initialDate});

  @override
  State<HijriDatePickerDialog> createState() => _HijriDatePickerDialogState();
}

class _HijriDatePickerDialogState extends State<HijriDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  static const int _startYear = 1400;
  static const int _endYear = 1500;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? HijriDate.fromGregorian(DateTime.now());
    _selectedYear = initial.year.clamp(_startYear, _endYear);
    _selectedMonth = initial.month.clamp(1, 12);
    _selectedDay = initial.day.clamp(1, 30);

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear - _startYear);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    final currentDate = HijriDate(
      year: _selectedYear,
      month: _selectedMonth,
      day: _selectedDay,
    );

    return CustomBottomSheet(
      title: isArabic ? 'تحديد التاريخ الهجري' : 'Select Hijri Date',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.spacing12,
              horizontal: AppSpacing.spacing16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.radius12),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Text(
              currentDate.format(locale),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(AppSpacing.spacing16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: context.secondaryBackground,
              borderRadius: BorderRadius.circular(AppRadius.radius16),
              border: Border.all(color: context.secondaryBorderLighter),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CupertinoPicker(
                    scrollController: _dayController,
                    itemExtent: 38,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                      ),
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedDay = index + 1);
                    },
                    children: List.generate(30, (index) {
                      final day = index + 1;
                      return Center(
                        child: Text(
                          '$day',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: day == _selectedDay ? FontWeight.bold : FontWeight.normal,
                            color: day == _selectedDay ? AppColors.primary : context.secondaryText,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: CupertinoPicker(
                    scrollController: _monthController,
                    itemExtent: 38,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                      ),
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedMonth = index + 1);
                    },
                    children: List.generate(12, (index) {
                      final monthNum = index + 1;
                      final name = isArabic
                          ? HijriDate.monthsArabic[index]
                          : HijriDate.monthsEnglish[index];
                      return Center(
                        child: Text(
                          name,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: monthNum == _selectedMonth ? FontWeight.bold : FontWeight.normal,
                            color: monthNum == _selectedMonth ? AppColors.primary : context.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: CupertinoPicker(
                    scrollController: _yearController,
                    itemExtent: 38,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                      ),
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedYear = _startYear + index);
                    },
                    children: List.generate(_endYear - _startYear + 1, (index) {
                      final year = _startYear + index;
                      return Center(
                        child: Text(
                          '$year ${isArabic ? "هـ" : "AH"}',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: year == _selectedYear ? FontWeight.bold : FontWeight.normal,
                            color: year == _selectedYear ? AppColors.primary : context.secondaryText,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.spacing20),
          PrimaryButton(
            label: isArabic ? 'تأكيد التاريخ' : 'Confirm Date',
            onPressed: () {
              Navigator.of(context).pop(currentDate);
            },
          ),
        ],
      ),
    );
  }
}
