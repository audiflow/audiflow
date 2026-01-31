import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/library/presentation/screens/library_screen.dart';
import '../features/podcast_detail/presentation/screens/episode_detail_screen.dart';
import '../features/podcast_detail/presentation/screens/podcast_detail_screen.dart';
import '../features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart';
import '../features/queue/presentation/screens/queue_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'scaffold_with_nav_bar.dart';

/// Application route paths.
///
/// These constants define all route paths used in the application.
class AppRoutes {
  static const String search = '/search';
  static const String library = '/library';
  static const String queue = '/queue';
  static const String settings = '/settings';
  static const String podcastDetail = '/search/podcast';
  static const String smartPlaylistEpisodes = 'smart-playlist/:playlistId';
  static const String episodeDetail = 'episode/:episodeGuid';
}

/// Navigator keys for each tab branch.
///
/// Each tab has its own navigator to maintain
/// independent navigation stacks.
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _libraryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _queueNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'queue');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Creates the application router configuration.
///
/// This function returns a configured [GoRouter] instance
/// with all application routes defined. The router uses
/// [StatefulShellRoute.indexedStack] to provide tab-based
/// navigation with preserved state per tab.
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
                    builder: (context, state) =>
                        _buildPodcastDetailScreen(state),
                    routes: [
                      GoRoute(
                        path: AppRoutes.smartPlaylistEpisodes,
                        builder: (context, state) =>
                            _buildSmartPlaylistEpisodesScreen(state),
                      ),
                      GoRoute(
                        path: AppRoutes.episodeDetail,
                        builder: (context, state) =>
                            _buildEpisodeDetailScreen(state),
                      ),
                    ],
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
                routes: [
                  GoRoute(
                    path: 'podcast/:id',
                    builder: (context, state) =>
                        _buildPodcastDetailScreen(state),
                    routes: [
                      GoRoute(
                        path: AppRoutes.smartPlaylistEpisodes,
                        builder: (context, state) =>
                            _buildSmartPlaylistEpisodesScreen(state),
                      ),
                      GoRoute(
                        path: AppRoutes.episodeDetail,
                        builder: (context, state) =>
                            _buildEpisodeDetailScreen(state),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _queueNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.queue,
                builder: (context, state) => const QueueScreen(),
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

/// Builds the podcast detail screen from route state.
///
/// Returns [_PodcastNotFoundScreen] if podcast data
/// is not available.
Widget _buildPodcastDetailScreen(GoRouterState state) {
  final podcast = state.extra as Podcast?;
  if (podcast == null) {
    return const _PodcastNotFoundScreen();
  }
  return PodcastDetailScreen(podcast: podcast);
}

/// Builds the smart playlist episodes screen from
/// route state.
///
/// Returns [_SmartPlaylistNotFoundScreen] if playlist
/// data is not available.
Widget _buildSmartPlaylistEpisodesScreen(GoRouterState state) {
  final extra = state.extra as Map<String, dynamic>?;
  if (extra == null) {
    return const _SmartPlaylistNotFoundScreen();
  }

  final playlist = extra['smartPlaylist'] as SmartPlaylist?;
  if (playlist == null) {
    return const _SmartPlaylistNotFoundScreen();
  }

  final podcastTitle = extra['podcastTitle'] as String? ?? '';
  final podcastArtworkUrl = extra['podcastArtworkUrl'] as String?;

  return SmartPlaylistEpisodesScreen(
    smartPlaylist: playlist,
    podcastTitle: podcastTitle,
    podcastArtworkUrl: podcastArtworkUrl,
  );
}

/// Builds the episode detail screen from route state.
///
/// Returns [_EpisodeNotFoundScreen] if episode data
/// is not available.
Widget _buildEpisodeDetailScreen(GoRouterState state) {
  final extra = state.extra as Map<String, dynamic>?;
  if (extra == null) {
    return const _EpisodeNotFoundScreen();
  }

  final episode = extra['episode'] as PodcastItem?;
  if (episode == null) {
    return const _EpisodeNotFoundScreen();
  }

  final podcastTitle = extra['podcastTitle'] as String? ?? '';
  final artworkUrl = extra['artworkUrl'] as String?;
  final progress = extra['progress'] as EpisodeWithProgress?;

  return EpisodeDetailScreen(
    episode: episode,
    podcastTitle: podcastTitle,
    artworkUrl: artworkUrl,
    progress: progress,
  );
}

/// Fallback screen shown when podcast data is not available.
class _PodcastNotFoundScreen extends StatelessWidget {
  const _PodcastNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Podcast data not available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback screen shown when smart playlist data
/// is not available.
class _SmartPlaylistNotFoundScreen extends StatelessWidget {
  const _SmartPlaylistNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Playlist data not available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback screen shown when episode data is not
/// available.
class _EpisodeNotFoundScreen extends StatelessWidget {
  const _EpisodeNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Episode Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Episode data not available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
