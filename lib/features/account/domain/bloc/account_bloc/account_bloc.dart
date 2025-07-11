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
      },
      // transformer: droppable(),
    );
  }

  final AccountRepository _accountRepository;

  Future<void> _load(_Load event, _Emitter emitter) async {
    emitter(AccountState.processing(state.account, isOffline: state.isOffline));
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
        emitter(AccountState.idle(state.account!, isOffline: state.isOffline));
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
      await for (final account in accountsStream) {
        switch (account.isOffline) {
          case true:
            emitter(AccountState.processing(state.account?.fromEntity(account.data), isOffline: true));
          case false:
            final details = _accountRepository.getAccountDetail(account.data.id);
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
}
