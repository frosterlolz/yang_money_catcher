import 'package:json_annotation/json_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/core/utils/converters/converters.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_history_dto.g.dart';

@JsonSerializable(createToJson: false)
class AccountHistoryDto {
  const AccountHistoryDto({
    required this.accountId,
    required this.accountName,
    required this.currency,
    required this.currencyBalance,
    required this.history,
  });

  factory AccountHistoryDto.fromJson(JsonMap json) => _$AccountHistoryDtoFromJson(json);

  final int accountId;
  final String accountName;
  final Currency currency;
  final String currencyBalance;
  final List<AccountHistoryItemDto> history;
}

@JsonSerializable(createToJson: false)
class AccountHistoryItemDto {
  const AccountHistoryItemDto({
    required this.id,
    required this.accountId,
    required this.changeType,
    required this.previousState,
    required this.newState,
    required this.changeTimestamp,
    required this.createdAt,
  });

  factory AccountHistoryItemDto.fromJson(JsonMap json) => _$AccountHistoryItemDtoFromJson(json);

  final int id;
  final int accountId;
  final AccountStateChangingReason changeType;
  final AccountStateDto previousState;
  final AccountStateDto newState;
  @JsonKey(fromJson: DateTimeConverter.fromJson)
  final DateTime changeTimestamp;
  @JsonKey(fromJson: DateTimeConverter.fromJson)
  final DateTime createdAt;
}

@JsonSerializable(createToJson: false)
class AccountStateDto {
  const AccountStateDto({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
  });

  factory AccountStateDto.fromJson(JsonMap json) => _$AccountStateDtoFromJson(json);

  final int id;
  final String name;
  final String balance;
  final Currency currency;
}
