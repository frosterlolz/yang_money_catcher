import 'package:database/database.dart';

class AccountEventsValueObject {
  factory AccountEventsValueObject({
    required AccountEventItem event,
    required AccountItem? account,
  }) =>
      AccountEventsValueObject._(
        event: event,
        account: account,
      );

  const AccountEventsValueObject._({
    required this.event,
    required this.account,
  });

  final AccountEventItem event;
  final AccountItem? account;
}
