import 'package:json_annotation/json_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/data/dto/account_dto.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';

part 'transaction_dto.g.dart';

@JsonSerializable(createToJson: false)
class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionDto.fromJson(JsonMap json) => _$TransactionDtoFromJson(json);

  final int id;
  final int accountId;
  final int categoryId;
  final String amount;
  final DateTime transactionDate;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@JsonSerializable(createToJson: false)
class TransactionDetailsDto {
  const TransactionDetailsDto({
    required this.id,
    required this.account,
    required this.category,
    required this.amount,
    required this.transactionDate,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionDetailsDto.fromJson(JsonMap json) => _$TransactionDetailsDtoFromJson(json);

  final int id;
  final AccountBriefDto account;
  final TransactionCategory category;
  final String amount;
  final DateTime transactionDate;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
}
