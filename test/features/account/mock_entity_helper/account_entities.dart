import 'package:yang_money_catcher/features/account/data/dto/dto.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

abstract class MockAccountEntitiesHelper {
  static AccountDto accountDto({
    int id = 1,
    String name = 'Test Account',
    String balance = '100.00',
    Currency currency = Currency.rub,
    int userId = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();

    return AccountDto(
      id: id,
      name: name,
      balance: balance,
      currency: currency,
      userId: userId,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  static AccountEntity account({
    int id = 1,
    String name = 'Test Account',
    String balance = '100.00',
    Currency currency = Currency.rub,
    int? remoteId = 1,
    int userId = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();

    return AccountEntity(
      id: id,
      name: name,
      balance: balance,
      currency: currency,
      remoteId: remoteId,
      userId: userId,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  static AccountDetailsDto accountDetailsDto(int id) {
    final now = DateTime.now();
    return AccountDetailsDto(
      id: id,
      name: 'Test Account',
      balance: '100.00',
      currency: Currency.rub,
      createdAt: now,
      updatedAt: now,
      incomeStats: [],
      expenseStats: [],
    );
  }

  static AccountDetailEntity makeFakeAccountDetail(int id) {
    final now = DateTime.now();
    return AccountDetailEntity(
      id: id,
      name: 'Test Account',
      balance: '100.00',
      currency: Currency.rub,
      incomeStats: [],
      expenseStats: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  static AccountRequest$Create createRequest() => const AccountRequest$Create(
        name: 'Test Account',
        balance: '123.45',
        currency: Currency.rub,
      );

  static AccountRequest$Update updateRequest() => const AccountRequest$Update(
        id: 1,
        name: 'Test Account',
        balance: '123.45',
        currency: Currency.rub,
      );

  static AccountHistoryDto accountHistoryDto(int id) => AccountHistoryDto(
        accountId: id,
        history: [],
        currencyBalance: '123.45',
        currency: Currency.rub,
        accountName: 'Test Account',
      );
}
