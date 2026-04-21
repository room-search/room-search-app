class RoomParticipant {
  const RoomParticipant({
    required this.id,
    required this.name,
    required this.isHost,
  });

  final String id;
  final String name;
  final bool isHost;

  RoomParticipant copyWith({String? id, String? name, bool? isHost}) =>
      RoomParticipant(
        id: id ?? this.id,
        name: name ?? this.name,
        isHost: isHost ?? this.isHost,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isHost': isHost,
      };

  factory RoomParticipant.fromJson(Map<String, dynamic> json) =>
      RoomParticipant(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isHost: json['isHost'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomParticipant &&
          other.id == id &&
          other.name == name &&
          other.isHost == isHost;

  @override
  int get hashCode => Object.hash(id, name, isHost);
}
