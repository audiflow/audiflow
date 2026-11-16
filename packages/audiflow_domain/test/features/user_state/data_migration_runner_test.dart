import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

class _Step implements DataMigrationStep {
  _Step(this.version, this.log, {this.failuresLeft = 0, this.during});

  @override
  final int version;

  final List<int> log;

  int failuresLeft;

  /// Runs inside the step, standing in for another runner's work.
  final Future<void> Function(Isar isar)? during;

  @override
  String get name => 'step $version';

  @override
  Future<void> run(Isar isar) async {
    log.add(version);
    await during?.call(isar);
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

    check(log).deepEquals([1, 2, 5]);
    check((await meta())?.schemaVersion).equals(5);
  });

  test('skips steps that already ran', () async {
    final log = <int>[];
    final steps = [_Step(1, log), _Step(2, log)];
    await DataMigrationRunner(isar, steps: steps).run();
    log.clear();

    await DataMigrationRunner(isar, steps: [...steps, _Step(3, log)]).run();

    check(log).deepEquals([3]);
    check((await meta())?.schemaVersion).equals(3);
  });

  test(
    'keeps earlier steps done and retries a failed one next launch',
    () async {
      final log = <int>[];
      final failing = _Step(2, log, failuresLeft: 1);
      final steps = [_Step(1, log), failing, _Step(3, log)];

      await check(
        DataMigrationRunner(isar, steps: steps).run(),
      ).throws<StateError>();
      check(log).deepEquals([1, 2]);
      check((await meta())?.schemaVersion).equals(1);

      log.clear();
      await DataMigrationRunner(isar, steps: steps).run();

      check(log).deepEquals([2, 3]);
      check((await meta())?.schemaVersion).equals(3);
    },
  );

  test('two runners at once finish every step once recorded', () async {
    final log = <int>[];
    final steps = [_Step(1, log), _Step(2, log)];

    await Future.wait([
      DataMigrationRunner(isar, steps: steps).run(),
      DataMigrationRunner(isar, steps: steps).run(),
    ]);

    check(log.toSet()).deepEquals({1, 2});
    check((await meta())?.schemaVersion).equals(2);
  });

  test('a slower runner never lowers the recorded version', () async {
    final log = <int>[];
    // Another runner records step 3 while this one is still in step 1.
    final slow = _Step(
      1,
      log,
      during: (isar) => isar.writeTxn(() async {
        final row = await isar.syncMetas.get(SyncMeta.singletonId);
        await isar.syncMetas.put(row!..schemaVersion = 3);
      }),
    );

    await DataMigrationRunner(
      isar,
      steps: [slow, _Step(2, log), _Step(3, log), _Step(4, log)],
    ).run();

    check(log).deepEquals([1, 4]);
    check((await meta())?.schemaVersion).equals(4);
  });

  test('rejects versions that do not strictly increase', () {
    check(
      () => DataMigrationRunner(isar, steps: [_Step(2, []), _Step(2, [])]),
    ).throws<ArgumentError>();
    check(
      () => DataMigrationRunner(isar, steps: [_Step(3, []), _Step(1, [])]),
    ).throws<ArgumentError>();
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

    check((await meta())?.historyId).equals('first');
  });

  test('records the device id once and never replaces it', () async {
    await DataMigrationRunner(isar, steps: const [], deviceId: 'a').run();
    await DataMigrationRunner(isar, steps: const [], deviceId: 'b').run();
    await DataMigrationRunner(isar, steps: const []).run();

    check((await meta())?.deviceId).equals('a');
  });

  test(
    'records the device id on a later launch when the first had none',
    () async {
      await DataMigrationRunner(isar, steps: const []).run();
      check((await meta())?.deviceId).isNull();

      await DataMigrationRunner(isar, steps: const [], deviceId: 'a').run();

      check((await meta())?.deviceId).equals('a');
    },
  );

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

    check((await meta())?.historyId).equals('after-reset');
  });
}
