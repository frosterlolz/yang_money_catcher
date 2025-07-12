import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';

/// Репозиторий для работы с банковскими счетами пользователя.
abstract interface class AccountRepository {
  /// Получить список всех счетов пользователя.
  ///
  /// Returns:
  ///   Iterable<AccountEntity> — список счетов.
  Stream<DataResult<Iterable<AccountEntity>>> getAccounts();

  /// Создать новый банковский счет.
  ///
  /// Parameters:
  ///   [request] — объект с данными для создания счета.
  ///
  /// Returns:
  ///   AccountEntity — созданный счет.
  Stream<DataResult<AccountEntity>> createAccount(AccountRequest$Create request);

  /// Обновить существующий банковский счет.
  ///
  /// Parameters:
  ///   [request] — объект с обновленными данными счета.
  ///
  /// Returns:
  ///   AccountEntity — обновленный счет.
  Stream<DataResult<AccountEntity>> updateAccount(AccountRequest$Update request);

  /// Получить подробную информацию о конкретном счете.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   AccountDetailEntity — полные данные счета.
  Stream<DataResult<AccountDetailEntity>> getAccountDetail(int accountId);

  /// Удалить существующий банковский счет.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   Stream<DataResult<void>>
  Stream<DataResult<void>> deleteAccount(int accountId);

  /// Получить историю операций по конкретному счету.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   AccountHistory — история операций (список транзакций или действий).
  Stream<DataResult<AccountHistory>> getAccountHistory(int accountId);

  /// Получить изменения по всем счетам.
  ///
  /// Returns:
  ///   Iterable<AccountEntity>
  Stream<List<AccountEntity>> watchAccounts();

  /// Получить изменения по конкретному счету.
  ///
  /// Parameters:
  ///   [accountId] — идентификатор счета.
  ///
  /// Returns:
  ///   AccountDetailEntity - полные данные счета.
  Stream<AccountDetailEntity> watchAccount(int accountId);
}
