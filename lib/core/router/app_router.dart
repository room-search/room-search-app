import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cafe/presentation/cafe_detail_page.dart';
import '../../features/cafe/presentation/cafe_map_page.dart';
import '../../features/cafe/presentation/cafe_search_page.dart';
import '../../features/favorites/presentation/favorites_page.dart';
import '../../features/finder/presentation/dashboard/finder_dashboard_page.dart';
import '../../features/finder/presentation/finder_intro_page.dart';
import '../../features/finder/presentation/results/finder_results_page.dart';
import '../../features/finder/presentation/wizard/wizard_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/room/presentation/room_search_page.dart';
import '../../features/theme/presentation/theme_detail_page.dart';
import '../../features/theme/presentation/theme_search_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/themes',
    redirect: (context, state) {
      final qp = state.uri.queryParameters;
      final target = qp['target'];
      final id = qp['id'];
      if (target != null && id != null && id.isNotEmpty) {
        if (target == 'theme') return '/themes/$id';
        if (target == 'cafe') return '/cafes/$id';
      }
      final path = state.uri.path;
      if (path.isEmpty || path == '/') return '/themes';
      return null;
    },
    routes: [
      GoRoute(
        path: '/map',
        name: 'map',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const CafeMapPage(),
      ),
      GoRoute(
        path: '/cafe-detail/:id',
        name: 'cafe-detail-root',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) =>
            CafeDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/themes',
                name: 'themes',
                builder: (ctx, state) => const ThemeSearchPage(),
                routes: [
                  GoRoute(
                    path: ':refId',
                    name: 'theme-detail',
                    builder: (ctx, state) {
                      final refId =
                          int.tryParse(state.pathParameters['refId'] ?? '') ?? 0;
                      final photoUrl =
                          state.extra is String ? state.extra as String : null;
                      return ThemeDetailPage(
                          refId: refId, heroPhotoUrl: photoUrl);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cafes',
                name: 'cafes',
                builder: (ctx, state) => const CafeSearchPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'cafe-detail',
                    builder: (ctx, state) =>
                        CafeDetailPage(id: state.pathParameters['id'] ?? ''),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finder',
                name: 'finder',
                builder: (ctx, state) => const FinderIntroPage(),
                routes: [
                  GoRoute(
                    path: 'wizard',
                    name: 'finder-wizard',
                    builder: (ctx, state) => const WizardPage(),
                  ),
                  GoRoute(
                    path: 'dashboard',
                    name: 'finder-dashboard',
                    builder: (ctx, state) => const FinderDashboardPage(),
                  ),
                  GoRoute(
                    path: 'results',
                    name: 'finder-results',
                    builder: (ctx, state) => const FinderResultsPage(),
                  ),
                  GoRoute(
                    path: 'room',
                    name: 'finder-room',
                    builder: (ctx, state) => const RoomSearchPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (ctx, state) => const FavoritesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
