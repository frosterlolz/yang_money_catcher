part of 'accounts_bloc.dart';

@freezed
sealed class AccountsEvent with _$AccountsEvent {
  const factory AccountsEvent.load() = _Load;

  /// Create new or update existing account
  const factory AccountsEvent.update(AccountRequest request) = _Update;
  const factory AccountsEvent.delete(int id) = _Delete;
}
