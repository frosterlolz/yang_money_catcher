import 'package:database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
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

  factory AccountBrief.fromEntity(AccountEntity entity) => AccountBrief(
        id: entity.id,
        name: entity.name,
        balance: entity.balance,
        currency: entity.currency,
      );

  factory AccountBrief.fromTableItem(AccountItem item) => AccountBrief(
        id: item.id,
        name: item.name,
        balance: item.balance,
        currency: Currency.fromKey(item.currency),
      );
}
