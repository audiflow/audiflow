import 'package:audiflow/features/browser/episode/data/episode_stats_provider.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_played_episode_provider.g.dart';

@riverpod
class LastPlayedEpisode extends _$LastPlayedEpisode {
  ProviderSubscription<AsyncValue<EpisodeStats?>>? _subscription;

  @override
  Episode? build() {
    final episode = ref.read(audioPlayerServiceProvider)?.episode;
    if (episode != null) {
      _listenStats(episode.id);
    }

    ref.listen(audioPlayerServiceProvider.select((state) => state?.episode),
        (_, episode) {
      if (episode != null) {
        state = episode;
        _listenStats(episode.id);
      }
    });

    return episode;
  }

  void _listenStats(int eid) {
    _subscription?.close();
    _subscription = ref.listen(episodeStatsProvider(eid: eid), (_, __) {});
  }
}
