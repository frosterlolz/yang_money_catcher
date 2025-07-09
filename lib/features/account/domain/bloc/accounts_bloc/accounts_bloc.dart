import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';

part 'accounts_event.dart';
part 'accounts_state.dart';
part 'accounts_bloc.freezed.dart';

typedef _Emitter = Emitter<AccountsState>;

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc(this._accountRepository) : super(const AccountsState.processing(null, isOffline: true)) {
    on<AccountsEvent>(
      (event, emitter) => switch (event) {
        _Load() => _load(event, emitter),
        _Delete() => _delete(event, emitter),
      },
    );
  }

  final AccountRepository _accountRepository;

  Future<void> _load(_Load event, _Emitter emitter) async {
    emitter(AccountsState.processing(state.accounts, isOffline: state.isOffline));
    try {
      final accountsStream = _accountRepository.getAccounts();
      await for (final accountsResult in accountsStream) {
        final accounts = UnmodifiableListView(accountsResult.data);
        switch (accountsResult.isOffline) {
          case true:
            emitter(AccountsState.processing(accounts, isOffline: true));
          case false:
            emitter(AccountsState.idle(accounts, isOffline: false));
        }
      }
    } on Object catch (e, s) {
      emitter(AccountsState.error(state.accounts, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }

  Future<void> _delete(_Delete event, _Emitter emitter) async {
    emitter(AccountsState.processing(state.accounts, isOffline: state.isOffline));
    try {
      final resultStream = _accountRepository.deleteAccount(event.id);
      await for (final deleteResult in resultStream) {
        final updatedAccounts = state.accounts?.toList()?..removeWhere((account) => account.id == event.id);
        final unmodifiableAccounts = UnmodifiableListView(updatedAccounts ?? <AccountEntity>[]);
        switch (deleteResult.isOffline) {
          case true:
            emitter(AccountsState.processing(unmodifiableAccounts, isOffline: state.isOffline));
          case false:
            emitter(AccountsState.idle(unmodifiableAccounts, isOffline: false));
        }
      }
    } on Object catch (e, s) {
      emitter(AccountsState.error(state.accounts, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }
}
