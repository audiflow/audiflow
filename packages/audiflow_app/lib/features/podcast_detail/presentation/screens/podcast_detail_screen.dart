import 'package:audiflow_domain/audiflow_domain.dart'
    show
        EpisodeFilter,
        PodcastViewMode,
        SmartPlaylist,
        SmartPlaylistGroup,
        SortOrder,
        podcastViewPreferenceControllerProvider,
        subscriptionByFeedUrlProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/podcast_detail_controller.dart';
import '../widgets/episode_filter_chips.dart';
import '../widgets/episode_list_section.dart';
import '../widgets/inline_playlist_section.dart';
import '../widgets/podcast_detail_empty_states.dart';
import '../widgets/podcast_detail_header.dart';
import '../widgets/smart_playlist_view_toggle.dart';

/// Displays podcast details and episode list with
/// playback controls.
class PodcastDetailScreen extends ConsumerStatefulWidget {
  const PodcastDetailScreen({super.key, required this.podcast});

  final Podcast podcast;

  @override
  ConsumerState<PodcastDetailScreen> createState() =>
      _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends ConsumerState<PodcastDetailScreen> {
  final _scrollController = ScrollController();

  String _searchQuery = '';

  /// Local view mode for non-subscribed podcasts.
  PodcastViewMode _localViewMode = PodcastViewMode.episodes;

  /// Local selected playlist ID for non-subscribed podcasts.
  String? _localSelectedPlaylistId;

  Podcast get podcast => widget.podcast;

  /// RSS feed-level image URL for thumbnail deduplication.
  String? _feedImageUrl;

  /// Subscription's last refresh timestamp for "new" badge.
  DateTime? _lastRefreshedAt;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchableAppBar(
        title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        onSearchChanged: (query) => setState(() => _searchQuery = query),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final feedUrl = podcast.feedUrl;

    if (feedUrl == null) {
      return const PodcastDetailNoFeedUrlState();
    }

    final feedAsync = ref.watch(podcastDetailProvider(feedUrl));

    return feedAsync.when(
      data: (_) => _buildContent(feedUrl),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => PodcastDetailErrorState(
        error: error.toString(),
        onRetry: () => ref.invalidate(podcastDetailProvider(feedUrl)),
      ),
    );
  }

  Widget _buildContent(String feedUrl) {
    _feedImageUrl = ref
        .watch(podcastDetailProvider(feedUrl))
        .value
        ?.podcast
        .primaryImage
        ?.url;

    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;
    _lastRefreshedAt = subscription?.lastRefreshedAt;

    final prefsAsync = subscription != null
        ? ref.watch(podcastViewPreferenceControllerProvider(subscription.id))
        : null;
    final prefs = prefsAsync?.value;

    final viewMode = prefs?.viewMode ?? _localViewMode;
    final filter = prefs?.episodeFilter ?? EpisodeFilter.all;
    final selectedPlaylistId =
        prefs?.selectedPlaylistId ?? _localSelectedPlaylistId;
    final sortOrder = prefs?.episodeSortOrder ?? SortOrder.descending;

    final filteredAsync = ref.watch(
      filteredSortedEpisodesProvider(feedUrl, filter, sortOrder),
    );
    final progressMapAsync = ref.watch(podcastEpisodeProgressProvider(feedUrl));

    final playlistsAsync = ref.watch(
      sortedPodcastSmartPlaylistsProvider(feedUrl, podcast.id),
    );
    final grouping = playlistsAsync.value;
    final allPlaylists = grouping?.playlists ?? [];

    final displayPlaylists = <SmartPlaylist>[
      ...allPlaylists,
      if (grouping != null && grouping.hasUngrouped)
        SmartPlaylist(
          id: 'ungrouped',
          displayName: AppLocalizations.of(context).podcastDetailUngrouped,
          sortKey: 999999,
          episodeIds: grouping.ungroupedEpisodeIds,
        ),
    ];

    SmartPlaylist? activePlaylist;
    if (viewMode == PodcastViewMode.smartPlaylists &&
        displayPlaylists.isNotEmpty) {
      activePlaylist =
          displayPlaylists
              .where((p) => p.id == selectedPlaylistId)
              .firstOrNull ??
          displayPlaylists.first;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(podcastDetailProvider(feedUrl));
        ref.invalidate(podcastEpisodeProgressProvider(feedUrl));
        await ref.read(podcastDetailProvider(feedUrl).future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: PodcastDetailHeader(podcast: podcast)),
          if (displayPlaylists.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: SmartPlaylistViewToggle(
                  playlists: displayPlaylists,
                  selectedMode: viewMode,
                  selectedPlaylistId: activePlaylist?.id ?? selectedPlaylistId,
                  onEpisodesSelected: () {
                    _onEpisodesViewSelected(subscription?.id);
                  },
                  onPlaylistSelected: (playlist) {
                    _onPlaylistSelected(subscription?.id, playlist);
                  },
                ),
              ),
            ),
          if (viewMode == PodcastViewMode.episodes)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: EpisodeFilterChips(
                  selected: filter,
                  onSelected: (f) {
                    if (subscription != null) {
                      ref
                          .read(
                            podcastViewPreferenceControllerProvider(
                              subscription.id,
                            ).notifier,
                          )
                          .setEpisodeFilter(f);
                    }
                  },
                ),
              ),
            ),
          if (viewMode == PodcastViewMode.episodes)
            ...buildEpisodeListSlivers(
              ref: ref,
              feedUrl: feedUrl,
              episodesAsync: filteredAsync,
              progressMapAsync: progressMapAsync,
              sortOrder: sortOrder,
              searchQuery: _searchQuery,
              podcastTitle: podcast.name,
              artworkUrl: podcast.artworkUrl,
              feedImageUrl: _feedImageUrl,
              lastRefreshedAt: _lastRefreshedAt,
              scrollController: _scrollController,
              onToggleSortOrder: _toggleSortOrder,
            )
          else if (activePlaylist != null)
            ...buildInlinePlaylistSlivers(
              ref: ref,
              playlist: activePlaylist,
              feedUrl: podcast.feedUrl,
              searchQuery: _searchQuery,
              sortOrder: sortOrder,
              podcastTitle: podcast.name,
              artworkUrl: podcast.artworkUrl,
              feedImageUrl: _feedImageUrl,
              lastRefreshedAt: _lastRefreshedAt,
              scrollController: _scrollController,
              onToggleSortOrder: _toggleSortOrder,
              onNavigateToGroup: _navigateToGroupEpisodes,
            ),
        ],
      ),
    );
  }

  void _onEpisodesViewSelected(int? subscriptionId) {
    if (subscriptionId != null) {
      ref
          .read(
            podcastViewPreferenceControllerProvider(subscriptionId).notifier,
          )
          .setViewMode(PodcastViewMode.episodes);
    } else {
      setState(() {
        _localViewMode = PodcastViewMode.episodes;
      });
    }
  }

  void _onPlaylistSelected(int? subscriptionId, SmartPlaylist playlist) {
    if (subscriptionId != null) {
      ref
          .read(
            podcastViewPreferenceControllerProvider(subscriptionId).notifier,
          )
          .selectPlaylist(playlist.id);
    } else {
      setState(() {
        _localViewMode = PodcastViewMode.smartPlaylists;
        _localSelectedPlaylistId = playlist.id;
      });
    }
  }

  void _toggleSortOrder() {
    final feedUrl = podcast.feedUrl;
    if (feedUrl == null) return;
    final subscriptionAsync = ref.read(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;
    if (subscription == null) return;
    final prefsAsync = ref.read(
      podcastViewPreferenceControllerProvider(subscription.id),
    );
    final current = prefsAsync.value?.episodeSortOrder ?? SortOrder.descending;
    final next = current == SortOrder.descending
        ? SortOrder.ascending
        : SortOrder.descending;
    ref
        .read(podcastViewPreferenceControllerProvider(subscription.id).notifier)
        .setEpisodeSortOrder(next);
  }

  void _navigateToGroupEpisodes(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  }) {
    final uri = GoRouterState.of(context).uri;
    final directGroupPath = AppRoutes.smartPlaylistDirectGroup
        .replaceFirst(':playlistId', playlist.id)
        .replaceFirst(':groupId', group.id);
    context.push(
      '$uri/$directGroupPath',
      extra: <String, dynamic>{
        'podcast': podcast,
        'group': group,
        'smartPlaylist': playlist,
        'podcastTitle': podcast.name,
        'podcastArtworkUrl': podcast.artworkUrl,
        'feedImageUrl': _feedImageUrl,
        'lastRefreshedAt': _lastRefreshedAt,
        'filteredEpisodeIds': filteredEpisodeIds,
      },
    );
  }
}
