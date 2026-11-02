import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../queue/services/queue_item_player.dart' as queue_player;
import 'car_catalog.dart';

/// Speeds the in-car speed buttons step through, in order.
///
/// A short list: each press is one step, and a driver should reach any of
/// them in a few presses. All are members of `PlaybackSpeedScale.steps`.
const carSpeeds = [1.0, 1.2, 1.5, 1.8, 2.0];

/// The speed after [current] in [carSpeeds], wrapping to the first.
///
/// A speed between steps (set on the phone) moves up to the next step.
double nextCarSpeed(double current) {
  // Tolerance so a stored 1.5 is not treated as just below 1.5.
  const epsilon = 1e-9;
  for (final speed in carSpeeds) {
    if (current + epsilon < speed) return speed;
  }
  return carSpeeds.first;
}

/// Carries out the playback an in-car row or button asks for, through the
/// same controller the phone player uses.
///
/// The queue changes as it does on the phone after "replace the queue" is
/// confirmed. The car asks nothing: the head unit has no way to add items
/// to the queue by hand, and a confirmation is one more step for a driver.
class CarPlayback {
  CarPlayback(this._ref, {required this._catalog});

  final Ref _ref;

  /// Read on each play, as `CarPlayBridge` reads it, so a rebuilt catalog
  /// is picked up.
  final CarCatalog Function() _catalog;

  /// Plays episode [episodeId] alone, resuming from its saved position, as
  /// playing from the phone's episode detail does: the queue is cleared so
  /// a stale one does not continue after it. Used for rows (In Progress,
  /// Downloads) that are not one podcast's episodes. Returns false when the
  /// episode no longer exists.
  Future<bool> playEpisode(int episodeId) async {
    final episode = await _ref
        .read(episodeRepositoryProvider)
        .getById(episodeId);
    if (episode == null) return false;
    if (_continueLoaded(episode) != _Continued.no) return true;
    await _ref.read(queueServiceProvider).clearQueue();
    await queue_player.startEpisode(_ref, episode, PlaySource.car);
    return true;
  }

  /// Plays episode [episodeId] from its podcast's episode list and queues
  /// the episodes after it, as tapping a row on podcast detail does: the
  /// list's episodes in the podcast's effective play order. Returns false
  /// when the episode no longer exists.
  Future<bool> playPodcastEpisode(int episodeId) async {
    final episode = await _ref
        .read(episodeRepositoryProvider)
        .getById(episodeId);
    if (episode == null) return false;
    if (_continueLoaded(episode) != _Continued.no) return true;
    final podcastId = episode.podcastId;
    final siblingIds = await _catalog().podcastEpisodeIds(podcastId);
    final order = await _ref
        .read(playOrderPreferenceRepositoryProvider)
        .resolveForPodcast(podcastId);
    final subscription = await _ref
        .read(subscriptionRepositoryProvider)
        .getById(podcastId);
    await _ref
        .read(queueServiceProvider)
        .createAdhocQueue(
          startingEpisodeId: episodeId,
          sourceContext: subscription?.title ?? '',
          siblingEpisodeIds: siblingIds,
          effectiveOrder: order,
        );
    await queue_player.startEpisode(_ref, episode, PlaySource.car);
    return true;
  }

  /// Plays episode [episodeId] from station [stationId]'s list and queues
  /// the episodes after it in the order the list shows, as tapping a row
  /// on the station screen does. The play is recorded so the station moves
  /// up in the Library. Returns false when the station or the episode no
  /// longer exists.
  Future<bool> playStationEpisode(int stationId, int episodeId) async {
    final station = await _ref
        .read(stationRepositoryProvider)
        .findById(stationId);
    if (station == null) return false;
    final episode = await _ref
        .read(episodeRepositoryProvider)
        .getById(episodeId);
    if (episode == null) return false;
    switch (_continueLoaded(episode)) {
      case _Continued.no:
        break;
      case _Continued.alreadyPlaying:
        return true;
      case _Continued.resumed:
        // Resuming from a station is a play from it, as on the phone.
        _recordStationPlay(station);
        return true;
    }
    final siblingIds = await _catalog().stationEpisodeIds(stationId);
    await _ref
        .read(queueServiceProvider)
        .createAdhocQueue(
          startingEpisodeId: episodeId,
          sourceContext: station.name,
          siblingEpisodeIds: siblingIds,
          effectiveOrder: AutoPlayOrder.asDisplayed,
        );
    await queue_player.startEpisode(_ref, episode, PlaySource.car);
    _recordStationPlay(station);
    return true;
  }

  /// Leaves [episode] playing, or resumes it when paused, if the player
  /// already holds it.
  ///
  /// Selecting the episode that is on Now Playing must not reload it (an
  /// audible gap) or rebuild the queue, as on the phone's episode rows.
  ///
  /// Matched by episode id as well as audio URL: two feed entries can share
  /// an enclosure. A failed load, or an episode parked at its end (where
  /// resuming would advance the queue), is started again instead.
  _Continued _continueLoaded(Episode episode) {
    final controller = _ref.read(audioPlayerControllerProvider.notifier);
    if (controller.currentEpisodeId != episode.id) return _Continued.no;
    final url = episode.audioUrl;
    switch (_ref.read(audioPlayerControllerProvider)) {
      // A pending load goes on: resuming now would play the old source.
      case PlaybackPlaying(:final episodeUrl) ||
              PlaybackLoading(:final episodeUrl)
          when episodeUrl == url:
        return _Continued.alreadyPlaying;
      case PlaybackPaused(:final episodeUrl)
          when episodeUrl == url && !controller.isParkedAtEnd:
        unawaited(controller.resume());
        return _Continued.resumed;
      default:
        return _Continued.no;
    }
  }

  /// Fire-and-forget, as on the phone: a failed write only leaves the
  /// Library order stale, and a lost analytics event changes nothing.
  void _recordStationPlay(Station station) {
    final stations = _ref.read(stationRepositoryProvider);
    final installIds = _ref.read(installIdRepositoryProvider);
    final analytics = _ref.read(analyticsServiceProvider);
    final logger = _ref.read(namedLoggerProvider('CarPlayback'));
    void logFailure(Object error, StackTrace stackTrace) => logger.w(
      'Failed to record station play',
      error: error,
      stackTrace: stackTrace,
    );
    unawaited(
      stations
          .markPlayed(station.id, at: DateTime.now())
          .catchError(logFailure),
    );
    unawaited(
      () async {
        final installId = await installIds.getOrCreate();
        await analytics.log(
          StationPlayed(stationId: stableId('$installId:${station.name}')),
        );
      }().catchError(logFailure),
    );
  }

  /// Jumps to queue item [queueItemId], as tapping it in the Queue tab
  /// does. Returns false when the item has left the queue.
  Future<bool> playQueueItem(int queueItemId) =>
      queue_player.playQueueItem(_ref, queueItemId, source: PlaySource.car);

  /// Steps the now-playing speed to the next of [carSpeeds] and returns
  /// it, or null while the now-playing settings are still loading.
  ///
  /// Saved to the scope the now-playing podcast resolves to, so a podcast
  /// with its own speed keeps it to itself.
  Future<double?> cycleSpeed() async {
    final resolved = _ref.read(nowPlayingAudioSettingsProvider);
    if (resolved == null) return null;
    final next = nextCarSpeed(resolved.settings.speed);
    await _ref
        .read(audioPlayerControllerProvider.notifier)
        .setSpeed(next, scope: resolved.scope);
    return next;
  }
}

/// What [CarPlayback] did with an episode the player already holds.
enum _Continued {
  /// Not the loaded episode: it must be started.
  no,
  alreadyPlaying,
  resumed,
}
