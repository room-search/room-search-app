import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/spring_page.dart';
import '../../../shared/providers/dio_provider.dart';
import 'cafe_api.dart';
import 'models/cafe.dart';
import 'models/cafe_location.dart';

final cafeApiProvider = Provider<CafeApi>((ref) => CafeApi(ref.watch(dioProvider)));

class CafeRepository {
  CafeRepository(this._api);
  final CafeApi _api;

  Future<SpringPage<EscapeCafe>> search({
    String? area,
    String? location,
    String? search,
    bool? onlyOpen,
    int page = 0,
    int size = 20,
    String? sort,
  }) =>
      _api.search(
        area: area,
        location: location,
        search: search,
        onlyOpen: onlyOpen,
        page: page,
        size: size,
        sort: sort,
      );

  Future<EscapeCafe> byId(String id) => _api.getById(id);

  Future<List<EscapeCafe>> byBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    bool? onlyOpen,
  }) =>
      _api.byBounds(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
        onlyOpen: onlyOpen,
      );

  Future<List<CafeLocation>> locations() => _api.locations();
}

final cafeRepositoryProvider = Provider<CafeRepository>(
  (ref) => CafeRepository(ref.watch(cafeApiProvider)),
);

final cafeLocationsProvider = FutureProvider<List<CafeLocation>>((ref) async {
  final repo = ref.watch(cafeRepositoryProvider);
  return repo.locations();
});
