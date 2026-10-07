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
        SubscribeSource,
        appSettingsRepositoryProvider,
        hideExplicitForPodcastProvider,
        namedLoggerProvider,
        playOrderPreferenceRepositoryProvider,
        podcastViewPreferenceControllerProvider,
        smartPlaylistEpisodesProvider,
        presetByFeedUrlProvider,
        subscriptionByFeedUrlProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../player/presentation/widgets/audio_sheet.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
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
  const PodcastDetailScreen({
    super.key,
    required this.podcast,
    this.subscribeSource = SubscribeSource.discovery,
  });

  final Podcast podcast;

  /// Surface that led the user to this screen. Forwarded to the
  /// subscribe button so the `subscribe` analytics emit can report
  /// the correct origin (search, deeplink, etc.).
  final SubscribeSource subscribeSource;

  @override
  ConsumerState<PodcastDetailScreen> createState() =>
      _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends ConsumerState<PodcastDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _ownScrollController = ScrollController();

  ScrollController get _scrollController => _ownScrollController;

  /// Measures the hero so the collapse spans exactly its height.
  final GlobalKey _heroKey = GlobalKey();

  /// Drives the floating navigation and hero collapse without rebuilding
  /// the whole sliver tree on every scroll frame.
  final ValueNotifier<FloatingNavScroll> _navScroll = ValueNotifier(
    FloatingNavScroll.at(offset: 0, heroExtent: 1),
  );

  /// Whether episode search has replaced the navigation row.
  bool _searching = false;

  /// 0 while browsing, 1 while searching. Collapses the hero and fills
  /// the navigation in step with the bar's switch to the search field,
  /// so entering search reads as one motion rather than a jump.
  late final AnimationController _searchTransition = AnimationController(
    vsync: this,
    duration: _kSearchTransitionDuration,
  );

  static const Duration _kSearchTransitionDuration = Duration(
    milliseconds: 260,
  );

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

    _scrollController.addListener(_updateNavScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachScrollLogger();
    });
  }

  void _updateNavScroll() {
    if (!_scrollController.hasClients) return;
    final heroHeight = _heroKey.currentContext?.size?.height;
    _navScroll.value = FloatingNavScroll.at(
      offset: _scrollController.offset,
      heroExtent: heroHeight ?? 1,
    );
  }

  void _setSearching(bool searching) {
    _searchDebounce?.cancel();
    setState(() {
      _searching = searching;
      _searchQuery = '';
    });
    if (!searching) _searchController.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: _kSearchTransitionDuration,
        curve: Curves.easeOutCubic,
      );
    }
    if (searching) {
      _searchTransition.animateTo(1, curve: Curves.easeOutCubic);
    } else {
      _searchTransition.animateBack(0, curve: Curves.easeOutCubic);
    }
  }

  FloatingNavScroll get _effectiveNavScroll =>
      _navScroll.value.withSearch(_searchTransition.value);

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
    _navScroll.dispose();
    _searchTransition.dispose();
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
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: Listenable.merge([_navScroll, _searchTransition]),
              builder: (context, _) => _buildNavigation(_effectiveNavScroll),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(FloatingNavScroll scroll) {
    final l10n = AppLocalizations.of(context);
    final feedUrl = podcast.feedUrl;
    final subscription = feedUrl == null
        ? null
        : ref.watch(subscriptionByFeedUrlProvider(feedUrl)).value;
    final isSubscribed = subscription != null && !subscription.isCached;
    return FloatingNavigationBar(
      leading: FloatingNavButton(
        icon: Icons.arrow_back_ios_new_rounded,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: podcast.name,
      titleOpacity: scroll.title,
      backgroundOpacity: scroll.background,
      trailing: FloatingNavActions(
        actions: [
          FloatingNavAction(
            icon: Icons.search_rounded,
            tooltip: l10n.podcastDetailSearchTooltip,
            onPressed: feedUrl == null ? null : () => _setSearching(true),
          ),
          if (isSubscribed)
            FloatingNavAction(
              icon: Icons.tune_rounded,
              tooltip: l10n.podcastDetailSettingsTooltip,
              onPressed: () =>
                  showPodcastSettingsSheet(context: context, podcast: podcast),
            ),
          FloatingNavAction(
            icon: Icons.more_horiz_rounded,
            tooltip: l10n.podcastDetailMoreTooltip,
            onPressed: _showMoreMenu,
          ),
        ],
      ),
      search: _searching
          ? NavigationSearchField(
              controller: _searchController,
              hintText: l10n.podcastDetailSearchHint,
              cancelLabel: l10n.commonCancel,
              onChanged: _onSearchChanged,
              onCancel: () => _setSearching(false),
            )
          : null,
    );
  }

  /// Overflow popover under the navigation's trailing pill: primary
  /// actions as tiles, then the podcast's play settings.
  Future<void> _showMoreMenu() {
    final l10n = AppLocalizations.of(context);
    final feedUrl = podcast.feedUrl;
    final subscriptionId = feedUrl == null
        ? null
        : ref.read(subscriptionByFeedUrlProvider(feedUrl)).value?.id;
    final isSubscribed =
        ref.read(subscriptionControllerProvider(podcast.id)).value ?? false;
    return showActionMenu(
      context: context,
      top: FloatingNavigationBar.heightOf(context),
      tiles: [
        if (feedUrl != null)
          ActionMenuEntry(
            icon: isSubscribed
                ? Icons.remove_circle_outline
                : Icons.add_circle_outline,
            label: isSubscribed
                ? l10n.podcastDetailUnsubscribe
                : l10n.podcastDetailSubscribe,
            onSelected: () => togglePodcastSubscription(
              context: context,
              ref: ref,
              podcast: podcast,
              source: widget.subscribeSource,
            ),
          ),
        ActionMenuEntry(
          icon: Icons.ios_share,
          label: l10n.podcastDetailShareShort,
          onSelected: () =>
              sharePodcast(context: context, ref: ref, itunesId: podcast.id),
        ),
        ActionMenuEntry(
          icon: Icons.info_outline,
          label: l10n.podcastDetailDescriptionMenuTitle,
          onSelected: () =>
              showPodcastDescriptionSheet(context: context, podcast: podcast),
        ),
      ],
      sections: [
        [
          ActionMenuEntry(
            icon: Icons.swap_vert,
            label: l10n.playOrderMenuTitle,
            onSelected: _showPlayOrderSheet,
          ),
          if (subscriptionId != null)
            ActionMenuEntry(
              icon: Icons.graphic_eq,
              label: l10n.podcastDetailAudioSettingsMenuTitle,
              // Lets the override be edited while nothing is playing.
              onSelected: () =>
                  showAudioSheet(context, podcastId: subscriptionId),
            ),
        ],
      ],
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
    final patternAsync = ref.watch(presetByFeedUrlProvider(feedUrl));

    // Surface transient pattern-load errors — we deliberately fall
    // back to "assume a pattern might exist" for UX, but the failure
    // itself should still be observable.
    ref.listen(presetByFeedUrlProvider(feedUrl), (prev, next) {
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
    var filteredAsync = ref.watch(
      filteredSortedEpisodesProvider(feedUrl, filter, sortOrder),
    );

    // Post-filter explicit episodes when the per-podcast hide-explicit flag is
    // on. Uses explicit .when() to log errors instead of silently defaulting.
    if (subscription != null) {
      final hideExplicit = ref
          .watch(hideExplicitForPodcastProvider(subscription.id))
          .when(
            data: (v) => v,
            loading: () => false,
            error: (e, st) {
              ref
                  .read(namedLoggerProvider('ParentalControl'))
                  .w(
                    'hideExplicitForPodcast stream error; defaulting to false',
                    error: e,
                    stackTrace: st,
                  );
              return false;
            },
          );
      if (hideExplicit) {
        filteredAsync = filteredAsync.whenData(
          // isExplicit != true is intentional: per RSS spec, absence of the
          // <itunes:explicit> tag means the publisher did not mark it explicit,
          // so it is treated as clean. Only episodes where the publisher
          // explicitly set explicit=true are filtered out.
          (episodes) => episodes.where((e) => e.isExplicit != true).toList(),
        );
      }
    }

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
      edgeOffset: FloatingNavigationBar.heightOf(context),
      onRefresh: () async {
        ref.invalidate(podcastDetailProvider(feedUrl));
        ref.invalidate(podcastEpisodeProgressProvider(feedUrl));
        await ref.read(podcastDetailProvider(feedUrl).future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Reserves the floating navigation's height. Pinned so sticky
          // headers below (e.g. the year header) stop under the bar
          // instead of behind it; transparent so the hero shows through
          // while it scrolls up.
          PinnedHeaderSliver(
            child: SizedBox(height: FloatingNavigationBar.heightOf(context)),
          ),
          SliverToBoxAdapter(
            // Kept mounted in search: its height animates to zero (bottom
            // edge fixed, like scrolling up) instead of popping out.
            child: SizeTransition(
              sizeFactor: ReverseAnimation(_searchTransition),
              alignment: Alignment.bottomCenter,
              child: ListenableBuilder(
                listenable: Listenable.merge([_navScroll, _searchTransition]),
                builder: (context, child) => CollapsingHero(
                  progress: _effectiveNavScroll.hero,
                  child: child!,
                ),
                child: KeyedSubtree(
                  key: _heroKey,
                  child: PodcastDetailHeader(
                    podcast: podcast,
                    subscribeSource: widget.subscribeSource,
                  ),
                ),
              ),
            ),
          ),
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
