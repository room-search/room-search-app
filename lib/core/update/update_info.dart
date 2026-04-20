class UpdateInfo {
  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.apkUrl,
    required this.releaseNotes,
    required this.releaseUrl,
  });

  final String latestVersion;
  final String currentVersion;
  final String apkUrl;
  final String releaseNotes;
  final String releaseUrl;

  bool get hasUpdate => _isNewer(latestVersion, currentVersion);

  static bool _isNewer(String latest, String current) {
    final a = _parse(latest);
    final b = _parse(current);
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av > bv) return true;
      if (av < bv) return false;
    }
    return false;
  }

  static List<int> _parse(String v) {
    final cleaned = v.replaceAll(RegExp(r'^v'), '').split('+').first;
    return cleaned
        .split('.')
        .map((p) => int.tryParse(RegExp(r'\d+').firstMatch(p)?.group(0) ?? '') ?? 0)
        .toList();
  }
}
