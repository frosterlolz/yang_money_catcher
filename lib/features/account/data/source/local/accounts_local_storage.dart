import 'package:database/database.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';

/// Интерфейс локального хранилища аккаунтов.
/// Используется для взаимодействия с локальной базой данных (например, через Drift).
abstract interface class AccountsLocalStorage {
  /// Загружает список всех аккаунтов из базы данных.
  ///
  /// Возвращает список [AccountItem], включая их `id`, `createdAt`, `updatedAt` и другие поля.
  Future<List<AccountItem>> fetchAccounts();

  /// Возвращает аккаунт с указанным [id], если он существует.
  ///
  /// Возвращает `null`, если аккаунт не найден.
  Future<AccountItem?> fetchAccount(int id);

  /// Обновляет существующий аккаунт или вставляет новый, если `id` не существует.
  ///
  /// Использует [AccountRequest] (например, Drift Companion), чтобы указать нужные поля.
  ///
  /// Возвращает `id` обновлённого или добавленного аккаунта.
  ///
  /// Использует поведение `INSERT ON CONFLICT UPDATE`.
  Future<int> updateAccount(AccountRequest item);

  /// Удаляет аккаунт по его идентификатору [accountId].
  ///
  /// Возвращает количество удалённых строк (0, если аккаунт не найден).
  Future<int> deleteAccount(int accountId);
}
