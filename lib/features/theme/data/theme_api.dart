import 'package:dio/dio.dart';

import '../../../shared/models/spring_page.dart';
import 'models/theme.dart';
import 'models/theme_search_query.dart';

class ThemeApi {
  ThemeApi(this._dio);
  final Dio _dio;

  Future<SpringPage<EscapeTheme>> search(ThemeSearchQuery q) async {
    final res = await _dio.get<dynamic>(
      '/api/escape/themes',
      queryParameters: q.toQuery(),
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return SpringPage<EscapeTheme>.fromJson(data, EscapeTheme.fromJson);
    }
    return SpringPage.empty$<EscapeTheme>();
  }

  Future<EscapeTheme> getById(int refId) async {
    final res = await _dio.get<dynamic>('/api/escape/themes/$refId');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return EscapeTheme.fromJson(data);
    }
    throw StateError('Invalid theme detail payload');
  }

  Future<int> countMatches(ThemeSearchQuery q) async {
    final probe = q.copyWith(page: 0, size: 1);
    final res = await _dio.get<dynamic>(
      '/api/escape/themes',
      queryParameters: probe.toQuery(),
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return (data['totalElements'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }
}
