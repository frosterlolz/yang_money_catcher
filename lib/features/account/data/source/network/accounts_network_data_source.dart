import 'package:yang_money_catcher/features/account/data/dto/dto.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';

/// Контракт для сетевого слоя, работающего с пользовательскими счетами.
abstract interface class AccountsNetworkDataSource {
  /// Получает список всех счетов.
  Future<List<AccountDto>> getAccounts();

  /// Создаёт новый счёт.
  Future<AccountDto> createAccount(AccountRequest$Create request);

  /// Возвращает детали счёта по ID.
  Future<AccountDetailsDto> getAccount(int id);

  /// Обновляет существующий счёт.
  Future<AccountDto> updateAccount(AccountRequest$Update request);

  /// Удаляет счёт по ID.
  Future<void> deleteAccount(int id);

  /// Получает историю операций по счёту.
  Future<AccountHistoryDto> getAccountHistory(int id);
}
