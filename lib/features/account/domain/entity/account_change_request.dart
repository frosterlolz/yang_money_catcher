import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_change_request.freezed.dart';
part 'account_change_request.g.dart';

// ignore_for_file: invalid_annotation_target

@Freezed(fromJson: false, toJson: true)
sealed class AccountRequest with _$AccountRequest {
  const factory AccountRequest.create({
    required String name,
    required String balance,
    required Currency currency,
  }) = AccountRequest$Create;

  const factory AccountRequest.update({
    @JsonKey(includeToJson: false) required int id,
    required String name,
    required String balance,
    required Currency currency,
  }) = AccountRequest$Update;

  factory AccountRequest.fromEntity(AccountEntity account) => AccountRequest.update(
        id: account.id,
        name: account.name,
        balance: account.balance,
        currency: account.currency,
      );
}
