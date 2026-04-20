import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedThemeImage extends StatelessWidget {
  const CachedThemeImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final fallback = Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: scheme.onSurface.withValues(alpha: 0.3),
          size: 32,
        ),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (_, __) => Container(
          color: scheme.surfaceContainerHighest,
        ),
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}
