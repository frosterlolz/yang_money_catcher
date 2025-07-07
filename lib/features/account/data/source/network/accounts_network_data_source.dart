import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';

/// Контракт для сетевого слоя, работающего с пользовательскими счетами.
abstract interface class AccountsNetworkDataSource {
  /// Получает список всех счетов.
  Future<List<AccountEntity>> getAccounts();

  /// Создаёт новый счёт.
  Future<AccountEntity?> createAccount(AccountRequest$Create request);

  /// Возвращает детали счёта по ID.
  Future<AccountDetailEntity?> getAccount(int id);

  /// Обновляет существующий счёт.
  Future<AccountEntity?> updateAccount(AccountRequest$Update request);

  /// Удаляет счёт по ID.
  Future<void> deleteAccount(int id);

  /// Получает историю операций по счёту.
  Future<AccountHistory?> getAccountHistory(int id);
}
