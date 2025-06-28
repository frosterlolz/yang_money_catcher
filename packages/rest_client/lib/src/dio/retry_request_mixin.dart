import 'package:dio/dio.dart';
import 'package:rest_client/src/dio/dio_x.dart';

/// A mixin that provides a method to retry a request.
mixin class RetryRequestMixin {
  /// Retry the request
  Future<Response<R>> retryRequest<R>({
    required Response<R> response,
    required Map<String, Object?> headers,
    required Dio retryClient,
  }) =>
      retryClient.request<R>(
        response.requestOptions.fullPath,
        cancelToken: response.requestOptions.cancelToken,
        data: response.requestOptions.data,
        onReceiveProgress: response.requestOptions.onReceiveProgress,
        onSendProgress: response.requestOptions.onSendProgress,
        queryParameters: response.requestOptions.queryParameters,
        options: Options(
          method: response.requestOptions.method,
          sendTimeout: response.requestOptions.sendTimeout,
          receiveTimeout: response.requestOptions.receiveTimeout,
          extra: response.requestOptions.extra,
          headers: headers,
          responseType: response.requestOptions.responseType,
          contentType: response.requestOptions.contentType,
          validateStatus: response.requestOptions.validateStatus,
          receiveDataWhenStatusError: response.requestOptions.receiveDataWhenStatusError,
          followRedirects: response.requestOptions.followRedirects,
          maxRedirects: response.requestOptions.maxRedirects,
          requestEncoder: response.requestOptions.requestEncoder,
          responseDecoder: response.requestOptions.responseDecoder,
          listFormat: response.requestOptions.listFormat,
        ),
      );
}
