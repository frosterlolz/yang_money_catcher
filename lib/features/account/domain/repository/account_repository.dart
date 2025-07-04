import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';

/// Репозиторий для работы с банковскими счетами пользователя.
abstract interface class AccountRepository {
  /// Получить список всех счетов пользователя.
  ///
  /// Returns:
  ///   Iterable<AccountEntity> — список счетов.
  Stream<Iterable<AccountEntity>> getAccounts();

  /// Создать новый банковский счет.
  ///
  /// Parameters:
  ///   [request] — объект с данными для создания счета.
  ///
  /// Returns:
  ///   AccountEntity — созданный счет.
  Stream<AccountEntity> createAccount(AccountRequest$Create request);

  /// Обновить существующий банковский счет.
  ///
  /// Parameters:
  ///   [request] — объект с обновленными данными счета.
  ///
  /// Returns:
  ///   AccountEntity — обновленный счет.
  Stream<AccountEntity> updateAccount(AccountRequest$Update request);

  /// Получить подробную информацию о конкретном счете.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   AccountDetailEntity — полные данные счета.
  Future<AccountDetailEntity> getAccountDetail(int accountId);

  /// Удалить существующий банковский счет.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   void
  Future<void> deleteAccount(int accountId);

  /// Получить историю операций по конкретному счету.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   AccountHistory — история операций (список транзакций или действий).
  Future<AccountHistory> getAccountHistory(int accountId);
}
