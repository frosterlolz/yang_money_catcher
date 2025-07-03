import 'package:database/database.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

abstract class MockAccountEntitiesHelper {
  static AccountRequest$Create sampleCreateRequest() =>
      const AccountRequest$Create(name: 'My Account', balance: '1000', currency: Currency.rub);

  static AccountItem sampleAccountItem() => AccountItem(
        id: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: 'My Account',
        balance: '1000',
        currency: 'RUB',
        userId: 1,
      );

  static AccountItem accountFromRequest(AccountRequest request, {int id = 1}) => AccountItem(
        id: switch (request) {
          AccountRequest$Create() => id,
          AccountRequest$Update(:final id) => id,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: request.name,
        balance: request.balance,
        currency: request.currency.name,
        userId: 1,
      );
}
