class CafeLocation {
  const CafeLocation({required this.area, required this.location});

  final String area;
  final String location;

  factory CafeLocation.fromJson(Map<String, dynamic> json) => CafeLocation(
        area: json['area'] as String? ?? '',
        location: json['location'] as String? ?? '',
      );
}
