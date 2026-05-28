import 'package:isar_community/isar.dart';

import '../../models/parental_control_settings.dart';
import '../../models/podcast_parental_flags.dart';

class ParentalControlLocalDataSource {
  ParentalControlLocalDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar;

  Future<ParentalControlSettings> getSettings() async {
    final existing = await _isar.parentalControlSettings.get(0);
    if (existing != null) return existing;

    final fresh = ParentalControlSettings();
    await _isar.writeTxn(() async {
      await _isar.parentalControlSettings.put(fresh);
    });
    return fresh;
  }

  Future<void> saveSettings(ParentalControlSettings settings) async {
    await _isar.writeTxn(() async {
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
