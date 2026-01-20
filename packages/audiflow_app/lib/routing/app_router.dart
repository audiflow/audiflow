import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/library/presentation/screens/library_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'scaffold_with_nav_bar.dart';

/// Application route paths.
///
/// These constants define all route paths used in the application.
class AppRoutes {
  static const String search = '/search';
  static const String library = '/library';
  static const String settings = '/settings';
  static const String podcastDetail = '/podcast';
}

/// Navigator keys for each tab branch.
///
/// Each tab has its own navigator to maintain independent navigation stacks.
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _libraryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Creates the application router configuration.
///
/// This function returns a configured [GoRouter] instance with all
/// application routes defined. The router uses [StatefulShellRoute.indexedStack]
/// to provide tab-based navigation with preserved state per tab.
///
/// Route structure:
/// - `/search` (default tab)
///   - `/search/podcast/:id`
/// - `/library`
/// - `/settings`
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.search,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'podcast/:id',
                    builder: (context, state) {
                      final podcastId = state.pathParameters['id']!;
                      return _PodcastDetailPlaceholder(podcastId: podcastId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _libraryNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Placeholder podcast detail page widget.
///
/// This temporary widget serves as the podcast detail route until the proper
/// podcast detail screen is implemented.
class _PodcastDetailPlaceholder extends StatelessWidget {
  const _PodcastDetailPlaceholder({required this.podcastId});

  final String podcastId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Detail')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.podcasts, size: 64),
            const SizedBox(height: 16),
            Text(
              'Podcast ID: $podcastId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Podcast detail page coming soon'),
          ],
        ),
      ),
    );
  }
}
