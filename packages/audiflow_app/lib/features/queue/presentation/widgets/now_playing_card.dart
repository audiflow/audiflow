import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../podcast_detail/presentation/screens/episode_detail_screen.dart';

/// The playing episode at the top of the queue (redesign 4.6): a card on
/// the artwork-derived player ground, white text, and a white bottom-edge
/// progress line. Tapping opens the episode's detail screen.
class NowPlayingCard extends ConsumerStatefulWidget {
  const NowPlayingCard({super.key});

  @override
  ConsumerState<NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends ConsumerState<NowPlayingCard> {
  static const double _artworkSize = 56;

  /// Last live progress seen and the episode it belonged to, kept so a
  /// mid-episode buffer (reported as loading) does not drop the line.
  String? _liveUrl;
  double? _liveFraction;

  @override
  Widget build(BuildContext context) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    if (nowPlaying == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenHorizontal,
        vertical: Spacing.sm,
      ),
      child: ArtworkGround(
        url: nowPlaying.artworkUrl,
        builder: (context, ground) => DecoratedBox(
          decoration: BoxDecoration(
            color: ground,
            borderRadius: AppBorders.card,
            boxShadow: AppShadows.floating,
          ),
          child: ClipRRect(
            borderRadius: AppBorders.card,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => _navigateToEpisodeDetail(context, nowPlaying),
                child: BottomEdgeProgress(
                  fraction: _fraction(nowPlaying),
                  fillColor: NowPlayingColors.foreground,
                  trackColor: NowPlayingColors.trackInactive,
                  child: _content(context, nowPlaying),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, NowPlayingInfo nowPlaying) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.md - Spacing.xxs),
      child: Row(
        children: [
          MiniPlayerArtwork(
            imageUrl: nowPlaying.artworkUrl,
            size: _artworkSize,
            borderRadius: 12,
          ),
          const SizedBox(width: Spacing.sm + Spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.playerNowPlaying,
                  style: AppTextStyles.overline.copyWith(
                    color: NowPlayingColors.labelSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  nowPlaying.episodeTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(
                    color: NowPlayingColors.foreground,
                  ),
                ),
                Text(
                  nowPlaying.podcastTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta.copyWith(
                    color: NowPlayingColors.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Live position while this episode plays or is paused, else the saved
  /// position. While a new episode loads, the live progress still belongs
  /// to the previous audio, so it only counts once the player reports
  /// this episode; a buffer within the same episode keeps the last value.
  double? _fraction(NowPlayingInfo nowPlaying) {
    final url = nowPlaying.episodeUrl;
    final playback = ref.watch(audioPlayerControllerProvider);
    final live = ref.watch(playbackProgressProvider);
    final reportsThisEpisode = switch (playback) {
      PlaybackPlaying(:final episodeUrl) => episodeUrl == url,
      PlaybackPaused(:final episodeUrl) => episodeUrl == url,
      _ => false,
    };
    if (reportsThisEpisode &&
        live != null &&
        0 < live.duration.inMilliseconds) {
      _liveUrl = url;
      _liveFraction =
          live.position.inMilliseconds / live.duration.inMilliseconds;
      return _liveFraction;
    }
    final buffering = playback is PlaybackLoading && playback.episodeUrl == url;
    if (buffering && _liveUrl == url) return _liveFraction;
    final saved = nowPlaying.savedPosition;
    final total = nowPlaying.totalDuration;
    if (saved == null || total == null || total == Duration.zero) return null;
    return saved.inMilliseconds / total.inMilliseconds;
  }

  void _navigateToEpisodeDetail(
    BuildContext context,
    NowPlayingInfo nowPlaying,
  ) {
    final episode = nowPlaying.episode;
    if (episode == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeDetailScreen(
          episode: episode.toPodcastItem(),
          podcastTitle: nowPlaying.podcastTitle,
          artworkUrl: nowPlaying.artworkUrl,
        ),
      ),
    );
  }
}
