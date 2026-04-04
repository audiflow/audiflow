import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../helpers/podcast_lookup.dart';
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

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final progress = ref.watch(playbackProgressProvider);
    final appSettingsRepo = ref.watch(appSettingsRepositoryProvider);

    final isPlaying = playbackState is PlaybackPlaying;
    final isLoading = playbackState is PlaybackLoading;

    // Preserve play/pause state during seeking
    final displayIsPlaying = _isSeeking ? _wasPlayingBeforeSeek : isPlaying;
    final displayIsLoading = _isSeeking ? false : isLoading;

    if (nowPlaying == null) {
      return Scaffold(body: Center(child: Text(l10n.playerNoAudio)));
    }

    final episodeId = nowPlaying.episode?.id;
    final hasTranscriptTab = episodeId != null;

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
                      onEpisodeTitleTap: nowPlaying.episode != null
                          ? () => _navigateToEpisode(
                              nowPlaying.episode!,
                              nowPlaying.podcastTitle,
                              nowPlaying.artworkUrl,
                            )
                          : null,
                      onPodcastTitleTap: nowPlaying.episode != null
                          ? () => _navigateToPodcast(
                              nowPlaying.episode!,
                              nowPlaying.podcastTitle,
                            )
                          : null,
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
                  const _PlaybackSpeedButton(),
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

  Future<void> _navigateToEpisode(
    Episode episode,
    String podcastTitle,
    String? artworkUrl,
  ) async {
    final podcast = await _lookupPodcast(episode.podcastId, podcastTitle);
    if (podcast == null || !mounted) return;

    final episodePath = AppRoutes.episodeDetail.replaceAll(
      ':episodeGuid',
      Uri.encodeComponent(episode.guid),
    );
    _popSheetAndPush(
      '${AppRoutes.library}/podcast/${podcast.id}/$episodePath',
      extra: <String, dynamic>{
        'episode': episode.toPodcastItem(),
        'podcastTitle': podcastTitle,
        'artworkUrl': artworkUrl,
      },
    );
  }

  void _popSheetAndPush(String path, {Object? extra}) {
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
    this.onEpisodeTitleTap,
    this.onPodcastTitleTap,
  });

  final TabController tabController;
  final bool hasTranscript;
  final int? episodeId;
  final String? artworkUrl;
  final String episodeTitle;
  final String podcastTitle;
  final VoidCallback? onEpisodeTitleTap;
  final VoidCallback? onPodcastTitleTap;

  @override
  Widget build(BuildContext context) {
    final nowPlayingContent = Column(
      children: [
        Expanded(
          child: Center(child: _PlayerArtwork(artworkUrl: artworkUrl)),
        ),
        _PlayerInfo(
          episodeTitle: episodeTitle,
          podcastTitle: podcastTitle,
          onEpisodeTitleTap: onEpisodeTitleTap,
          onPodcastTitleTap: onPodcastTitleTap,
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
              ? Image.network(
                  artworkUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _Placeholder(colorScheme: colorScheme),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.progress;

    final displayValue = _isDragging ? _dragValue : (progress?.progress ?? 0.0);
    final displayPosition = _isDragging
        ? _computeDragPosition(progress?.duration)
        : progress?.position;

    return Semantics(
      slider: true,
      value:
          '${_formatDuration(displayPosition)}'
          ' of ${_formatDuration(progress?.duration)}',
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: displayValue,
              onChangeStart: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
                widget.onSeekStart?.call();
              },
              onChanged: (value) {
                setState(() => _dragValue = value);
              },
              onChangeEnd: (value) async {
                final duration = progress?.duration ?? Duration.zero;
                final seekPosition = Duration(
                  milliseconds: (duration.inMilliseconds * value).round(),
                );
                await ref
                    .read(audioPlayerControllerProvider.notifier)
                    .seek(seekPosition);
                await widget.onSeekEnd?.call();
                if (!mounted) return;
                setState(() => _isDragging = false);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ExcludeSemantics(
                  child: Text(
                    _formatDuration(displayPosition),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                ExcludeSemantics(
                  child: Text(
                    _formatDuration(progress?.duration),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Duration? _computeDragPosition(Duration? duration) {
    if (duration == null) return null;
    return Duration(
      milliseconds: (duration.inMilliseconds * _dragValue).round(),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (60 <= duration.inMinutes) {
      final hours = duration.inHours;
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
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
          } else {
            controller.resume();
          }
        },
      ),
    );
  }
}

class _PlaybackSpeedButton extends ConsumerWidget {
  const _PlaybackSpeedButton();

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncSpeed = ref.watch(playbackSpeedProvider);
    final speed = asyncSpeed.value ?? 1.0;

    return Semantics(
      button: true,
      label: l10n.playerSpeedLabel('$speed'),
      child: TextButton(
        onPressed: () {
          final nextSpeed = _nextSpeed(speed);
          ref.read(audioPlayerControllerProvider.notifier).setSpeed(nextSpeed);
        },
        child: Text('${speed}x', style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }

  double _nextSpeed(double current) {
    for (final s in _speeds) {
      if (current < s) return s;
    }
    return _speeds.first;
  }
}
