import 'package:flutter/services.dart';

class DecimalSanitizerFormatter extends TextInputFormatter {
  const DecimalSanitizerFormatter({
    this.fractionalLength = 2,
  });

  final int fractionalLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(',', '.');

    // Разрешить только одну точку
    final dotCount = '.'.allMatches(newText).length;
    if (dotCount > 1) return oldValue;

    // Разделяем целую и дробную часть
    final parts = newText.split('.');

    if (parts.length > 2) {
      // Невалидный ввод: больше одной точки
      return oldValue;
    }

    // Обрезаем дробную часть до нужной длины
    if (parts.length == 2 && parts[1].length > fractionalLength) {
      parts[1] = parts[1].substring(0, fractionalLength);
      newText = '${parts[0]}.${parts[1]}';
    }

    // Рассчитываем новое положение курсора
    final offset = newText.length;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
