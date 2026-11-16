import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

class _Step implements DataMigrationStep {
  _Step(this.version, this.log, {this.failuresLeft = 0});

  @override
  final int version;

  final List<int> log;

  int failuresLeft;

  @override
  String get name => 'step $version';

  @override
  Future<void> run(Isar isar) async {
    log.add(version);
    if (0 < failuresLeft) {
      failuresLeft--;
      throw StateError('step $version failed');
    }
  }
}

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([]);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<SyncMeta?> meta() => isar.syncMetas.get(SyncMeta.singletonId);

  test('runs pending steps in order and records the last one', () async {
    final log = <int>[];

    await DataMigrationRunner(
      isar,
      steps: [_Step(1, log), _Step(2, log), _Step(5, log)],
    ).run();

    expect(log, [1, 2, 5]);
    expect((await meta())?.schemaVersion, 5);
  });

  test('skips steps that already ran', () async {
    final log = <int>[];
    final steps = [_Step(1, log), _Step(2, log)];
    await DataMigrationRunner(isar, steps: steps).run();
    log.clear();

    await DataMigrationRunner(isar, steps: [...steps, _Step(3, log)]).run();

    expect(log, [3]);
    expect((await meta())?.schemaVersion, 3);
  });

  test(
    'keeps earlier steps done and retries a failed one next launch',
    () async {
      final log = <int>[];
      final failing = _Step(2, log, failuresLeft: 1);
      final steps = [_Step(1, log), failing, _Step(3, log)];

      await expectLater(
        DataMigrationRunner(isar, steps: steps).run(),
        throwsStateError,
      );
      expect(log, [1, 2]);
      expect((await meta())?.schemaVersion, 1);

      log.clear();
      await DataMigrationRunner(isar, steps: steps).run();

      expect(log, [2, 3]);
      expect((await meta())?.schemaVersion, 3);
    },
  );

  test('rejects versions that do not strictly increase', () {
    expect(
      () => DataMigrationRunner(isar, steps: [_Step(2, []), _Step(2, [])]),
      throwsArgumentError,
    );
    expect(
      () => DataMigrationRunner(isar, steps: [_Step(3, []), _Step(1, [])]),
      throwsArgumentError,
    );
  });

  test('creates the history on first launch and keeps it after', () async {
    await DataMigrationRunner(
      isar,
      steps: const [],
      createHistoryId: () => 'first',
    ).run();
    await DataMigrationRunner(
      isar,
      steps: const [],
      createHistoryId: () => 'second',
    ).run();

    expect((await meta())?.historyId, 'first');
  });

  test('starts a new history after every collection is cleared', () async {
    await DataMigrationRunner(
      isar,
      steps: const [],
      createHistoryId: () => 'before-reset',
    ).run();
    // What "Reset All Data" does to Isar.
    await isar.writeTxn(() => isar.clear());

    await DataMigrationRunner(
      isar,
      steps: const [],
      createHistoryId: () => 'after-reset',
    ).run();

    expect((await meta())?.historyId, 'after-reset');
  });
}
