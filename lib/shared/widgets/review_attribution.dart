import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _channelName = '방탈출 하고싶어요';
const _channelUrl = 'https://www.instagram.com/want_escape_/';

/// Attribution line for theme reviews sourced from the Instagram channel.
class ReviewAttribution extends StatefulWidget {
  const ReviewAttribution({super.key, this.compact = false});

  final bool compact;

  @override
  State<ReviewAttribution> createState() => _ReviewAttributionState();
}

class _ReviewAttributionState extends State<ReviewAttribution> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = _open;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final uri = Uri.parse(_channelUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final base = widget.compact
        ? text.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.55),
          )
        : text.labelMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          );
    final link = base?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: scheme.primary.withValues(alpha: 0.6),
    );

    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: widget.compact ? 1 : 2,
      text: TextSpan(
        style: base,
        children: [
          const TextSpan(text: '리뷰 제공: '),
          TextSpan(
            text: _channelName,
            style: link,
            recognizer: _recognizer,
          ),
        ],
      ),
    );
  }
}
