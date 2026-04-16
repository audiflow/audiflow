import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';

/// In-memory fake for [PlayOrderPreferenceLocalDatasource].
class FakePlayOrderPreferenceLocalDatasource
    implements PlayOrderPreferenceLocalDatasource {
  final _podcastOrders = <int, String?>{};
  final _playlistOrders = <String, String?>{};
  final _groupOrders = <String, String?>{};

  String _playlistKey(int podcastId, String playlistId) =>
      '$podcastId:$playlistId';

  String _groupKey(int podcastId, String playlistId, String groupId) =>
      '$podcastId:$playlistId:$groupId';

  @override
  Future<String?> getPodcastPlayOrder(int podcastId) async =>
      _podcastOrders[podcastId];

  @override
  Future<void> setPodcastPlayOrder(int podcastId, String? order) async {
    _podcastOrders[podcastId] = order;
  }

  @override
  Future<String?> getPlaylistPlayOrder(
    int podcastId,
    String playlistId,
  ) async => _playlistOrders[_playlistKey(podcastId, playlistId)];

  @override
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    String? order,
  ) async {
    final key = _playlistKey(podcastId, playlistId);
    if (order == null) {
      _playlistOrders.remove(key);
    } else {
      _playlistOrders[key] = order;
    }
  }

  @override
  Future<String?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  ) async => _groupOrders[_groupKey(podcastId, playlistId, groupId)];

  @override
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    String? order,
  ) async {
    final key = _groupKey(podcastId, playlistId, groupId);
    if (order == null) {
      _groupOrders.remove(key);
    } else {
      _groupOrders[key] = order;
    }
  }
}

void main() {
  late FakePlayOrderPreferenceLocalDatasource fakeDatasource;
  late FakeAppSettingsRepository fakeSettings;
  late PlayOrderPreferenceRepositoryImpl repository;

  setUp(() {
    fakeDatasource = FakePlayOrderPreferenceLocalDatasource();
    fakeSettings = FakeAppSettingsRepository();
    repository = PlayOrderPreferenceRepositoryImpl(
      fakeDatasource,
      fakeSettings,
    );
  });

  group('podcast play order', () {
    test('returns null when not set', () async {
      final result = await repository.getPodcastPlayOrder(1);
      check(result).isNull();
    });

    test('stores and retrieves oldestFirst', () async {
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.oldestFirst);
      final result = await repository.getPodcastPlayOrder(1);
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('stores and retrieves asDisplayed', () async {
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.asDisplayed);
      final result = await repository.getPodcastPlayOrder(1);
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('setting defaultOrder stores null', () async {
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.oldestFirst);
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.defaultOrder);
      final result = await repository.getPodcastPlayOrder(1);
      check(result).isNull();
    });

    test('setting null clears value', () async {
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.oldestFirst);
      await repository.setPodcastPlayOrder(1, null);
      final result = await repository.getPodcastPlayOrder(1);
      check(result).isNull();
    });
  });

  group('playlist play order', () {
    test('returns null when not set', () async {
      final result = await repository.getPlaylistPlayOrder(1, 'pl1');
      check(result).isNull();
    });

    test('stores and retrieves a value', () async {
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.asDisplayed,
      );
      final result = await repository.getPlaylistPlayOrder(1, 'pl1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('setting defaultOrder stores null', () async {
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.oldestFirst,
      );
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.defaultOrder,
      );
      final result = await repository.getPlaylistPlayOrder(1, 'pl1');
      check(result).isNull();
    });
  });

  group('group play order', () {
    test('returns null when not set', () async {
      final result = await repository.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).isNull();
    });

    test('stores and retrieves a value', () async {
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.oldestFirst,
      );
      final result = await repository.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('setting defaultOrder stores null', () async {
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.asDisplayed,
      );
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.defaultOrder,
      );
      final result = await repository.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).isNull();
    });
  });

  group('resolveForPodcast', () {
    test('returns global when no podcast override', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('returns podcast override when set', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.asDisplayed);
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('falls through defaultOrder to global', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.defaultOrder);
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.asDisplayed);
    });
  });

  group('resolveForPlaylist', () {
    test('returns global when no overrides', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      final result = await repository.resolveForPlaylist(1, 'pl1');
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('returns playlist override when set', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForPlaylist(1, 'pl1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('skips playlist defaultOrder and uses global', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.defaultOrder,
      );
      final result = await repository.resolveForPlaylist(1, 'pl1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });
  });

  group('resolveForGroup', () {
    test('returns global when no overrides', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      final result = await repository.resolveForGroup(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('returns group override when set', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForGroup(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('falls through group to playlist override', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForGroup(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('falls through group defaultOrder to playlist override', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.defaultOrder,
      );
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForGroup(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('falls through all to global', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.defaultOrder,
      );
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.defaultOrder,
      );
      final result = await repository.resolveForGroup(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('group override wins over playlist override', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPlaylistPlayOrder(
        1,
        'pl1',
        AutoPlayOrder.oldestFirst,
      );
      await repository.setGroupPlayOrder(
        1,
        'pl1',
        'g1',
        AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForGroup(1, 'pl1', 'g1');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });
  });
}
