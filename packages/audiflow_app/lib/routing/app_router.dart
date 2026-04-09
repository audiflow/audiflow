import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../l10n/app_localizations.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/library/presentation/screens/subscriptions_list_screen.dart';
import '../features/podcast_detail/presentation/screens/episode_detail_screen.dart';
import '../features/station/presentation/screens/station_detail_screen.dart';
import '../features/station/presentation/screens/station_edit_screen.dart';
import '../features/podcast_detail/presentation/screens/podcast_detail_screen.dart';
import '../features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart';
import '../features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart';
import '../features/queue/presentation/screens/queue_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/appearance_settings_screen.dart';
import '../features/download/presentation/screens/download_management_screen.dart';
import '../features/player/presentation/screens/transcript_screen.dart';
import '../features/share/presentation/screens/deep_link_screen.dart';
import '../features/settings/presentation/screens/downloads_settings_screen.dart';
import '../features/settings/presentation/screens/feed_sync_settings_screen.dart';
import '../features/settings/presentation/screens/playback_settings_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/storage_settings_screen.dart';
import '../features/settings/presentation/screens/developer_settings_screen.dart';
import '../features/settings/presentation/screens/voice_settings_screen.dart';
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
  static const String smartPlaylistGroupEpisodesPath = 'group/:groupId';
  static const String smartPlaylistDirectGroup =
      'smart-playlist/:playlistId/group/:groupId';
  static const String subscriptions = '/library/subscriptions';
  static const String stationNew = '/library/station/new';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsPlayback = '/settings/playback';
  static const String settingsDownloads = '/settings/downloads';
  static const String settingsFeedSync = '/settings/feed-sync';
  static const String settingsStorage = '/settings/storage';
  static const String settingsAbout = '/settings/about';
  static const String settingsVoice = '/settings/voice';
  static const String settingsDeveloper = '/settings/developer';
  static const String settingsDownloadManagement =
      '/settings/downloads/management';
  static const String transcript = '/transcript';
  static const String deepLinkPodcast = '/p/:itunesId';
  static const String deepLinkEpisode = '/p/:itunesId/e/:encodedGuid';
  static const String notificationEpisode =
      '/notification/episode/:podcastId/:episodeId';
}

/// Root navigator key for the application.
///
/// Used by components outside the router tree (e.g.
/// [OpmlFileReceiver]) that need to push full-screen routes.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
GoRouter createAppRouter({int lastTabIndex = 0}) {
  final initialLocation = switch (lastTabIndex) {
    1 => AppRoutes.library,
    2 => AppRoutes.queue,
    _ => AppRoutes.search,
  };

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    // File URIs from the share sheet (e.g. file:///...opml)
    // are handled by OpmlFileReceiverController via app_links,
    // not by the router. Redirect to home on unknown routes.
    onException: (_, _, router) => router.go(AppRoutes.search),
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
                        routes: [
                          GoRoute(
                            path: AppRoutes.smartPlaylistGroupEpisodesPath,
                            builder: (context, state) =>
                                _buildGroupEpisodesScreen(state),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: AppRoutes.smartPlaylistDirectGroup,
                        builder: (context, state) =>
                            _buildGroupEpisodesScreen(state),
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
                        routes: [
                          GoRoute(
                            path: AppRoutes.smartPlaylistGroupEpisodesPath,
                            builder: (context, state) =>
                                _buildGroupEpisodesScreen(state),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: AppRoutes.smartPlaylistDirectGroup,
                        builder: (context, state) =>
                            _buildGroupEpisodesScreen(state),
                      ),
                      GoRoute(
                        path: AppRoutes.episodeDetail,
                        builder: (context, state) =>
                            _buildEpisodeDetailScreen(state),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'station/new',
                    builder: (context, state) => const StationEditScreen(),
                  ),
                  GoRoute(
                    path: 'station/:stationId',
                    builder: (context, state) =>
                        _buildStationDetailScreen(state),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) =>
                            _buildStationEditScreen(state),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'subscriptions',
                    builder: (context, state) =>
                        const SubscriptionsListScreen(),
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
                            routes: [
                              GoRoute(
                                path: AppRoutes.smartPlaylistGroupEpisodesPath,
                                builder: (context, state) =>
                                    _buildGroupEpisodesScreen(state),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: AppRoutes.smartPlaylistDirectGroup,
                            builder: (context, state) =>
                                _buildGroupEpisodesScreen(state),
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
                routes: [
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) =>
                        const AppearanceSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'playback',
                    builder: (context, state) => const PlaybackSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'downloads',
                    builder: (context, state) =>
                        const DownloadsSettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'management',
                        builder: (context, state) =>
                            const DownloadManagementScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'feed-sync',
                    builder: (context, state) => const FeedSyncSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'storage',
                    builder: (context, state) => const StorageSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                  GoRoute(
                    path: 'voice',
                    builder: (context, state) => const VoiceSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'developer',
                    builder: (context, state) =>
                        const DeveloperSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.transcript,
        builder: (context, state) => _buildTranscriptScreen(state),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.deepLinkPodcast,
        builder: (context, state) {
          return DeepLinkScreen(uri: state.uri);
        },
        routes: [
          GoRoute(
            path: 'e/:encodedGuid',
            builder: (context, state) {
              return DeepLinkScreen(uri: state.uri);
            },
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.notificationEpisode,
        builder: (context, state) => _NotificationEpisodeScreen(
          podcastId: int.tryParse(state.pathParameters['podcastId'] ?? '') ?? 0,
          episodeId: int.tryParse(state.pathParameters['episodeId'] ?? '') ?? 0,
        ),
      ),
    ],
  );
}

/// Builds the podcast detail screen from route state.
///
/// When [extra] contains a [Podcast], uses it directly. Otherwise falls back
/// to an iTunes ID lookup from the `:id` path parameter (supports
/// notification taps and deep links where extra is unavailable).
Widget _buildPodcastDetailScreen(GoRouterState state) {
  final extra = state.extra;
  final podcast = extra is Podcast
      ? extra
      : extra is Map<String, dynamic>
      ? extra['podcast'] as Podcast?
      : null;
  if (podcast != null) {
    return PodcastDetailScreen(podcast: podcast);
  }

  // Fallback: resolve from iTunes ID in path parameter.
  final itunesId = state.pathParameters['id'] ?? '';
  if (itunesId.isEmpty) {
    return const _PodcastNotFoundScreen();
  }
  return _PodcastDetailFromSubscription(itunesId: itunesId);
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
  final feedImageUrl = extra['feedImageUrl'] as String?;
  final lastRefreshedAt = extra['lastRefreshedAt'] as DateTime?;

  final podcast = extra['podcast'] as Podcast?;
  if (podcast == null) {
    return const _SmartPlaylistNotFoundScreen();
  }

  return SmartPlaylistEpisodesScreen(
    podcast: podcast,
    smartPlaylist: playlist,
    podcastTitle: podcastTitle,
    podcastArtworkUrl: podcastArtworkUrl,
    feedImageUrl: feedImageUrl,
    lastRefreshedAt: lastRefreshedAt,
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
  final itunesId = extra['itunesId'] as String?;

  return EpisodeDetailScreen(
    episode: episode,
    podcastTitle: podcastTitle,
    artworkUrl: artworkUrl,
    progress: progress,
    itunesId: itunesId,
  );
}

/// Builds the group episodes screen from route state.
Widget _buildGroupEpisodesScreen(GoRouterState state) {
  final extra = state.extra as Map<String, dynamic>?;
  if (extra == null) {
    return const _SmartPlaylistNotFoundScreen();
  }

  final group = extra['group'] as SmartPlaylistGroup?;
  final parentPlaylist = extra['smartPlaylist'] as SmartPlaylist?;
  if (group == null || parentPlaylist == null) {
    return const _SmartPlaylistNotFoundScreen();
  }

  return SmartPlaylistGroupEpisodesScreen(
    group: group,
    parentPlaylist: parentPlaylist,
    podcastTitle: extra['podcastTitle'] as String? ?? '',
    podcastArtworkUrl: extra['podcastArtworkUrl'] as String?,
    feedImageUrl: extra['feedImageUrl'] as String?,
    lastRefreshedAt: extra['lastRefreshedAt'] as DateTime?,
    filteredEpisodeIds: extra['filteredEpisodeIds'] as List<int>?,
    itunesId: extra['itunesId'] as String?,
    feedUrl: extra['feedUrl'] as String?,
  );
}

/// Builds the transcript screen from route state.
Widget _buildTranscriptScreen(GoRouterState state) {
  final extra = state.extra as Map<String, dynamic>?;
  if (extra == null) {
    return const _PodcastNotFoundScreen();
  }

  final transcriptId = extra['transcriptId'] as int?;
  final episodeId = extra['episodeId'] as int?;
  final episodeTitle = extra['episodeTitle'] as String? ?? '';

  if (transcriptId == null || episodeId == null) {
    return const _PodcastNotFoundScreen();
  }

  return TranscriptScreen(
    transcriptId: transcriptId,
    episodeId: episodeId,
    episodeTitle: episodeTitle,
  );
}

/// Builds the station detail screen from route state.
Widget _buildStationDetailScreen(GoRouterState state) {
  final stationId = int.tryParse(state.pathParameters['stationId'] ?? '');
  if (stationId == null) {
    return const _StationNotFoundScreen();
  }
  return StationDetailScreen(stationId: stationId);
}

/// Builds the station edit screen from route state.
Widget _buildStationEditScreen(GoRouterState state) {
  final stationId = int.tryParse(state.pathParameters['stationId'] ?? '');
  if (stationId == null) {
    return const _StationNotFoundScreen();
  }
  return StationEditScreen(stationId: stationId);
}

/// Fallback screen shown when station data is not available.
class _StationNotFoundScreen extends StatelessWidget {
  const _StationNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stationNotFoundTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.stationNotFoundMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.commonGoBack),
            ),
          ],
        ),
      ),
    );
  }
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
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).commonGoBack),
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
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).commonGoBack),
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
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).commonGoBack),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves a podcast detail screen from an iTunes ID via DB lookup.
///
/// Used when navigating without [extra] data (notification taps, deep links).
class _PodcastDetailFromSubscription extends ConsumerWidget {
  const _PodcastDetailFromSubscription({required this.itunesId});

  final String itunesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSub = ref.watch(subscriptionByItunesIdProvider(itunesId));

    return asyncSub.when(
      data: (subscription) {
        if (subscription == null) return const _PodcastNotFoundScreen();
        return PodcastDetailScreen(podcast: subscription.toPodcast());
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const _PodcastNotFoundScreen(),
    );
  }
}

/// Resolves notification tap to the episode detail screen.
///
/// Looks up [Episode] and [Subscription] from Isar by ID, converts
/// to [PodcastItem], and renders [EpisodeDetailScreen]. Falls back
/// to library if either lookup fails.
class _NotificationEpisodeScreen extends ConsumerStatefulWidget {
  const _NotificationEpisodeScreen({
    required this.podcastId,
    required this.episodeId,
  });

  final int podcastId;
  final int episodeId;

  @override
  ConsumerState<_NotificationEpisodeScreen> createState() =>
      _NotificationEpisodeScreenState();
}

class _NotificationEpisodeScreenState
    extends ConsumerState<_NotificationEpisodeScreen> {
  final _logger = Logger(printer: PrefixPrinter(PrettyPrinter(methodCount: 0)));

  @override
  void initState() {
    super.initState();
    _logger.i(
      '[NotifResolve] initState: '
      'podcastId=${widget.podcastId}, episodeId=${widget.episodeId}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    _logger.i('[NotifResolve] _resolve() started');
    final episodeRepo = ref.read(episodeRepositoryProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    final episode = await episodeRepo.getById(widget.episodeId);
    _logger.i(
      '[NotifResolve] episodeRepo.getById(${widget.episodeId}) -> '
      '${episode == null ? "null" : "found (podcastId=${episode.podcastId}, guid=${episode.guid})"}',
    );
    if (episode == null || episode.podcastId != widget.podcastId || !mounted) {
      _logger.w(
        '[NotifResolve] episode lookup failed or podcastId mismatch '
        '(expected=${widget.podcastId}, '
        'actual=${episode?.podcastId}, mounted=$mounted). '
        'Falling back to library.',
      );
      if (mounted) context.go(AppRoutes.library);
      return;
    }

    final subscription = await subscriptionRepo.getById(widget.podcastId);
    _logger.i(
      '[NotifResolve] subscriptionRepo.getById(${widget.podcastId}) -> '
      '${subscription == null ? "null" : "found (itunesId=${subscription.itunesId}, title=${subscription.title})"}',
    );
    if (subscription == null || !mounted) {
      _logger.w(
        '[NotifResolve] subscription lookup failed (mounted=$mounted). '
        'Falling back to library.',
      );
      if (mounted) context.go(AppRoutes.library);
      return;
    }

    if (!mounted) return;

    // Capture all navigation data before router.go() disposes this widget.
    final router = GoRouter.of(context);
    final episodePath =
        '${AppRoutes.library}/podcast/${subscription.itunesId}/${AppRoutes.episodeDetail}'
            .replaceAll(':episodeGuid', Uri.encodeComponent(episode.guid));
    final episodeExtra = <String, dynamic>{
      'episode': episode.toPodcastItem(feedUrl: subscription.feedUrl),
      'podcastTitle': subscription.title,
      'artworkUrl': subscription.artworkUrl,
      'itunesId': subscription.itunesId,
    };

    _logger.i('[NotifResolve] navigating to: $episodePath');

    // Single atomic navigation via go(). GoRouter builds the full route
    // stack (library -> podcast detail -> episode detail) in one pass.
    // The intermediate podcast detail screen resolves via the :id path
    // parameter when extra is null (see _buildPodcastDetailScreen).
    router.go(episodePath, extra: episodeExtra);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
