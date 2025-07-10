import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_filters.freezed.dart';
part 'transaction_filters.g.dart';

// ignore_for_file: invalid_annotation_target

@Freezed(fromJson: false, toJson: true)
class TransactionFilters with _$TransactionFilters {
  const factory TransactionFilters({
    @JsonKey(includeToJson: false) required int? accountRemoteId,
    @JsonKey(includeToJson: false) required int accountId,
    @JsonKey(includeIfNull: false, toJson: _dateToJson) DateTime? startDate,
    @JsonKey(includeIfNull: false, toJson: _dateToJson) DateTime? endDate,
    @JsonKey(includeToJson: false) bool? isIncome,
  }) = _TransactionFilters;
}

String? _dateToJson(DateTime? dt) => dt?.toIso8601String().split('T').first;
