import '../../../theme/data/models/theme.dart';

class EscapeCafe {
  const EscapeCafe({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    required this.location,
    required this.lat,
    required this.lng,
    required this.homepage,
    required this.phoneNo,
    required this.isOpen,
    required this.createDate,
    required this.themes,
  });

  final String id;
  final String name;
  final String address;
  final String area;
  final String location;
  final double lat;
  final double lng;
  final String homepage;
  final String phoneNo;
  final bool isOpen;
  final String createDate;
  final List<EscapeTheme> themes;

  factory EscapeCafe.fromJson(Map<String, dynamic> json) {
    final rawThemes = json['themes'] as List<dynamic>? ?? const <dynamic>[];
    return EscapeCafe(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      area: json['area'] as String? ?? '',
      location: json['location'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      homepage: json['homepage'] as String? ?? '',
      phoneNo: json['phoneNo'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      createDate: json['createDate'] as String? ?? '',
      themes: rawThemes
          .whereType<Map<String, dynamic>>()
          .map(EscapeTheme.fromJson)
          .toList(growable: false),
    );
  }
}
