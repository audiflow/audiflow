import 'dart:async';
import 'dart:convert';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../helpers/chapter_seek_bar_segments.dart';
import '../../helpers/playback_time_format.dart';
import '../../helpers/podcast_lookup.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../../services/audio_route_channel.dart';
import '../controllers/seek_undo_controller.dart';
import '../widgets/audio_output_picker_button.dart';
import '../widgets/current_chapter_row.dart';
import '../widgets/player_action_row.dart';
import '../widgets/seek_undo_overlay.dart';
import '../widgets/sleep_timer_countdown_format.dart';
import '../widgets/transcript_timeline_view.dart';

/// Full player screen presented as a Cupertino sheet.
///
/// Shows playback controls, progress bar, and a second, transcript page
/// when the current episode's transcript has loaded.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

// TickerProviderStateMixin, not the single variant: the tab controller is
// recreated when transcript availability resolves after the first frame.
class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  bool _isSeeking = false;
  bool _wasPlayingBeforeSeek = false;
  TabController? _tabController;

  void _beginSeek(bool wasPlaying) {
    setState(() {
      _isSeeking = true;
      _wasPlayingBeforeSeek = wasPlaying;
    });
  }

  Future<void> _endSeek() async {
    // Allow player state to stabilize after seek
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _isSeeking = false);
  }

  void _ensureTabController({required bool hasTranscript}) {
    final tabCount = hasTranscript ? 2 : 1;
    if (_tabController?.length == tabCount) return;

    _tabController?.dispose();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  /// Last episode shown, kept so the exit animation has something to draw.
  NowPlayingInfo? _lastNowPlaying;

  /// Dismisses the sheet once nothing is left to show.
  ///
  /// The service clears now-playing when the queue is exhausted or playback
  /// is stopped outright; advancing to the next queued episode replaces the
  /// value instead, so the sheet stays open for that case.
  ///
  /// Routes stacked above the sheet (a picker, a dialog) go with it: the
  /// listener fires once, and a sheet left behind would show nothing. A sheet
  /// that is already being popped is left alone, since popping again would
  /// hit the route underneath.
  void _dismissWhenNothingPlaying(NowPlayingInfo? _, NowPlayingInfo? next) {
    if (next != null || !mounted) return;
    final sheetRoute = ModalRoute.of(context);
    if (sheetRoute == null || !sheetRoute.isActive) return;

    var reachedSheet = false;
    Navigator.of(context, rootNavigator: true).popUntil((route) {
      if (reachedSheet) return true;
      reachedSheet = route == sheetRoute;
      return false;
    });
  }

  /// While the sheet slides out after now-playing was cleared, keep drawing
  /// the last episode instead of the empty placeholder.
  NowPlayingInfo? _nowPlayingWhileDismissing(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null || route.isActive) return null;
    return _lastNowPlaying;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NowPlayingInfo?>(
      nowPlayingControllerProvider,
      _dismissWhenNothingPlaying,
    );

    final l10n = AppLocalizations.of(context);
    final nowPlaying =
        ref.watch(nowPlayingControllerProvider) ??
        _nowPlayingWhileDismissing(context);
    _lastNowPlaying = nowPlaying ?? _lastNowPlaying;
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final liveProgress = ref.watch(playbackProgressProvider);
    // Fall back to saved position/duration when no audio is loaded (post-restore).
    // The stream emits 0/0 when idle, so check duration > 0 for real data.
    final hasLiveData =
        liveProgress != null && 0 < liveProgress.duration.inMilliseconds;
    final progress = hasLiveData
        ? liveProgress
        : (nowPlaying?.savedPosition != null
              ? PlaybackProgress(
                  position: nowPlaying!.savedPosition!,
                  duration: nowPlaying.totalDuration ?? Duration.zero,
                  bufferedPosition: Duration.zero,
                )
              : null);
    final appSettingsRepo = ref.watch(appSettingsRepositoryProvider);
    final showOutputPicker =
        ref.watch(audioOutputPickerAvailableProvider).value ?? false;

    final isPlaying = playbackState is PlaybackPlaying;
    final isLoading = playbackState is PlaybackLoading;

    // Preserve play/pause state during seeking
    final displayIsPlaying = _isSeeking ? _wasPlayingBeforeSeek : isPlaying;
    final displayIsLoading = _isSeeking ? false : isLoading;

    if (nowPlaying == null) {
      return Scaffold(body: Center(child: Text(l10n.playerNoAudio)));
    }

    final episodeId = nowPlaying.episode?.id;
    // The transcript page exists only once its content has loaded: a feed
    // can declare a file that turns out empty or unreachable, and offering
    // the page before then would lead to a blank one. While the fetch runs
    // the player stays on a single page.
    final transcriptId = episodeId == null
        ? null
        : ref.watch(usableTranscriptIdProvider(episodeId)).value;
    final hasTranscriptTab = transcriptId != null;

    // Ensure tab controller exists (short-circuits if tab count unchanged)
    _ensureTabController(hasTranscript: hasTranscriptTab);

    return ArtworkGround(
      url: nowPlaying.artworkUrl,
      builder: (context, ground) => Theme(
        data: nowPlayingTheme(ground),
        child: Scaffold(
          backgroundColor: ground,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: LayoutConstants.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const _DragHandle(),
                      _PlayerHeader(
                        playingFrom:
                            ref.watch(
                              queueControllerProvider.select(
                                (queue) => playingFromContext(
                                  queue.value,
                                  nowPlaying.episodeUrl,
                                ),
                              ),
                            ) ??
                            nowPlaying.podcastTitle,
                        onMore: (anchor) => _showMoreMenu(
                          nowPlaying,
                          anchor: anchor,
                          hasTranscript: hasTranscriptTab,
                        ),
                      ),
                      Expanded(
                        child: _PlayerTabBody(
                          tabController: _tabController!,
                          transcriptId: transcriptId,
                          episodeId: episodeId,
                          artworkUrl: nowPlaying.artworkUrl,
                          episodeTitle: nowPlaying.episodeTitle,
                          podcastTitle: nowPlaying.podcastTitle,
                          onEpisodeTitleTap: _canNavigateToEpisode(nowPlaying)
                              ? () => _navigateToEpisode(nowPlaying)
                              : null,
                          onPodcastTitleTap: nowPlaying.episode != null
                              ? () => _navigateToPodcast(
                                  nowPlaying.episode!,
                                  nowPlaying.podcastTitle,
                                )
                              : null,
                          onChapterSelected: (position) => _handleSkip(
                            () => ref
                                .read(seekUndoControllerProvider.notifier)
                                .seekWithUndo(position),
                            isPlaying,
                          ),
                          onSeekUndo: () => _handleSkip(
                            ref
                                .read(seekUndoControllerProvider.notifier)
                                .goBack,
                            isPlaying,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _PlayerProgressBar(
                        progress: progress,
                        onSeekStart: () => _beginSeek(isPlaying),
                        onSeekEnd: _endSeek,
                      ),
                      const SizedBox(height: 16),
                      _PlayerControls(
                        isPlaying: displayIsPlaying,
                        isLoading: displayIsLoading,
                        skipForwardSeconds: appSettingsRepo
                            .getSkipForwardSeconds(),
                        skipBackwardSeconds: appSettingsRepo
                            .getSkipBackwardSeconds(),
                        onSkipBackward: () => _handleSkip(
                          ref
                              .read(audioPlayerControllerProvider.notifier)
                              .skipBackward,
                          isPlaying,
                        ),
                        onSkipForward: () => _handleSkip(
                          ref
                              .read(audioPlayerControllerProvider.notifier)
                              .skipForward,
                          isPlaying,
                        ),
                      ),
                      // The action row's buttons carry their own inner padding,
                      // so 8 pt here makes the visible gap below the play button
                      // match the one above it, below the time labels.
                      const SizedBox(height: 16),
                      _TranslucentBar(
                        child: PlayerActionRow(
                          outputPicker: showOutputPicker
                              ? const AudioOutputPickerButton()
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Switches pages on the controller current at selection time: the
  /// episode may have advanced (and the controller been replaced, or the
  /// transcript page dropped) while the menu was open.
  void _showPage(int index) {
    final tabs = _tabController;
    if (!mounted || tabs == null || tabs.length <= index) return;
    tabs.animateTo(index);
  }

  /// Player overflow: page switch (when there is a transcript), links out
  /// to the episode and podcast, and sharing the episode.
  ///
  /// [anchor] is the `…` button's context: the menu opens below it and the
  /// share sheet points at it on iPad.
  Future<void> _showMoreMenu(
    NowPlayingInfo nowPlaying, {
    required BuildContext anchor,
    required bool hasTranscript,
  }) {
    final l10n = AppLocalizations.of(context);
    final tabs = _tabController;
    final onTranscript = tabs != null && tabs.index == 1;
    final episode = nowPlaying.episode;
    return showActionMenu(
      context: context,
      top: _menuTopBelow(anchor),
      sections: [
        [
          if (hasTranscript && tabs != null)
            onTranscript
                ? ActionMenuEntry(
                    icon: Symbols.album,
                    label: l10n.playerTabNowPlaying,
                    onSelected: () => _showPage(0),
                  )
                : ActionMenuEntry(
                    icon: Symbols.subtitles,
                    label: l10n.playerTabTranscript,
                    onSelected: () => _showPage(1),
                  ),
        ],
        [
          if (_canNavigateToEpisode(nowPlaying))
            ActionMenuEntry(
              icon: Icons.info_outline,
              label: l10n.playerEpisodeDetails,
              onSelected: () => _navigateToEpisode(nowPlaying),
            ),
          if (episode != null)
            ActionMenuEntry(
              icon: Symbols.podcasts,
              label: l10n.playerGoToPodcast,
              onSelected: () =>
                  _navigateToPodcast(episode, nowPlaying.podcastTitle),
            ),
        ],
        [
          if (_canShare(nowPlaying))
            ActionMenuEntry(
              icon: Icons.ios_share,
              label: l10n.shareEpisode,
              onSelected: () => _share(nowPlaying, anchor),
            ),
        ],
      ],
    );
  }

  /// Places the menu where the other screens' `…` menus open: at the bottom
  /// of a floating navigation bar centred on the button. The sheet drops
  /// the status bar inset from its MediaQuery, so a padding-based offset
  /// would land the menu over the Dynamic Island.
  double _menuTopBelow(BuildContext anchor) {
    final box = anchor.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return FloatingNavigationBar.heightOf(context);
    }
    final center = box.localToGlobal(box.size.center(Offset.zero));
    return center.dy + FloatingNavigationBar.barHeight / 2;
  }

  bool _canShare(NowPlayingInfo nowPlaying) {
    final guid = nowPlaying.episodeGuid ?? nowPlaying.episode?.guid;
    final hasDeepLink =
        nowPlaying.itunesId != null && guid != null && guid.isNotEmpty;
    return hasDeepLink || nowPlaying.episode?.link != null;
  }

  void _share(NowPlayingInfo nowPlaying, BuildContext anchor) {
    if (!anchor.mounted) return;
    shareEpisode(
      context: anchor,
      ref: ref,
      itunesId: nowPlaying.itunesId,
      episodeGuid: nowPlaying.episodeGuid ?? nowPlaying.episode?.guid,
      fallbackLink: nowPlaying.episode?.link,
    );
  }

  Future<void> _handleSkip(
    Future<void> Function() skipAction,
    bool wasPlaying,
  ) async {
    _beginSeek(wasPlaying);
    // A failed seek must still release the guard, or the play/pause icon
    // stays frozen.
    try {
      await skipAction();
    } finally {
      await _endSeek();
    }
  }

  Future<void> _navigateToPodcast(Episode episode, String podcastTitle) async {
    final podcast = await _lookupPodcast(episode.podcastId, podcastTitle);
    if (podcast == null || !mounted) return;

    _popSheetAndPush(
      '${AppRoutes.library}/podcast/${podcast.id}',
      extra: podcast,
    );
  }

  bool _canNavigateToEpisode(NowPlayingInfo nowPlaying) {
    if (nowPlaying.episode != null) return true;
    final guid = nowPlaying.episodeGuid;
    return nowPlaying.itunesId != null && guid != null && guid.isNotEmpty;
  }

  Future<void> _navigateToEpisode(NowPlayingInfo nowPlaying) async {
    final episode = nowPlaying.episode;

    // Subscribed path: resolve the subscription and push the library route
    // with full extras so progress, share, and DB-backed actions all wire up.
    if (episode != null) {
      final podcast = await _lookupPodcast(
        episode.podcastId,
        nowPlaying.podcastTitle,
      );
      if (!mounted) return;
      if (podcast != null) {
        final episodePath = AppRoutes.episodeDetail.replaceAll(
          ':episodeGuid',
          Uri.encodeComponent(episode.guid),
        );
        _popSheetAndPush(
          '${AppRoutes.library}/podcast/${podcast.id}/$episodePath',
          extra: <String, dynamic>{
            'episode': episode.toPodcastItem(feedUrl: podcast.feedUrl ?? ''),
            'podcastTitle': nowPlaying.podcastTitle,
            'artworkUrl': nowPlaying.artworkUrl,
            'itunesId': podcast.id,
          },
        );
        return;
      }
    }

    // Unsubscribed fallback: route through the universal deep link so the
    // detail screen can resolve the episode from iTunes + feed when we have
    // no local podcast record. The deep-link resolver decodes the GUID
    // segment as base64url (no padding), so encode it the same way here.
    final itunesId = nowPlaying.itunesId;
    final guid = nowPlaying.episodeGuid ?? episode?.guid;
    if (itunesId != null && guid != null && guid.isNotEmpty && mounted) {
      final encodedGuid = base64Url
          .encode(utf8.encode(guid))
          .replaceAll('=', '');
      _popSheetAndPush('/p/$itunesId/e/$encodedGuid');
    }
  }

  void _popSheetAndPush(String path, {Object? extra}) {
    // The queue can end while a lookup above is awaited, and the listener
    // then pops the sheet first; a second pop would hit the route underneath.
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final router = GoRouter.of(context);
    CupertinoSheetRoute.popSheet(context);
    router.push(path, extra: extra);
  }

  Future<Podcast?> _lookupPodcast(int podcastId, String podcastTitle) async {
    final result = await lookupPodcastForEpisode(
      subscriptionRepo: ref.read(subscriptionRepositoryProvider),
      podcastId: podcastId,
      podcastTitle: podcastTitle,
    );
    if (!mounted) return null;
    return result;
  }
}

/// Close chevron, the context the episode plays from, and the overflow.
class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.playingFrom, required this.onMore});

  final String playingFrom;

  /// Receives the `…` button's context, to anchor the menu below it.
  final ValueChanged<BuildContext> onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.playerCloseLabel,
            icon: const Icon(Symbols.keyboard_arrow_down),
            color: colors.ink,
            onPressed: () => CupertinoSheetRoute.popSheet(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.playerPlayingFrom,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
                Text(
                  playingFrom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(color: colors.ink),
                ),
              ],
            ),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: l10n.playerMoreTooltip,
              icon: const Icon(Icons.more_horiz_rounded),
              color: colors.ink,
              onPressed: () => onMore(buttonContext),
            ),
          ),
        ],
      ),
    );
  }
}

/// The translucent strip holding speed, output route, and sleep timer.
class _TranslucentBar extends StatelessWidget {
  const _TranslucentBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NowPlayingColors.foreground.withValues(alpha: 0.1),
        borderRadius: AppBorders.card,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
        child: child,
      ),
    );
  }
}

class _PlayerTabBody extends StatelessWidget {
  const _PlayerTabBody({
    required this.tabController,
    required this.transcriptId,
    required this.episodeId,
    required this.artworkUrl,
    required this.episodeTitle,
    required this.podcastTitle,
    required this.onChapterSelected,
    required this.onSeekUndo,
    this.onEpisodeTitleTap,
    this.onPodcastTitleTap,
  });

  /// Smallest height the artwork shrinks to before the page scrolls.
  static const double artworkMinHeight = 160;

  final TabController tabController;

  /// Stored transcript to show on the second page; null for a single page.
  final int? transcriptId;
  final int? episodeId;
  final String? artworkUrl;
  final String episodeTitle;
  final String podcastTitle;
  final VoidCallback? onEpisodeTitleTap;
  final VoidCallback? onPodcastTitleTap;
  final ValueChanged<Duration> onChapterSelected;
  final VoidCallback onSeekUndo;

  @override
  Widget build(BuildContext context) {
    // The artwork takes whatever height is left and shrinks to make room for
    // the text below. SliverFillRemaining sizes the column to at least its
    // intrinsic height, and the tight 160 box reports exactly 160 as the
    // artwork's intrinsic height (at layout the Expanded's tighter height
    // still wins), so the artwork never drops below 160 and the page
    // scrolls instead. Clamping physics, and not being the primary scroll
    // view, keep it from grabbing drags when everything fits, so the sheet
    // can still be swiped down.
    final nowPlayingContent = CustomScrollView(
      primary: false,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                    height: artworkMinHeight,
                  ),
                  child: Center(
                    child: _PlayerArtwork(
                      artworkUrl: artworkUrl,
                      onSeekUndo: onSeekUndo,
                    ),
                  ),
                ),
              ),
              _PlayerInfo(
                episodeTitle: episodeTitle,
                podcastTitle: podcastTitle,
                onEpisodeTitleTap: onEpisodeTitleTap,
                onPodcastTitleTap: onPodcastTitleTap,
              ),
              CurrentChapterRow(onChapterSelected: onChapterSelected),
            ],
          ),
        ),
      ],
    );

    final transcript = transcriptId;
    final episode = episodeId;
    if (transcript == null || episode == null) return nowPlayingContent;

    return TabBarView(
      controller: tabController,
      children: [
        nowPlayingContent,
        TranscriptTimelineView(transcriptId: transcript, episodeId: episode),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 5,
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }
}

class _PlayerArtwork extends StatelessWidget {
  const _PlayerArtwork({required this.onSeekUndo, this.artworkUrl});

  /// Artwork edge on a regular phone (redesign 4.5); smaller screens
  /// shrink it to the space left.
  static const double maxSize = 342;

  final String? artworkUrl;
  final VoidCallback onSeekUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // The pill sits beside, not inside, the image semantics node so screen
    // readers reach its buttons.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: AppBorders.artworkHero,
            boxShadow: AppShadows.floating,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                image: true,
                label: l10n.playerArtworkLabel,
                child: ClipRRect(
                  borderRadius: AppBorders.artworkHero,
                  child: artworkUrl != null
                      ? ArtworkImage(
                          url: artworkUrl!,
                          loading: const SizedBox.shrink(),
                          placeholder: _Placeholder(colorScheme: colorScheme),
                        )
                      : _Placeholder(colorScheme: colorScheme),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SeekUndoOverlay(onGoBack: onSeekUndo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Symbols.podcasts,
        color: colorScheme.onSurfaceVariant,
        size: 100,
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({
    required this.episodeTitle,
    required this.podcastTitle,
    this.onEpisodeTitleTap,
    this.onPodcastTitleTap,
  });

  final String episodeTitle;
  final String podcastTitle;
  final VoidCallback? onEpisodeTitleTap;
  final VoidCallback? onPodcastTitleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: '$episodeTitle by $podcastTitle',
      child: SelectionArea(
        child: Column(
          children: [
            ExcludeSemantics(
              child: GestureDetector(
                onTap: onEpisodeTitleTap,
                child: Text(
                  episodeTitle,
                  style: AppTextStyles.heroTitle.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: GestureDetector(
                onTap: onPodcastTitleTap,
                child: Text(
                  podcastTitle,
                  style: AppTextStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerProgressBar extends ConsumerStatefulWidget {
  const _PlayerProgressBar({this.progress, this.onSeekStart, this.onSeekEnd});

  final PlaybackProgress? progress;
  final VoidCallback? onSeekStart;
  final Future<void> Function()? onSeekEnd;

  @override
  ConsumerState<_PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<_PlayerProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  late bool _showRemainingTime;
  // Last value known to be persisted; a failed write reverts to it.
  late bool _savedShowRemainingTime;
  // Writes run one after another so they finish in tap order, which keeps
  // _savedShowRemainingTime accurate.
  Future<void> _labelWrites = Future<void>.value();
  // Bumped per toggle so only the latest write may revert the label.
  int _labelWriteSequence = 0;
  // While a sleep timer runs, the trailing label shows its countdown unless
  // the user tapped back to the time label. Session-only; a newly armed
  // timer shows the countdown again.
  bool _showSleepCountdown = true;

  @override
  void initState() {
    super.initState();
    _showRemainingTime = _savedShowRemainingTime = ref
        .read(appSettingsRepositoryProvider)
        .getShowRemainingTime();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final duration = progress?.duration;
    final displayValue = _isDragging ? _dragValue : (progress?.progress ?? 0.0);
    final displayPosition = _isDragging
        ? _computeDragPosition(duration)
        : progress?.position;
    // unwrapPrevious: while a new episode's chapters load, do not split the
    // bar with the previous episode's chapters.
    final chapters =
        ref.watch(currentEpisodeChaptersProvider).unwrapPrevious().value ?? [];

    final l10n = AppLocalizations.of(context);
    ref.listen(sleepTimerControllerProvider.select((state) => state.config), (
      previous,
      next,
    ) {
      if (isNewSleepTimerArm(previous, next)) {
        setState(() => _showSleepCountdown = true);
      }
    });
    final sleepConfig = ref.watch(
      sleepTimerControllerProvider.select((state) => state.config),
    );
    final sleepLeft = ref.watch(sleepTimerTimeLeftProvider);
    // Scrubbing needs position feedback, so the time label comes back
    // until the drag is released.
    final sleepCountdown = _showSleepCountdown && !_isDragging
        ? sleepLeft
        : null;
    return PlayerSeekBar(
      value: displayValue,
      leadingLabel: formatPlaybackTime(displayPosition),
      trailingLabel: sleepCountdown != null
          ? formatSleepTimerCountdown(sleepCountdown)
          : _timeTrailingLabel(displayPosition, duration),
      trailingLabelIcon: sleepCountdown != null
          ? Icon(
              Symbols.sleep,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      trailingLabelSemanticsLabel: sleepCountdown != null
          ? sleepTimerSemanticsLabel(
              sleepConfig,
              sleepCountdown,
              l10n,
              includeMode: false,
            )
          : null,
      segments: chapterSeekBarSegments(chapters, duration ?? Duration.zero),
      tooltipBuilder: (context, value) =>
          _buildTooltip(chapters, _positionAt(value, null)),
      semanticValueFormatter: (value) =>
          '${formatPlaybackTime(_positionAt(value, displayPosition))}'
          ' of ${formatPlaybackTime(duration)}',
      // A seek is dropped while the duration is unknown, so screen readers
      // must not be offered steps that would never move the position.
      adjustable: duration != null && duration != Duration.zero,
      scrubSpeedLabels: {
        ScrubSpeed.half: l10n.playerScrubSpeedHalf,
        ScrubSpeed.quarter: l10n.playerScrubSpeedQuarter,
        ScrubSpeed.fine: l10n.playerScrubSpeedFine,
      },
      onChangeStart: (value) {
        setState(() {
          _isDragging = true;
          _dragValue = value;
        });
        widget.onSeekStart?.call();
      },
      onChanged: (value) => setState(() => _dragValue = value),
      onChangeEnd: _handleSeekEnd,
      // While a countdown is available the tap switches between it and the
      // time label, leaving the remaining/total choice untouched.
      onTrailingLabelTap: sleepLeft != null
          ? () => setState(() => _showSleepCountdown = !_showSleepCountdown)
          : _toggleTrailingLabel,
    );
  }

  String _timeTrailingLabel(Duration? position, Duration? duration) {
    return _showRemainingTime
        ? _formatRemaining(position, duration)
        : formatPlaybackTime(duration);
  }

  @override
  void dispose() {
    // The bar can vanish mid-drag (e.g. now-playing cleared). Release the
    // parent's seek guard so the play/pause icon does not stay frozen; the
    // abandoned drag itself is not committed.
    if (_isDragging) unawaited(widget.onSeekEnd?.call());
    super.dispose();
  }

  /// Chapter title (when the position is inside a chapter) over the scrub
  /// position.
  Widget _buildTooltip(List<EpisodeChapter> chapters, Duration? position) {
    final index = position == null ? null : chapterIndexAt(chapters, position);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index != null)
            Text(
              chapters[index].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          Text(formatPlaybackTime(position)),
        ],
      ),
    );
  }

  void _toggleTrailingLabel() {
    final next = !_showRemainingTime;
    final sequence = ++_labelWriteSequence;
    final settings = ref.read(appSettingsRepositoryProvider);
    final logger = ref.read(namedLoggerProvider('Player'));
    setState(() => _showRemainingTime = next);
    _labelWrites = _labelWrites.then(
      (_) => _persistTrailingLabel(next, sequence, settings, logger),
    );
  }

  Future<void> _persistTrailingLabel(
    bool value,
    int sequence,
    AppSettingsRepository settings,
    Logger logger,
  ) async {
    try {
      await settings.setShowRemainingTime(value);
      _savedShowRemainingTime = value;
    } on Object catch (e, stack) {
      logger.w('Failed to save showRemainingTime', error: e, stackTrace: stack);
      // A queued newer toggle decides the label; otherwise fall back to the
      // last saved choice so the label matches what the next launch shows.
      if (!mounted || sequence != _labelWriteSequence) return;
      setState(() => _showRemainingTime = _savedShowRemainingTime);
    }
  }

  Future<void> _handleSeekEnd(double value) async {
    final duration = widget.progress?.duration ?? Duration.zero;
    // A failed seek must still release the parent's seek guard and end the
    // drag, or the play/pause icon and the bar would stay frozen.
    try {
      // Duration unknown -- cannot compute a meaningful position.
      if (duration != Duration.zero) {
        await ref
            .read(seekUndoControllerProvider.notifier)
            .seekWithUndo(
              Duration(milliseconds: (duration.inMilliseconds * value).round()),
            );
      }
    } finally {
      try {
        await widget.onSeekEnd?.call();
      } finally {
        if (mounted) setState(() => _isDragging = false);
      }
    }
  }

  /// Position at track fraction [value]; falls back to [fallback] when the
  /// duration is unknown and a fraction cannot be mapped to a time.
  Duration? _positionAt(double value, Duration? fallback) {
    final duration = widget.progress?.duration;
    if (duration == null || duration == Duration.zero) return fallback;
    return Duration(milliseconds: (duration.inMilliseconds * value).round());
  }

  Duration? _computeDragPosition(Duration? duration) {
    if (duration == null) return null;
    return Duration(
      milliseconds: (duration.inMilliseconds * _dragValue).round(),
    );
  }

  // Remaining media time; deliberately not scaled by playback speed.
  String _formatRemaining(Duration? position, Duration? duration) {
    // A zero duration means "unknown" (e.g. restored session without metadata).
    if (position == null || duration == null || duration == Duration.zero) {
      return '--:--';
    }
    final remaining = duration - position;
    return '-${formatPlaybackTime(remaining.isNegative ? Duration.zero : remaining)}';
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.isLoading,
    required this.skipForwardSeconds,
    required this.skipBackwardSeconds,
    required this.onSkipBackward,
    required this.onSkipForward,
  });

  final bool isPlaying;
  final bool isLoading;
  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  final VoidCallback onSkipBackward;
  final VoidCallback onSkipForward;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          label: l10n.playerRewindLabel(skipBackwardSeconds),
          child: IconButton(
            icon: SkipDurationIcon(
              seconds: skipBackwardSeconds,
              isForward: false,
              size: 36,
            ),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: onSkipBackward,
          ),
        ),
        const SizedBox(width: 24),
        _PlayerPlayPauseButton(isPlaying: isPlaying, isLoading: isLoading),
        const SizedBox(width: 24),
        Semantics(
          button: true,
          label: l10n.playerForwardLabel(skipForwardSeconds),
          child: IconButton(
            icon: SkipDurationIcon(
              seconds: skipForwardSeconds,
              isForward: true,
              size: 36,
            ),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: onSkipForward,
          ),
        ),
      ],
    );
  }
}

class _PlayerPlayPauseButton extends ConsumerWidget {
  const _PlayerPlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
  });

  /// White circle on the ground (redesign 2.2, 4.5).
  static const double size = 80;

  final bool isPlaying;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Semantics(
        label: l10n.playerLoadingLabel,
        child: const SizedBox(
          width: size,
          height: size,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: isPlaying ? l10n.playerPauseLabel : l10n.playerPlayLabel,
      child: IconButton.filled(
        icon: Icon(isPlaying ? Symbols.pause : Symbols.play_arrow, fill: 1),
        iconSize: 44,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(size, size),
        ),
        onPressed: () {
          final controller = ref.read(audioPlayerControllerProvider.notifier);
          if (isPlaying) {
            controller.pause();
          } else if (controller.currentUrl != null) {
            controller.resume();
          } else {
            // After restore: no audio loaded yet, start full playback.
            final nowPlaying = ref.read(nowPlayingControllerProvider);
            if (nowPlaying != null) {
              // Restore-after-restart tap; treat as deeplink for source.
              controller
                ..markPlaySource(PlaySource.deeplink)
                ..play(nowPlaying.episodeUrl, metadata: nowPlaying);
            }
          }
        },
      ),
    );
  }
}

/// Where the episode at [episodeUrl] plays from: the source of its own
/// ad hoc queue entry (e.g. a season), or null when it was not started
/// from one (manually queued, or already taken off the queue), in which
/// case the header falls back to the podcast.
@visibleForTesting
String? playingFromContext(PlaybackQueue? queue, String episodeUrl) {
  if (queue == null) return null;
  for (final item in queue.allItems) {
    if (item.episode.audioUrl != episodeUrl) continue;
    return item.queueItem.isAdhoc ? item.queueItem.sourceContext : null;
  }
  return null;
}
