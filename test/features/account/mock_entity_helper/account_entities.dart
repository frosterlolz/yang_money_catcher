import 'package:database/database.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';
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

  static AccountEntity entityFromRequest(AccountRequest request, {int id = 1}) => AccountEntity(
        id: switch (request) {
          AccountRequest$Create() => id,
          AccountRequest$Update(:final id) => id,
        },
        remoteId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: request.name,
        balance: request.balance,
        currency: request.currency,
        userId: 1,
      );

  static AccountHistory historyFromEntity(AccountEntity entity) => AccountHistory(
        accountId: entity.id,
        accountName: entity.name,
        currencyBalance: entity.balance,
        history: [],
        currency: entity.currency,
      );
}
