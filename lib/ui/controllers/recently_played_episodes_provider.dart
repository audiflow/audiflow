import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recently_played_episodes_provider.freezed.dart';
part 'recently_played_episodes_provider.g.dart';

@Riverpod(keepAlive: true)
class RecentlyPlayedEpisodes extends _$RecentlyPlayedEpisodes {
  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<RecentlyPlayedEpisodesState> build() async {
    logger.d('build');

    final episodes = <Episode>[];

    List<Episode> list;
    int? cursor;
    do {
      (list, cursor) =
          await _repository.findRecentlyPlayedEpisodeList(cursor: cursor);
      episodes.addAll(list);
    } while (list.length < 50 && cursor != null);

    _listen();
    return RecentlyPlayedEpisodesState(
      episodes: episodes,
      cursor: cursor,
    );
  }

  void _listen() {
    ref.listen(audioPlayerEventStreamProvider, (_, next) {
      final event = next.requireValue;
      if (event
          case AudioPlayerActionEvent(
            action: AudioPlayerAction.play,
            episode: final episode,
          )) {
        final list = state.requireValue.episodes
            .where((e) => e.guid != episode.guid)
            .toList()
          ..insert(0, episode);
        state = AsyncData(state.requireValue.copyWith(episodes: list));
      }
    });
  }
}

@freezed
class RecentlyPlayedEpisodesState with _$RecentlyPlayedEpisodesState {
  const factory RecentlyPlayedEpisodesState({
    required List<Episode> episodes,
    required int? cursor,
  }) = _RecentlyPlayedEpisodesState;
}
