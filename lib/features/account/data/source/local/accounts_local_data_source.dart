import 'package:yang_money_catcher/features/account/data/dto/dto.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

/// Интерфейс локального хранилища аккаунтов.
/// Используется для взаимодействия с локальной базой данных (например, через Drift).
abstract interface class AccountsLocalDataSource {
  Future<int> fetchAccountsCount();

  /// Обновляет аккаунты в базе данных.
  ///
  /// Возвращает список обновленных аккаунтов.
  Future<List<AccountEntity>> syncAccounts({
    required List<AccountEntity> localAccounts,
    required List<AccountDto> remoteAccounts,
  });

  /// Обновляет аккаунт в базе данных.
  ///
  /// Возвращает обновленный аккаунт
  Future<AccountEntity> syncAccount(AccountEntity account);

  /// Обновляет аккаунт в базе данных.
  ///
  /// Возвращает обновленный аккаунт
  Future<AccountEntity> syncAccountDetails(AccountDetailsDto account, {int? id});

  /// Обновляет аккаунт в базе данных с учетом истории.
  ///
  /// Возвращает обновленный аккаунт
  Future<AccountEntity> syncAccountHistory(int? id, {required AccountHistoryDto accountHistory});

  /// Загружает список всех аккаунтов из базы данных.
  ///
  /// Возвращает список [AccountEntity], включая их `id`, `createdAt`, `updatedAt` и другие поля.
  Future<List<AccountEntity>> fetchAccounts();

  /// Возвращает аккаунт с указанным [id], если он существует.
  ///
  /// Возвращает `null`, если аккаунт не найден.
  Future<AccountEntity?> fetchAccount(int id);

  /// Обновляет существующий аккаунт или вставляет новый, если `id` не существует.
  ///
  /// Использует [AccountRequest], чтобы указать нужные поля.
  ///
  /// Возвращает [AccountEntity] обновлённого или добавленного аккаунта.
  ///
  /// Использует поведение `INSERT ON CONFLICT UPDATE`.
  Future<AccountEntity> updateAccount(AccountRequest request);

  /// Удаляет аккаунт по его идентификатору [accountId].
  ///
  /// Возвращает id аккаунта на бэкенде (если он был).
  Future<int?> deleteAccount(int accountId);
}
