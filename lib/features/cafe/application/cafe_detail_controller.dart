import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cafe_repository.dart';
import '../data/models/cafe.dart';

final cafeDetailProvider =
    FutureProvider.family.autoDispose<EscapeCafe, String>((ref, id) async {
  return ref.watch(cafeRepositoryProvider).byId(id);
});
