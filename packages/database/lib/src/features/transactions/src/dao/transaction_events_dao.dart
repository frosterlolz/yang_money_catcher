import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'transaction_events_dao.g.dart';

@DriftAccessor(tables: [TransactionEventItems])
class TransactionEventsDao extends DatabaseAccessor<AppDatabase> with _$TransactionEventsDaoMixin {
  TransactionEventsDao(super.attachedDatabase);

  Future<List<TransactionEventValueObject>> fetchEvents() async {
    final eventsWithRefs = await attachedDatabase.managers.transactionEventItems
        .withReferences((prefetch) => prefetch(transaction: true))
        .get();

    return eventsWithRefs
        .map(
          (eventWithRefs) => TransactionEventValueObject(
            event: eventWithRefs.$1,
            transaction: eventWithRefs.$2.transaction.prefetchedData?.singleOrNull,
          ),
        )
        .toList();
  }

  Future<void> insertEvent(TransactionEventItemsCompanion companion) async =>
      into(transactionEventItems).insert(companion, mode: InsertMode.insertOrReplace);

  Future<void> updateEvent(TransactionEventItemsCompanion companion) async {
    final statement = update(transactionEventItems)
      ..where((table) => table.transaction.equals(companion.transaction.value));
    await statement.write(companion);
  }

  Future<void> deleteEvent(int transactionId) =>
      transactionEventItems.deleteWhere((table) => table.transaction.equals(transactionId));

  Stream<List<TransactionEventValueObject>> watchEvents() => attachedDatabase.managers.transactionEventItems
      .withReferences(
        (prefetch) => prefetch(transaction: true),
      )
      .map<TransactionEventValueObject>(
        (mapper) => TransactionEventValueObject(
          event: mapper.$1,
          transaction: mapper.$2.transaction.prefetchedData?.singleOrNull,
        ),
      )
      .watch();
}
