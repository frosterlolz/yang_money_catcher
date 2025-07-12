import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/features/initialization/presentation/initialization_failed_app.dart';

/// AuthInterceptor is used to add the Auth token to the request header
/// and redirect to fail app if the request fails with a 401
class AuthInterceptor extends QueuedInterceptor {
  /// Create an Auth interceptor
  ///
  /// [String] may be preloaded and passed via constructor
  AuthInterceptor({required this.token});

  /// static token
  final String token;

  Map<String, String> _tokenHeaders(String token) => {'Authorization': 'Bearer $token'};

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll(_tokenHeaders(token));

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      const clientException = ClientException(statusCode: 401, message: 'Unauthorized');
      runApp(InitializationFailedApp(error: clientException, stackTrace: err.stackTrace));
    }

    return handler.next(err);
  }
}
