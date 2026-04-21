import '../data/room_participant.dart';

enum RoomPhase { idle, searching, locked, error }

class RoomShareNotification {
  const RoomShareNotification({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.themeRefId,
    required this.themeName,
    this.photoUrl,
    required this.receivedAt,
  });

  final String id;
  final String fromId;
  final String fromName;
  final int themeRefId;
  final String themeName;
  final String? photoUrl;
  final DateTime receivedAt;
}

class RoomState {
  const RoomState({
    this.phase = RoomPhase.idle,
    this.selfId = '',
    this.selfName = '',
    this.participants = const [],
    this.hostId,
    this.errorMessage,
    this.currentNotification,
  });

  final RoomPhase phase;
  final String selfId;
  final String selfName;
  final List<RoomParticipant> participants;
  final String? hostId;
  final String? errorMessage;
  final RoomShareNotification? currentNotification;

  bool get isHost => hostId != null && hostId == selfId;
  bool get isActive =>
      phase == RoomPhase.searching || phase == RoomPhase.locked;
  bool get canShare =>
      phase == RoomPhase.locked && participants.length > 1;
  bool get canLock =>
      phase == RoomPhase.searching && isHost && participants.length > 1;

  RoomParticipant? get hostParticipant {
    final id = hostId;
    if (id == null) return null;
    for (final p in participants) {
      if (p.id == id) return p;
    }
    return null;
  }

  RoomState copyWith({
    RoomPhase? phase,
    String? selfId,
    String? selfName,
    List<RoomParticipant>? participants,
    String? hostId,
    bool clearHostId = false,
    String? errorMessage,
    bool clearError = false,
    RoomShareNotification? currentNotification,
    bool clearNotification = false,
  }) {
    return RoomState(
      phase: phase ?? this.phase,
      selfId: selfId ?? this.selfId,
      selfName: selfName ?? this.selfName,
      participants: participants ?? this.participants,
      hostId: clearHostId ? null : (hostId ?? this.hostId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentNotification: clearNotification
          ? null
          : (currentNotification ?? this.currentNotification),
    );
  }
}
