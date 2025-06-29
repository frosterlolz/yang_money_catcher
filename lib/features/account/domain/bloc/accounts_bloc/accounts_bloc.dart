import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';

part 'accounts_event.dart';
part 'accounts_state.dart';
part 'accounts_bloc.freezed.dart';

typedef _Emitter = Emitter<AccountsState>;

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc(this._accountRepository) : super(const AccountsState.processing(null)) {
    on<AccountsEvent>(
      (event, emitter) => switch (event) {
        _Load() => _load(event, emitter),
        _Update() => _update(event, emitter),
        _Delete() => _delete(event, emitter),
      },
    );
  }

  final AccountRepository _accountRepository;

  Future<void> _load(_Load event, _Emitter emitter) async {
    emitter(AccountsState.processing(state.accounts));
    try {
      final accounts = await _accountRepository.getAccounts();
      emitter(AccountsState.idle(UnmodifiableListView(accounts)));
    } on Object catch (e, s) {
      emitter(AccountsState.error(state.accounts, error: e));
      onError(e, s);
    }
  }

  Future<void> _update(_Update event, _Emitter emitter) async {
    emitter(AccountsState.processing(state.accounts));
    try {
      final updatedAccount = await switch (event.request) {
        final AccountRequest$Create createRequest => _accountRepository.createAccount(createRequest),
        final AccountRequest$Update updateRequest => _accountRepository.updateAccount(updateRequest),
      };
      final hasOverlap = state.accounts?.any((account) => account.id == updatedAccount.id) ?? false;
      final updatedAccounts = hasOverlap
          ? state.accounts?.map((account) => account.id == updatedAccount.id ? updatedAccount : account)
          : [...state.accounts ?? <AccountEntity>[], updatedAccount];
      emitter(AccountsState.idle(UnmodifiableListView(updatedAccounts ?? [])));
    } on Object catch (e, s) {
      emitter(AccountsState.error(state.accounts, error: e));
      onError(e, s);
    }
  }

  Future<void> _delete(_Delete event, _Emitter emitter) async {
    emitter(AccountsState.processing(state.accounts));
    try {
      await _accountRepository.deleteAccount(event.id);
      final updatedAccounts = state.accounts?.toList()?..removeWhere((account) => account.id == event.id);
      emitter(AccountsState.idle(UnmodifiableListView(updatedAccounts ?? [])));
    } on Object catch (e, s) {
      emitter(AccountsState.error(state.accounts, error: e));
      onError(e, s);
    }
  }
}
