// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pockaw/core/components/form_fields/custom_text_field.dart';
import 'package:pockaw/features/currency_picker/data/models/currency.dart';
import 'package:pockaw/features/currency_picker/data/sources/currency_local_source.dart';
import 'package:pockaw/features/currency_picker/presentation/riverpod/currency_picker_provider.dart';
import 'package:pockaw/features/wallet/data/model/wallet_model.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';

class CustomNumericField extends ConsumerWidget {
  final String label;
  final String? defaultCurrency;
  final TextEditingController? controller;
  final String? hint;
  final Color? hintColor;
  final Color? background;
  final List<List<dynamic>>? icon;
  final List<List<dynamic>>? suffixIcon;
  final bool useSelectedCurrency;
  final bool appendCurrencySymbolToHint;
  final bool isRequired;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;

  const CustomNumericField({
    super.key,
    required this.label,
    this.defaultCurrency,
    this.controller,
    this.hint,
    this.hintColor,
    this.background,
    this.icon,
    this.suffixIcon,
    this.useSelectedCurrency = false,
    this.appendCurrencySymbolToHint = false,
    this.isRequired = false,
    this.autofocus = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Currency currency = ref.watch(currencyProvider);
    final activeWallet = ref.watch(activeWalletProvider).value;
    String defaultCurrency =
        this.defaultCurrency ??
        activeWallet?.currencyByIsoCode(ref).symbol ??
        CurrencyLocalDataSource.dummy.symbol;

    if (useSelectedCurrency) {
      defaultCurrency = currency.symbol;
    }

    String hint = this.hint ?? '1,000.00';

    String convertArabicDigitsToEnglish(String input) {
      const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      const easternArabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      String result = input;
      for (int i = 0; i < 10; i++) {
        result = result.replaceAll(arabicDigits[i], '$i');
        result = result.replaceAll(easternArabicDigits[i], '$i');
      }
      return result;
    }

    void onChanged(String value) {
      // Convert any Arabic/Persian digits to English digits
      String normalizedInput = convertArabicDigitsToEnglish(value);

      // Extract numbers and single decimal dot
      String digitsAndDotOnly = normalizedInput.replaceAll(RegExp(r'[^\d.]'), '');

      List<String> parts = digitsAndDotOnly.split('.');
      String integerPart = parts[0];
      String decimalPart = parts.length >= 2 ? parts.sublist(1).join('') : '';

      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }

      final formatter = NumberFormat('#,##0', 'en_US');
      String formattedInteger = '';
      if (integerPart.isNotEmpty) {
        try {
          formattedInteger = formatter.format(BigInt.parse(integerPart));
        } catch (_) {
          formattedInteger = integerPart;
        }
      }

      String formattedValue = (decimalPart.isNotEmpty || parts.length >= 2)
          ? '$formattedInteger.$decimalPart'
          : formattedInteger;

      if (formattedValue != value && controller != null) {
        controller!.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    }

    return CustomTextField(
      context: context,
      controller: controller,
      label: label,
      prefixIcon: icon,
      hint: hint,
      textInputAction: TextInputAction.done,
      suffixIcon: suffixIcon,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 20,
      customCounterText: '',
      onChanged: onChanged,
      isRequired: isRequired,
      autofocus: autofocus,
      contentPadding: contentPadding,
    );
  }
}

class SingleDotInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if the new input contains more than one dot
    if (newValue.text.split('.').length > 2) {
      return oldValue; // Reject the new input
    }
    return newValue;
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow only numbers, a single dot, and two digits after the dot
    final regex = RegExp(r'^\d*\.?\d{0,2}$');

    if (!regex.hasMatch(text)) {
      return oldValue; // Reject invalid input
    }

    return newValue;
  }
}
