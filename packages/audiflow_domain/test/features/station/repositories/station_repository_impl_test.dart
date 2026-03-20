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
}
