import 'package:dio/dio.dart';
import 'package:rest_client/rest_client.dart';

/// {@template rest_client_dio}
/// Rest client that uses [Dio] as HTTP library.
/// {@endtemplate}
final class RestClientDio extends RestClientBase {
  /// {@macro rest_client_dio}
  RestClientDio({required Dio dio})
      : _dio = dio,
        super(baseUrl: dio.options.baseUrl);

  final Dio _dio;

  /// Send [Dio] request
  @override
  Future<JsonMap?> send({
    required String path,
    required String method,
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  }) async {
    try {
      final options = Options(
        headers: headers,
        extra: extra,
        method: method,
        contentType: 'application/json',
        responseType: ResponseType.json,
      );

      final response = await _dio.request<Object?>(
        path,
        queryParameters: queryParams,
        data: body,
        options: options,
      );

      final resp = await decodeResponse(
        response.data,
        statusCode: response.statusCode,
      );

      return resp;
    } on RestClientException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        Error.throwWithStackTrace(
          ConnectionException(
            message: 'ConnectionException',
            statusCode: e.response?.statusCode,
            cause: e,
          ),
          e.stackTrace,
        );
      }
      // TODO(frosterlolz): Optional. Remove in another scenarios
      if (e.response?.statusCode == 404) {
        return null;
      }
      if (e.response != null) {
        final result = await decodeResponse(
          e.response!.data,
          statusCode: e.response?.statusCode,
        );
        if (result is JsonMap) {
          Error.throwWithStackTrace(StructuredBackendException(error: result), e.stackTrace);
        }
      }
      Error.throwWithStackTrace(
        ClientException(
          message: e.toString(),
          statusCode: e.response?.statusCode,
          cause: e,
        ),
        e.stackTrace,
      );
    }
  }
}
