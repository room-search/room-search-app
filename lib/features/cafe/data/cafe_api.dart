import 'package:dio/dio.dart';

import '../../../shared/models/spring_page.dart';
import 'models/cafe.dart';
import 'models/cafe_location.dart';

class CafeApi {
  CafeApi(this._dio);
  final Dio _dio;

  Future<SpringPage<EscapeCafe>> search({
    String? area,
    String? location,
    String? search,
    bool? onlyOpen,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final query = <String, dynamic>{'page': page, 'size': size};
    if (area != null && area.isNotEmpty) query['area'] = area;
    if (location != null && location.isNotEmpty) query['location'] = location;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (onlyOpen != null) query['onlyOpen'] = onlyOpen;
    if (sort != null && sort.isNotEmpty) query['sort'] = sort;

    final res = await _dio.get<dynamic>('/api/escape/cafes', queryParameters: query);
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return SpringPage<EscapeCafe>.fromJson(data, EscapeCafe.fromJson);
    }
    return SpringPage.empty$<EscapeCafe>();
  }

  Future<EscapeCafe> getById(String id) async {
    final res = await _dio.get<dynamic>('/api/escape/cafes/$id');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return EscapeCafe.fromJson(data);
    }
    throw StateError('Invalid cafe detail payload');
  }

  Future<List<EscapeCafe>> byBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    bool? onlyOpen,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/escape/cafes/by-bounds',
      queryParameters: {
        'minLat': minLat,
        'maxLat': maxLat,
        'minLng': minLng,
        'maxLng': maxLng,
        if (onlyOpen != null) 'onlyOpen': onlyOpen,
      },
    );
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(EscapeCafe.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Future<List<CafeLocation>> locations() async {
    final res = await _dio.get<dynamic>('/api/escape/cafes/location');
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CafeLocation.fromJson)
          .toList(growable: false);
    }
    return const [];
  }
}
