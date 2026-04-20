import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/theme.dart';
import '../data/theme_repository.dart';

final themeDetailProvider =
    FutureProvider.family.autoDispose<EscapeTheme, int>((ref, refId) async {
  final repo = ref.watch(themeRepositoryProvider);
  return repo.byId(refId);
});
