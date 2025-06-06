import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';

part 'transaction_change_request.freezed.dart';
part 'transaction_change_request.g.dart';

abstract interface class TransactionRequest$Create {}

abstract interface class TransactionRequest$Update {}

@freezed
class TransactionRequest with _$TransactionRequest {
  @Implements<TransactionRequest$Create>()
  @Implements<TransactionRequest$Update>()
  const factory TransactionRequest({
    required int accountId,
    required int categoryId,
    required String amount,
    required DateTime transactionDate,
    required String? comment,
  }) = _TransactionRequest;

  factory TransactionRequest.fromJson(JsonMap json) => _$TransactionRequestFromJson(json);
}
