import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/providers/playback_speed_settings_provider.dart';
import '../services/effective_audio_settings_applier.dart';

part 'now_playing_speed_provider.g.dart';

/// Playback speed in effect for the now-playing podcast: its override, or
/// the global speed.
///
/// Falls back to the global speed while the podcast's override is still
/// loading, so the value is always usable for display.
@riverpod
double nowPlayingSpeed(Ref ref) {
  final resolved = ref.watch(
    nowPlayingAudioSettingsProvider.select((s) => s?.settings.speed),
  );
  if (resolved != null) return resolved;
  return ref.watch(
    playbackSpeedSettingsControllerProvider.select((s) => s.speed),
  );
}
