import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_state.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_history.freezed.dart';
part 'account_history.g.dart';

@freezed
class AccountHistory with _$AccountHistory {
  const factory AccountHistory({
    required int accountId,
    required String accountName,
    required Currency currency,
    required String currencyBalance,
    required List<AccountHistoryItem> history,
  }) = _AccountHistory;

  factory AccountHistory.fromJson(JsonMap json) => _$AccountHistoryFromJson(json);
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

  factory AccountHistoryItem.fromJson(JsonMap json) => _$AccountHistoryItemFromJson(json);
}
