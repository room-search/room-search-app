import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(enabled: enabled, child: child);
  }
}
