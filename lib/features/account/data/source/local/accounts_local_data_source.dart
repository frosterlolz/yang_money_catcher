import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

/// Интерфейс локального хранилища аккаунтов.
/// Используется для взаимодействия с локальной базой данных (например, через Drift).
abstract interface class AccountsLocalDataSource {
  Future<int> fetchAccountsCount();

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
  /// Возвращает количество удалённых строк (0, если аккаунт не найден).
  Future<int> deleteAccount(int accountId);
}
