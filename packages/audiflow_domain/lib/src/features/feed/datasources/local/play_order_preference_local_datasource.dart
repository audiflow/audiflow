import 'package:isar_community/isar.dart';

import '../../../user_state/models/podcast_user_state.dart';
import '../../../user_state/services/podcast_user_state_access.dart';
import '../../../user_state/services/user_state_store.dart';
import '../../models/podcast_view_preference.dart';

/// Local datasource for per-scope play order preferences.
///
/// Three scope levels: podcast, playlist, and group. Each stores the raw
/// string representation of `AutoPlayOrder`. The values live in
/// [PodcastUserState]; see [PodcastUserStateAccess].
class PlayOrderPreferenceLocalDatasource {
  PlayOrderPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _access = PodcastUserStateAccess(_isar);

  // -- Podcast level (stored with the view preference) --

  /// Reads the podcast-level play order.
  Future<String?> getPodcastPlayOrder(int podcastId) async {
    final pref = await _access.view(podcastId);
    return pref?.autoPlayOrder;
  }

  /// Sets the podcast-level play order.
  ///
  /// When [order] is null, clears only the play order, keeping the rest of
  /// the view preference.
  Future<void> setPodcastPlayOrder(int podcastId, String? order) async {
    await _store.write((txn) async {
      final pref =
          await _access.view(podcastId) ??
          (PodcastViewPreference()..podcastId = podcastId);
      pref.autoPlayOrder = order;
      await _access.saveView(podcastId, pref, txn);
    });
  }

  // -- Playlist level --

  /// Reads the play order for a specific playlist within a podcast.
  Future<String?> getPlaylistPlayOrder(int podcastId, String playlistId) {
    return _access.playOrder(podcastId, playlistId);
  }

  /// Sets or clears (null) the play order for a playlist.
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    String? order,
  ) async {
    await _store.write(
      (txn) => _access.savePlayOrder(podcastId, playlistId, null, order, txn),
    );
  }

  // -- Group level --

  /// Reads the play order for a specific group within a playlist.
  Future<String?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return _access.playOrder(podcastId, playlistId, groupId: groupId);
  }

  /// Sets or clears (null) the play order for a group.
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    String? order,
  ) async {
    await _store.write(
      (txn) =>
          _access.savePlayOrder(podcastId, playlistId, groupId, order, txn),
    );
  }
}
