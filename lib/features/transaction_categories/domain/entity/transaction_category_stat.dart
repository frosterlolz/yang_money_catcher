import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';

part 'transaction_category_stat.freezed.dart';
part 'transaction_category_stat.g.dart';

@freezed
class TransactionCategoryStat with _$TransactionCategoryStat {
  const factory TransactionCategoryStat({
    required int categoryId,
    required String categoryName,
    required String emoji,
    required String amount,
  }) = _TransactionCategoryStat;

  factory TransactionCategoryStat.fromJson(JsonMap json) => _$TransactionCategoryStatFromJson(json);

  factory TransactionCategoryStat.fromTableItem(
  TransactionCategory category, {
    required String amount,
  }) =>
      TransactionCategoryStat(
        categoryId: category.id,
        categoryName: category.name,
        emoji: category.emoji,
        amount: amount,
      );
}
