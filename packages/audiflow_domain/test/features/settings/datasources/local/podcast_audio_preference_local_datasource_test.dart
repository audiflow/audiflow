import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late PodcastAudioPreferenceLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([PodcastAudioPreferenceSchema]);
    datasource = PodcastAudioPreferenceLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  test('returns null when no override exists', () async {
    check(await datasource.get(1)).isNull();
  });

  test('upsertSpeed creates then updates a single row', () async {
    await datasource.upsertSpeed(1, 1.5);
    await datasource.upsertSpeed(1, 2.0);

    final row = await datasource.get(1);
    check(row).isNotNull().has((r) => r.speed, 'speed').equals(2.0);
    check(await isar.podcastAudioPreferences.count()).equals(1);
  });

  test('upsertSpeed keeps the reserved columns of an existing row', () async {
    await isar.writeTxn(
      () => isar.podcastAudioPreferences.put(
        PodcastAudioPreference()
          ..podcastId = 1
          ..speed = 1.0
          ..skipSilence = true
          ..voiceBoost = false,
      ),
    );

    await datasource.upsertSpeed(1, 1.5);

    final row = (await datasource.get(1))!;
    check(row.skipSilence).equals(true);
    check(row.voiceBoost).equals(false);
  });

  test('delete removes only the given podcast', () async {
    await datasource.upsertSpeed(1, 1.5);
    await datasource.upsertSpeed(2, 0.8);

    await datasource.delete(1);

    check(await datasource.get(1)).isNull();
    check(await datasource.get(2)).isNotNull();
  });
}
