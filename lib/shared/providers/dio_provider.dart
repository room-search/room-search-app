import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = buildApisisDio();
  ref.onDispose(dio.close);
  return dio;
});
