import 'package:flutter/material.dart';
import 'package:pockaw/core/utils/hijri_calendar_helper.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_status.dart';
import 'package:pockaw/features/khums/data/enum/khums_payment_type.dart';

class KhumsYearModel {
  final int id;
  final int hijriStartDay;
  final int hijriStartMonth;
  final int hijriStartYear;
  final DateTime gregorianStartDate;
  final DateTime gregorianEndDate;
  final double totalAmount;
  final double khumsAmount;
  final KhumsPaymentType paymentType;
  final KhumsPaymentStatus paymentStatus;
  final bool isArchived;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KhumsYearModel({
    required this.id,
    required this.hijriStartDay,
    required this.hijriStartMonth,
    required this.hijriStartYear,
    required this.gregorianStartDate,
    required this.gregorianEndDate,
    required this.totalAmount,
    required this.khumsAmount,
    required this.paymentType,
    required this.paymentStatus,
    required this.isArchived,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  HijriDate get hijriStartDate => HijriDate(
        year: hijriStartYear,
        month: hijriStartMonth,
        day: hijriStartDay,
      );

  HijriDate get hijriEndDate => HijriDate(
        year: hijriStartYear + 1,
        month: hijriStartMonth,
        day: hijriStartDay,
      );

  int get daysRemaining {
    final now = DateTime.now();
    final difference = gregorianEndDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  String formatHijriRange(Locale? locale) {
    return '${hijriStartDate.format(locale)} → ${hijriEndDate.format(locale)}';
  }
}
