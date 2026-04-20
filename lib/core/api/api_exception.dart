class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.endpoint});

  final String message;
  final int? statusCode;
  final String? endpoint;

  bool get isRateLimited => statusCode == 429;
  bool get isNetwork => statusCode == null;

  @override
  String toString() => 'ApiException($statusCode, $endpoint): $message';
}
