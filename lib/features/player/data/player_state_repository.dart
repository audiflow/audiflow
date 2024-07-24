import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_state_repository.g.dart';

abstract class PlayerStateRepository {
  Future<int?> playingEpisodeId();

  Future<void> savePlayingEpisodeId(int eid);

  Future<void> clearPlayingEpisodeId();
}

@Riverpod(keepAlive: true)
PlayerStateRepository playerStateRepository(PlayerStateRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
