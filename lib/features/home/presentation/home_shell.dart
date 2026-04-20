import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: Icon(_tabs[i].iconOutlined),
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
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.iconOutlined, this.iconFilled);
  final String label;
  final IconData iconOutlined;
  final IconData iconFilled;
}
