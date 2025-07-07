import 'package:dio/dio.dart';

class ApiKeyInterceptor extends InterceptorsWrapper {
  ApiKeyInterceptor(this._apiKey);

  final String _apiKey;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO(frosterlolz): Change header key if needed
    options.headers['Api-key'] = _apiKey;

    return handler.next(options);
  }
}
