import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// {@template dio_configurator.class}
/// The base class with client configuration of [Dio].
/// {@endtemplate}
class DioConfigurator {
  /// {@macro dio_configurator.class}
  const DioConfigurator();

  /// Creating a client [Dio].
  Dio create({
    Iterable<Interceptor>? interceptors,
    required String url,
    Transformer? transformer,
  }) {
    const timeout = Duration(seconds: 30);

    final dio = Dio()..transformer = transformer ?? BackgroundTransformer();

    dio.options
      ..baseUrl = url
      ..connectTimeout = timeout
      ..receiveTimeout = timeout
      ..sendTimeout = (kIsWeb ? null : timeout);

    if (interceptors?.isNotEmpty ?? false) {
      dio.interceptors.addAll(interceptors!);
    }

    return dio;
  }
}
