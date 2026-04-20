import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FavoriteHeartButton extends StatefulWidget {
  const FavoriteHeartButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 28,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton> {
  Key _pulseKey = UniqueKey();

  void _handle() {
    HapticFeedback.lightImpact();
    setState(() => _pulseKey = UniqueKey());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: _handle,
      iconSize: widget.size,
      icon: Animate(
        key: _pulseKey,
        effects: const [
          ScaleEffect(
            begin: Offset(1, 1),
            end: Offset(1.3, 1.3),
            duration: Duration(milliseconds: 120),
            curve: Curves.easeOut,
          ),
          ScaleEffect(
            begin: Offset(1.3, 1.3),
            end: Offset(1, 1),
            delay: Duration(milliseconds: 120),
            duration: Duration(milliseconds: 180),
            curve: Curves.elasticOut,
          ),
        ],
        child: Icon(
          widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: widget.isFavorite ? scheme.error : scheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
