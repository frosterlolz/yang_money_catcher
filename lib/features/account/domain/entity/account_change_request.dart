import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_change_request.freezed.dart';
part 'account_change_request.g.dart';

abstract interface class AccountRequest$Create {}

abstract interface class AccountRequest$Update {}

@Freezed(fromJson: false, toJson: true)
class AccountRequest with _$AccountRequest {
  @Implements<AccountRequest$Create>()
  @Implements<AccountRequest$Update>()
  const factory AccountRequest({
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountRequest;
}
