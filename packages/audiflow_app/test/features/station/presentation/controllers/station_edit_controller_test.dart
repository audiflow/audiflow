import 'dart:async';

import 'package:audiflow_app/features/station/presentation/controllers/station_edit_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import '../station_fakes.dart';

void main() {
  late FakeStationRepository stations;
  late FakeStationPodcastRepository links;
  late FakeReconciler reconciler;
  late ProviderContainer container;

  setUp(() {
    stations = FakeStationRepository();
    links = FakeStationPodcastRepository();
    reconciler = FakeReconciler();
    container = ProviderContainer(
      overrides: [
        stationRepositoryProvider.overrideWithValue(stations),
        stationPodcastRepositoryProvider.overrideWithValue(links),
        stationEpisodeRepositoryProvider.overrideWithValue(
          FakeStationEpisodeRepository(),
        ),
        stationReconcilerServiceProvider.overrideWithValue(reconciler),
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  StationEditController controllerFor(int? stationId) {
    // Keeps the auto-dispose provider alive for the test.
    container.listen(stationEditControllerProvider(stationId), (_, _) {});
    return container.read(stationEditControllerProvider(stationId).notifier);
  }

  Future<Station> existingStation({
    String name = 'Morning',
    List<int> podcastIds = const [1, 2],
  }) async {
    final station = await stations.create(
      Station()
        ..name = name
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026),
    );
    for (final id in podcastIds) {
      await links.add(station.id, id);
    }
    return station;
  }

  group('a new station', () {
    test('is not created until a podcast is selected', () async {
      final controller = controllerFor(null)
        ..useDefaultName('Station 1')
        ..setHideCompleted(true);
      await controller.pendingWrites;
      check(stations.creates).equals(0);

      await controller.updateSelectedPodcasts({7});
      await controller.pendingWrites;
      check(stations.creates).equals(1);
      final created = stations.stations.values.single;
      check(created.name).equals('Station 1');
      check(created.hideCompleted).isTrue();
      check(links.podcastIdsOf(created.id)).deepEquals([7]);
    });

    test('keeps saving to the station it created', () async {
      final controller = controllerFor(null)..useDefaultName('Station 1');
      await controller.updateSelectedPodcasts({7});
      controller.setName('Commute');
      await controller.updateSelectedPodcasts({7, 8});
      await controller.pendingWrites;

      check(stations.creates).equals(1);
      final created = stations.stations.values.single;
      check(created.name).equals('Commute');
      check(links.podcastIdsOf(created.id).toSet()).deepEquals({7, 8});
    });

    test('falls back to the default name when the name is cleared', () async {
      final controller = controllerFor(null)
        ..useDefaultName('Station 1')
        ..setName('  ');
      await controller.updateSelectedPodcasts({7});
      await controller.pendingWrites;
      check(stations.stations.values.single.name).equals('Station 1');
    });

    test('reports the station limit', () async {
      for (var i = 0; i < StationLimitExceededException.maxStations; i++) {
        await existingStation(name: 'S$i');
      }
      final controller = controllerFor(null)..useDefaultName('Station 16');
      await controller.updateSelectedPodcasts({7});
      await controller.pendingWrites;
      check(
        StationEditError.isLimitReached(
          container.read(stationEditControllerProvider(null)).error!,
        ),
      ).isTrue();
    });
  });

  group('an existing station', () {
    test('saves an empty podcast selection', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      await controller.updateSelectedPodcasts({});
      await controller.pendingWrites;
      check(links.podcastIdsOf(station.id)).isEmpty();
      check(stations.stations).containsKey(station.id);
    });

    test('keeps its saved name while the field is empty', () async {
      final station = await existingStation(name: 'Morning');
      final controller = controllerFor(station.id);
      await controller.loaded;
      controller
        ..setName('')
        ..setHideCompleted(true);
      await controller.pendingWrites;
      check(stations.stations[station.id]!.name).equals('Morning');
      check(stations.stations[station.id]!.hideCompleted).isTrue();
    });

    test('is not written before it has loaded', () async {
      final station = await existingStation(name: 'Morning');
      final controller = controllerFor(station.id)..setHideCompleted(true);
      await controller.pendingWrites;
      await controller.loaded;
      check(stations.stations[station.id]!.hideCompleted).isFalse();
    });

    test('is not written again after it is deleted', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      controller.setHideCompleted(true);
      check(await controller.delete()).isTrue();
      controller.setHideCompleted(false);
      await controller.pendingWrites;
      check(stations.stations).isEmpty();
      check(links.links).isEmpty();
    });
  });

  group('reconcile', () {
    test('waits for the edits to settle', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      controller
        ..setHideCompleted(true)
        ..setFilterDownloaded(true);
      await controller.pendingWrites;
      check(reconciler.reconciled).isEmpty();
    });

    test('runs once when the editor closes', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      controller
        ..setHideCompleted(true)
        ..setFilterDownloaded(true);
      final writes = controller.pendingWrites;
      container.dispose();
      await writes;
      await pumpEventQueue();
      check(reconciler.reconciled).deepEquals([station.id]);
    });
  });

  group('closing the editor', () {
    test('a reopened editor loads after the earlier saves', () async {
      final station = await existingStation();
      final first = container.listen(
        stationEditControllerProvider(station.id),
        (_, _) {},
      );
      final firstController = container.read(
        stationEditControllerProvider(station.id).notifier,
      );
      await firstController.loaded;
      stations.updateGate = Completer<void>();
      firstController.setHideCompleted(true);
      first.close();
      await pumpEventQueue();

      // Reopen while the first editor's save is still in flight.
      final reopened = controllerFor(station.id);
      var loaded = false;
      unawaited(reopened.loaded.then((_) => loaded = true));
      await pumpEventQueue();
      check(loaded).isFalse();

      stations.updateGate!.complete();
      await reopened.loaded;
      check(
        container.read(stationEditControllerProvider(station.id)).hideCompleted,
      ).isTrue();
    });

    test('keeps a sort change made just before it', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      // Automatic sorts read subscriptions before updating the display.
      unawaited(controller.setPodcastSort(StationPodcastSort.nameAsc));
      final writes = controller.pendingWrites;
      container.dispose();
      await writes;
      check(
        stations.stations[station.id]!.podcastSort,
      ).equals(StationPodcastSort.nameAsc);
    });
  });

  group('rebuilds', () {
    setUp(() => StationEditController.reconcileDelay = Duration.zero);
    tearDown(
      () => StationEditController.reconcileDelay = const Duration(
        milliseconds: 800,
      ),
    );

    test('a delete waits for a running rebuild', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      reconciler.gate = Completer<void>();
      controller.setHideCompleted(true);
      await controller.pendingWrites;
      await pumpEventQueue();
      check(reconciler.started).deepEquals([station.id]);

      final deleted = controller.delete();
      await pumpEventQueue();
      // Still there: deleting now would let the rebuild write rows after.
      check(stations.stations).containsKey(station.id);

      reconciler.gate!.complete();
      check(await deleted).isTrue();
      check(reconciler.reconciled).deepEquals([station.id]);
      check(stations.stations).isEmpty();
    });

    test('run one at a time', () async {
      final station = await existingStation();
      final controller = controllerFor(station.id);
      await controller.loaded;
      reconciler.gate = Completer<void>();
      controller.setHideCompleted(true);
      await controller.pendingWrites;
      await pumpEventQueue();
      controller.setHideCompleted(false);
      await controller.pendingWrites;
      await pumpEventQueue();
      // The second waits for the first.
      check(reconciler.started).deepEquals([station.id]);

      reconciler.gate!.complete();
      await pumpEventQueue();
      check(reconciler.reconciled).deepEquals([station.id, station.id]);
    });
  });

  group('a new station without a name yet', () {
    test('names itself when the default has not arrived yet', () async {
      final controller = controllerFor(null)
        ..useDefaultNameLabel((number) => 'Station $number');
      await controller.updateSelectedPodcasts({7});
      await controller.pendingWrites;
      check(stations.stations.values.single.name).equals('Station 1');
    });

    test('is still created when the editor closes first', () async {
      await existingStation(name: 'Station 1');
      final controller = controllerFor(null)
        ..useDefaultNameLabel((number) => 'Station $number');
      unawaited(controller.updateSelectedPodcasts({7}));
      final writes = controller.pendingWrites;
      // Closed before the screen's name lookup could finish.
      container.dispose();
      await writes;
      final created = stations.stations.values.where((s) => s.id != 1);
      check(created.single.name).equals('Station 2');
    });

    test('reports its id once created, so it can be deleted', () async {
      final controller = controllerFor(null)..useDefaultName('Station 1');
      check(
        container.read(stationEditControllerProvider(null)).savedStationId,
      ).isNull();
      await controller.updateSelectedPodcasts({7});
      await controller.pendingWrites;
      check(
        container.read(stationEditControllerProvider(null)).savedStationId,
      ).equals(stations.stations.values.single.id);
    });
  });

  group('a station that fails to load', () {
    test('is never written over', () async {
      final station = await existingStation(name: 'Morning');
      links.failReads = true;
      final controller = controllerFor(station.id);
      await controller.loaded;
      check(
        container.read(stationEditControllerProvider(station.id)).loadFailed,
      ).isTrue();

      controller.setHideCompleted(true);
      await controller.pendingWrites;
      check(stations.stations[station.id]!.hideCompleted).isFalse();
      links.failReads = false;
      check(links.podcastIdsOf(station.id)).deepEquals([1, 2]);
    });

    test('reports a missing station as failed', () async {
      final controller = controllerFor(99);
      await controller.loaded;
      check(
        container.read(stationEditControllerProvider(99)).loadFailed,
      ).isTrue();
    });
  });
}
