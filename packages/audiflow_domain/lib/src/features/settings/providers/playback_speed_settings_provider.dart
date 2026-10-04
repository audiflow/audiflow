import 'package:audiflow_core/audiflow_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_providers.dart';

part 'playback_speed_settings_provider.g.dart';

/// Snapshot of the persisted playback speed and its recent-speed history.
///
/// Every speed control (player audio sheet, playback settings screen)
/// reads this single source so they always agree on the current value.
final class PlaybackSpeedSettings {
  const PlaybackSpeedSettings({
    required this.speed,
    required this.recentSpeeds,
  });

  /// Current speed, always a member of [PlaybackSpeedScale.steps].
  final double speed;

  /// Recently used non-normal speeds, newest first.
  final List<double> recentSpeeds;

  /// Quick-chip speeds: normal plus [recentSpeeds], ascending.
  List<double> get chipSpeeds => RecentPlaybackSpeeds.chipSpeeds(recentSpeeds);

  @override
  bool operator ==(Object other) =>
      other is PlaybackSpeedSettings &&
      other.speed == speed &&
      _listEquals(other.recentSpeeds, recentSpeeds);

  @override
  int get hashCode => Object.hash(speed, Object.hashAll(recentSpeeds));

  static bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Holds the global [PlaybackSpeedSettings] and persists changes.
///
/// UI must not call [save] directly: speed changes go through
/// `AudioPlayerController.setSpeed`, which applies the speed to the
/// player, emits analytics, and then calls [save].
@Riverpod(keepAlive: true)
class PlaybackSpeedSettingsController
    extends _$PlaybackSpeedSettingsController {
  @override
  PlaybackSpeedSettings build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return PlaybackSpeedSettings(
      speed: repo.getPlaybackSpeed(),
      recentSpeeds: repo.getRecentPlaybackSpeeds(),
    );
  }

  /// Persists [speed] (snapped to the grid) as the current speed.
  ///
  /// When [recordRecent] is true the speed is also pushed onto the
  /// recent list. Slider drags pass false for intermediate steps so only
  /// the speed the user settles on is remembered.
  Future<void> save(double speed, {required bool recordRecent}) async {
    final snapped = PlaybackSpeedScale.snap(speed);
    final repo = ref.read(appSettingsRepositoryProvider);
    final recent = recordRecent
        ? RecentPlaybackSpeeds.record(state.recentSpeeds, snapped)
        : state.recentSpeeds;
    // Update memory first so the UI follows the slider without waiting
    // on disk; persistence failures surface to the caller.
    state = PlaybackSpeedSettings(speed: snapped, recentSpeeds: recent);
    await repo.setPlaybackSpeed(snapped);
    if (recordRecent) await repo.setRecentPlaybackSpeeds(recent);
  }

  /// Pushes [speed] onto the recent list without changing the global
  /// speed.
  ///
  /// Used when a speed is committed to a podcast override: the quick-pick
  /// chips are one shared history of speeds the user settled on, whichever
  /// scope the speed was saved to.
  Future<void> recordRecent(double speed) async {
    final recent = RecentPlaybackSpeeds.record(
      state.recentSpeeds,
      PlaybackSpeedScale.snap(speed),
    );
    state = PlaybackSpeedSettings(speed: state.speed, recentSpeeds: recent);
    await ref
        .read(appSettingsRepositoryProvider)
        .setRecentPlaybackSpeeds(recent);
  }
}
