import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/data/dto/account_history_dto.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_history.freezed.dart';

@freezed
class AccountHistory with _$AccountHistory {
  const factory AccountHistory({
    required int accountId,
    required String accountName,
    required Currency currency,
    required String currencyBalance,
    required List<AccountHistoryItem> history,
  }) = _AccountHistory;

  factory AccountHistory.fromLocalSource(
    AccountEntity item, {
    required List<AccountHistoryItem> history,
  }) =>
      AccountHistory(
        accountId: item.id,
        accountName: item.name,
        currency: item.currency,
        currencyBalance: item.balance,
        history: history,
      );
}

@freezed
class AccountHistoryItem with _$AccountHistoryItem {
  const factory AccountHistoryItem({
    required int id,
    required int accountId,
    required AccountStateChangingReason changeType,
    required AccountState previousState,
    required AccountState newState,
    required DateTime changeTimestamp,
    required DateTime createdAt,
  }) = _AccountHistoryItem;

  factory AccountHistoryItem.fromDto(AccountHistoryItemDto dto) => AccountHistoryItem(
        id: dto.id,
        accountId: dto.accountId,
        changeType: dto.changeType,
        previousState: AccountState.fromDto(dto.previousState),
        newState: AccountState.fromDto(dto.newState),
        changeTimestamp: dto.changeTimestamp,
        createdAt: dto.createdAt,
      );
}

@freezed
class AccountState with _$AccountState {
  const factory AccountState({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountState;

  factory AccountState.fromDto(AccountStateDto dto) => AccountState(
        id: dto.id,
        name: dto.name,
        balance: dto.balance,
        currency: dto.currency,
      );
}
