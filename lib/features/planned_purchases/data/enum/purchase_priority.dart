import 'package:flutter/material.dart';

enum PurchasePriority {
  urgentNeed, // Urgent & Important Need 🔴
  nonUrgentImportant, // Non-Urgent Important 🟡
  desireWant, // Desire / Want 🟢
}

extension PurchasePriorityExtension on PurchasePriority {
  int get dbValue {
    switch (this) {
      case PurchasePriority.urgentNeed:
        return 0;
      case PurchasePriority.nonUrgentImportant:
        return 1;
      case PurchasePriority.desireWant:
        return 2;
    }
  }

  static PurchasePriority fromDbValue(int? value) {
    switch (value) {
      case 0:
        return PurchasePriority.urgentNeed;
      case 1:
        return PurchasePriority.nonUrgentImportant;
      case 2:
        return PurchasePriority.desireWant;
      default:
        return PurchasePriority.urgentNeed;
    }
  }

  Color get color {
    switch (this) {
      case PurchasePriority.urgentNeed:
        return const Color(0xFFD32F2F); // Red
      case PurchasePriority.nonUrgentImportant:
        return const Color(0xFFFBC02D); // Yellow / Amber
      case PurchasePriority.desireWant:
        return const Color(0xFF4CAF50); // Green
    }
  }

  String getLabel(BuildContext context, bool isArabic) {
    switch (this) {
      case PurchasePriority.urgentNeed:
        return isArabic ? 'حاجة عاجلة ومهمة' : 'Urgent & Important Need';
      case PurchasePriority.nonUrgentImportant:
        return isArabic ? 'مهمة غير عاجلة' : 'Non-Urgent Important';
      case PurchasePriority.desireWant:
        return isArabic ? 'رغبة / ترفيه' : 'Desire / Want';
    }
  }
}
