part of 'account_bloc.dart';

@freezed
sealed class AccountEvent with _$AccountEvent {
  const factory AccountEvent.load(int accountId) = _Load;
  const factory AccountEvent.update(AccountRequest request) = _Update;
}
