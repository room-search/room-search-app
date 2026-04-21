/// Deterministic host election: lexicographically smallest id wins.
///
/// Every device participating in discovery runs this with the same inputs
/// (own id + all discovered peer ids) and converges to the same host.
String? electHost(Iterable<String> ids) {
  String? min;
  for (final id in ids) {
    if (id.isEmpty) continue;
    if (min == null || id.compareTo(min) < 0) min = id;
  }
  return min;
}
