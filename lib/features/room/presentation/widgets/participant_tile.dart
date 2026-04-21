import 'package:flutter/material.dart';

import '../../data/room_participant.dart';

class ParticipantTile extends StatelessWidget {
  const ParticipantTile({
    super.key,
    required this.participant,
    required this.isSelf,
  });

  final RoomParticipant participant;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = participant.isHost
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final fg = participant.isHost
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: fg.withValues(alpha: 0.2),
            child: Icon(
              participant.isHost
                  ? Icons.workspace_premium_rounded
                  : Icons.person_rounded,
              color: fg,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  participant.isHost
                      ? (isSelf ? '내가 호스트예요' : '호스트')
                      : (isSelf ? '나' : '참여자'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: fg.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (participant.isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'HOST',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
