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

  test('upsert creates then updates a single row', () async {
    await datasource.upsert(
      1,
      speed: 1.5,
      skipSilence: false,
      voiceBoost: true,
    );
    await datasource.upsert(
      1,
      speed: 2.0,
      skipSilence: true,
      voiceBoost: false,
    );

    final row = (await datasource.get(1))!;
    check(row.speed).equals(2.0);
    check(row.skipSilence).equals(true);
    check(row.voiceBoost).equals(false);
    check(await isar.podcastAudioPreferences.count()).equals(1);
  });

  test('delete removes only the given podcast', () async {
    await datasource.upsert(
      1,
      speed: 1.5,
      skipSilence: false,
      voiceBoost: false,
    );
    await datasource.upsert(
      2,
      speed: 0.8,
      skipSilence: false,
      voiceBoost: false,
    );

    await datasource.delete(1);

    check(await datasource.get(1)).isNull();
    check(await datasource.get(2)).isNotNull();
  });
}
