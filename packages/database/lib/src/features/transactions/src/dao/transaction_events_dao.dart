import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'transaction_events_dao.g.dart';

@DriftAccessor(tables: [TransactionEventItems])
class TransactionEventsDao extends DatabaseAccessor<AppDatabase> with _$TransactionEventsDaoMixin {
  TransactionEventsDao(super.attachedDatabase);

  Future<int> eventsRowCount() async {
    final isExists = await _isTableExists();
    if (!isExists) return 0;
    return transactionEventItems.count().getSingle();
  }

  // Future<dynamic> fetchEvents() async {
  //   final isExists = await _isTableExists();
  //   if (!isExists) return [];
  //   final eventsWithRefs = await attachedDatabase.managers.transactionEventItems
  //       .withReferences((prefetch) => prefetch(transaction: true))
  //       .get();
  //   return eventsWithRefs;
  // }



  Future<bool> _isTableExists() => attachedDatabase.managers.transactionEventItems.exists();
}
