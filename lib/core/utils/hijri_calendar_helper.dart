import 'package:flutter/material.dart';

class HijriDate {
  final int year;
  final int month; // 1-12
  final int day; // 1-30

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const List<String> monthsArabic = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> monthsEnglish = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  String getMonthName(Locale? locale) {
    final isArabic = locale?.languageCode == 'ar';
    final index = (month - 1).clamp(0, 11);
    return isArabic ? monthsArabic[index] : monthsEnglish[index];
  }

  String format(Locale? locale) {
    final isArabic = locale?.languageCode == 'ar';
    final monthName = getMonthName(locale);
    if (isArabic) {
      return '$day $monthName $year هـ';
    } else {
      return '$day $monthName $year AH';
    }
  }

  /// Convert standard Gregorian DateTime to astronomical HijriDate
  factory HijriDate.fromGregorian(DateTime date) {
    final jd = _gregorianToJulian(date.year, date.month, date.day);
    return _julianToHijri(jd);
  }

  /// Convert HijriDate to estimated Gregorian DateTime
  DateTime toGregorian() {
    final jd = _hijriToJulian(year, month, day);
    return _julianToGregorian(jd);
  }

  // --- Astronomical / Tabular Julian Day Algorithm ---
  static double _gregorianToJulian(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  static DateTime _julianToGregorian(double jd) {
    final z = (jd + 0.5).floor();
    final f = (jd + 0.5) - z;
    int a = z;
    if (z >= 2299161) {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha / 4).floor();
    }
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    final day = b - d - (30.6001 * e).floor() + f;
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;
    return DateTime(year, month, day.round());
  }

  static HijriDate _julianToHijri(double jd) {
    final l = (jd - 1948440 + 10632).floor();
    final n = ((l - 1) / 10631).floor();
    final lRemainder = l - 10631 * n + 354;
    final j = ((10985 - lRemainder) / 5316).floor() *
            ((50 * lRemainder) / 17719).floor() +
        (lRemainder / 5670).floor() * ((43 * lRemainder) / 15238).floor();
    final l2 = lRemainder -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m = ((24 * l2) / 709).floor();
    final day = l2 - ((709 * m) / 24).floor();
    final year = 30 * n + j - 30;
    return HijriDate(
      year: year,
      month: m.clamp(1, 12),
      day: day.clamp(1, 30),
    );
  }

  static double _hijriToJulian(int year, int month, int day) {
    return ((11 * year + 3) / 30).floor() +
        354 * year +
        30 * month -
        ((month - 1) / 2).floor() +
        day +
        1948440 -
        385;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}
