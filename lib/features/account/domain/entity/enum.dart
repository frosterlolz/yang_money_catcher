import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'key')
enum Currency {
  rub('RUB'),
  usd('USD'),
  eur('EUR');

  const Currency(this.key);

  final String key;
}

@JsonEnum(valueField: 'key')
enum AccountStateChangingReason {
  creation('CREATION'),
  modification('MODIFICATION');

  const AccountStateChangingReason(this.key);

  final String key;
}
