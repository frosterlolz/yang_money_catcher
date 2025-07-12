import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_logger/pretty_logger.dart';

class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor(this._logger);

  final PrettyLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final fullUrl = '${options.baseUrl}${options.path}';

    _logger.debug(
      '$method $fullUrl',
      context: {
        'headers': options.headers,
        if (options.queryParameters.isNotEmpty) 'query': options.queryParameters,
        if (options.data != null) 'body': options.data,
      },
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    final fullUrl = '${req.baseUrl}${req.path}';

    _logger.info(
      'Response [$fullUrl]',
      context: {
        'statusCode': response.statusCode,
        'headers': response.headers.map,
        'data': response.data,
        'source': response.statusCode == 304 ? 'cache' : 'network',
      },
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    final fullUrl = '${req.baseUrl}${req.path}';
    final method = req.method.toUpperCase();

    final context = <String, Object?>{
      'method': method,
      'url': fullUrl,
      'type': err.type.name,
      if (err.response != null) ...{
        'statusCode': err.response?.statusCode,
        'headers': err.response?.headers.map,
        'data': err.response?.data,
      },
      if (err.error != null) 'error': err.error.toString(),
    };

    if (!kIsWeb && err.error is SocketException) {
      _logger.warn('No internet: $method $fullUrl', context: context, error: err);
    } else {
      _logger.error('HTTP error: $method $fullUrl', context: context, error: err, stackTrace: err.stackTrace);
    }

    super.onError(err, handler);
  }
}
