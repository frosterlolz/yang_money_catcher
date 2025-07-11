import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/utils/converters/converters.dart';

part 'transaction_change_request.freezed.dart';
part 'transaction_change_request.g.dart';

// ignore_for_file: invalid_annotation_target

@Freezed(fromJson: false, toJson: true)
sealed class TransactionRequest with _$TransactionRequest {
  const factory TransactionRequest.create({
    required int accountId,
    required int categoryId,
    required String amount,
    @JsonKey(toJson: DateTimeConverter.toIsoDTString) required DateTime transactionDate,
    required String? comment,
  }) = TransactionRequest$Create;

  const factory TransactionRequest.update({
    @JsonKey(includeToJson: false) required int id,
    required int accountId,
    required int categoryId,
    required String amount,
    @JsonKey(toJson: DateTimeConverter.toIsoDTString) required DateTime transactionDate,
    required String? comment,
  }) = TransactionRequest$Update;
}
