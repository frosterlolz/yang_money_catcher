part of 'account_bloc.dart';

@freezed
sealed class AccountEvent with _$AccountEvent {
  const AccountEvent._();
  const factory AccountEvent.load(int accountId) = _Load;
  const factory AccountEvent.update(AccountRequest request) = _Update;
  const factory AccountEvent.delete(int id) = _Delete;
}

final class _InternalUpdate extends AccountEvent {
  const _InternalUpdate(this.account) : super._();

  final AccountDetailEntity? account;
}
