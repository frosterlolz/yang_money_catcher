import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';

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
}
