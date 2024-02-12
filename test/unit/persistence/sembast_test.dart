import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_repository.dart';

import '../mocks/mock_path_provider.dart';

void main() {
  MockPathProvder mockPath;
  Repository? persistenceService;

  const podcast1 = Podcast(
    title: 'Podcast 1',
    description: '1st podcast',
    guid: 'http://p1.com',
    link: 'http://p1.com',
    url: 'http://p1.com',
  );

  const podcast2 = Podcast(
    title: 'Podcast 2',
    description: '2nd podcast',
    guid: 'http://p2.com',
    link: 'http://p2.com',
    url: 'http://p2.com',
  );

  setUp(() async {
    mockPath = MockPathProvder();
    PathProviderPlatform.instance = mockPath;
  });

  final numberFormat = NumberFormat('000');

  List<Episode> createEpisodeMocks(Podcast podcast, int count) {
    return Iterable<int>.generate(count)
        .map(
          (i) => Episode(
            pguid: podcast.guid,
            podcast: podcast.title,
            guid: 'EP${numberFormat.format(i + 1)}',
            title: 'Title ${i + 1}',
            description: 'desc ${i + 1}',
            contentUrl: 'http://example.com/episode${i + 1}.mp3',
            imageUrl: 'http://example.com/image.jpg',
            thumbImageUrl: 'http://example.com/thumb.jpg',
            publicationDate: DateTime.now().add(Duration(days: -i)),
          ),
        )
        .toList();
  }

  void createRepository() {
    persistenceService = SembastRepository(cleanup: false);
  }

  Future<void> cleanUpRepository() async {
    await persistenceService!.close();
    persistenceService = null;

    final f = File('${Directory.systemTemp.path}/seasoning.db');
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  /// Test the creation and retrieval of podcasts both with and without
  /// episodes. Ensure that data fetched is equal to the data originally
  /// stored.
  group('Podcast', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('Fetch podcast with non-existent ID', () async {
      final actual = await persistenceService!.findPodcastById(123);
      expect(actual, null);
    });

    late Podcast saved;

    test('savePodcast', () async {
      saved = await persistenceService!.savePodcast(podcast1);
      expect(saved.id, isNotNull);
      expect(saved.guid, isNotNull);
      expect(saved.subscribedDate, isNotNull);
      expect(saved.subscribed, isTrue);
    });

    test('findPodcastById', () async {
      final loaded = await persistenceService!.findPodcastById(saved.id!);
      expect(loaded, saved);
      expect(loaded!.guid, isNotNull);
      expect(loaded.subscribedDate, isNotNull);
      expect(loaded.subscribed, isTrue);
    });

    test('findPodcastByGuid', () async {
      final loaded = await persistenceService!.findPodcastByGuid(saved.guid);
      expect(loaded, saved);
      expect(loaded!.guid, isNotNull);
    });

    test('subscriptions', () async {
      final loaded = await persistenceService!.subscriptions();
      expect(loaded, hasLength(1));
      expect(loaded[0], saved);
    });

    test('Update', () async {
      final updated = saved.copyWith(title: '${saved.title} updated');
      final saved2 = await persistenceService!.savePodcast(updated);
      expect(updated == saved2, isTrue);

      final loaded = await persistenceService!.findPodcastById(saved.id!);
      expect(loaded, saved2);
      expect(
        loaded!.subscribedDate!.isAtSameMomentAs(saved2.subscribedDate!),
        isTrue,
      );
    });

    test('deletePodcast', () async {
      await persistenceService!.deletePodcast(saved);
      final loaded = await persistenceService!.findPodcastById(saved.id!);
      expect(loaded, isNull);

      // deletePodcast twice should do nothing.
      await persistenceService!.deletePodcast(saved);
    });

    test('Save another podcast. It should have a new ID', () async {
      final saved2 = await persistenceService!.savePodcast(podcast1);
      expect(saved.id == saved2.id, isFalse);
    });
  });

  group('Episode', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    late List<Episode> saved;
    test('Create and save', () async {
      final episodes = createEpisodeMocks(podcast1, 3);
      saved = await persistenceService!.saveEpisodes(episodes);
      expect(saved[0].id, isNotNull);
      expect(saved[2].id, isNotNull);
      expect(saved[0].id == saved[2].id, isFalse);
    });

    test('Load', () async {
      final loaded =
          await persistenceService!.findEpisodesByPodcastGuid(podcast1.guid);
      expect(loaded.length, saved.length);
      expect(loaded[0].title, saved[0].title);
    });

    test('Update all episodes', () async {
      final updated = [...saved];
      updated[1] = updated[1].copyWith(title: '${updated[1].title} updated');
      final saved2 = await persistenceService!.saveEpisodes(updated);

      final loaded =
          await persistenceService!.findEpisodesByPodcastGuid(podcast1.guid);
      expect(loaded.length, saved.length);
      expect(listEquals(loaded, saved2), isTrue);

      expect(loaded[1].title == saved[1].title, isFalse);
    });

    test('Update single episode', () async {
      final saved2 = await persistenceService!
          .saveEpisode(saved[2].copyWith(title: '${saved[2].title} updated'));
      expect(saved2.id, saved[2].id);
      expect(saved2.title == saved[2].title, isFalse);

      final loaded =
          await persistenceService!.findEpisodesByPodcastGuid(podcast1.guid);
      expect(loaded[2].title == saved[2].title, isFalse);
    });

    test('Delete', () async {
      await persistenceService!.deleteEpisode(saved[1]);

      final loaded =
          await persistenceService!.findEpisodesByPodcastGuid(podcast1.guid);
      expect(loaded, hasLength(2));
      expect(loaded[0].id, saved[0].id);
      expect(loaded[1].id, saved[2].id);
    });
  });

  group('Queue', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    late List<Episode> saved1;
    late List<Episode> saved2;

    test('empty', () async {
      final loaded = await persistenceService!.loadQueue();
      expect(loaded, isEmpty);
    });

    test('Create and save', () async {
      final episodes1 = createEpisodeMocks(podcast1, 3);
      final episodes2 = createEpisodeMocks(podcast2, 3);
      saved1 = await persistenceService!.saveEpisodes(episodes1);
      saved2 = await persistenceService!.saveEpisodes(episodes2);

      final queue = [...saved1, ...saved2];
      await persistenceService!.saveQueue(queue);

      final loaded = await persistenceService!.loadQueue();
      expect(listEquals(queue, loaded), isTrue);
    });
  });

  group('Downloads', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    late List<Downloadable> saved;

    test('findDownloads but empty', () async {
      final loaded = await persistenceService!.findDownloads();
      expect(loaded, isEmpty);
    });

    test('findDownloadsByPodcastGuid but empty', () async {
      final loaded =
          await persistenceService!.findDownloadsByPodcastGuid(podcast1.guid);
      expect(loaded, isEmpty);
    });

    test('Create and save', () async {
      final episodes = createEpisodeMocks(podcast1, 3);
      final list = episodes.map(
        (e) => Downloadable(
          pguid: e.pguid,
          guid: e.guid,
          url: e.contentUrl!,
          directory: 'dir',
          filename: '${e.guid}.mp3',
          taskId: 'TASK${e.guid}',
          state: e == episodes[0]
              ? DownloadState.none
              : e == episodes[1]
                  ? DownloadState.downloading
                  : DownloadState.downloaded,
          percentage: e == episodes[0]
              ? 0
              : e == episodes[1]
                  ? 99
                  : 100,
        ),
      );
      saved = await Future.wait(
        list.map((d) => persistenceService!.saveDownload(d)),
      );
    });

    test('findDownloads', () async {
      final loaded = await persistenceService!.findDownloads();
      expect(loaded, hasLength(3));
    });

    test('findDownloads', () async {
      var loaded =
          await persistenceService!.findDownloadsByPodcastGuid(podcast1.guid);
      expect(loaded, hasLength(3));

      loaded =
          await persistenceService!.findDownloadsByPodcastGuid(podcast2.guid);
      expect(loaded, isEmpty);
    });

    test('findDownloads', () async {
      final loaded = await persistenceService!
          .findDownloadByTaskId(saved[1].taskId);
      expect(loaded, saved[1]);
    });
  });
}
