import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:audiflow_domain/src/features/station/datasources/local/station_local_datasource.dart';
import 'package:audiflow_domain/src/features/station/models/station.dart';
import 'package:audiflow_domain/src/features/station/repositories/station_repository.dart';
import 'package:audiflow_domain/src/features/station/repositories/station_repository_impl.dart';

import '../../../helpers/isar_test_helper.dart';

Station _buildStation(String name) => Station()
  ..name = name
  ..createdAt = DateTime.now()
  ..updatedAt = DateTime.now();

void main() {
  late Isar isar;
  late StationRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([StationSchema]);
    final datasource = StationLocalDatasource(isar);
    repository = StationRepositoryImpl(datasource: datasource);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('create', () {
    test('allows creating up to 15 stations', () async {
      for (var i = 0; i < StationLimitExceededException.maxStations; i++) {
        await repository.create(_buildStation('Station $i'));
      }

      final count = await repository.count();
      check(count).equals(StationLimitExceededException.maxStations);
    });

    test('throws StationLimitExceededException on the 16th station', () async {
      for (var i = 0; i < StationLimitExceededException.maxStations; i++) {
        await repository.create(_buildStation('Station $i'));
      }

      await check(
        repository.create(_buildStation('Over the limit')),
      ).throws<StationLimitExceededException>();
    });
  });

  group('markPlayed', () {
    test('records when the station was last played', () async {
      final station = await repository.create(_buildStation('Morning'));
      final updatedAt = station.updatedAt;
      final at = DateTime(2026, 10, 8, 9);

      await repository.markPlayed(station.id, at: at);

      final stored = await repository.findById(station.id);
      check(stored!.lastPlayedAt).equals(at);
      // Playing is not an edit.
      check(stored.updatedAt).equals(updatedAt);
    });

    test('ignores a station that no longer exists', () async {
      await repository.markPlayed(999, at: DateTime(2026));
      check(await repository.count()).equals(0);
    });
  });
}
