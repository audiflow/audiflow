import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'audiflow_audio_handler.dart';

part 'audio_handler_provider.g.dart';

/// Platform configuration for the audio_service session.
///
/// The art downscale size must be set: without it the Android plugin decodes
/// [MediaItem.artUri] at full resolution, and podcast artwork of 3000x3000
/// costs about 36 MB per bitmap (#451). Only the Android loader reads the
/// value; the iOS plugin decodes the file at native size, which is why
/// `NowPlayingMediaItemSync` hands both platforms a pre-scaled local file
/// (#453). This setting stays as the second line of defense for the remote
/// URL fallback.
const audioServiceConfig = AudioServiceConfig(
  androidNotificationChannelId: 'com.audiflow.player',
  androidNotificationChannelName: 'audiflow Playback',
  androidNotificationOngoing: true,
  androidStopForegroundOnPause: true,
  artDownscaleWidth: androidArtworkDownscalePixels,
  artDownscaleHeight: androidArtworkDownscalePixels,
);

/// Lower bound for the decoded artwork edge on Android.
///
/// The plugin picks a power-of-two sample size, so the result is at least
/// this large: 3000 px art decodes to 375 px and 1400 px art to 350 px.
/// That matches Android's 320 px guideline for MediaMetadata bitmaps.
/// Raising it to 512 would decode 3000 px art at 1500 px (about 9 MB).
const androidArtworkDownscalePixels = 256;

/// Initializes AudioService with [AudiflowAudioHandler] and sets up
/// media item sync listeners.
///
/// Playback state is synced via direct stream piping inside the handler.
/// This provider only handles media item (now playing info) sync.
///
/// Must be awaited before the app starts to ensure platform media
/// controls are connected.
@Riverpod(keepAlive: true)
Future<AudiflowAudioHandler> audioHandler(Ref ref) async {
  final handler = await AudioService.init<AudiflowAudioHandler>(
    builder: () => AudiflowAudioHandler(ref),
    config: audioServiceConfig,
  );

  // Sync media item metadata (title, artist, artwork) to platform.
  ref.listen<NowPlayingInfo?>(nowPlayingControllerProvider, (prev, next) {
    handler.syncNowPlaying(next);
  });

  // Sync duration updates from the progress stream.
  ref.listen<AsyncValue<PlaybackProgress>>(playbackProgressStreamProvider, (
    prev,
    next,
  ) {
    final progress = next.value;
    if (progress == null) return;
    handler.updateDuration(progress.duration);
  });

  // Invalidate cached episode progress / list views when the player
  // marks an episode as completed, so already-rendered list screens
  // reflect the new state without a manual reload.
  final lifecycleStream = ref.read(playerLifecycleEventsProvider);
  final lifecycleSub = lifecycleStream.listen((event) {
    if (event is! EpisodeCompletedLifecycle) return;
    ref.invalidate(podcastEpisodeProgressProvider);
    ref.invalidate(filteredSortedEpisodesProvider);
    ref.invalidate(smartPlaylistEpisodesProvider);
  });
  ref.onDispose(lifecycleSub.cancel);

  return handler;
}
