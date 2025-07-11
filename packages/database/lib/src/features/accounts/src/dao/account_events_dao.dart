import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'account_events_dao.g.dart';

@DriftAccessor(tables: [AccountEventItems])
class AccountEventsDao extends DatabaseAccessor<AppDatabase> with _$AccountEventsDaoMixin {
  AccountEventsDao(super.attachedDatabase);

  Future<List<AccountEventsValueObject>> fetchEvents() async {
    final eventsWithRefs =
        await attachedDatabase.managers.accountEventItems.withReferences((prefetch) => prefetch(account: true)).get();

    return eventsWithRefs
        .map(
          (eventWithRefs) => AccountEventsValueObject(
            event: eventWithRefs.$1,
            account: eventWithRefs.$2.account.prefetchedData?.singleOrNull,
          ),
        )
        .toList();
  }

  Future<void> insertEvent(AccountEventItemsCompanion companion) async =>
      into(accountEventItems).insert(companion, mode: InsertMode.insertOrReplace);

  Future<void> updateEvent(AccountEventItemsCompanion companion) async {
    final statement = update(accountEventItems)..where((table) => table.account.equals(companion.account.value));
    await statement.write(companion);
  }

  Future<void> deleteEvent(int accountId) => accountEventItems.deleteWhere((table) => table.account.equals(accountId));

  Stream<List<AccountEventsValueObject>> watchEvents() => attachedDatabase.managers.accountEventItems
      .withReferences(
        (prefetch) => prefetch(account: true),
      )
      .map<AccountEventsValueObject>(
        (mapper) => AccountEventsValueObject(
          event: mapper.$1,
          account: mapper.$2.account.prefetchedData?.singleOrNull,
        ),
      )
      .watch();
}
