import 'package:isar_community/isar.dart';

import '../../models/parental_control_settings.dart';
import '../../models/podcast_parental_flags.dart';
import '../../../subscription/models/subscriptions.dart';
import '../../../user_state/models/podcast_user_state.dart';
import '../../../user_state/services/podcast_user_state_access.dart';
import '../../../user_state/services/watch_query.dart';
import '../../../user_state/services/user_state_store.dart';

class ParentalControlLocalDataSource {
  ParentalControlLocalDataSource({required this._isar});

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _access = PodcastUserStateAccess(_isar);

  /// Returns the singleton settings row, creating it atomically if absent.
  Future<ParentalControlSettings> getSettings() async {
    return _store.write((_) async {
      final existing = await _isar.parentalControlSettings.get(0);
      if (existing != null) return existing;
      final fresh = ParentalControlSettings()..id = 0;
      await _isar.parentalControlSettings.put(fresh);
      return fresh;
    });
  }

  /// Applies [mutate] to the current settings inside a single transaction.
  ///
  /// Prefer this over the read-modify-write pattern via [saveSettings] for
  /// any operation that reads and then writes settings.
  Future<ParentalControlSettings> updateSettings(
    ParentalControlSettings Function(ParentalControlSettings) mutate,
  ) async {
    return _store.write((_) async {
      final current =
          await _isar.parentalControlSettings.get(0) ??
          (ParentalControlSettings()..id = 0);
      final next = mutate(current);
      next.id = 0;
      await _isar.parentalControlSettings.put(next);
      return next;
    });
  }

  /// Persists [settings] directly.
  ///
  /// Prefer [updateSettings] for read-modify-write operations; this method
  /// is provided for callers that already hold the full settings object.
  Future<void> saveSettings(ParentalControlSettings settings) async {
    await _store.write((_) async {
      settings.id = 0;
      await _isar.parentalControlSettings.put(settings);
    });
  }

  Stream<ParentalControlSettings> watchSettings() {
    return _isar.parentalControlSettings
        .watchObject(0, fireImmediately: true)
        .asyncMap((s) async => s ?? await getSettings());
  }

  // The flags are addressed by Subscription.id, under the old column name.

  Future<PodcastParentalFlags?> getFlags(int itunesId) {
    return _access.parental(itunesId);
  }

  Future<void> setHideExplicit({
    required int itunesId,
    required bool hide,
  }) async {
    await _store.write((txn) async {
      final row =
          await _access.parental(itunesId) ??
          (PodcastParentalFlags()..itunesId = itunesId);
      row.hideExplicitEpisodes = hide;
      await _access.saveParental(itunesId, row, txn);
    });
  }

  Future<void> pruneFlagsFor(int itunesId) async {
    await _store.write((txn) => _access.saveParental(itunesId, null, txn));
  }

  Stream<bool> watchHideExplicit(int itunesId) {
    return watchQuery<bool>(
      triggers: [
        _isar.podcastParentalFlags
            .filter()
            .itunesIdEqualTo(itunesId)
            .watchLazy(),
        _isar.podcastUserStates.watchLazy(),
        _isar.subscriptions.where().idEqualTo(itunesId).watchLazy(),
      ],
      load: () async =>
          (await _access.parental(itunesId))?.hideExplicitEpisodes ?? false,
      same: (a, b) => a == b,
    );
  }
}
