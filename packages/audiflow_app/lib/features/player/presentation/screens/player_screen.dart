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
import '../../services/audio_route_channel.dart';
import '../widgets/audio_output_picker_button.dart';
import '../widgets/current_chapter_row.dart';
import '../widgets/player_action_row.dart';
import '../widgets/transcript_tab.dart';

/// Full player screen presented as a Cupertino sheet.
///
/// Shows playback controls, progress bar, and optionally a transcript
/// tab when the current episode has transcript or chapter data.
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
    final hasTranscriptTab =
        episodeId != null &&
        (ref.watch(episodeHasTranscriptProvider(episodeId)).value ?? false);

    // Ensure tab controller exists (short-circuits if tab count unchanged)
    _ensureTabController(hasTranscript: hasTranscriptTab);

    return Scaffold(
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
                  _SheetHeaderWithTabs(
                    tabController: _tabController!,
                    hasTranscript: hasTranscriptTab,
                    closeLabel: l10n.playerCloseLabel,
                  ),
                  Expanded(
                    child: _PlayerTabBody(
                      tabController: _tabController!,
                      hasTranscript: hasTranscriptTab,
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
                            .read(audioPlayerControllerProvider.notifier)
                            .seekNowPlaying(position),
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
                    skipForwardSeconds: appSettingsRepo.getSkipForwardSeconds(),
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
                  const SizedBox(height: 8),
                  PlayerActionRow(
                    outputPicker: showOutputPicker
                        ? const AudioOutputPickerButton()
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSkip(
    Future<void> Function() skipAction,
    bool wasPlaying,
  ) async {
    _beginSeek(wasPlaying);
    await skipAction();
    await _endSeek();
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

class _SheetHeaderWithTabs extends StatelessWidget {
  const _SheetHeaderWithTabs({
    required this.tabController,
    required this.hasTranscript,
    required this.closeLabel,
  });

  final TabController tabController;
  final bool hasTranscript;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: hasTranscript
                ? TabBar(
                    controller: tabController,
                    tabs: [
                      Tab(text: l10n.playerTabNowPlaying),
                      Tab(text: l10n.playerTabTranscript),
                    ],
                    labelStyle: theme.textTheme.titleSmall,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerHeight: 0,
                  )
                : Text(
                    l10n.playerNowPlaying,
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
          ),
          Semantics(
            button: true,
            label: closeLabel,
            child: IconButton(
              icon: const Icon(Symbols.keyboard_arrow_down),
              onPressed: () => CupertinoSheetRoute.popSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerTabBody extends StatelessWidget {
  const _PlayerTabBody({
    required this.tabController,
    required this.hasTranscript,
    required this.episodeId,
    required this.artworkUrl,
    required this.episodeTitle,
    required this.podcastTitle,
    required this.onChapterSelected,
    this.onEpisodeTitleTap,
    this.onPodcastTitleTap,
  });

  /// Smallest height the artwork shrinks to before the page scrolls.
  static const double artworkMinHeight = 160;

  final TabController tabController;
  final bool hasTranscript;
  final int? episodeId;
  final String? artworkUrl;
  final String episodeTitle;
  final String podcastTitle;
  final VoidCallback? onEpisodeTitleTap;
  final VoidCallback? onPodcastTitleTap;
  final ValueChanged<Duration> onChapterSelected;

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
                  child: Center(child: _PlayerArtwork(artworkUrl: artworkUrl)),
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

    if (!hasTranscript) return nowPlayingContent;

    return TabBarView(
      controller: tabController,
      children: [
        nowPlayingContent,
        TranscriptTab(episodeId: episodeId!),
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
  const _PlayerArtwork({this.artworkUrl});

  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      image: true,
      label: l10n.playerArtworkLabel,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: artworkUrl != null
              ? ArtworkImage(
                  url: artworkUrl!,
                  loading: const SizedBox.shrink(),
                  placeholder: _Placeholder(colorScheme: colorScheme),
                )
              : _Placeholder(colorScheme: colorScheme),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
                  style: theme.textTheme.bodyLarge?.copyWith(
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
    return PlayerSeekBar(
      value: displayValue,
      leadingLabel: formatPlaybackTime(displayPosition),
      trailingLabel: _showRemainingTime
          ? _formatRemaining(displayPosition, duration)
          : formatPlaybackTime(duration),
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
      onTrailingLabelTap: _toggleTrailingLabel,
    );
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
            .read(audioPlayerControllerProvider.notifier)
            .seekNowPlaying(
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
          width: 64,
          height: 64,
          child: Padding(
            padding: EdgeInsets.all(16),
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
        iconSize: 40,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(64, 64),
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
