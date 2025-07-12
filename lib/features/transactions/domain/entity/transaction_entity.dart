import 'package:database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';

part 'transaction_entity.freezed.dart';

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required int id,
    required int? remoteId,
    required int accountId,
    required int categoryId,
    required String amount,
    required DateTime transactionDate,
    required String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionEntity;

  factory TransactionEntity.merge(TransactionDto dto, {required int localId, required int localAccountId}) =>
      TransactionEntity(
        id: localId,
        remoteId: dto.id,
        accountId: localAccountId,
        categoryId: dto.categoryId,
        amount: dto.amount,
        transactionDate: dto.transactionDate,
        comment: dto.comment,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
      );

  factory TransactionEntity.fromDetails(TransactionDetailEntity details) => TransactionEntity(
        id: details.id,
        remoteId: details.remoteId,
        accountId: details.account.id,
        categoryId: details.category.id,
        amount: details.amount,
        transactionDate: details.transactionDate,
        comment: details.comment,
        createdAt: details.createdAt,
        updatedAt: details.updatedAt,
      );

  factory TransactionEntity.fromTableItem(TransactionItem item) => TransactionEntity(
        id: item.id,
        remoteId: item.remoteId,
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
    required int? remoteId,
    required AccountBrief account,
    required TransactionCategory category,
    required String amount,
    required DateTime transactionDate,
    required String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionDetailEntity;

  const TransactionDetailEntity._();

  factory TransactionDetailEntity.fromTableItem(
    TransactionItem item, {
    required AccountBrief accountBrief,
    required TransactionCategory category,
  }) =>
      TransactionDetailEntity(
        id: item.id,
        remoteId: item.remoteId,
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
