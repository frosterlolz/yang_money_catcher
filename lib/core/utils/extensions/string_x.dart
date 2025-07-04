import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';

extension StringExtension on String {
  /// Returns a new string with the first [length] characters of this string.
  String limit(int length) => length < this.length ? substring(0, length) : this;

  num amountToNum() {
    final numValue = num.tryParse(this) ?? 0;
    return numValue.smartTruncate();
  }

  String withCurrency(String currencySymbol, [int? spaces]) => '$this${spaces == null ? '' : '\u00A0' * spaces}₽';
}
