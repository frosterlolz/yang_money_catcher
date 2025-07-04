import 'package:flutter/services.dart';

class DecimalSanitizerFormatter extends TextInputFormatter {
  const DecimalSanitizerFormatter({
    this.fractionalLength = 2,
    this.decimalSeparator = '.',
  });

  final int fractionalLength;
  final String decimalSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp('[^0-9.,]'), '').replaceAll(
          decimalSeparator == ',' ? '.' : ',',
          decimalSeparator,
        );

    // Разрешить только одну точку
    final dotCount = decimalSeparator.allMatches(newText).length;
    if (dotCount > 1) return oldValue;

    // Разделяем целую и дробную часть
    final parts = newText.split(decimalSeparator);

    if (parts.length > 2) {
      // Невалидный ввод: больше одной точки
      return oldValue;
    }

    // Обрезаем дробную часть до нужной длины
    if (parts.length == 2 && parts[1].length > fractionalLength) {
      parts[1] = parts[1].substring(0, fractionalLength);
      newText = '${parts[0]}$decimalSeparator${parts[1]}';
    }

    return TextEditingValue(
      text: newText,
      selection: updateCursorPosition(newText, newValue),
    );
  }

  TextSelection updateCursorPosition(String newText, TextEditingValue value) {
    final newOffset = newText.length;
    return TextSelection.collapsed(offset: newOffset);
  }
}
