// ignore_for_file: strict_raw_type

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../cafe/data/models/cafe.dart';
import '../../theme/data/models/theme.dart';

/// Favorites are stored as plain `Map<String, dynamic>` in Hive boxes,
/// keyed by the stable domain id (theme refId as string, cafe id).
class FavoriteRepository {
  FavoriteRepository._(this._themes, this._cafes);

  static Future<FavoriteRepository> open() async {
    final themes = await Hive.openBox<Map>(HiveBoxes.favoriteThemes);
    final cafes = await Hive.openBox<Map>(HiveBoxes.favoriteCafes);
    return FavoriteRepository._(themes, cafes);
  }

  final Box<Map> _themes;
  final Box<Map> _cafes;

  // ---- Themes ----
  bool isThemeFavorite(int refId) => _themes.containsKey(refId.toString());

  Future<void> removeTheme(int refId) => _themes.delete(refId.toString());

  Future<void> toggleTheme(EscapeTheme t) async {
    final key = t.refId.toString();
    if (_themes.containsKey(key)) {
      await _themes.delete(key);
    } else {
      await _themes.put(key, {
        'refId': t.refId,
        'name': t.name,
        'photoUrl': t.photoUrl,
        'escapeCafeId': t.escapeCafeId,
        'playtime': t.playtime,
        'price': t.price,
        'difficulty': t.difficulty,
        'fear': t.fear,
        'satisfy': t.satisfy,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  List<Map<String, dynamic>> listThemes() => _themes.values
      .map((m) => Map<String, dynamic>.from(m))
      .toList(growable: false)
    ..sort((a, b) => (b['savedAt'] as String? ?? '')
        .compareTo(a['savedAt'] as String? ?? ''));

  Stream<BoxEvent> watchThemes() => _themes.watch();

  // ---- Cafes ----
  bool isCafeFavorite(String id) => _cafes.containsKey(id);

  Future<void> removeCafe(String id) => _cafes.delete(id);

  Future<void> toggleCafe(EscapeCafe c) async {
    if (_cafes.containsKey(c.id)) {
      await _cafes.delete(c.id);
    } else {
      await _cafes.put(c.id, {
        'id': c.id,
        'name': c.name,
        'address': c.address,
        'area': c.area,
        'location': c.location,
        'lat': c.lat,
        'lng': c.lng,
        'phoneNo': c.phoneNo,
        'themeCount': c.themes.length,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  List<Map<String, dynamic>> listCafes() => _cafes.values
      .map((m) => Map<String, dynamic>.from(m))
      .toList(growable: false)
    ..sort((a, b) => (b['savedAt'] as String? ?? '')
        .compareTo(a['savedAt'] as String? ?? ''));

  Stream<BoxEvent> watchCafes() => _cafes.watch();
}

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  throw UnimplementedError(
    'favoriteRepositoryProvider must be overridden in bootstrap',
  );
});

/// Stream of the theme favorites box events — UI listens to rebuild.
final themeFavoritesChangedProvider = StreamProvider<BoxEvent>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchThemes();
});

final cafeFavoritesChangedProvider = StreamProvider<BoxEvent>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchCafes();
});
