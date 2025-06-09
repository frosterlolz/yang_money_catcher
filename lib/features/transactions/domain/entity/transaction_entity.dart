import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';

part 'transaction_entity.freezed.dart';
part 'transaction_entity.g.dart';

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required int id,
    required int accountId,
    required int categoryId,
    required String amount,
    required DateTime transactionDate,
    required String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(JsonMap json) => _$TransactionEntityFromJson(json);
}

@freezed
class TransactionDetailEntity with _$TransactionDetailEntity {
  const factory TransactionDetailEntity({
    required int id,
    required AccountBrief account,
    required TransactionCategory category,
    required String amount,
    required DateTime transactionDate,
    required String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionDetailEntity;

  factory TransactionDetailEntity.fromJson(JsonMap json) => _$TransactionDetailEntityFromJson(json);
}
