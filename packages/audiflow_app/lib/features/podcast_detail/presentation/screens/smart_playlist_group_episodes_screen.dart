import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart' show AutoPlayOrder;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../download/presentation/helpers/batch_download_action_helper.dart';
import '../utils/smart_playlist_def_resolver.dart';
import '../widgets/play_order_bottom_sheet.dart';
import '../utils/series_resume.dart';
import '../widgets/episode_list_section.dart' show SortOrderButton;
import '../widgets/inline_group_card.dart' show formatGroupDuration;
import '../widgets/series_hero.dart';
import '../widgets/smart_playlist_episode_list_tile.dart';

/// Screen showing episodes within a smart playlist group.
class SmartPlaylistGroupEpisodesScreen extends ConsumerStatefulWidget {
  const SmartPlaylistGroupEpisodesScreen({
    super.key,
    required this.group,
    required this.parentPlaylist,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
    this.feedImageUrl,
    this.lastRefreshedAt,
    this.filteredEpisodeIds,
    this.itunesId,
    this.feedUrl,
  });

  final SmartPlaylistGroup group;
  final SmartPlaylist parentPlaylist;
  final String podcastTitle;
  final String? podcastArtworkUrl;
  final String? feedImageUrl;
  final DateTime? lastRefreshedAt;

  /// When perEpisode year mode, only these IDs shown.
  final List<int>? filteredEpisodeIds;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  /// Feed URL for invalidating batch progress after changes.
  final String? feedUrl;

  @override
  ConsumerState<SmartPlaylistGroupEpisodesScreen> createState() =>
      _SmartPlaylistGroupEpisodesScreenState();
}

class _SmartPlaylistGroupEpisodesScreenState
    extends ConsumerState<SmartPlaylistGroupEpisodesScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  /// Measures the hero so the collapse spans exactly its height, and
  /// finds where the list surface starts (the hero's bottom edge).
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _bodyKey = GlobalKey();

  /// Drives the floating navigation and hero collapse without rebuilding
  /// the sliver tree on every scroll frame.
  final ValueNotifier<FloatingNavScroll> _navScroll = ValueNotifier(
    FloatingNavScroll.at(offset: 0, heroExtent: 1),
  );

  /// Screen y where the list surface starts. Infinite until first layout
  /// so the texture never flashes over the hero.
  final ValueNotifier<double> _listTop = ValueNotifier(double.infinity);

  late final AnimationController _searchTransition = AnimationController(
    vsync: this,
    duration: FloatingNavigationBar.switchDuration,
  );

  late SortOrder _sortOrder;
  bool _searching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  /// Resolved effective play order for this group.
  AutoPlayOrder? _resolvedPlayOrder;

  @override
  void initState() {
    super.initState();
    final groupSort =
        widget.group.episodeSort ?? widget.parentPlaylist.episodeSort;
    _sortOrder =
        groupSort?.order ??
        (widget.parentPlaylist.userSortable &&
                widget.parentPlaylist.groupSort != null
            ? widget.parentPlaylist.groupSort!.order
            : SortOrder.descending);
    _resolvePlayOrder();
    _scrollController.addListener(_updateNavScroll);
    _searchTransition.addListener(_updateListTop);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateNavScroll();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _navScroll.dispose();
    _listTop.dispose();
    _searchTransition.dispose();
    super.dispose();
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
    final hero = _heroKey.currentContext?.findRenderObject();
    if (body is! RenderBox || hero is! RenderBox) return;
    if (!body.hasSize || !hero.hasSize || !hero.attached) return;
    final bottom = hero.localToGlobal(
      Offset(0, hero.size.height),
      ancestor: body,
    );
    _listTop.value = bottom.dy;
  }

  FloatingNavScroll get _effectiveNavScroll =>
      _navScroll.value.withSearch(_searchTransition.value);

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
        duration: FloatingNavigationBar.switchDuration,
        curve: Curves.easeOutCubic,
      );
    }
    if (searching) {
      _searchTransition.animateTo(1, curve: Curves.easeOutCubic);
    } else {
      _searchTransition.animateBack(0, curve: Curves.easeOutCubic);
    }
  }

  List<int> get _episodeIds =>
      widget.filteredEpisodeIds ?? widget.group.episodeIds;

  /// Effective year binding for this group.
  ///
  /// Per-group yearOverride takes precedence over the parent playlist's
  /// yearBinding. Used to decide whether year headers should be shown.
  YearBinding get _yearBinding =>
      widget.group.yearOverride ?? widget.parentPlaylist.yearBinding;

  bool get _showYearHeaders {
    // If yearBinding is active, year headers are implied.
    if (_yearBinding != YearBinding.none) return true;
    // Per-group showYearHeaders override takes precedence, then fall
    // back to the parent playlist's definition-level setting.
    final groupOverride = widget.group.showYearHeaders;
    if (groupOverride != null) return groupOverride;
    return widget.parentPlaylist.showYearHeaders;
  }

  String _formatGroupTitle() {
    return widget.group.formattedDisplayName(
      parentPrependSeasonNumber: widget.parentPlaylist.prependSeasonNumber,
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.descending
          ? SortOrder.ascending
          : SortOrder.descending;
    });
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _searchQuery = text),
    );
  }

  /// Looks up the subscription by iTunes ID first, then falls back
  /// to feed URL so feeds without an iTunes ID still work.
  Subscription? _readSubscription() {
    final itunesId = widget.itunesId;
    if (itunesId != null) {
      final sub = ref.read(subscriptionByItunesIdProvider(itunesId)).value;
      if (sub != null) return sub;
    }
    final feedUrl = widget.feedUrl;
    if (feedUrl != null) {
      return ref.read(subscriptionByFeedUrlProvider(feedUrl)).value;
    }
    return null;
  }

  void _resolvePlayOrder() {
    final subscription = _readSubscription();
    if (subscription == null) return;
    final repo = ref.read(playOrderPreferenceRepositoryProvider);
    repo
        .resolveForGroup(
          subscription.id,
          widget.parentPlaylist.id,
          widget.group.id,
        )
        .then((resolved) {
          if (!mounted) return;
          setState(() => _resolvedPlayOrder = resolved);
        });
  }

  void _showPlayOrderSheet() {
    final subscription = _readSubscription();
    if (subscription == null) return;

    final podcastId = subscription.id;
    final playlistId = widget.parentPlaylist.id;
    final groupId = widget.group.id;
    final repo = ref.read(playOrderPreferenceRepositoryProvider);
    repo.getGroupPlayOrder(podcastId, playlistId, groupId).then((currentOrder) {
      if (!mounted) return;
      repo.resolveForPlaylist(podcastId, playlistId).then((parentOrder) {
        if (!mounted) return;
        showPlayOrderBottomSheet(
          context: context,
          currentOrder: currentOrder ?? AutoPlayOrder.defaultOrder,
          resolvedParentOrder: parentOrder,
          onOrderSelected: (order) {
            // Await the write before re-resolving to avoid reading stale data.
            repo
                .setGroupPlayOrder(podcastId, playlistId, groupId, order)
                .then((_) => _resolvePlayOrder());
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-resolve play order when subscription finishes loading.
    // initState reads synchronously and may miss a still-loading provider.
    // Listen to whichever provider is available (itunesId preferred).
    final itunesId = widget.itunesId;
    final feedUrl = widget.feedUrl;
    if (itunesId != null) {
      ref.listen(subscriptionByItunesIdProvider(itunesId), (prev, next) {
        if (prev?.value == null && next.value != null) {
          _resolvePlayOrder();
        }
      });
    } else if (feedUrl != null) {
      ref.listen(subscriptionByFeedUrlProvider(feedUrl), (prev, next) {
        if (prev?.value == null && next.value != null) {
          _resolvePlayOrder();
        }
      });
    }

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
          _buildScrollView(),
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
    return FloatingNavigationBar(
      leading: FloatingNavButton(
        icon: Icons.arrow_back_ios_new_rounded,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: _formatGroupTitle(),
      titleOpacity: scroll.title,
      backgroundOpacity: scroll.background,
      trailing: FloatingNavActions(
        actions: [
          FloatingNavAction(
            icon: Icons.search_rounded,
            tooltip: l10n.podcastDetailSearchTooltip,
            onPressed: () => _setSearching(true),
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

  /// Overflow popover: downloads as tiles, play order below.
  Future<void> _showMoreMenu() {
    final l10n = AppLocalizations.of(context);
    final allTasks = ref.read(allDownloadsProvider).value ?? [];
    final dlState = computeBatchDownloadState(
      episodeIds: _episodeIds,
      allTasks: allTasks,
    );
    return showActionMenu(
      context: context,
      top: FloatingNavigationBar.heightOf(context),
      tiles: [
        if (dlState.hasDownloadable)
          ActionMenuEntry(
            icon: Icons.download_rounded,
            label: l10n.downloadAllEpisodes,
            onSelected: () => unawaited(
              handleBatchDownload(
                context: context,
                ref: ref,
                episodeIds: _episodeIds,
                downloadableCount: dlState.downloadableCount,
              ),
            ),
          ),
        if (dlState.hasCancelable)
          ActionMenuEntry(
            icon: Icons.cancel_outlined,
            label: l10n.downloadCancelAll,
            onSelected: () => unawaited(
              handleBatchCancel(
                context: context,
                ref: ref,
                episodeIds: _episodeIds,
              ),
            ),
          ),
        if (dlState.hasPaused)
          ActionMenuEntry(
            icon: Icons.play_arrow_rounded,
            label: l10n.downloadResumeAll,
            onSelected: () => unawaited(
              handleBatchResume(
                context: context,
                ref: ref,
                episodeIds: _episodeIds,
              ),
            ),
          ),
      ],
      sections: [
        [
          ActionMenuEntry(
            icon: Icons.swap_vert,
            label: l10n.playOrderMenuTitle,
            onSelected: _showPlayOrderSheet,
          ),
        ],
      ],
    );
  }

  Widget _buildScrollView() {
    final episodesAsync = ref.watch(smartPlaylistEpisodesProvider(_episodeIds));
    final episodes = episodesAsync.value;

    // Resolve shared thumbnail from episodes. Non-null when the group
    // has a single episode, or when the first two episodes share the
    // same image (indicating ALL episodes likely use the same thumbnail).
    final sharedThumbnailUrl = episodes == null
        ? null
        : _resolveSharedThumbnail(episodes);

    // Header shows group.thumbnailUrl, then the shared thumbnail,
    // then podcast-level artwork. Page header artwork always
    // renders; the smart playlist showThumbnail flags apply only
    // to inline group cards and episode rows, not to this header.
    final headerThumbnailUrl =
        widget.group.thumbnailUrl ??
        sharedThumbnailUrl ??
        widget.podcastArtworkUrl ??
        widget.feedImageUrl;

    // Content swaps (search, sort) can clamp the offset without a scroll
    // event; resync the hero and backdrop after layout.
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateNavScroll();
        });
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Reserves the floating navigation's height; pinned so the year
          // header stops under the bar instead of behind it.
          PinnedHeaderSliver(
            child: SizedBox(height: FloatingNavigationBar.heightOf(context)),
          ),
          SliverToBoxAdapter(
            // Kept mounted in search: its height animates to zero instead
            // of popping out.
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
                  child: _buildHero(episodes, headerThumbnailUrl),
                ),
              ),
            ),
          ),
          // Dedup only uses the shared thumbnail (never group.thumbnailUrl,
          // which may match only one episode and hide just that one).
          ..._buildEpisodeList(episodesAsync, sharedThumbnailUrl),
        ],
      ),
    );
  }

  Widget _buildHero(
    List<SmartPlaylistEpisodeData>? episodes,
    String? thumbnailUrl,
  ) {
    final l10n = AppLocalizations.of(context);
    final totalMs = episodes == null
        ? widget.group.totalDurationMs
        : episodes.fold<int>(0, (sum, d) => sum + (d.episode.durationMs ?? 0));
    final count = l10n.groupEpisodeCount(_episodeIds.length);
    final duration = formatGroupDuration(totalMs, l10n);
    final target = episodes == null
        ? null
        : seriesResumeTarget(episodes, field: _effectiveSortField);
    return SeriesHero(
      title: _formatGroupTitle(),
      podcastTitle: widget.podcastTitle,
      meta: duration == null ? count : '$count · $duration',
      thumbnailUrl: thumbnailUrl,
      onArtworkTap: thumbnailUrl == null
          ? null
          : () => _showArtworkOverlay(thumbnailUrl),
      onPodcastTap: () => Navigator.of(context).maybePop(),
      resumeLabel: target == null
          ? null
          : target.resuming
          ? l10n.seriesResumeEpisode(target.number)
          : l10n.seriesPlayEpisode(target.number),
      onResume: target == null
          ? null
          : () => _tileFor(target.data).togglePlayback(context, ref),
    );
  }

  void _showArtworkOverlay(String artworkUrl) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ArtworkOverlay(
            imageUrl: artworkUrl,
            heroTag: 'group_artwork_$artworkUrl',
          );
        },
      ),
    );
  }

  /// Returns the first episode's imageUrl when the group has a single
  /// episode or when it matches the second episode's (indicating a shared
  /// series thumbnail). Returns null when images differ to avoid hiding
  /// only the first episode's thumbnail.
  String? _resolveSharedThumbnail(List<SmartPlaylistEpisodeData> episodes) {
    if (episodes.isEmpty) return null;
    final firstUrl = episodes.first.episode.imageUrl;
    if (firstUrl == null) return null;
    if (episodes.length < 2) return firstUrl;
    return firstUrl == episodes[1].episode.imageUrl ? firstUrl : null;
  }

  EpisodeSortField get _effectiveSortField =>
      (widget.group.episodeSort ?? widget.parentPlaylist.episodeSort)?.field ??
      EpisodeSortField.publishedAt;

  /// The row for [data]; also used to start playback from the hero the
  /// same way the row's play pill would.
  SmartPlaylistEpisodeListTile _tileFor(
    SmartPlaylistEpisodeData data, {
    String? feedImageUrl,
  }) {
    final number = data.episode.episodeNumber;
    return SmartPlaylistEpisodeListTile(
      key: ValueKey(data.episode.id),
      episode: data.episode,
      podcastTitle: widget.podcastTitle,
      artworkUrl: widget.podcastArtworkUrl,
      feedImageUrl: feedImageUrl ?? widget.feedImageUrl,
      showThumbnail: _resolveEpisodeRowThumbnail(),
      lastRefreshedAt: widget.lastRefreshedAt,
      progress: data.progress,
      siblingEpisodeIds: _episodeIds,
      itunesId: widget.itunesId,
      feedUrl: widget.feedUrl,
      effectiveOrder: _resolvedPlayOrder,
      displayTitle: EffectiveEpisodeTitle.forPlaylist(
        playlist: _resolvePlaylistDef(),
        episode: data.episode,
      ),
      playlistId: widget.parentPlaylist.id,
      numberLabel: number == null ? null : '#$number',
    );
  }

  /// Right-aligned sort toggle above the list; scrolls with the content.
  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: SortOrderButton(
          sortOrder: _sortOrder,
          onPressed: _toggleSortOrder,
        ),
      ),
    );
  }

  List<Widget> _buildEpisodeList(
    AsyncValue<List<SmartPlaylistEpisodeData>> episodesAsync,
    String? sharedThumbnailUrl,
  ) {
    final theme = Theme.of(context);
    final feedImageUrl = sharedThumbnailUrl ?? widget.feedImageUrl;

    return episodesAsync.when(
      data: (episodes) {
        final displayEpisodes = filterBySearchQuery(
          items: episodes,
          query: _searchQuery,
          getTitle: (e) => e.episode.title,
          getDescription: (e) => e.episode.description,
        );

        final showSortSwitch =
            _showYearHeaders || widget.parentPlaylist.userSortable;
        final sortRow = SliverToBoxAdapter(
          child: showSortSwitch
              ? _buildSortRow()
              : const SizedBox(height: Spacing.sm),
        );

        if (displayEpisodes.isEmpty) {
          if (2 <= _searchQuery.length) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).podcastDetailNoResults,
                  ),
                ),
              ),
            ];
          }
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(theme),
            ),
          ];
        }

        if (_showYearHeaders) {
          return [
            sortRow,
            ..._buildYearGroupedSlivers(
              displayEpisodes,
              feedImageUrl: feedImageUrl,
            ),
          ];
        }

        final effectiveRule = EpisodeSortRule(
          field: _effectiveSortField,
          order: _sortOrder,
        );
        final sorted = List.of(displayEpisodes);
        sortEpisodeData(sorted, effectiveRule);

        return [
          sortRow,
          SliverList.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) =>
                _tileFor(sorted[index], feedImageUrl: feedImageUrl),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ];
      },
      loading: () => [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Center(
              child: Text(
                AppLocalizations.of(context).podcastDetailLoadError,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildYearGroupedSlivers(
    List<SmartPlaylistEpisodeData> episodes, {
    String? feedImageUrl,
  }) {
    final byYear = <int, List<SmartPlaylistEpisodeData>>{};
    for (final data in episodes) {
      final year = data.episode.publishedAt?.year ?? 0;
      byYear.putIfAbsent(year, () => []).add(data);
    }

    if (_sortOrder == SortOrder.descending) {
      for (final key in byYear.keys) {
        byYear[key] = byYear[key]!.reversed.toList();
      }
    }

    final sortedYears = byYear.keys.toList()
      ..sort(
        _sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    return buildYearGroupedSlivers<SmartPlaylistEpisodeData>(
      itemsByYear: byYear,
      sortedYears: sortedYears,
      itemBuilder: (context, data) =>
          _tileFor(data, feedImageUrl: feedImageUrl),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            AppLocalizations.of(context).podcastDetailNoEpisodes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Resolves the effective `showThumbnail` flag for episode rows
  /// rendered inside this group, walking the
  /// group → playlist → pattern cascade.
  bool _resolveEpisodeRowThumbnail() {
    final feedUrl = widget.feedUrl;
    if (feedUrl == null) return true;

    final config = ref.watch(presetByFeedUrlProvider(feedUrl)).value;
    if (config == null) return true;

    final playlistDef = config.findPlaylist(widget.parentPlaylist.id);
    if (playlistDef == null) return true;

    final groupDef = playlistDef.grouping.findStaticClassifier(widget.group.id);

    return EffectiveThumbnails.episodeRowInGroup(
      showEpisodeThumbnail: config.showEpisodeThumbnail,
      playlist: playlistDef,
      group: groupDef,
    );
  }

  SmartPlaylistDefinition? _resolvePlaylistDef() => resolveSmartPlaylistDef(
    ref: ref,
    feedUrl: widget.feedUrl,
    playlistId: widget.parentPlaylist.id,
  );
}
