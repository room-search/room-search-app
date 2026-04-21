import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/room_controller.dart';
import '../application/room_state.dart';
import 'widgets/participant_tile.dart';

class RoomSearchPage extends ConsumerStatefulWidget {
  const RoomSearchPage({super.key});

  @override
  ConsumerState<RoomSearchPage> createState() => _RoomSearchPageState();
}

class _RoomSearchPageState extends ConsumerState<RoomSearchPage> {
  final TextEditingController _nicknameController =
      TextEditingController(text: '');

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('함께 찾기'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () async {
            if (state.isActive) {
              await ref.read(roomControllerProvider.notifier).cancel();
            }
            if (context.mounted) Navigator.of(context).maybePop();
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RoomState state) {
    switch (state.phase) {
      case RoomPhase.idle:
        return _IdleView(
          key: const ValueKey('idle'),
          nicknameController: _nicknameController,
          onStart: () {
            ref.read(roomControllerProvider.notifier).startSearch(
                  nickname: _nicknameController.text,
                );
          },
        );
      case RoomPhase.searching:
        return _ActiveView(
          key: const ValueKey('searching'),
          state: state,
          onCancel: ref.read(roomControllerProvider.notifier).cancel,
          onLock: ref.read(roomControllerProvider.notifier).lockRoom,
        );
      case RoomPhase.locked:
        return _ActiveView(
          key: const ValueKey('locked'),
          state: state,
          onCancel: ref.read(roomControllerProvider.notifier).cancel,
          onLock: null,
        );
      case RoomPhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          message: state.errorMessage ?? '오류가 발생했어요.',
          onRetry: ref.read(roomControllerProvider.notifier).cancel,
        );
    }
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({
    super.key,
    required this.nicknameController,
    required this.onStart,
  });

  final TextEditingController nicknameController;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '같은 Wi-Fi 친구와\n테마를 함께 골라요',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '탐색을 시작하면 주변에서 같이 탐색 중인 다른 기기가\n자동으로 매칭돼요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Text('내 이름', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: nicknameController,
            textInputAction: TextInputAction.done,
            maxLength: 16,
            decoration: InputDecoration(
              hintText: '친구들에게 표시될 이름',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
            onSubmitted: (_) => onStart(),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.radar_rounded),
            label: const Text('탐색 시작'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({
    super.key,
    required this.state,
    required this.onCancel,
    required this.onLock,
  });

  final RoomState state;
  final Future<void> Function() onCancel;
  final Future<void> Function()? onLock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching = state.phase == RoomPhase.searching;
    final locked = state.phase == RoomPhase.locked;
    final host = state.hostParticipant;
    final participants = state.participants;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusHeader(
            searching: searching,
            locked: locked,
            isHost: state.isHost,
            hostName: host?.name,
            count: participants.length,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: participants.isEmpty
                ? const _WaitingBlock()
                : ListView.separated(
                    itemCount: participants.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = participants[i];
                      return ParticipantTile(
                        participant: p,
                        isSelf: p.id == state.selfId,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          if (searching && state.isHost)
            FilledButton.icon(
              onPressed:
                  state.canLock ? () => onLock?.call() : null,
              icon: const Icon(Icons.lock_rounded),
              label: Text(
                state.canLock
                    ? '인원 확정하고 방 열기'
                    : '다른 친구를 기다리는 중...',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          if (searching && !state.isHost)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      host != null
                          ? '${host.name}님이 확정할 때까지 기다려주세요'
                          : '호스트가 확정할 때까지 기다려주세요',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (locked)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '방이 열렸어요. 테마 상세 화면에서 "방에 공유"로 전달할 수 있어요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => onCancel(),
            icon: const Icon(Icons.logout_rounded),
            label: Text(locked ? '방 나가기' : '탐색 취소'),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.searching,
    required this.locked,
    required this.isHost,
    required this.hostName,
    required this.count,
  });

  final bool searching;
  final bool locked;
  final bool isHost;
  final String? hostName;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = locked
        ? '방이 열렸어요'
        : (count > 1 ? '친구를 찾았어요' : '탐색 중...');
    final subtitle = locked
        ? '$count명이 함께 있어요'
        : (count > 1
            ? (isHost ? '내가 호스트예요' : '호스트: ${hostName ?? '...'}')
            : '같은 Wi-Fi에서 탐색 중인 친구를 기다리는 중');

    final pulse = searching && count <= 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: locked
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.tertiaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            locked
                ? Icons.check_rounded
                : (count > 1 ? Icons.group_rounded : Icons.radar_rounded),
            color: locked
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onTertiaryContainer,
          ),
        )
            .animate(
              target: pulse ? 1 : 0,
              onPlay: (c) => c.repeat(reverse: true),
            )
            .scaleXY(end: 1.08, duration: 900.ms, curve: Curves.easeInOut),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaitingBlock extends StatelessWidget {
  const _WaitingBlock();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_tethering_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 700.ms)
              .then()
              .fadeOut(duration: 700.ms),
          const SizedBox(height: 12),
          Text(
            '친구가 탐색을 시작하면 여기에 나타나요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 56, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => onRetry(),
            child: const Text('처음으로'),
          ),
        ],
      ),
    );
  }
}
