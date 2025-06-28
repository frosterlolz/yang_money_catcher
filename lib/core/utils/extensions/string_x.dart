extension StringExtension on String {
  /// Returns a new string with the first [length] characters of this string.
  String limit(int length) => length < this.length ? substring(0, length) : this;

  num amountToNum() => num.tryParse(this) ?? 0;

  String withCurrency(String currencySymbol, [int? spaces]) => '$this${spaces == null ? '' : ' ' * spaces}₽';
}
