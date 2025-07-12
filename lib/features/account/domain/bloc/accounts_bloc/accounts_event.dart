part of 'accounts_bloc.dart';

@freezed
sealed class AccountsEvent with _$AccountsEvent {
  const AccountsEvent._();
  const factory AccountsEvent.load() = _Load;
}

final class _InternalUpdate extends AccountsEvent {
  const _InternalUpdate(this.accounts) : super._();

  final List<AccountEntity> accounts;
}
