import 'package:isar_community/isar.dart';

import '../../models/podcast_view_preference.dart';
import '../../models/smart_playlist_group_user_preference.dart';
import '../../models/smart_playlist_user_preference.dart';

/// Local datasource for per-scope play order preferences using Isar.
///
/// Wraps Isar operations for three scope levels: podcast, playlist,
/// and group. Each scope stores the raw string representation of
/// [AutoPlayOrder].
class PlayOrderPreferenceLocalDatasource {
  PlayOrderPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  // -- Podcast level (PodcastViewPreference) --

  /// Reads the autoPlayOrder from [PodcastViewPreference].
  Future<String?> getPodcastPlayOrder(int podcastId) async {
    final pref = await _isar.podcastViewPreferences.getByPodcastId(podcastId);
    return pref?.autoPlayOrder;
  }

  /// Upserts [PodcastViewPreference] with the given autoPlayOrder.
  ///
  /// When [order] is null, clears only the autoPlayOrder field
  /// without deleting the whole record (it has other fields).
  Future<void> setPodcastPlayOrder(int podcastId, String? order) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.podcastViewPreferences.getByPodcastId(
        podcastId,
      );
      final pref = existing ?? (PodcastViewPreference()..podcastId = podcastId);
      pref.autoPlayOrder = order;
      await _isar.podcastViewPreferences.put(pref);
    });
  }

  // -- Playlist level (SmartPlaylistUserPreference) --

  /// Reads autoPlayOrder for a specific playlist within a podcast.
  Future<String?> getPlaylistPlayOrder(int podcastId, String playlistId) async {
    final pref = await _isar.smartPlaylistUserPreferences
        .getByPodcastIdPlaylistId(podcastId, playlistId);
    return pref?.autoPlayOrder;
  }

  /// Sets or clears autoPlayOrder for a playlist.
  ///
  /// When [order] is null, deletes the record entirely (the
  /// collection only stores autoPlayOrder).
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    String? order,
  ) async {
    await _isar.writeTxn(() async {
      if (order == null) {
        await _isar.smartPlaylistUserPreferences.deleteByPodcastIdPlaylistId(
          podcastId,
          playlistId,
        );
        return;
      }

      final existing = await _isar.smartPlaylistUserPreferences
          .getByPodcastIdPlaylistId(podcastId, playlistId);
      final pref =
          existing ??
          (SmartPlaylistUserPreference()
            ..podcastId = podcastId
            ..playlistId = playlistId);
      pref.autoPlayOrder = order;
      await _isar.smartPlaylistUserPreferences.put(pref);
    });
  }

  // -- Group level (SmartPlaylistGroupUserPreference) --

  /// Reads autoPlayOrder for a specific group within a playlist.
  Future<String?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  ) async {
    final pref = await _isar.smartPlaylistGroupUserPreferences
        .getByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
    return pref?.autoPlayOrder;
  }

  /// Sets or clears autoPlayOrder for a group.
  ///
  /// When [order] is null, deletes the record entirely.
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    String? order,
  ) async {
    await _isar.writeTxn(() async {
      if (order == null) {
        await _isar.smartPlaylistGroupUserPreferences
            .deleteByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
        return;
      }

      final existing = await _isar.smartPlaylistGroupUserPreferences
          .getByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
      final pref =
          existing ??
          (SmartPlaylistGroupUserPreference()
            ..podcastId = podcastId
            ..playlistId = playlistId
            ..groupId = groupId);
      pref.autoPlayOrder = order;
      await _isar.smartPlaylistGroupUserPreferences.put(pref);
    });
  }
}
