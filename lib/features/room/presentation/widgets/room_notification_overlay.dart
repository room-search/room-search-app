import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/room_controller.dart';
import '../../application/room_state.dart';

class RoomNotificationOverlay extends ConsumerWidget {
  const RoomNotificationOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(
      roomControllerProvider.select((s) => s.currentNotification),
    );
    final media = MediaQuery.of(context);
    final topInset = media.padding.top + 8;

    return Stack(
      children: [
        child,
        if (notif != null)
          Positioned(
            top: topInset,
            left: 12,
            right: 12,
            child: _RoomBanner(
              key: ValueKey(notif.id),
              notification: notif,
              onTap: () {
                final router = GoRouter.of(context);
                ref
                    .read(roomControllerProvider.notifier)
                    .dismissNotification();
                if (notif.kind == RoomBannerKind.share &&
                    notif.themeRefId > 0) {
                  router.push(
                    '/themes/${notif.themeRefId}',
                    extra: notif.photoUrl,
                  );
                }
              },
              onDismiss: () => ref
                  .read(roomControllerProvider.notifier)
                  .dismissNotification(),
            ),
          ),
      ],
    );
  }
}

class _RoomBanner extends StatelessWidget {
  const _RoomBanner({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final RoomShareNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLeave = notification.kind == RoomBannerKind.leave;
    final bg = isLeave
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.primary;
    final fg = isLeave
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              _Leading(notification: notification, fg: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _titleText(notification),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: fg.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _bodyText(notification),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close_rounded, color: fg),
                tooltip: '닫기',
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: -0.4,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 220.ms);
  }

  String _titleText(RoomShareNotification n) {
    switch (n.kind) {
      case RoomBannerKind.share:
        return '${n.fromName}님이 공유';
      case RoomBannerKind.leave:
        return '방 알림';
    }
  }

  String _bodyText(RoomShareNotification n) {
    switch (n.kind) {
      case RoomBannerKind.share:
        return n.themeName;
      case RoomBannerKind.leave:
        return '${n.fromName}님이 방에서 나갔어요';
    }
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.notification, required this.fg});

  final RoomShareNotification notification;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    if (notification.kind == RoomBannerKind.leave) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.logout_rounded, color: fg),
      );
    }
    return _Thumbnail(photoUrl: notification.photoUrl, fg: fg);
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photoUrl, required this.fg});

  final String? photoUrl;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.casino_rounded, color: fg),
    );
    final url = photoUrl;
    if (url == null || url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
