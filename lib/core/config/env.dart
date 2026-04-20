class Env {
  const Env._();

  static const String apiBaseUrl = 'https://apisis.dev';
  static const String apisisKey = 'O4Um8YwKLCFFtzERO31QytFlRLtp0fXbZj-kGvKX7xs';
  static const String naverMapNcpKeyId = 'u3umk5nw8r';

  static const Duration apiConnectTimeout = Duration(seconds: 10);
  static const Duration apiReceiveTimeout = Duration(seconds: 20);
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const Duration sessionCacheTtl = Duration(minutes: 5);
}
