import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late FileDeviceOnlyStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('device_only_');
    store = FileDeviceOnlyStore(() async => root.path);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  group('FileDeviceOnlyStore', () {
    test('returns null for a key never written', () async {
      check(await store.read('device_id')).isNull();
    });

    test('reads back what was written, across instances', () async {
      await store.write('device_id', 'abc');

      final again = FileDeviceOnlyStore(() async => root.path);

      check(await again.read('device_id')).equals('abc');
    });

    test('replaces an existing value', () async {
      await store.write('device_id', 'first');
      await store.write('device_id', 'second');

      check(await store.read('device_id')).equals('second');
    });

    test('writes under the directory the backup rules exclude', () async {
      await store.write('install_id', 'abc');

      final file = File(
        p.join(root.path, FileDeviceOnlyStore.directoryName, 'install_id'),
      );
      check(await file.readAsString()).equals('abc');
    });

    test('rejects a key that could escape the directory', () async {
      await check(
        store.write('../outside', 'x'),
      ).throws<ArgumentError>();
    });
  });
}
