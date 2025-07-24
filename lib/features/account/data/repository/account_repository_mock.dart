import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/common/data/mock_data_store.dart';

final class AccountRepository$Mock implements AccountRepository {
  const AccountRepository$Mock(this._store);

  final MockDataStore _store;

  @override
  Stream<DataResult<AccountEntity>> createAccount(AccountRequest$Create request) {
    final upsertedId = _store.upsertAccount(request);
    final detailed = _store.findAccount(upsertedId);
    if (detailed == null) throw StateError('Cannot fetch account after insert/update');
    return Stream.value(DataResult.offline(data: detailed));
  }

  @override
  Stream<DataResult<void>> deleteAccount(int accountId) {
    _store.deleteAccount(accountId);
    return Stream.value(const DataResult.offline(data: null));
  }

  @override
  Stream<DataResult<AccountDetailEntity>> getAccountDetail(int accountId) {
    final account = _store.findAccount(accountId);
    if (account == null) throw StateError('Cannot fetch account');
    final detailed = AccountDetailEntity.fromLocalSource(account, incomeStats: [], expenseStats: []);
    return Stream.value(DataResult.offline(data: detailed));
  }

  @override
  Stream<DataResult<AccountHistory>> getAccountHistory(int accountId) {
    throw UnimplementedError();
  }

  @override
  Stream<DataResult<Iterable<AccountEntity>>> getAccounts() {
    final res = _store.accounts;
    return Stream.value(DataResult.offline(data: res));
  }

  @override
  Stream<DataResult<AccountEntity>> updateAccount(AccountRequest$Update request) {
    final upsertedId = _store.upsertAccount(request);
    final detailed = _store.findAccount(upsertedId);
    if (detailed == null) throw StateError('Cannot fetch account after insert/update');
    return Stream.value(DataResult.offline(data: detailed));
  }

  @override
  Stream<AccountDetailEntity> watchAccount(int accountId) => _store.accountChanges(accountId).asyncMap((account) async {
        final detailed = AccountDetailEntity.fromLocalSource(account.$1, incomeStats: [], expenseStats: []);
        return detailed;
      });

  @override
  Stream<List<AccountEntity>> watchAccounts() => _store.accountsListChanges();
}
