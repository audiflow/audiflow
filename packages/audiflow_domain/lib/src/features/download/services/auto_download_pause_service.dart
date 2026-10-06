import 'package:audiflow_core/audiflow_core.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../../subscription/repositories/subscription_repository_impl.dart';

part 'auto_download_pause_service.g.dart';

@Riverpod(keepAlive: true)
AutoDownloadPauseService autoDownloadPauseService(Ref ref) {
  return AutoDownloadPauseService(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
    logger: ref.watch(namedLoggerProvider('AutoDownloadPause')),
  );
}

/// Pauses auto-download for podcasts the listener has stopped playing, and
/// resumes it once they play the podcast again.
///
/// Inactivity is measured in auto-downloads received since the last play
/// rather than elapsed days, so a daily show and a monthly show both pause
/// after the same number of unheard episodes.
class AutoDownloadPauseService {
  AutoDownloadPauseService({
    required this._subscriptionRepository,
    required this._episodeRepository,
    this._logger,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SubscriptionRepository _subscriptionRepository;
  final EpisodeRepository _episodeRepository;
  final Logger? _logger;
  final DateTime Function() _clock;

  /// Counts [count] auto-downloads just created for [subscriptionId] and
  /// pauses its auto-download once [AppConstants.autoDownloadPauseThreshold]
  /// accumulate without a play.
  Future<void> recordAutoDownloads(int subscriptionId, int count) async {
    if (count < 1) return;
    final paused = await _subscriptionRepository.recordAutoDownloads(
      subscriptionId,
      count,
      pauseThreshold: AppConstants.autoDownloadPauseThreshold,
      at: _clock(),
    );
    if (paused) {
      _logger?.i(
        'Paused auto-download for podcast $subscriptionId: '
        '${AppConstants.autoDownloadPauseThreshold} unplayed auto downloads',
      );
    }
  }

  /// Auto-downloads [subscription] may still receive before it pauses, so a
  /// single sync cannot overshoot the threshold.
  int remainingAllowance(Subscription subscription) =>
      AppConstants.autoDownloadPauseThreshold -
      subscription.autoDownloadsSinceLastPlay;

  /// Resumes auto-download for the podcast of [episodeId] and restarts its
  /// inactivity count.
  Future<void> recordPlayback(int episodeId) async {
    final episode = await _episodeRepository.getById(episodeId);
    if (episode == null) return;
    await _subscriptionRepository.resetAutoDownloadActivity(episode.podcastId);
  }
}
