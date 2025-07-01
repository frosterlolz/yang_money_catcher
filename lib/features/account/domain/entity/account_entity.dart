import 'package:database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category_stat.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

// ignore_for_file: invalid_annotation_target

// Account (swagger)

@freezed
class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required int id,
    required int userId,
    required String name,
    required String balance,
    // TODO(frosterlolz): уточнить по Currency, тк в схеме это String, но для матчинга со знаком рубля- нужен enum
    @JsonKey(defaultValue: Currency.rub) required Currency currency,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountEntity;

  factory AccountEntity.fromJson(JsonMap json) => _$AccountEntityFromJson(json);

  factory AccountEntity.fromTableItem(AccountItem item) => AccountEntity(
        id: item.id,
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
    required String name,
    required String balance,
    required Currency currency,
    required List<TransactionCategoryStat> incomeStats,
    required List<TransactionCategoryStat> expenseStats,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountDetailEntity;

  factory AccountDetailEntity.fromJson(JsonMap json) => _$AccountDetailEntityFromJson(json);

  factory AccountDetailEntity.fromTableItem(
    AccountItem item, {
    required List<TransactionCategoryStat> incomeStats,
    required List<TransactionCategoryStat> expenseStats,
  }) =>
      AccountDetailEntity(
        id: item.id,
        name: item.name,
        balance: item.balance,
        currency: Currency.fromKey(item.currency),
        incomeStats: incomeStats,
        expenseStats: expenseStats,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
}
