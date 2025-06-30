import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_filters.freezed.dart';

@freezed
class TransactionFilters with _$TransactionFilters {
  const factory TransactionFilters({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
  }) = _TransactionFilters;
}
