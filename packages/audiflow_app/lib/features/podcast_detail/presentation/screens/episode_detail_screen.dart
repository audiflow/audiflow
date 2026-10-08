import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../download/presentation/helpers/download_action_helper.dart';
import '../../../player/helpers/podcast_lookup.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../../../station/presentation/helpers/record_station_play.dart';
import '../controllers/podcast_detail_controller.dart';
import '../utils/played_display.dart';
import '../widgets/episode_description_card.dart';
import '../widgets/episode_detail_actions.dart';
import '../widgets/episode_detail_hero.dart';
import '../widgets/episode_dev_info_widget.dart';
import '../widgets/episode_playback_record.dart';

/// Episode detail (redesign 4.9): hero, play / queue / download actions,
/// progress, show notes, and the playback record under a floating
/// navigation bar.
class EpisodeDetailScreen extends ConsumerStatefulWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.progress,
    this.itunesId,
    this.startAt,
    this.stationId,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;
  final EpisodeWithProgress? progress;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  /// Position to seek to on the first user-initiated play, sourced from
  /// a `?t=<seconds>` query param on an incoming universal link. One-shot:
  /// consumed the first time playback starts, then ignored.
  final Duration? startAt;

  /// The station this episode was opened from, so playing it here counts
  /// as a play from that station.
  final int? stationId;

  @override
  ConsumerState<EpisodeDetailScreen> createState() =>
      _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends ConsumerState<EpisodeDetailScreen> {
  static const double _actionGap = 10;

  final ScrollController _scrollController = ScrollController();

  /// Measures the hero so the collapse spans exactly its height.
  final GlobalKey _heroKey = GlobalKey();

  /// Drives the floating navigation and hero collapse without rebuilding
  /// the content on every scroll frame.
  final ValueNotifier<FloatingNavScroll> _navScroll = ValueNotifier(
    FloatingNavScroll.at(offset: 0, heroExtent: 1),
  );

  /// Pending one-shot seek position from a timestamped share link.
  /// Cleared on the first user-initiated `play()` so later pause/resume
  /// cycles fall back to saved-history resume semantics.
  Duration? _pendingStartAt;

  /// Local override after manually toggling played status. Wins over the
  /// reactive provider value because the provider re-fetches by audio URL
  /// and may briefly miss when the URL doesn't round-trip cleanly. Cleared
  /// once the provider delivers a newer value, so later playback (an
  /// auto-completion or a replay) is not hidden behind it.
  EpisodeWithProgress? _localProgress;

  @override
  void initState() {
    super.initState();
    _pendingStartAt = widget.startAt;
    _scrollController.addListener(_updateNavScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateNavScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navScroll.dispose();
    super.dispose();
  }

  void _updateNavScroll() {
    if (!_scrollController.hasClients) return;
    final heroHeight = _heroKey.currentContext?.size?.height;
    _navScroll.value = FloatingNavScroll.at(
      offset: _scrollController.offset,
      heroExtent: heroHeight ?? 1,
    );
  }

  String? get _imageUrl =>
      widget.episode.primaryImage?.url ?? widget.artworkUrl;

  bool get _canShare =>
      (widget.itunesId != null && widget.episode.guid != null) ||
      widget.episode.link != null;

  @override
  Widget build(BuildContext context) {
    final view = _watchView();
    return Scaffold(
      body: Stack(
        children: [
          _buildScrollView(view),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: _navScroll,
              builder: (context, scroll, _) => _buildNavigation(view, scroll),
            ),
          ),
        ],
      ),
    );
  }

  _EpisodeView _watchView() {
    final enclosureUrl = widget.episode.enclosureUrl;
    final isPlaying =
        enclosureUrl != null &&
        ref.watch(isEpisodePlayingProvider(enclosureUrl));
    final isLoading =
        enclosureUrl != null &&
        ref.watch(isEpisodeLoadingProvider(enclosureUrl));

    // Watch reactive progress when enclosureUrl is available;
    // fall back to the constructor-provided snapshot otherwise.
    if (enclosureUrl != null) {
      ref.listen(episodeProgressProvider(enclosureUrl), (_, next) {
        final local = _localProgress;
        if (local == null || next.isLoading) return;
        // The URL lookup may resolve to another episode sharing the audio
        // URL; only this episode's own row replaces the override.
        if (next.value?.episode.id == local.episode.id) {
          setState(() => _localProgress = null);
        }
      });
    }
    final reactiveProgress = enclosureUrl != null
        ? ref.watch(episodeProgressProvider(enclosureUrl)).value
        : null;
    final progress = _localProgress ?? reactiveProgress ?? widget.progress;

    // Derive episodeId from the progress so that DB-backed actions
    // (download, queue) remain available even when the screen is opened
    // without an initial progress snapshot (e.g. from NowPlayingCard).
    final episodeId = progress?.episode.id;
    final downloadTask = episodeId != null
        ? ref.watch(episodeDownloadProvider(episodeId)).value
        : null;
    // Whether this episode is loaded in the player (any state).
    final isLoadedInPlayer =
        enclosureUrl != null &&
        ref
            .watch(audioPlayerControllerProvider)
            .maybeWhen(
              playing: (url) => url == enclosureUrl,
              paused: (url) => url == enclosureUrl,
              loading: (url) => url == enclosureUrl,
              orElse: () => false,
            );

    return _EpisodeView(
      enclosureUrl: enclosureUrl,
      isPlaying: isPlaying,
      isLoading: isLoading,
      isLoadedInPlayer: isLoadedInPlayer,
      progress: progress,
      episodeId: episodeId,
      downloadTask: downloadTask,
    );
  }

  Widget _buildNavigation(_EpisodeView view, FloatingNavScroll scroll) {
    final l10n = AppLocalizations.of(context);
    return FloatingNavigationBar(
      leading: FloatingNavButton(
        icon: Icons.arrow_back_ios_new_rounded,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: widget.episode.title,
      titleOpacity: scroll.title,
      backgroundOpacity: scroll.background,
      trailing: FloatingNavActions(
        actions: [
          if (_canShare)
            FloatingNavAction(
              icon: Icons.ios_share,
              tooltip: l10n.shareEpisode,
              onPressed: _share,
            ),
          FloatingNavAction(
            icon: Icons.more_horiz_rounded,
            tooltip: l10n.episodeMoreActions,
            onPressed: () => _showMoreMenu(view),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollView(_EpisodeView view) {
    final content =
        widget.episode.contentEncoded ??
        widget.episode.summary ??
        widget.episode.description;
    const sectionGap = EdgeInsets.only(top: Spacing.sectionGap);

    // Late layout changes (fonts, show notes expanding) can shift the
    // hero without a scroll event; resync after layout.
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
          SliverToBoxAdapter(
            child: SizedBox(height: FloatingNavigationBar.heightOf(context)),
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: _navScroll,
              builder: (context, scroll, child) =>
                  CollapsingHero(progress: scroll.hero, child: child!),
              child: KeyedSubtree(key: _heroKey, child: _buildHero()),
            ),
          ),
          SliverToBoxAdapter(child: _buildActions(view)),
          if (content.isNotBlank)
            SliverPadding(
              padding: sectionGap,
              sliver: SliverToBoxAdapter(
                child: EpisodeDescriptionCard(content: content),
              ),
            ),
          SliverPadding(
            padding: sectionGap,
            sliver: SliverToBoxAdapter(
              child: EpisodePlaybackRecord(history: view.progress?.history),
            ),
          ),
          SliverToBoxAdapter(
            child: EpisodeDevInfoWidget(feedUrl: widget.episode.sourceUrl),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: Spacing.xl + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return EpisodeDetailHero(
      episode: widget.episode,
      podcastTitle: widget.podcastTitle,
      artworkUrl: _imageUrl,
      heroTag: 'episode_artwork_${widget.episode.guid ?? widget.episode.title}',
      onPodcastTap: () => _navigateToPodcast(context),
    );
  }

  Widget _buildActions(_EpisodeView view) {
    final progress = view.progress;
    final fraction = progress?.progressPercent;
    final showsLine = view.showsPlayed || ProgressLine.isStarted(fraction);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: Column(
        children: [
          _buildActionRow(view),
          if (showsLine)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.md),
              child: EpisodeProgressStatus(
                fraction: fraction ?? 0,
                remaining: progress?.remainingDuration,
                isCompleted: view.showsPlayed,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow(_EpisodeView view) {
    final enclosureUrl = view.enclosureUrl;
    final episodeId = view.episodeId;
    return Row(
      children: [
        Expanded(
          child: EpisodePrimaryPill(
            state: view.playState,
            duration: widget.episode.duration,
            isLoading: view.isLoading,
            onPressed: enclosureUrl == null
                ? null
                : () => _onPlayPausePressed(
                    context,
                    enclosureUrl,
                    view.isPlaying,
                    restart: view.playState == EpisodePlayState.played,
                  ),
          ),
        ),
        if (episodeId != null) ...[
          const SizedBox(width: _actionGap),
          EpisodeQueueCircle(
            onPlayNext: () => _playNext(episodeId),
            onAddToEnd: () => _playLater(episodeId),
          ),
          const SizedBox(width: _actionGap),
          EpisodeDownloadCircle(
            task: view.downloadTask,
            onPressed: () => handleDownloadTap(
              context: context,
              ref: ref,
              episodeId: episodeId,
              task: view.downloadTask,
            ),
          ),
        ],
      ],
    );
  }

  void _playNext(int episodeId) {
    ref.read(queueControllerProvider.notifier).playNext(episodeId);
    _showQueueSnackBar(AppLocalizations.of(context).queuePlayingNext);
  }

  void _playLater(int episodeId) {
    ref.read(queueControllerProvider.notifier).playLater(episodeId);
    _showQueueSnackBar(AppLocalizations.of(context).queueAddedToQueue);
  }

  void _showQueueSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _share() {
    shareEpisode(
      context: context,
      ref: ref,
      itunesId: widget.itunesId,
      episodeGuid: widget.episode.guid,
      fallbackLink: widget.episode.link,
    );
  }

  /// Overflow popover. Play next, add to queue, download and share are
  /// on screen, so they are not repeated here.
  Future<void> _showMoreMenu(_EpisodeView view) {
    final l10n = AppLocalizations.of(context);
    final enclosureUrl = view.enclosureUrl;
    final task = view.downloadTask;
    final downloaded = task?.downloadStatus is DownloadStatusCompleted;
    return showActionMenu(
      context: context,
      top: FloatingNavigationBar.heightOf(context),
      sections: [
        [
          if (enclosureUrl != null)
            ActionMenuEntry(
              icon: view.isCompleted
                  ? Icons.remove_done_rounded
                  : Icons.done_rounded,
              label: view.isCompleted ? l10n.markAsUnplayed : l10n.markAsPlayed,
              onSelected: () => _togglePlayedStatus(
                enclosureUrl,
                view.isCompleted,
                knownEpisodeId: view.episodeId,
              ),
            ),
          if (downloaded)
            ActionMenuEntry(
              icon: Icons.delete_outline_rounded,
              label: l10n.removeDownload,
              destructive: true,
              onSelected: () => showDownloadDeleteConfirmation(
                context: context,
                ref: ref,
                task: task!,
              ),
            ),
        ],
        [
          ActionMenuEntry(
            icon: Icons.podcasts_rounded,
            label: l10n.episodeDetailOpenPodcast,
            onSelected: () => _navigateToPodcast(context),
          ),
        ],
      ],
    );
  }

  Future<void> _navigateToPodcast(BuildContext context) async {
    final podcastId = widget.progress?.episode.podcastId;
    if (podcastId == null) {
      // Episode not yet in DB -- look up by audio URL
      final enclosureUrl = widget.episode.enclosureUrl;
      if (enclosureUrl != null) {
        final episodeRepo = ref.read(episodeRepositoryProvider);
        final dbEpisode = await episodeRepo.getByAudioUrl(enclosureUrl);
        if (dbEpisode != null && context.mounted) {
          return _pushPodcastDetail(context, podcastId: dbEpisode.podcastId);
        }
      }

      // Fallback: navigate via deep link when itunesId is available
      if (widget.itunesId != null && context.mounted) {
        final path = AppRoutes.deepLinkPodcast.replaceFirst(
          ':itunesId',
          Uri.encodeComponent(widget.itunesId!),
        );
        context.push(path);
      }
      return;
    }
    return _pushPodcastDetail(context, podcastId: podcastId);
  }

  Future<void> _pushPodcastDetail(
    BuildContext context, {
    required int podcastId,
  }) async {
    final podcast = await lookupPodcastForEpisode(
      subscriptionRepo: ref.read(subscriptionRepositoryProvider),
      podcastId: podcastId,
      podcastTitle: widget.podcastTitle,
    );
    if (podcast == null || !context.mounted) return;

    context.push('${AppRoutes.library}/podcast/${podcast.id}', extra: podcast);
  }

  void _recordStationPlay() {
    if (widget.stationId case final id?) recordStationPlay(ref, id);
  }

  /// [restart] plays a played episode again from the start ("Play
  /// again"); a shared timestamp still wins.
  Future<void> _onPlayPausePressed(
    BuildContext context,
    String url,
    bool isPlaying, {
    bool restart = false,
  }) async {
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    if (isPlaying) {
      controller.pause();
      return;
    }

    if (controller.isLoaded(url)) {
      // Honour a pending `?t=` deep-link timestamp even when the episode is
      // already loaded in the player — otherwise resume falls back to the
      // in-memory position and the shared timestamp is silently ignored.
      final startAt = _pendingStartAt;
      if (startAt != null) {
        // Observe the controller's lifecycle stream for the synchronous
        // SeekLifecycle event that only fires when seek() actually
        // committed. This avoids racing the progress provider, which can
        // lag behind an in-flight seek.
        var seekCommitted = false;
        final subscription = controller.lifecycleEvents.listen((event) {
          if (event is SeekLifecycle) seekCommitted = true;
        });
        try {
          await controller.seek(startAt);
        } finally {
          await subscription.cancel();
        }
        if (seekCommitted) {
          _pendingStartAt = null;
        }
      } else if (restart) {
        // A player parked at the end would advance to the next queued
        // episode on resume; seeking back replays this one instead.
        await controller.seek(Duration.zero);
      }
      _recordStationPlay();
      controller.resume();
      return;
    }

    final episodeId = widget.progress?.episode.id;
    if (episodeId != null) {
      final queueService = ref.read(queueServiceProvider);
      final shouldConfirm = await queueService.shouldConfirmAdhocReplace();

      if (shouldConfirm) {
        if (!context.mounted) return;
        final confirmed = await _showReplaceQueueDialog(context);
        if (!confirmed) return;
      }

      await queueService.createAdhocQueue(
        startingEpisodeId: episodeId,
        sourceContext: widget.podcastTitle,
      );
    }

    // Only now, past the replace-queue confirmation: a cancelled play must
    // not move the station up the Library.
    _recordStationPlay();

    // Kick off playback without awaiting: just_audio's play() future only
    // completes when the session pauses/ends, so awaiting would leave the
    // pending timestamp armed for the entire listening session and re-fire
    // on the next pause/resume tap.
    final startAt = _pendingStartAt;
    unawaited(
      _startPlaybackAndClearPending(
        controller: controller,
        url: url,
        startAt: startAt,
      ),
    );
  }

  /// Drives [AudioPlayerController.play] to completion and clears the
  /// pending deep-link timestamp once the controller transitions to a
  /// terminal running state. If playback errors out before reaching
  /// `playing`/`paused`, the timestamp is preserved so a retry honours
  /// the shared `?t=` target.
  Future<void> _startPlaybackAndClearPending({
    required AudioPlayerController controller,
    required String url,
    required Duration? startAt,
  }) async {
    // Subscribe before calling play() so we don't miss the transition.
    final completer = Completer<bool>();
    late final ProviderSubscription<PlaybackState> subscription;
    subscription = ref.listenManual<PlaybackState>(
      audioPlayerControllerProvider,
      (previous, next) {
        if (completer.isCompleted) return;
        // Only `playing` is a definitive success signal. just_audio can
        // briefly emit `paused` as an intermediate state right after
        // setUrl() and before _player.play() runs; treating that as
        // success would clear the pending deep-link timestamp even when
        // playback still fails afterwards.
        next.maybeWhen(
          playing: (episodeUrl) {
            if (episodeUrl == url) completer.complete(true);
          },
          error: (_) => completer.complete(false),
          orElse: () {},
        );
      },
    );

    try {
      // Source: a tap on the episode-detail screen is reached from search
      // results or in-app deep links. Pick `search` for the conservative
      // default; the deep-link path sets its own source elsewhere.
      controller.markPlaySource(PlaySource.search);
      unawaited(
        controller.play(
          url,
          metadata: NowPlayingInfo(
            episodeUrl: url,
            episodeTitle: widget.episode.title,
            podcastTitle: widget.podcastTitle,
            artworkUrl: widget.artworkUrl ?? widget.episode.primaryImage?.url,
            totalDuration: widget.episode.duration,
            itunesId: widget.itunesId,
            episodeGuid: widget.episode.guid,
            feedUrl: widget.episode.sourceUrl,
          ),
          startAt: startAt,
        ),
      );

      // Bound the wait so we don't leak the subscription if something
      // prevents the expected transition from ever happening.
      final didStart = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
      if (didStart && mounted) {
        _pendingStartAt = null;
      }
    } finally {
      subscription.close();
    }
  }

  Future<bool> _showReplaceQueueDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.episodeReplaceQueueTitle),
        content: Text(l10n.episodeReplaceQueueContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.episodeReplace),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _togglePlayedStatus(
    String audioUrl,
    bool isCurrentlyCompleted, {
    int? knownEpisodeId,
  }) async {
    var episodeId = knownEpisodeId;
    if (episodeId == null) {
      final episodeRepo = ref.read(episodeRepositoryProvider);
      final ep = await episodeRepo.getByAudioUrl(audioUrl);
      if (ep == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Episode not yet saved'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      episodeId = ep.id;
    }

    final historyService = ref.read(playbackHistoryServiceProvider);
    if (isCurrentlyCompleted) {
      await historyService.markIncomplete(episodeId);
    } else {
      await historyService.markCompleted(episodeId);
    }

    // Drop the cached value so any other watchers refetch.
    ref.invalidate(episodeProgressProvider(audioUrl));

    // Fetch the canonical row by id (avoids audio-URL lookup mismatches)
    // and stash it locally so this screen rebuilds immediately even when
    // the provider can't resolve the same URL we just toggled.
    final episodeRepo = ref.read(episodeRepositoryProvider);
    final historyRepo = ref.read(playbackHistoryRepositoryProvider);
    final freshEpisode = await episodeRepo.getById(episodeId);
    if (freshEpisode == null || !mounted) return;
    final freshHistory = await historyRepo.getByEpisodeId(episodeId);
    if (!mounted) return;
    setState(() {
      _localProgress = EpisodeWithProgress(
        episode: freshEpisode,
        history: freshHistory,
      );
    });
  }
}

/// Watched playback, progress and download state for one build.
class _EpisodeView {
  const _EpisodeView({
    required this.enclosureUrl,
    required this.isPlaying,
    required this.isLoading,
    required this.isLoadedInPlayer,
    required this.progress,
    required this.episodeId,
    required this.downloadTask,
  });

  final String? enclosureUrl;
  final bool isPlaying;
  final bool isLoading;
  final bool isLoadedInPlayer;
  final EpisodeWithProgress? progress;
  final int? episodeId;
  final DownloadTask? downloadTask;

  /// Played status, also while the episode is being replayed (menus).
  bool get isCompleted => progress?.isCompleted ?? false;

  /// Whether the pill and progress line show the played look; a replay
  /// shows its own progress instead (FR 04).
  bool get showsPlayed => showsPlayedState(progress, isPlaying: isPlaying);

  EpisodePlayState get playState {
    if (isPlaying) return EpisodePlayState.playing;
    if (showsPlayed) return EpisodePlayState.played;
    if (isLoadedInPlayer || (progress?.isInProgress ?? false)) {
      return EpisodePlayState.inProgress;
    }
    return EpisodePlayState.unplayed;
  }
}
