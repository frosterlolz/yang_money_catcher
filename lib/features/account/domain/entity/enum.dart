import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'key')
enum Currency {
  rub('RUB', '₽'),
  usd('USD', r'$'),
  eur('EUR', '€');

  const Currency(this.key, this.symbol);

  // TODO(frosterlolz): возможно спавнить "неизвестную" валюту, либо ошибку
  factory Currency.fromKey(String key) => values.firstWhere((e) => e.key == key, orElse: () => Currency.rub);

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
