import 'package:dio/dio.dart';

/// APISIS wraps every response in:
/// { title, version, current, limit, timestamp, payload, processMs }
/// This interceptor unwraps `payload` so callers only see domain shape.
/// Envelope metadata is preserved under `response.extra['envelope']`.
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('payload')) {
      response.extra['envelope'] = {
        'title': data['title'],
        'version': data['version'],
        'current': data['current'],
        'limit': data['limit'],
        'timestamp': data['timestamp'],
        'processMs': data['processMs'],
      };
      response.data = data['payload'];
    }
    super.onResponse(response, handler);
  }
}
