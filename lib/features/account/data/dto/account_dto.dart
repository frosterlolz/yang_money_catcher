import 'package:json_annotation/json_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/core/utils/converters/converters.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category_stat.dart';

part 'account_dto.g.dart';

// Account (swagger)
@JsonSerializable(createFactory: true, createToJson: false)
class AccountDto {
  const AccountDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountDto.fromJson(JsonMap json) => _$AccountDtoFromJson(json);

  final int id;
  final int userId;
  final String name;
  final String balance;
  final Currency currency;
  @JsonKey(fromJson: DateTimeConverter.fromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: DateTimeConverter.fromJson)
  final DateTime updatedAt;
}

@JsonSerializable(createFactory: true, createToJson: false)
class AccountBriefDto {
  const AccountBriefDto({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
  });

  factory AccountBriefDto.fromJson(JsonMap json) => _$AccountBriefDtoFromJson(json);
  final int id;
  final String name;
  final String balance;
  final Currency currency;
}

@JsonSerializable(createFactory: true, createToJson: false)
class AccountDetailsDto {
  const AccountDetailsDto({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.incomeStats,
    required this.expenseStats,
  });

  factory AccountDetailsDto.fromJson(JsonMap json) => _$AccountDetailsDtoFromJson(json);

  final int id;
  final String name;
  final String balance;
  final Currency currency;
  @JsonKey(fromJson: DateTimeConverter.fromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: DateTimeConverter.fromJson)
  final DateTime updatedAt;
  final List<TransactionCategoryStat> incomeStats;
  final List<TransactionCategoryStat> expenseStats;
}
