import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/models/podcast_parental_flags.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  late Isar isar;
  late ParentalControlLocalDataSource ds;

  setUp(() async {
    isar = await openTestIsar([
      ParentalControlSettingsSchema,
      PodcastParentalFlagsSchema,
    ]);
    ds = ParentalControlLocalDataSource(isar: isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('ParentalControlLocalDataSource', () {
    test('getSettings returns default singleton when empty', () async {
      final s = await ds.getSettings();
      check(s.id).equals(0);
      check(s.restrictedModeEnabled).isFalse();
      check(s.pinHashBase64).isNull();
      check(s.pinIterations).equals(100000);
    });

    test('saveSettings persists and getSettings returns it', () async {
      final s = await ds.getSettings();
      s.restrictedModeEnabled = true;
      s.unlockTimeoutMs = 600000;
      await ds.saveSettings(s);

      final read = await ds.getSettings();
      check(read.restrictedModeEnabled).isTrue();
      check(read.unlockTimeoutMs).equals(600000);
    });

    test('watchSettings emits on save', () async {
      final emissions = <ParentalControlSettings>[];
      final sub = ds.watchSettings().listen(emissions.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final s = await ds.getSettings();
      s.restrictedModeEnabled = true;
      await ds.saveSettings(s);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      check(emissions.length).isGreaterOrEqual(1);
      check(emissions.last.restrictedModeEnabled).isTrue();
    });

    test('setHideExplicit upserts per-podcast flag', () async {
      await ds.setHideExplicit(itunesId: 42, hide: true);
      final f = await ds.getFlags(42);
      check(f).isNotNull();
      check(f!.hideExplicitEpisodes).isTrue();

      await ds.setHideExplicit(itunesId: 42, hide: false);
      final f2 = await ds.getFlags(42);
      check(f2!.hideExplicitEpisodes).isFalse();
    });

    test('pruneFlagsFor removes the row', () async {
      await ds.setHideExplicit(itunesId: 42, hide: true);
      await ds.pruneFlagsFor(42);
      check(await ds.getFlags(42)).isNull();
    });

    test('watchHideExplicit emits on change', () async {
      final emissions = <bool>[];
      final sub = ds.watchHideExplicit(42).listen(emissions.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await ds.setHideExplicit(itunesId: 42, hide: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      check(emissions.last).isTrue();
    });

    test(
      'watchHideExplicit emits false initially when no row exists',
      () async {
        final emissions = <bool>[];
        final sub = ds.watchHideExplicit(999).listen(emissions.add);
        addTearDown(sub.cancel);

        await Future<void>.delayed(const Duration(milliseconds: 100));
        check(emissions).isNotEmpty();
        check(emissions.first).isFalse();
      },
    );

    test('pruneFlagsFor is a no-op when no row exists', () async {
      // Should not throw and leave the collection empty.
      await ds.pruneFlagsFor(12345);
      final count = await isar.podcastParentalFlags.count();
      check(count).equals(0);
    });
  });
}

extension on Subject<int> {
  void isGreaterOrEqual(int v) {
    has((x) => v <= x, 'is >= $v').isTrue();
  }
}
