import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../room/application/room_controller.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int _finderIndex = 2;

  static const _tabs = <_TabSpec>[
    _TabSpec('테마', Icons.casino_outlined, Icons.casino_rounded),
    _TabSpec('카페', Icons.storefront_outlined, Icons.storefront_rounded),
    _TabSpec('딱맞는 찾기', Icons.auto_awesome_outlined, Icons.auto_awesome_rounded),
    _TabSpec('즐겨찾기', Icons.favorite_border_rounded, Icons.favorite_rounded),
  ];

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final roomActive =
        ref.watch(roomControllerProvider.select((s) => s.isActive));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await _confirmExit(context);
        if (confirmed == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: _buildIcon(
                context,
                iconData: _tabs[i].iconOutlined,
                highlighted: i == _finderIndex && roomActive,
                color: theme.colorScheme.primary,
              ),
              selectedIcon: Icon(_tabs[i].iconFilled)
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.15, 1.15),
                    duration: 220.ms,
                    curve: Curves.easeOutBack,
                  ),
              label: _tabs[i].label,
            ),
        ],
      ),
      ),
    );
  }

  Future<bool?> _confirmExit(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('방서치를 종료할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context, {
    required IconData iconData,
    required bool highlighted,
    required Color color,
  }) {
    if (!highlighted) return Icon(iconData);
    return Badge(
      backgroundColor: color,
      smallSize: 8,
      child: Icon(
        // use filled variant to emphasize active state
        Icons.auto_awesome_rounded,
        color: color,
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.iconOutlined, this.iconFilled);
  final String label;
  final IconData iconOutlined;
  final IconData iconFilled;
}
