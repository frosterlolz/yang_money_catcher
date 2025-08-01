import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

typedef _Emitter = Emitter<AccountState>;

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc(this._accountRepository) : super(const AccountState.processing(null, isOffline: true)) {
    on<AccountEvent>(
      (event, emitter) => switch (event) {
        _Load() => _load(event, emitter),
        _Update() => _update(event, emitter),
        _Delete() => _delete(event, emitter),
        _InternalUpdate() => _internalUpdate(event, emitter),
      },
    );
    if (state.account != null) {
      _updateAccountSubscription(state.account!.id);
    }
  }

  final AccountRepository _accountRepository;
  StreamSubscription<AccountDetailEntity>? _accountSubscription;

  @override
  Future<void> close() async {
    await _accountSubscription?.cancel();
    return super.close();
  }

  Future<void> _load(_Load event, _Emitter emitter) async {
    final isSameAccount = state.account?.id == event.accountId;
    emitter(AccountState.processing(state.account, isOffline: state.isOffline));
    if (!isSameAccount) {
      _updateAccountSubscription(event.accountId);
    }
    try {
      final accountStream = _accountRepository.getAccountDetail(event.accountId);
      await for (final account in accountStream) {
        switch (account.isOffline) {
          case true:
            emitter(AccountState.processing(account.data, isOffline: true));
          case false:
            emitter(AccountState.idle(account.data, isOffline: false));
        }
      }
      if (state.account != null) {
        emitter(AccountState.idle(state.account, isOffline: state.isOffline));
      }
    } on Object catch (e, s) {
      emitter(AccountState.error(state.account, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }

  Future<void> _update(_Update event, _Emitter emitter) async {
    emitter(AccountState.processing(state.account, isOffline: state.isOffline));
    try {
      final accountsStream = switch (event.request) {
        final AccountRequest$Create createRequest => _accountRepository.createAccount(createRequest),
        final AccountRequest$Update updateRequest => _accountRepository.updateAccount(updateRequest),
      };
      await for (final accountResult in accountsStream) {
        final isSameAccount = state.account?.id == accountResult.data.id;
        if (!isSameAccount) {
          _updateAccountSubscription(accountResult.data.id);
        }
        switch (accountResult.isOffline) {
          case true:
            emitter(AccountState.processing(state.account?.fromEntity(accountResult.data), isOffline: true));
          case false:
            final details = _accountRepository.getAccountDetail(accountResult.data.id);
            await for (final accountResult in details) {
              emitter(AccountState.idle(accountResult.data, isOffline: accountResult.isOffline));
            }
        }
      }
    } on Object catch (e, s) {
      emitter(AccountState.error(state.account, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }

  Future<void> _delete(_Delete event, _Emitter emitter) async {
    emitter(AccountState.processing(state.account, isOffline: state.isOffline));
    try {
      final resultStream = _accountRepository.deleteAccount(event.id);
      await for (final deleteResult in resultStream) {
        switch (deleteResult.isOffline) {
          case true:
            emitter(const AccountState.processing(null, isOffline: true));
          case false:
            emitter(const AccountState.idle(null, isOffline: false));
        }
      }
      await _accountSubscription?.cancel();
    } on Object catch (e, s) {
      emitter(AccountState.error(state.account, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }

  void _internalUpdate(_InternalUpdate event, _Emitter emitter) {
    emitter(AccountState.idle(event.account, isOffline: event.account?.remoteId == null));
  }

  void _accountChangesListener(AccountDetailEntity account) => add(_InternalUpdate(account));

  void _updateAccountSubscription(int id) {
    _accountSubscription?.cancel();
    _accountSubscription = null;
    _accountSubscription = _accountRepository.watchAccount(id).listen(_accountChangesListener);
  }
}
