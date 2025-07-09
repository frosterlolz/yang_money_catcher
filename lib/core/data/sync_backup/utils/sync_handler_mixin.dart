import 'package:rest_client/rest_client.dart';

mixin SyncHandlerMixin on Object {
  Future<T> handleWithSync<T>({
    required Future<T> Function() method,
    required Future<void> Function() addEventMethod,
  }) async {
    try {
      final result = await method();

      return result;
    } on RestClientException catch (e) {
      switch (e) {
        case ConnectionException():
          await addEventMethod();
        case ClientException(:final statusCode) || StructuredBackendException(:final statusCode)
            when (statusCode ?? 0) >= 500:
          await addEventMethod();
        default:
          break;
      }
      rethrow;
    }
  }
}
