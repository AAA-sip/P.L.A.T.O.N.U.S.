import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _log = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: false,
    ),
  );

  static const _sensitiveHeaders = {'token', 'authorization', 'cookie'};
  static const _sensitiveFields = {'password'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = options.headers.map((k, v) =>
        MapEntry(k, _sensitiveHeaders.contains(k.toLowerCase()) ? '***' : v));
    var data = options.data;
    if (data is Map) {
      data = data.map((k, v) =>
          MapEntry(k, _sensitiveFields.contains(k.toString().toLowerCase()) ? '***' : v));
    }
    _log.i('--> ${options.method} ${options.uri}');
    _log.d('headers: $headers');
    if (data != null) _log.d('body: $data');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.i('<-- ${response.statusCode} ${response.requestOptions.uri}');
    _log.d('response: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e('<-- ${err.response?.statusCode} ${err.requestOptions.uri}');
    _log.e('error: ${err.message}', error: err.error);
    if (err.response?.data != null) {
      _log.d('response: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
