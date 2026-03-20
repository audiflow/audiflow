import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late StationLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([StationSchema]);
    datasource = StationLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Station makeStation({String name = 'My Station', int sortOrder = 0}) {
    final now = DateTime(2026, 3, 20);
    return Station()
      ..name = name
      ..sortOrder = sortOrder
      ..createdAt = now
      ..updatedAt = now;
  }

  group('insert', () {
    test('inserts station and returns it with generated id', () async {
      final result = await datasource.insert(makeStation());

      check(0 < result.id).isTrue();
      check(result.name).equals('My Station');
    });
  });

  group('getById', () {
    test('returns station when found', () async {
      final inserted = await datasource.insert(makeStation());

      final result = await datasource.getById(inserted.id);

      check(result).isNotNull();
      check(result!.name).equals('My Station');
    });

    test('returns null when not found', () async {
      final result = await datasource.getById(999);

      check(result).isNull();
    });
  });

  group('getAll', () {
    test('returns empty list when no stations exist', () async {
      final result = await datasource.getAll();

      check(result).isEmpty();
    });

    test('returns stations sorted by sortOrder ascending', () async {
      await datasource.insert(makeStation(name: 'C', sortOrder: 2));
      await datasource.insert(makeStation(name: 'A', sortOrder: 0));
      await datasource.insert(makeStation(name: 'B', sortOrder: 1));

      final result = await datasource.getAll();

      check(result).length.equals(3);
      check(result[0].name).equals('A');
      check(result[1].name).equals('B');
      check(result[2].name).equals('C');
    });
  });

  group('watchAll', () {
    test('emits on insert', () async {
      await datasource.insert(makeStation(name: 'First'));

      final result = await datasource.watchAll().first;

      check(result).length.equals(1);
      check(result.first.name).equals('First');
    });
  });

  group('count', () {
    test('returns correct number of stations', () async {
      check(await datasource.count()).equals(0);

      await datasource.insert(makeStation(name: 'A'));
      await datasource.insert(makeStation(name: 'B'));

      check(await datasource.count()).equals(2);
    });
  });

  group('delete', () {
    test('removes existing station and returns true', () async {
      final station = await datasource.insert(makeStation());

      final deleted = await datasource.delete(station.id);

      check(deleted).isTrue();
      check(await datasource.getById(station.id)).isNull();
    });

    test('returns false when station does not exist', () async {
      final deleted = await datasource.delete(999);

      check(deleted).isFalse();
    });
  });

  group('reorder', () {
    test('updates sortOrder to match list index', () async {
      final a = await datasource.insert(makeStation(name: 'A', sortOrder: 0));
      final b = await datasource.insert(makeStation(name: 'B', sortOrder: 1));
      final c = await datasource.insert(makeStation(name: 'C', sortOrder: 2));

      // Reverse the order
      await datasource.reorder([c.id, b.id, a.id]);

      final all = await datasource.getAll();
      check(all[0].name).equals('C');
      check(all[0].sortOrder).equals(0);
      check(all[1].name).equals('B');
      check(all[1].sortOrder).equals(1);
      check(all[2].name).equals('A');
      check(all[2].sortOrder).equals(2);
    });
  });
}
