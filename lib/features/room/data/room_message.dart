import 'dart:convert';

import 'room_participant.dart';

enum RoomMessageType {
  hello,
  roster,
  lock,
  share,
  leave,
  unknown;

  static RoomMessageType parse(String raw) {
    for (final t in values) {
      if (t.name == raw) return t;
    }
    return RoomMessageType.unknown;
  }
}

class RoomMessage {
  const RoomMessage({
    required this.type,
    required this.from,
    this.payload = const {},
  });

  final RoomMessageType type;
  final String from;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'from': from,
        'payload': payload,
      };

  String encode() => jsonEncode(toJson());

  factory RoomMessage.fromJson(Map<String, dynamic> json) => RoomMessage(
        type: RoomMessageType.parse(json['type'] as String? ?? ''),
        from: json['from'] as String? ?? '',
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  static RoomMessage decode(String raw) {
    final data = jsonDecode(raw);
    if (data is! Map) {
      return const RoomMessage(type: RoomMessageType.unknown, from: '');
    }
    return RoomMessage.fromJson(data.cast<String, dynamic>());
  }

  factory RoomMessage.hello({required String from, required String name}) =>
      RoomMessage(
        type: RoomMessageType.hello,
        from: from,
        payload: {'name': name},
      );

  factory RoomMessage.roster({
    required String from,
    required List<RoomParticipant> participants,
    required bool locked,
  }) =>
      RoomMessage(
        type: RoomMessageType.roster,
        from: from,
        payload: {
          'participants': participants.map((p) => p.toJson()).toList(),
          'locked': locked,
        },
      );

  factory RoomMessage.lock({required String from}) => RoomMessage(
        type: RoomMessageType.lock,
        from: from,
      );

  factory RoomMessage.share({
    required String from,
    required int themeRefId,
    required String themeName,
    String? photoUrl,
  }) =>
      RoomMessage(
        type: RoomMessageType.share,
        from: from,
        payload: {
          'themeRefId': themeRefId,
          'themeName': themeName,
          'photoUrl': ?photoUrl,
        },
      );

  factory RoomMessage.leave({required String from}) => RoomMessage(
        type: RoomMessageType.leave,
        from: from,
      );

  List<RoomParticipant> rosterParticipants() {
    final list = payload['participants'];
    if (list is! List) return const [];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => RoomParticipant.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  bool get rosterLocked => payload['locked'] == true;
  String get helloName => payload['name'] as String? ?? '';
  int get shareThemeRefId => (payload['themeRefId'] as num?)?.toInt() ?? 0;
  String get shareThemeName => payload['themeName'] as String? ?? '';
  String? get sharePhotoUrl => payload['photoUrl'] as String?;
}
