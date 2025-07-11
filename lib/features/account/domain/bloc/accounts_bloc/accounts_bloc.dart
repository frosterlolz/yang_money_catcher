import 'dart:async';

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
        _InternalUpdate() => _internalUpdate(event, emitter),
      },
    );
    _accountsSubscription = _accountRepository.watchAccounts().listen(_onAccountsListChanged);
  }

  final AccountRepository _accountRepository;
  StreamSubscription<List<AccountEntity>>? _accountsSubscription;

  @override
  Future<void> close() async {
    await _accountsSubscription?.cancel();
    await super.close();
  }

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
      if (state.accounts != null) {
        emitter(AccountsState.idle(state.accounts!, isOffline: state.isOffline));
      }
    } on Object catch (e, s) {
      emitter(AccountsState.error(state.accounts, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }

  void _internalUpdate(_InternalUpdate event, _Emitter emitter) {
    emitter(state.copyWith(accounts: UnmodifiableListView(event.accounts.toList())));
  }

  void _onAccountsListChanged(List<AccountEntity> accounts) => add(_InternalUpdate(accounts));
}
