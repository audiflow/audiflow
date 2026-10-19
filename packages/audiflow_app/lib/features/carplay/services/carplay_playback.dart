import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../queue/services/queue_item_player.dart' as queue_player;

/// Speeds the CarPlay playback-rate button steps through, in order.
///
/// A short list: each press is one step, and a driver should reach any of
/// them in a few presses. All are members of `PlaybackSpeedScale.steps`.
const carPlaySpeeds = [1.0, 1.2, 1.5, 1.8, 2.0];

/// The speed after [current] in [carPlaySpeeds], wrapping to the first.
///
/// A speed between steps (set on the phone) moves up to the next step.
double nextCarPlaySpeed(double current) {
  // Tolerance so a stored 1.5 is not treated as just below 1.5.
  const epsilon = 1e-9;
  for (final speed in carPlaySpeeds) {
    if (current + epsilon < speed) return speed;
  }
  return carPlaySpeeds.first;
}

/// Carries out the playback a CarPlay row or button asks for, through the
/// same controller the phone player uses.
///
/// CarPlay plays a tapped episode without rebuilding the queue: the phone's
/// replace-queue confirmation cannot be asked while driving, and silently
/// replacing a hand-built queue would lose it.
class CarPlayPlayback {
  CarPlayPlayback(this._ref);

  final Ref _ref;

  /// Plays episode [episodeId], resuming from its saved position.
  /// Returns false when the episode no longer exists.
  Future<bool> playEpisode(int episodeId) async {
    final episode = await _ref
        .read(episodeRepositoryProvider)
        .getById(episodeId);
    if (episode == null) return false;
    await queue_player.startEpisode(_ref, episode, PlaySource.carplay);
    return true;
  }

  /// Jumps to queue item [queueItemId], as tapping it in the Queue tab
  /// does. Returns false when the item has left the queue.
  Future<bool> playQueueItem(int queueItemId) =>
      queue_player.playQueueItem(_ref, queueItemId);

  /// Steps the now-playing speed to the next of [carPlaySpeeds] and returns
  /// it, or null while the now-playing settings are still loading.
  ///
  /// Saved to the scope the now-playing podcast resolves to, so a podcast
  /// with its own speed keeps it to itself.
  Future<double?> cycleSpeed() async {
    final resolved = _ref.read(nowPlayingAudioSettingsProvider);
    if (resolved == null) return null;
    final next = nextCarPlaySpeed(resolved.settings.speed);
    await _ref
        .read(audioPlayerControllerProvider.notifier)
        .setSpeed(next, scope: resolved.scope);
    return next;
  }
}
