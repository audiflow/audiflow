import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart' show AutoPlayOrder;
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        EpisodeFilter,
        PodcastItem,
        PodcastViewMode,
        SmartPlaylist,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
        SortOrder,
        appSettingsRepositoryProvider,
        namedLoggerProvider,
        playOrderPreferenceRepositoryProvider,
        podcastViewPreferenceControllerProvider,
        smartPlaylistEpisodesProvider,
        smartPlaylistPatternByFeedUrlProvider,
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
import '../widgets/play_order_bottom_sheet.dart';
import '../widgets/podcast_description_sheet.dart';
import '../widgets/podcast_detail_empty_states.dart';
import '../widgets/podcast_detail_header.dart';
import '../widgets/podcast_settings_sheet.dart';
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
  late final ScrollController _ownScrollController = ScrollController(
    initialScrollOffset: _kSearchBarHeight,
  );

  ScrollController get _scrollController => _ownScrollController;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  /// Resolved effective play order for this podcast.
  AutoPlayOrder? _resolvedPlayOrder;

  /// Local view mode for non-subscribed podcasts.
  PodcastViewMode _localViewMode = PodcastViewMode.episodes;

  /// Local selected playlist ID for non-subscribed podcasts.
  String? _localSelectedPlaylistId;

  /// Local sort order for non-subscribed podcasts.
  SortOrder _localSortOrder = SortOrder.descending;

  /// Local episode filter for non-subscribed podcasts.
  EpisodeFilter _localEpisodeFilter = EpisodeFilter.all;

  Podcast get podcast => widget.podcast;

  /// RSS feed-level image URL for thumbnail deduplication.
  String? _feedImageUrl;

  /// Subscription's last refresh timestamp for "new" badge.
  DateTime? _lastRefreshedAt;

  /// Last successful filtered episode list, kept across provider-key
  /// switches (filter / sort changes) so the sliver tree -- and the
  /// CustomScrollView's total scroll extent -- stays stable while the
  /// new key is still resolving.
  List<PodcastItem>? _lastFilteredEpisodes;

  /// Last successful smart-playlist episode data, used the same way as
  /// [_lastFilteredEpisodes] to keep the sliver tree stable while a
  /// different playlist key is loading.
  List<SmartPlaylistEpisodeData>? _lastPlaylistEpisodes;

  // ---- diagnostics for scroll-jump investigation ----------------------
  // Logs the controller's offset on every scroll callback and flags any
  // transition larger than _kJumpThresholdPx as a JUMP. Wired in
  // initState's postFrameCallback so the controller (which may come from
  // an ancestor PrimaryScrollController) is resolvable. Remove once the
  // root cause is confirmed.
  static const double _kJumpThresholdPx = 200;
  static const double _kSearchBarHeight = 64;
  double? _lastScrollOffset;
  bool _scrollListenerAttached = false;
  EpisodeFilter? _previouslyLoggedFilter;
  AsyncValue<List<PodcastItem>>? _previouslyLoggedEpisodes;

  /// Latches once content has been built successfully. After this,
  /// `_buildBody` never returns a non-`CustomScrollView` widget, so
  /// transient provider loading states cannot unmount the scroll view
  /// and destroy its [ScrollPosition] (which would otherwise reset
  /// scroll offset to `initialScrollOffset` on remount).
  bool _contentEverRendered = false;

  @override
  void initState() {
    super.initState();
    // Set metadata hint so podcastDetail can create a cached
    // subscription for non-subscribed podcasts
    final feedUrl = podcast.feedUrl;
    if (feedUrl != null) {
      PodcastMetadataHints.set(feedUrl, podcast);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachScrollLogger();
    });
  }

  void _attachScrollLogger() {
    if (_scrollListenerAttached) return;
    final controller = _scrollController;
    final logger = ref.read(namedLoggerProvider('PodcastDetailScroll'));
    controller.addListener(() {
      if (!controller.hasClients) return;
      final offset = controller.offset;
      final last = _lastScrollOffset;
      final maxExtent = controller.position.maxScrollExtent;
      if (last != null && (last - offset).abs() >= _kJumpThresholdPx) {
        logger.w(
          'SCROLL JUMP: ${last.toStringAsFixed(1)} -> '
          '${offset.toStringAsFixed(1)} (max=${maxExtent.toStringAsFixed(1)})',
        );
      }
      _lastScrollOffset = offset;
    });
    _scrollListenerAttached = true;
    logger.i('Scroll logger attached (controller=$controller)');
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _ownScrollController.dispose();
    final feedUrl = podcast.feedUrl;
    if (feedUrl != null) {
      PodcastMetadataHints.remove(feedUrl);
    }
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _searchQuery = text),
    );
  }

  void _showPlayOrderSheet() {
    final feedUrl = podcast.feedUrl;
    if (feedUrl == null) return;
    final subscription = ref.read(subscriptionByFeedUrlProvider(feedUrl)).value;
    if (subscription == null) return;

    final repo = ref.read(playOrderPreferenceRepositoryProvider);
    repo.getPodcastPlayOrder(subscription.id).then((currentOrder) {
      if (!mounted) return;
      showPlayOrderBottomSheet(
        context: context,
        currentOrder: currentOrder ?? AutoPlayOrder.defaultOrder,
        resolvedParentOrder: ref
            .read(appSettingsRepositoryProvider)
            .getAutoPlayOrder(),
        onOrderSelected: (order) {
          // Await the write before re-resolving to avoid reading stale data.
          repo.setPodcastPlayOrder(subscription.id, order).then((_) {
            _resolvePlayOrder(subscription.id);
          });
        },
      );
    });
  }

  void _resolvePlayOrder(int subscriptionId) {
    final repo = ref.read(playOrderPreferenceRepositoryProvider);
    repo.resolveForPodcast(subscriptionId).then((resolved) {
      if (!mounted) return;
      setState(() => _resolvedPlayOrder = resolved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feedUrl = podcast.feedUrl;
    final subscription = feedUrl == null
        ? null
        : ref.watch(subscriptionByFeedUrlProvider(feedUrl)).value;
    final isSubscribed = subscription != null && !subscription.isCached;
    return Scaffold(
      appBar: AppBar(
        title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'description':
                  showPodcastDescriptionSheet(
                    context: context,
                    podcast: podcast,
                  );
                case 'play_order':
                  _showPlayOrderSheet();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'description',
                child: Text(l10n.podcastDetailDescriptionMenuTitle),
              ),
              PopupMenuItem(
                value: 'play_order',
                child: Text(l10n.playOrderMenuTitle),
              ),
            ],
          ),
          if (isSubscribed)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.podcastDetailSettingsTooltip,
              onPressed: () =>
                  showPodcastSettingsSheet(context: context, podcast: podcast),
            ),
        ],
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

    if (feedAsync.hasError) {
      return PodcastDetailErrorState(
        error: feedAsync.error.toString(),
        onRetry: () => ref.invalidate(podcastDetailProvider(feedUrl)),
      );
    }

    // Watch all downstream providers so we can gate on them
    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;

    final prefsAsync = subscription != null
        ? ref.watch(podcastViewPreferenceControllerProvider(subscription.id))
        : null;

    final playlistsAsync = ref.watch(
      sortedPodcastSmartPlaylistsProvider(feedUrl),
    );

    // Pattern presence decides whether the toggle can hide for a
    // single-bucket grouping, so gate on it too to avoid a flicker
    // from pattern-driven configs loading after the first frame.
    final patternAsync = ref.watch(
      smartPlaylistPatternByFeedUrlProvider(feedUrl),
    );

    // Surface transient pattern-load errors — we deliberately fall
    // back to "assume a pattern might exist" for UX, but the failure
    // itself should still be observable.
    ref.listen(smartPlaylistPatternByFeedUrlProvider(feedUrl), (prev, next) {
      if (next.hasError && (prev == null || !prev.hasError)) {
        ref
            .read(namedLoggerProvider('PodcastDetailScreen'))
            .e(
              'Smart playlist pattern load failed for feedUrl=$feedUrl; '
              'keeping toggle visible as a conservative fallback',
              error: next.error,
              stackTrace: next.stackTrace,
            );
      }
    });

    // Show single loading indicator until all data is ready
    final allReady =
        feedAsync.hasValue &&
        !subscriptionAsync.isLoading &&
        (prefsAsync == null || prefsAsync.hasValue) &&
        !playlistsAsync.isLoading &&
        !patternAsync.isLoading;

    // After the first successful content render, never return a
    // non-CustomScrollView body. Transient provider loading states
    // would otherwise unmount the CSV, destroy the ScrollPosition,
    // and reset the offset to initialScrollOffset on remount.
    if (!allReady && !_contentEverRendered) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasPattern = patternAsync.value != null || patternAsync.hasError;
    _contentEverRendered = true;
    return _buildContent(feedUrl, hasPattern: hasPattern);
  }

  Widget _buildContent(String feedUrl, {required bool hasPattern}) {
    _feedImageUrl = ref
        .watch(podcastDetailProvider(feedUrl))
        .value
        ?.podcast
        .primaryImage
        ?.url;

    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;
    _lastRefreshedAt = subscription?.lastRefreshedAt;

    // Resolve effective play order when subscription is available.
    if (subscription != null && _resolvedPlayOrder == null) {
      _resolvePlayOrder(subscription.id);
    }

    final prefsAsync = subscription != null
        ? ref.watch(podcastViewPreferenceControllerProvider(subscription.id))
        : null;
    final prefs = prefsAsync?.value;

    final viewMode = prefs?.viewMode ?? _localViewMode;
    final filter = prefs?.episodeFilter ?? _localEpisodeFilter;
    final selectedPlaylistId =
        prefs?.selectedPlaylistId ?? _localSelectedPlaylistId;
    final sortOrder = prefs?.episodeSortOrder ?? _localSortOrder;

    final scrollLogger = ref.read(namedLoggerProvider('PodcastDetailScroll'));
    if (_previouslyLoggedFilter != filter) {
      scrollLogger.i(
        'Filter changed: $_previouslyLoggedFilter -> $filter '
        '(offset=${_lastScrollOffset?.toStringAsFixed(1)})',
      );
      _previouslyLoggedFilter = filter;
    }
    ref.listen(filteredSortedEpisodesProvider(feedUrl, filter, sortOrder), (
      prev,
      next,
    ) {
      scrollLogger.d(
        'episodesAsync: ${prev?.runtimeType} (len=${prev?.value?.length}) '
        '-> ${next.runtimeType} (len=${next.value?.length}) '
        'offset=${_lastScrollOffset?.toStringAsFixed(1)}',
      );
      next.whenData((data) {
        if (!mounted) return;
        setState(() => _lastFilteredEpisodes = data);
      });
    });
    final filteredAsync = ref.watch(
      filteredSortedEpisodesProvider(feedUrl, filter, sortOrder),
    );

    if (_previouslyLoggedEpisodes?.runtimeType != filteredAsync.runtimeType ||
        _previouslyLoggedEpisodes?.value?.length !=
            filteredAsync.value?.length) {
      scrollLogger.d(
        'build: filter=$filter '
        'episodesAsync=${filteredAsync.runtimeType} '
        '(len=${filteredAsync.value?.length}, '
        'fallbackLen=${_lastFilteredEpisodes?.length}) '
        'offset=${_lastScrollOffset?.toStringAsFixed(1)}',
      );
      _previouslyLoggedEpisodes = filteredAsync;
    }
    final progressMapAsync = ref.watch(podcastEpisodeProgressProvider(feedUrl));

    final playlistsAsync = ref.watch(
      sortedPodcastSmartPlaylistsProvider(feedUrl),
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

    // Gate the toggle on the auto-detect-single-bucket heuristic.
    // See `shouldShowSmartPlaylistToggle` for the decision table.
    final showPlaylistToggle = shouldShowSmartPlaylistToggle(
      hasPattern: hasPattern,
      displayPlaylistsCount: displayPlaylists.length,
    );
    final effectiveViewMode = effectivePodcastViewMode(
      preferredMode: viewMode,
      showPlaylistToggle: showPlaylistToggle,
    );

    // When the toggle is hidden but the persisted preference still
    // says `smartPlaylists`, clear it so the stored state matches
    // what the user actually sees. Without this the UI would flip
    // back to the playlist view the next time the toggle returns.
    if (!showPlaylistToggle &&
        subscription != null &&
        prefs?.viewMode == PodcastViewMode.smartPlaylists) {
      final subscriptionId = subscription.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(
              podcastViewPreferenceControllerProvider(subscriptionId).notifier,
            )
            .setViewMode(PodcastViewMode.episodes);
      });
    }

    SmartPlaylist? activePlaylist;
    if (effectiveViewMode == PodcastViewMode.smartPlaylists &&
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
          SliverToBoxAdapter(
            child: SizedBox(
              height: _kSearchBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: MaterialLocalizations.of(
                      context,
                    ).searchFieldLabel,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, child) {
                        if (value.text.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchDebounce?.cancel();
                            setState(() => _searchQuery = '');
                          },
                        );
                      },
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: PodcastDetailHeader(podcast: podcast)),
          if (showPlaylistToggle)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: SmartPlaylistViewToggle(
                  playlists: displayPlaylists,
                  selectedMode: effectiveViewMode,
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
          if (effectiveViewMode == PodcastViewMode.episodes)
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
                    } else {
                      setState(() {
                        _localEpisodeFilter = f;
                      });
                    }
                  },
                ),
              ),
            ),
          if (effectiveViewMode == PodcastViewMode.episodes)
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
              fallbackEpisodes: _lastFilteredEpisodes,
              itunesId: podcast.id,
              effectiveOrder: _resolvedPlayOrder,
            )
          else if (activePlaylist != null)
            ..._buildInlinePlaylistSliversWithFallback(
              activePlaylist: activePlaylist,
              sortOrder: sortOrder,
            ),
          // Transparent trailing spacer so the CustomScrollView's scroll
          // extent is always large enough to keep the search bar hidden
          // by the initial jumpTo offset, even when the episode list is
          // empty or shorter than the viewport.
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.sizeOf(context).height),
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

  /// Wraps [buildInlinePlaylistSlivers] with a fallback-episodes cache
  /// so view-mode / playlist switches do not collapse the sliver tree
  /// while the new provider key is still loading.
  List<Widget> _buildInlinePlaylistSliversWithFallback({
    required SmartPlaylist activePlaylist,
    required SortOrder sortOrder,
  }) {
    final episodeIds = activePlaylist.episodeIds;
    ref.listen(smartPlaylistEpisodesProvider(episodeIds), (prev, next) {
      next.whenData((data) {
        if (!mounted) return;
        setState(() => _lastPlaylistEpisodes = data);
      });
    });
    return buildInlinePlaylistSlivers(
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
      itunesId: podcast.id,
      effectiveOrder: _resolvedPlayOrder,
      fallbackEpisodes: _lastPlaylistEpisodes,
    );
  }

  void _toggleSortOrder() {
    final feedUrl = podcast.feedUrl;
    if (feedUrl == null) return;
    final subscriptionAsync = ref.read(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;
    if (subscription == null) {
      setState(() {
        _localSortOrder = _localSortOrder == SortOrder.descending
            ? SortOrder.ascending
            : SortOrder.descending;
      });
      return;
    }
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
        'itunesId': podcast.id,
        'feedUrl': podcast.feedUrl,
      },
    );
  }
}
