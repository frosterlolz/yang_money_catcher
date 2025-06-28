part of 'accounts_bloc.dart';

@freezed
sealed class AccountsState with _$AccountsState {
  const factory AccountsState.idle(UnmodifiableListView<AccountEntity> accounts) = AccountsState$Idle;
  const factory AccountsState.processing(UnmodifiableListView<AccountEntity>? accounts) = AccountsState$Processing;
  const factory AccountsState.error(UnmodifiableListView<AccountEntity>? accounts, {required Object error}) =
      AccountsState$Error;
}
