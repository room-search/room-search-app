import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/room_controller.dart';

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
              fromName: notif.fromName,
              themeName: notif.themeName,
              photoUrl: notif.photoUrl,
              onTap: () {
                ref.read(roomControllerProvider.notifier).dismissNotification();
                GoRouter.of(context).push(
                  '/themes/${notif.themeRefId}',
                  extra: notif.photoUrl,
                );
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
    required this.fromName,
    required this.themeName,
    required this.photoUrl,
    required this.onTap,
    required this.onDismiss,
  });

  final String fromName;
  final String themeName;
  final String? photoUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              _Thumbnail(photoUrl: photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$fromName님이 공유',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary
                            .withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      themeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
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
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.casino_rounded,
        color: theme.colorScheme.onPrimary,
      ),
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
