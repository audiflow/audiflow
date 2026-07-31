import 'package:isar_community/isar.dart';

import '../../models/parental_control_settings.dart';
import '../../models/podcast_parental_flags.dart';

class ParentalControlLocalDataSource {
  ParentalControlLocalDataSource({required this._isar});

  final Isar _isar;

  /// Returns the singleton settings row, creating it atomically if absent.
  Future<ParentalControlSettings> getSettings() async {
    return _isar.writeTxn(() async {
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
    return _isar.writeTxn(() async {
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
    await _isar.writeTxn(() async {
      settings.id = 0;
      await _isar.parentalControlSettings.put(settings);
    });
  }

  Stream<ParentalControlSettings> watchSettings() {
    return _isar.parentalControlSettings
        .watchObject(0, fireImmediately: true)
        .asyncMap((s) async => s ?? await getSettings());
  }

  Future<PodcastParentalFlags?> getFlags(int itunesId) {
    return _isar.podcastParentalFlags
        .filter()
        .itunesIdEqualTo(itunesId)
        .findFirst();
  }

  Future<void> setHideExplicit({
    required int itunesId,
    required bool hide,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.podcastParentalFlags
          .filter()
          .itunesIdEqualTo(itunesId)
          .findFirst();
      final row = existing ?? (PodcastParentalFlags()..itunesId = itunesId);
      row.hideExplicitEpisodes = hide;
      await _isar.podcastParentalFlags.put(row);
    });
  }

  Future<void> pruneFlagsFor(int itunesId) async {
    await _isar.writeTxn(() async {
      await _isar.podcastParentalFlags
          .filter()
          .itunesIdEqualTo(itunesId)
          .deleteAll();
    });
  }

  Stream<bool> watchHideExplicit(int itunesId) {
    return _isar.podcastParentalFlags
        .filter()
        .itunesIdEqualTo(itunesId)
        .watch(fireImmediately: true)
        .map((rows) => rows.isNotEmpty && rows.first.hideExplicitEpisodes);
  }
}
