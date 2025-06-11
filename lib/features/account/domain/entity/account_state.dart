import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_state.freezed.dart';
part 'account_state.g.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountState;

  factory AccountState.fromJson(JsonMap json) => _$AccountStateFromJson(json);
}
