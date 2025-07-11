part of 'account_bloc.dart';

@freezed
sealed class AccountState with _$AccountState {
  const factory AccountState.idle(AccountDetailEntity? account, {required bool isOffline}) = AccountState$Idle;
  const factory AccountState.processing(AccountDetailEntity? account, {required bool isOffline}) =
      AccountState$Processing;
  const factory AccountState.error(AccountDetailEntity? account, {required bool isOffline, required Object error}) =
      AccountState$Error;
}
