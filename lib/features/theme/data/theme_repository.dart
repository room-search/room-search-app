import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import 'models/theme.dart';
import 'models/theme_search_query.dart';
import 'theme_api.dart';
import '../../../shared/models/spring_page.dart';

final themeApiProvider = Provider<ThemeApi>((ref) => ThemeApi(ref.watch(dioProvider)));

class ThemeRepository {
  ThemeRepository(this._api);
  final ThemeApi _api;

  Future<SpringPage<EscapeTheme>> search(ThemeSearchQuery q) => _api.search(q);
  Future<EscapeTheme> byId(int refId) => _api.getById(refId);
  Future<int> countMatches(ThemeSearchQuery q) => _api.countMatches(q);
}

final themeRepositoryProvider = Provider<ThemeRepository>(
  (ref) => ThemeRepository(ref.watch(themeApiProvider)),
);
