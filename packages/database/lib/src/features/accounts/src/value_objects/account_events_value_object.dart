import 'package:database/database.dart';

class AccountEventsValueObject {
  factory AccountEventsValueObject({
    required AccountEventItem event,
    required AccountItem? account,
  }) {
    if (account == null) throw StateError('AccountEventsValueObject creation failed: account is null');
    return AccountEventsValueObject._(
      event: event,
      account: account,
    );
  }

  const AccountEventsValueObject._({
    required this.event,
    required this.account,
  });

  final AccountEventItem event;
  final AccountItem account;
}
