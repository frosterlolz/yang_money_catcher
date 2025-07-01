import 'package:intl/intl.dart';

/// Common extensions for [num]
extension NumExtension on num {
  /// Return [int] if number has no fractional part
  /// else return [double] value
  num smartTruncate([int? fractionDigits]) {
    final pricedValue = double.parse(toStringAsFixed(fractionDigits ?? 2));
    final truncatedValue = pricedValue.truncateToDouble();
    if (truncatedValue == pricedValue) return pricedValue.truncate();

    return pricedValue;
  }

  /// Возвращает дробную часть числа, добавляя необходимое количество нулей
  /// в конец, в зависимости от [fractionalLength] полученного результата,
  /// Результат может быть пустым, если [fractionalLength] == 0
  /// Результат вернет обычную дробную часть (если она есть), когда [fractionalLength] == null
  /// ```dart
  /// 999.123.fractionalPart(null) -> '123'
  /// 999.123.fractionalPart() -> '12'
  /// 999.123.fractionalPart(5) -> '12300'
  /// 999.123.fractionalPart(0) -> ''
  /// 999.123.fractionalPart(-1) -> Exception
  /// ```
  String fractionalPart([int? fractionalLength = 2]) {
    assert(fractionalLength == null || fractionalLength >= 0, 'fractionalLength must be >= 0');
    if (fractionalLength == 0) return '';
    final strValue = fractionalLength == null ? '$this' : toStringAsFixed(fractionalLength);
    final fractionalPart = strValue.split('.').elementAtOrNull(1);
    return fractionalPart ?? '';
  }

  String thousandsSeparated({
    String thousandsSeparator = ' ',
    int? fractionalLength = 2,
    String fractionalSeparator = '.',
    bool isSmartTruncated = true,
  }) {
    final intSeparated = NumberFormat('#,###').format(toInt()).replaceAll(',', thousandsSeparator);
    if (this is int) return intSeparated;

    final fractionalDigits =
        isSmartTruncated ? smartTruncate().fractionalPart(fractionalLength) : fractionalPart(fractionalLength);

    return [intSeparated, fractionalDigits].where((e) => e.isNotEmpty).join(fractionalSeparator);
  }
}
