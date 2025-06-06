import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_brief.freezed.dart';
part 'account_brief.g.dart';

@freezed
class AccountBrief with _$AccountBrief {
  const factory AccountBrief({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountBrief;

  factory AccountBrief.fromJson(JsonMap json) => _$AccountBriefFromJson(json);
}
