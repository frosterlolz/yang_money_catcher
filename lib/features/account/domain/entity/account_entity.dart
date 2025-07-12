import 'package:database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/data/dto/account_dto.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category_stat.dart';

part 'account_entity.freezed.dart';

@freezed
class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required int id,
    required int? remoteId,
    required int userId,
    required String name,
    required String balance,
    required Currency currency,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountEntity;

  factory AccountEntity.merge(AccountDto dto, int localId) => AccountEntity(
        id: localId,
        remoteId: dto.id,
        userId: dto.userId,
        name: dto.name,
        balance: dto.balance,
        currency: dto.currency,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
      );

  factory AccountEntity.fromTableItem(AccountItem item) => AccountEntity(
        id: item.id,
        remoteId: item.remoteId,
        userId: item.userId,
        name: item.name,
        balance: item.balance,
        currency: Currency.fromKey(item.currency),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
}

// AccountResponse (swagger)
@freezed
class AccountDetailEntity with _$AccountDetailEntity {
  const factory AccountDetailEntity({
    required int id,
    int? remoteId,
    required String name,
    required String balance,
    required Currency currency,
    required List<TransactionCategoryStat> incomeStats,
    required List<TransactionCategoryStat> expenseStats,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountDetailEntity;

  factory AccountDetailEntity.fromLocalSource(
    AccountEntity item, {
    required List<TransactionCategoryStat> incomeStats,
    required List<TransactionCategoryStat> expenseStats,
  }) =>
      AccountDetailEntity(
        id: item.id,
        remoteId: item.remoteId,
        name: item.name,
        balance: item.balance,
        currency: item.currency,
        incomeStats: incomeStats,
        expenseStats: expenseStats,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  const AccountDetailEntity._();

  AccountDetailEntity fromEntity(AccountEntity other) => AccountDetailEntity(
        id: other.id,
        name: other.name,
        balance: other.balance,
        currency: other.currency,
        createdAt: other.createdAt,
        updatedAt: other.updatedAt,
        incomeStats: incomeStats,
        expenseStats: expenseStats,
      );
}
