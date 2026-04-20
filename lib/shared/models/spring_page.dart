class SpringPage<T> {
  const SpringPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
    required this.empty,
  });

  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;
  final bool first;
  final bool last;
  final bool empty;

  factory SpringPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFrom,
  ) {
    final raw = (json['content'] as List<dynamic>? ?? const <dynamic>[]);
    return SpringPage<T>(
      content: raw
          .whereType<Map<String, dynamic>>()
          .map(itemFrom)
          .toList(growable: false),
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? raw.isEmpty,
    );
  }

  static SpringPage<T> empty$<T>() => SpringPage<T>(
        content: const [],
        totalPages: 0,
        totalElements: 0,
        number: 0,
        size: 0,
        first: true,
        last: true,
        empty: true,
      );
}
