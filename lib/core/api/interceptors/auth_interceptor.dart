import 'package:dio/dio.dart';

import '../../config/env.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-API-Key'] = Env.apisisKey;
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }
}
