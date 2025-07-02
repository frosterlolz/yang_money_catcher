import 'package:database/database.dart';
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

  factory TransactionEntity.fromTableItem(TransactionItem item) => TransactionEntity(
      id: item.id,
      accountId: item.account,
      categoryId: item.category,
      amount: item.amount,
      transactionDate: item.transactionDate,
      comment: item.comment,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
  );
}

@freezed
class TransactionDetailEntity with _$TransactionDetailEntity implements Comparable<TransactionDetailEntity> {
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

  const TransactionDetailEntity._();

  factory TransactionDetailEntity.fromJson(JsonMap json) => _$TransactionDetailEntityFromJson(json);

  factory TransactionDetailEntity.fromTableItem(TransactionItem item, {
    required AccountBrief accountBrief,
    required TransactionCategory category,
  }) => TransactionDetailEntity(
    id: item.id,
    account: accountBrief,
    category: category,
    amount: item.amount,
    transactionDate: item.transactionDate,
    comment: item.comment,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
  );

  @override
  int compareTo(TransactionDetailEntity other) => id.compareTo(other.id);
}
