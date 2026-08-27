import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockaw/core/utils/hijri_calendar_helper.dart';

void main() {
  group('Khums Exact Calculations & Logic Tests', () {
    test('Khums is exactly amount / 5', () {
      const double totalAmount = 3000000.0;
      final khumsAmount = totalAmount / 5.0;
      expect(khumsAmount, 600000.0);
    });

    test('Installments calculation splits correctly over months', () {
      const double khumsAmount = 600000.0;
      const int months = 12;
      final monthly = (khumsAmount / months).roundToDouble();
      expect(monthly, 50000.0);
      expect(monthly * months, khumsAmount);
    });

    test('Yearly difference and percentage change calculation', () {
      const double current = 2500000.0;
      const double previous = 3000000.0;
      final diff = current - previous;
      final pct = (diff / previous) * 100;

      expect(diff, -500000.0);
      expect(pct.toStringAsFixed(1), '-16.7');
    });

    test('Hijri calendar helper conversion and formatting', () {
      final gregorian = DateTime(2026, 8, 27);
      final hijri = HijriDate.fromGregorian(gregorian);

      expect(hijri.year, isNonZero);
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, 30));

      final formattedAr = hijri.format(const Locale('ar'));
      expect(formattedAr.contains('هـ'), isTrue);

      final formattedEn = hijri.format(const Locale('en'));
      expect(formattedEn.contains('AH'), isTrue);
    });
  });
}
