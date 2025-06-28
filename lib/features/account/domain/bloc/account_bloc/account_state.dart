part of 'account_bloc.dart';

@freezed
sealed class AccountState with _$AccountState {
  const factory AccountState.idle(AccountDetailEntity account) = AccountState$Idle;
  const factory AccountState.processing(AccountDetailEntity? account) = AccountState$Processing;
  const factory AccountState.error(AccountDetailEntity? account, {required Object error}) = AccountState$Error;
}
