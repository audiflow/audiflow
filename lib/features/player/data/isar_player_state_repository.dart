import 'package:audiflow/features/player/data/player_state_repository.dart';
import 'package:audiflow/features/player/model/playing_episode.dart';
import 'package:isar/isar.dart';

class IsarPlayerStateRepository implements PlayerStateRepository {
  IsarPlayerStateRepository(this.isar);

  final Isar isar;

  @override
  Future<int?> playingEpisodeId() async {
    final e = await isar.playingEpisodes.get(1);
    return e?.eid;
  }

  @override
  Future<void> savePlayingEpisodeId(int eid) async {
    await isar
        .writeTxn(() => isar.playingEpisodes.put(PlayingEpisode(eid: eid)));
  }

  @override
  Future<void> clearPlayingEpisodeId() async {
    await isar.writeTxn(() => isar.playingEpisodes.delete(1));
  }
}
