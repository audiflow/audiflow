import 'package:isar_community/isar.dart';

import '../../../subscription/models/subscriptions.dart';
import '../../../user_state/models/podcast_user_state.dart';
import '../../../user_state/services/podcast_user_state_access.dart';
import '../../../user_state/services/user_state_store.dart';
import '../../../user_state/services/watch_query.dart';
import '../../models/podcast_view_preference.dart';

/// Local datasource for podcast view preferences.
///
/// The preference lives in [PodcastUserState], keyed by the podcast's
/// stable key; see [PodcastUserStateAccess] for how the old rows are kept
/// in step for one release.
class PodcastViewPreferenceLocalDatasource {
  PodcastViewPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _access = PodcastUserStateAccess(_isar);

  /// Gets preference for a podcast, returns null if not set.
  Future<PodcastViewPreference?> getPreference(int podcastId) {
    return _access.view(podcastId);
  }

  /// Watches preference for a podcast (emits null if not set).
  Stream<PodcastViewPreference?> watchPreference(int podcastId) {
    return watchQuery<PodcastViewPreference?>(
      triggers: [
        _isar.podcastViewPreferences
            .filter()
            .podcastIdEqualTo(podcastId)
            .watchLazy(),
        _isar.podcastUserStates.watchLazy(),
        // Keying the podcast switches it to its keyed state.
        _isar.subscriptions.where().idEqualTo(podcastId).watchLazy(),
      ],
      load: () => _access.view(podcastId),
      same: (a, b) => describeView(a) == describeView(b),
    );
  }

  /// Upserts preference (insert or update on conflict).
  Future<void> upsertPreference(PodcastViewPreference pref) async {
    await _store.write((txn) => _access.saveView(pref.podcastId, pref, txn));
  }

  /// Deletes preference for a podcast. Returns how many were deleted.
  Future<int> deletePreference(int podcastId) {
    return _store.write((txn) async {
      final existed = await _access.view(podcastId) != null;
      await _access.saveView(podcastId, null, txn);
      return existed ? 1 : 0;
    });
  }
}
