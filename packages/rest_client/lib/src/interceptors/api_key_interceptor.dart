import 'package:dio/dio.dart';

class ApiKeyInterceptor extends InterceptorsWrapper {
  ApiKeyInterceptor(this._apiKeyEntry);

  final MapEntry<String, String> _apiKeyEntry;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers[_apiKeyEntry.key] = _apiKeyEntry.value;

    return handler.next(options);
  }
}
