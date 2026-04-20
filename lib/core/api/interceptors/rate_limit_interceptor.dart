import 'dart:math';

import 'package:dio/dio.dart';

/// On 429 responses, sleep with exponential backoff and let the caller
/// decide whether to retry. Retries are intentionally NOT automatic so
/// daily call quotas are respected.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor();

  int _consecutive429 = 0;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 429) {
      _consecutive429++;
      final backoffMs = (pow(2, _consecutive429.clamp(1, 6)) * 500).toInt();
      await Future<void>.delayed(Duration(milliseconds: backoffMs));
    } else {
      _consecutive429 = 0;
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _consecutive429 = 0;
    super.onResponse(response, handler);
  }
}
