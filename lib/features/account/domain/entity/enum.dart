import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'key')
enum Currency {
  rub('RUB', '₽'),
  usd('USD', r'$'),
  eur('EUR', '€');

  const Currency(this.key, this.symbol);

  final String key;
  final String symbol;
}

@JsonEnum(valueField: 'key')
enum AccountStateChangingReason {
  creation('CREATION'),
  modification('MODIFICATION');

  const AccountStateChangingReason(this.key);

  final String key;
}
