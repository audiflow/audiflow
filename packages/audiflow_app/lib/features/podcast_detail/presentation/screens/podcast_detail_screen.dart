import 'dart:async';
import 'dart:math' as math;

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
import '../../../share/presentation/helpers/share_helper.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../controllers/podcast_detail_controller.dart';
import '../widgets/episode_list_section.dart';
import '../widgets/inline_playlist_section.dart';
import '../widgets/podcast_description_sheet.dart';
import '../widgets/podcast_detail_empty_states.dart';
import '../widgets/podcast_detail_header.dart';
import '../widgets/podcast_settings_sheet.dart';
import '../widgets/podcast_detail_sticky_bar.dart';

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

  /// Locate the sticky bar's bottom edge, where the list surface starts.
  final GlobalKey _bodyKey = GlobalKey();
  final GlobalKey _stickyBarKey = GlobalKey();

  /// Screen y where the list surface starts. Infinite until first layout
  /// so the texture never flashes over the hero.
  final ValueNotifier<double> _listTop = ValueNotifier(double.infinity);

  /// Drives the floating navigation and hero collapse without rebuilding
  /// the whole sliver tree on every scroll frame.
  final ValueNotifier<FloatingNavScroll> _navScroll = ValueNotifier(
    FloatingNavScroll.at(offset: 0, heroExtent: 1),
  );

  /// Whether episode search has replaced the navigation row.
  bool _searching = false;

  /// Scroll offset held across a view switch (mode, series type, filter,
  /// sort). The new list may still be loading, and its first frames are
  /// shorter than the old one; a spacer below the content keeps this
  /// offset reachable until the new list is ready.
  double? _heldOffset;

  /// View the hold started from; the hold ends once the view has changed
  /// and its content has loaded.
  String? _heldFromViewKey;
  String? _currentViewKey;
  double _holdSpacerExtent = 0;

  /// Identifies the current hold, so a release still animating for an
  /// earlier switch does not end a hold started by a later one.
  int _holdGeneration = 0;
  int? _releasingGeneration;

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
    _searchTransition.addListener(_updateListTop);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachScrollLogger();
      _updateListTop();
    });
  }

  void _updateNavScroll() {
    if (!_scrollController.hasClients) return;
    final heroHeight = _heroKey.currentContext?.size?.height;
    _navScroll.value = FloatingNavScroll.at(
      offset: _scrollController.offset,
      heroExtent: heroHeight ?? 1,
    );
    _updateListTop();
  }

  void _updateListTop() {
    final body = _bodyKey.currentContext?.findRenderObject();
    final bar = _stickyBarKey.currentContext?.findRenderObject();
    if (body is! RenderBox || bar is! RenderBox) return;
    if (!body.hasSize || !bar.hasSize || !bar.attached) return;
    final bottom = bar.localToGlobal(
      Offset(0, bar.size.height),
      ancestor: body,
    );
    _listTop.value = bottom.dy;
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
    _listTop.dispose();
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

  /// Play order, audio, and downloads live in the settings sheet; the
  /// play order may change there, so re-resolve it once the sheet closes.
  Future<void> _openSettingsSheet() async {
    await showPodcastSettingsSheet(context: context, podcast: podcast);
    final feedUrl = podcast.feedUrl;
    if (!mounted || feedUrl == null) return;
    final subscription = ref.read(subscriptionByFeedUrlProvider(feedUrl)).value;
    if (subscription != null) _resolvePlayOrder(subscription.id);
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
        key: _bodyKey,
        children: [
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: _listTop,
              builder: (context, top, _) => ContentBackdrop(top: top),
            ),
          ),
          // Row ink draws on the nearest Material; without this one it
          // would land on the Scaffold's, hidden under the backdrop.
          Material(type: MaterialType.transparency, child: _buildBody()),
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
    // Keeps the subscribe state loaded for the `…` menu, which may open
    // before the hero (its other listener) has mounted.
    ref.watch(subscriptionControllerProvider(podcast.id));
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
              onPressed: _openSettingsSheet,
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
  /// actions as tiles. Play order and audio live in the settings sheet.
  Future<void> _showMoreMenu() {
    final l10n = AppLocalizations.of(context);
    final feedUrl = podcast.feedUrl;
    // Null until known: the tile is left out rather than guessing, since a
    // wrong "Subscribe" label would toggle an existing subscription off.
    final isSubscribed = ref
        .read(subscriptionControllerProvider(podcast.id))
        .value;
    return showActionMenu(
      context: context,
      top: FloatingNavigationBar.heightOf(context),
      tiles: [
        if (feedUrl != null && isSubscribed != null)
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
              expectSubscribed: isSubscribed,
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

    final listSlivers = <Widget>[
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
          fallbackEpisodes: _lastFilteredEpisodes,
          itunesId: podcast.id,
          effectiveOrder: _resolvedPlayOrder,
        )
      else if (activePlaylist != null)
        ..._buildInlinePlaylistSliversWithFallback(
          activePlaylist: activePlaylist,
          sortOrder: sortOrder,
        ),
    ];

    final contentLoading = effectiveViewMode == PodcastViewMode.episodes
        ? filteredAsync.isLoading
        : activePlaylist != null &&
              ref
                  .watch(
                    smartPlaylistEpisodesProvider(activePlaylist.episodeIds),
                  )
                  .isLoading;
    _currentViewKey =
        '$effectiveViewMode|${activePlaylist?.id}|$filter|$sortOrder';
    if (_heldOffset != null &&
        _currentViewKey != _heldFromViewKey &&
        !contentLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _releaseScrollHold());
    }

    return RefreshIndicator(
      edgeOffset: FloatingNavigationBar.heightOf(context),
      onRefresh: () async {
        ref.invalidate(podcastDetailProvider(feedUrl));
        ref.invalidate(podcastEpisodeProgressProvider(feedUrl));
        await ref.read(podcastDetailProvider(feedUrl).future);
      },
      // Content swaps (view mode, filter) can clamp the offset without a
      // scroll event; resync the hero so it never stays faded while still
      // taking up its space.
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _updateNavScroll();
          });
          return false;
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
            PinnedHeaderSliver(
              child: PodcastDetailStickyBar(
                key: _stickyBarKey,
                showModeSwitch: showPlaylistToggle,
                mode: effectiveViewMode,
                onModeChanged: (mode) {
                  if (mode == effectiveViewMode) return;
                  if (mode == PodcastViewMode.episodes) {
                    _onEpisodesViewSelected(subscription?.id);
                    return;
                  }
                  final playlist =
                      displayPlaylists
                          .where((p) => p.id == selectedPlaylistId)
                          .firstOrNull ??
                      displayPlaylists.firstOrNull;
                  if (playlist == null) return;
                  _onPlaylistSelected(subscription?.id, playlist);
                },
                playlists: displayPlaylists,
                selectedPlaylist: activePlaylist,
                onPlaylistSelected: (playlist) {
                  if (playlist.id == activePlaylist?.id) return;
                  _onPlaylistSelected(subscription?.id, playlist);
                },
                filter: filter,
                onFilterSelected: (f) {
                  if (f == filter) return;
                  _onFilterSelected(subscription?.id, f);
                },
                sortOrder: sortOrder,
                onToggleSortOrder: _toggleSortOrder,
              ),
            ),
            ...listSlivers,
            _scrollHoldSpacer(loading: contentLoading),
          ],
        ),
      ),
    );
  }

  void _holdScrollPosition() {
    if (!_scrollController.hasClients) return;
    // Stops an earlier release still animating, so the hold starts from
    // where the list is now.
    _scrollController.jumpTo(_scrollController.offset);
    setState(() {
      _holdGeneration++;
      _heldOffset = _scrollController.offset;
      _heldFromViewKey = _currentViewKey;
    });
  }

  /// Ends the hold: stays put when the new list is long enough, otherwise
  /// animates up to the list's real end before removing the spacer.
  Future<void> _releaseScrollHold() async {
    final generation = _holdGeneration;
    if (_releasingGeneration == generation || _heldOffset == null) return;
    if (!mounted) return;
    _releasingGeneration = generation;
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final naturalMax = math.max(
        0.0,
        position.maxScrollExtent - _holdSpacerExtent,
      );
      if (naturalMax < position.pixels) {
        await _scrollController.animateTo(
          naturalMax,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    }
    // A newer switch took over while this one animated; its own release
    // will end its hold.
    if (!mounted || generation != _holdGeneration) return;
    setState(() {
      _heldOffset = null;
      _heldFromViewKey = null;
    });
  }

  /// Bottom spacer that keeps [_heldOffset] reachable while it is set,
  /// with a spinner where the list will appear if it is still loading.
  Widget _scrollHoldSpacer({required bool loading}) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final held = _heldOffset;
        final extent = held == null
            ? 0.0
            : math.max(
                0.0,
                held +
                    constraints.viewportMainAxisExtent -
                    constraints.precedingScrollExtent,
              );
        _holdSpacerExtent = extent;
        if (extent <= 0) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        // Puts the spinner in view: past any part of the spacer that sits
        // above the viewport, and below the pinned navigation and bar.
        final hiddenAbove = math.max(
          0.0,
          held! - constraints.precedingScrollExtent,
        );
        return SliverToBoxAdapter(
          child: SizedBox(
            height: extent,
            child: loading
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: hiddenAbove + _kHoldSpinnerTop,
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  static const double _kHoldSpinnerTop = 200;

  void _onEpisodesViewSelected(int? subscriptionId) {
    _holdScrollPosition();
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

  void _onFilterSelected(int? subscriptionId, EpisodeFilter filter) {
    _holdScrollPosition();
    if (subscriptionId == null) {
      setState(() => _localEpisodeFilter = filter);
      return;
    }
    ref
        .read(podcastViewPreferenceControllerProvider(subscriptionId).notifier)
        .setEpisodeFilter(filter);
  }

  void _onPlaylistSelected(int? subscriptionId, SmartPlaylist playlist) {
    _holdScrollPosition();
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
      onNavigateToGroup: _navigateToGroupEpisodes,
      itunesId: podcast.id,
      effectiveOrder: _resolvedPlayOrder,
      fallbackEpisodes: _lastPlaylistEpisodes,
    );
  }

  void _toggleSortOrder() {
    _holdScrollPosition();
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
