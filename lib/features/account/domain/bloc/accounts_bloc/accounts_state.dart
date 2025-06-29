part of 'accounts_bloc.dart';

@freezed
sealed class AccountsState with _$AccountsState {
  const AccountsState._();

  const factory AccountsState.idle(UnmodifiableListView<AccountEntity> accounts) = AccountsState$Idle;
  const factory AccountsState.processing(UnmodifiableListView<AccountEntity>? accounts) = AccountsState$Processing;
  const factory AccountsState.error(UnmodifiableListView<AccountEntity>? accounts, {required Object error}) =
      AccountsState$Error;

  AccountEntity? findAccount(int id) => accounts?.firstWhereOrNull((account) => account.id == id);
}
