import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'continue_listening_controller.g.dart';

/// Provides the list of episodes in progress with their details.
///
/// Combines PlaybackHistory with Episode data for display.
@riverpod
Stream<List<EpisodeWithProgress>> continueListeningEpisodes(Ref ref) async* {
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);

  await for (final histories in historyRepo.watchInProgress(limit: 10)) {
    final episodes = <EpisodeWithProgress>[];

    for (final history in histories) {
      final episode = await episodeRepo.getById(history.episodeId);
      if (episode != null) {
        episodes.add(EpisodeWithProgress(episode: episode, history: history));
      }
    }

    yield episodes;
  }
}
