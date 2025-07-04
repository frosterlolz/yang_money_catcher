part of 'accounts_bloc.dart';

@freezed
sealed class AccountsEvent with _$AccountsEvent {
  const factory AccountsEvent.load() = _Load;
  const factory AccountsEvent.delete(int id) = _Delete;
}
