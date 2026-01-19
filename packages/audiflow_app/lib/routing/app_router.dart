import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/search/presentation/screens/search_screen.dart';

/// Application route paths.
///
/// These constants define all route paths used in the application.
class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String podcastDetail = '/podcast';
}

/// Creates the application router configuration.
///
/// This function returns a configured [GoRouter] instance with all
/// application routes defined. The router supports:
/// - Home page (placeholder)
/// - Search page for podcast discovery
///
/// Usage:
/// ```dart
/// final router = createAppRouter();
/// MaterialApp.router(routerConfig: router);
/// ```
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _HomePage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.podcastDetail}/:id',
        builder: (context, state) {
          final podcastId = state.pathParameters['id']!;
          return _PodcastDetailPlaceholder(podcastId: podcastId);
        },
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
      appBar: AppBar(
        title: const Text('Podcast Detail'),
      ),
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

/// Placeholder home page widget.
///
/// This temporary widget serves as the initial route until the proper
/// home screen is implemented. It provides navigation to the search page.
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiflow'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Audiflow',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Your podcast companion'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.search),
              icon: const Icon(Icons.search),
              label: const Text('Search Podcasts'),
            ),
          ],
        ),
      ),
    );
  }
}
