import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';

part 'transaction_category.freezed.dart';
part 'transaction_category.g.dart';

@freezed
class TransactionCategory with _$TransactionCategory {
  const factory TransactionCategory({
    required int id,
    required String name,
    required String emoji,
    required bool isIncome,
  }) = _TransactionCategory;

  factory TransactionCategory.fromJson(JsonMap json) => _$TransactionCategoryFromJson(json);
}
