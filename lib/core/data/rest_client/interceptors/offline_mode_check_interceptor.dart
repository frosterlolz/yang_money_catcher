import 'dart:io';

import 'package:dio/dio.dart';

enum OfflineModeReason {
  /// no reason, we're online
  none,

  /// no connection, or cause of timeout from server
  noInternet,

  /// server is unavailable (500+ status code)
  serverUnavailable;

  bool get isOffline => switch (this) {
        OfflineModeReason.none => false,
        OfflineModeReason.noInternet => true,
        OfflineModeReason.serverUnavailable => true,
      };
}

class OfflineModeCheckInterceptor extends Interceptor {
  OfflineModeCheckInterceptor({
    required this.onStatusChange,
  });

  final void Function(OfflineModeReason reason) onStatusChange;

  var _status = OfflineModeReason.none;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isOfflineError(err)) {
      _setNextStatus(OfflineModeReason.noInternet);
    } else if (_isServerError(err.response)) {
      _setNextStatus(OfflineModeReason.serverUnavailable);
    }

    handler.next(err);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _setNextStatus(OfflineModeReason.none);

    handler.next(response);
  }

  void _setNextStatus(OfflineModeReason nextStatus) {
    if (_status != nextStatus) {
      _status = nextStatus;
      onStatusChange(nextStatus);
    }
  }

  bool _isOfflineError(DioException e) =>
      e.type == DioExceptionType.unknown ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      (e.error is SocketException);

  bool _isServerError(Response<dynamic>? response) {
    final code = response?.statusCode ?? 0;
    return code >= 500 && code < 600;
  }
}
