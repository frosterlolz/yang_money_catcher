import 'package:dio/dio.dart';

class AppUpdateInterceptor extends InterceptorsWrapper {
  AppUpdateInterceptor(
    this.versionHeaderEntry, {
    required this.triggerHandler,
    this.triggerStatusCode = 426,
  });

  final MapEntry<String, String> versionHeaderEntry;

  /// Status code, indicates to trigger [triggerHandler] method
  final int triggerStatusCode;
  final void Function(DioException error, ErrorInterceptorHandler handler) triggerHandler;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers[versionHeaderEntry.key] = versionHeaderEntry.value;

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != triggerStatusCode) return super.onError(err, handler);
    triggerHandler.call(err, handler);
  }
}
