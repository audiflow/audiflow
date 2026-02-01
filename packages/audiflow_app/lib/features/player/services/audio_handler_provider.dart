import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'audiflow_audio_handler.dart';

part 'audio_handler_provider.g.dart';

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
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.audiflow.player',
      androidNotificationChannelName: 'Audiflow Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
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

  return handler;
}
