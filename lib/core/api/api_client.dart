import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';
import 'interceptors/rate_limit_interceptor.dart';

Dio buildApisisDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.apiConnectTimeout,
      receiveTimeout: Env.apiReceiveTimeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
      listFormat: ListFormat.multi,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(),
    EnvelopeInterceptor(),
    RateLimitInterceptor(),
    if (kDebugMode)
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
        compact: true,
        maxWidth: 120,
      ),
  ]);

  return dio;
}
