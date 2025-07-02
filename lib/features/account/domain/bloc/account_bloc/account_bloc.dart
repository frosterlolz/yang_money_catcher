import 'package:bloc_concurrency/bloc_concurrency.dart';
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
  AccountBloc(this._accountRepository) : super(const AccountState.processing(null)) {
    on<AccountEvent>(
      (event, emitter) => switch (event) {
        _Load() => _load(event, emitter),
        _Update() => _update(event, emitter),
      },
      transformer: droppable(),
    );
  }

  final AccountRepository _accountRepository;

  Future<void> _load(_Load event, _Emitter emitter) async {
    emitter(AccountState.processing(state.account));
    try {
      final account = await _accountRepository.getAccountDetail(event.accountId);
      emitter(AccountState.idle(account));
    } on Object catch (e, s) {
      emitter(AccountState.error(state.account, error: e));
      onError(e, s);
    }
  }

  Future<void> _update(_Update event, _Emitter emitter) async {
    emitter(AccountState.processing(state.account));
    try {
      final account = await switch (event.request) {
        final AccountRequest$Create createRequest => _accountRepository.createAccount(createRequest),
        final AccountRequest$Update updateRequest => _accountRepository.updateAccount(updateRequest),
      };
      final details = await _accountRepository.getAccountDetail(account.id);
      emitter(AccountState.idle(details));
    } on Object catch (e, s) {
      emitter(AccountState.error(state.account, error: e));
      onError(e, s);
    }
  }
}
