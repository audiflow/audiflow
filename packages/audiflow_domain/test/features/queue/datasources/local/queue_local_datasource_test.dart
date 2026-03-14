import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late QueueLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [QueueItemSchema],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    datasource = QueueLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  QueueItem makeItem({
    required int episodeId,
    required int position,
    bool isAdhoc = false,
    String? sourceContext,
  }) {
    return QueueItem()
      ..episodeId = episodeId
      ..position = position
      ..isAdhoc = isAdhoc
      ..sourceContext = sourceContext
      ..addedAt = DateTime.now();
  }

  group('insert', () {
    test('inserts queue item and returns id', () async {
      final id = await datasource.insert(makeItem(episodeId: 1, position: 0));

      expect(0 < id, true);
    });
  });

  group('getAll', () {
    test('returns empty list when queue is empty', () async {
      final items = await datasource.getAll();

      expect(items, isEmpty);
    });

    test('returns items ordered by position ascending', () async {
      await datasource.insert(makeItem(episodeId: 2, position: 20));
      await datasource.insert(makeItem(episodeId: 1, position: 0));
      await datasource.insert(makeItem(episodeId: 3, position: 10));

      final items = await datasource.getAll();

      expect(items, hasLength(3));
      expect(items[0].episodeId, 1);
      expect(items[1].episodeId, 3);
      expect(items[2].episodeId, 2);
    });
  });

  group('watchAll', () {
    test('emits current queue items', () async {
      await datasource.insert(makeItem(episodeId: 1, position: 0));

      final result = await datasource.watchAll().first;

      expect(result, hasLength(1));
    });
  });

  group('getMaxPosition', () {
    test('returns -10 when queue is empty', () async {
      final max = await datasource.getMaxPosition();

      expect(max, -10);
    });

    test('returns maximum position value', () async {
      await datasource.insert(makeItem(episodeId: 1, position: 0));
      await datasource.insert(makeItem(episodeId: 2, position: 30));
      await datasource.insert(makeItem(episodeId: 3, position: 10));

      final max = await datasource.getMaxPosition();

      expect(max, 30);
    });
  });

  group('getMinPosition', () {
    test('returns 10 when queue is empty', () async {
      final min = await datasource.getMinPosition();

      expect(min, 10);
    });

    test('returns minimum position value', () async {
      await datasource.insert(makeItem(episodeId: 1, position: 5));
      await datasource.insert(makeItem(episodeId: 2, position: 30));
      await datasource.insert(makeItem(episodeId: 3, position: 10));

      final min = await datasource.getMinPosition();

      expect(min, 5);
    });
  });

  group('updatePosition', () {
    test('updates position of a queue item', () async {
      final id = await datasource.insert(makeItem(episodeId: 1, position: 0));

      await datasource.updatePosition(id, 50);

      final items = await datasource.getAll();
      expect(items.first.position, 50);
    });
  });

  group('deleteById', () {
    test('removes a queue item', () async {
      final id = await datasource.insert(makeItem(episodeId: 1, position: 0));

      final deleted = await datasource.deleteById(id);

      expect(deleted, 1);
      final items = await datasource.getAll();
      expect(items, isEmpty);
    });

    test('returns 0 when item does not exist', () async {
      final deleted = await datasource.deleteById(999);

      expect(deleted, 0);
    });
  });

  group('deleteAll', () {
    test('removes all queue items', () async {
      await datasource.insert(makeItem(episodeId: 1, position: 0));
      await datasource.insert(makeItem(episodeId: 2, position: 10));

      await datasource.deleteAll();

      final items = await datasource.getAll();
      expect(items, isEmpty);
    });
  });

  group('deleteAllAdhoc', () {
    test('removes only adhoc items', () async {
      await datasource.insert(
        makeItem(episodeId: 1, position: 0, isAdhoc: false),
      );
      await datasource.insert(
        makeItem(episodeId: 2, position: 10, isAdhoc: true),
      );
      await datasource.insert(
        makeItem(episodeId: 3, position: 20, isAdhoc: true),
      );

      final deleted = await datasource.deleteAllAdhoc();

      expect(deleted, 2);
      final items = await datasource.getAll();
      expect(items, hasLength(1));
      expect(items.first.episodeId, 1);
    });
  });

  group('deleteAllManual', () {
    test('removes only manual items', () async {
      await datasource.insert(
        makeItem(episodeId: 1, position: 0, isAdhoc: false),
      );
      await datasource.insert(
        makeItem(episodeId: 2, position: 10, isAdhoc: true),
      );

      final deleted = await datasource.deleteAllManual();

      expect(deleted, 1);
      final items = await datasource.getAll();
      expect(items, hasLength(1));
      expect(items.first.isAdhoc, true);
    });
  });

  group('getManualCount', () {
    test('returns 0 when queue is empty', () async {
      final count = await datasource.getManualCount();

      expect(count, 0);
    });

    test('counts only manual items', () async {
      await datasource.insert(
        makeItem(episodeId: 1, position: 0, isAdhoc: false),
      );
      await datasource.insert(
        makeItem(episodeId: 2, position: 10, isAdhoc: false),
      );
      await datasource.insert(
        makeItem(episodeId: 3, position: 20, isAdhoc: true),
      );

      final count = await datasource.getManualCount();

      expect(count, 2);
    });
  });

  group('getAdhocCount', () {
    test('returns 0 when queue is empty', () async {
      final count = await datasource.getAdhocCount();

      expect(count, 0);
    });

    test('counts only adhoc items', () async {
      await datasource.insert(
        makeItem(episodeId: 1, position: 0, isAdhoc: false),
      );
      await datasource.insert(
        makeItem(episodeId: 2, position: 10, isAdhoc: true),
      );

      final count = await datasource.getAdhocCount();

      expect(count, 1);
    });
  });

  group('shiftPositions', () {
    test('shifts all positions by delta', () async {
      await datasource.insert(makeItem(episodeId: 1, position: 0));
      await datasource.insert(makeItem(episodeId: 2, position: 10));

      await datasource.shiftPositions(5);

      final items = await datasource.getAll();
      expect(items[0].position, 5);
      expect(items[1].position, 15);
    });
  });

  group('shiftPositionsFrom', () {
    test('shifts positions at or after given position', () async {
      await datasource.insert(makeItem(episodeId: 1, position: 0));
      await datasource.insert(makeItem(episodeId: 2, position: 10));
      await datasource.insert(makeItem(episodeId: 3, position: 20));

      await datasource.shiftPositionsFrom(10, 5);

      final items = await datasource.getAll();
      expect(items[0].position, 0);
      expect(items[1].position, 15);
      expect(items[2].position, 25);
    });
  });
}
