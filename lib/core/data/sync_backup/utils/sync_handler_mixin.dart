import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';

mixin SyncHandlerMixin on Object {
  Future<T> handleWithSync<T, S>({
    required Future<T> Function() trySync,
    required SyncAction<S> action,
    required Future<void> Function(SyncAction<S>) saveAction,
  }) async {
    try {
      return await trySync();
    } on RestClientException catch (e) {
      if (e is ConnectionException || (e.statusCode ?? 0) >= 500) {
        await saveAction(action);
      }
      rethrow;
    }
  }
}
