import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

QueueItemWithEpisode _makeItem({
  required int id,
  required String title,
  required String audioUrl,
  bool isAdhoc = false,
}) {
  final episode = Episode()
    ..id = id
    ..podcastId = 1
    ..guid = 'guid-$id'
    ..title = title
    ..audioUrl = audioUrl;

  final queueItem = QueueItem()
    ..id = id
    ..episodeId = id
    ..position = id
    ..isAdhoc = isAdhoc
    ..addedAt = DateTime(2026);

  return QueueItemWithEpisode(queueItem: queueItem, episode: episode);
}

void main() {
  group('PlaybackQueue', () {
    final itemA = _makeItem(id: 1, title: 'A', audioUrl: 'https://a.mp3');
    final itemB = _makeItem(id: 2, title: 'B', audioUrl: 'https://b.mp3');
    final itemC = _makeItem(id: 3, title: 'C', audioUrl: 'https://c.mp3');

    group('upNextItems', () {
      test('excludes episode matching nowPlayingUrl', () {
        final queue = PlaybackQueue(manualItems: [itemA, itemB, itemC]);

        final result = queue.upNextItems(nowPlayingUrl: 'https://a.mp3');

        check(result).length.equals(2);
        check(result[0].episode.title).equals('B');
        check(result[1].episode.title).equals('C');
      });

      test('returns all items when nowPlayingUrl is null', () {
        final queue = PlaybackQueue(manualItems: [itemA, itemB, itemC]);

        final result = queue.upNextItems();

        check(result).length.equals(3);
      });

      test('returns all items when nowPlayingUrl matches nothing', () {
        final queue = PlaybackQueue(manualItems: [itemA, itemB, itemC]);

        final result = queue.upNextItems(nowPlayingUrl: 'https://x.mp3');

        check(result).length.equals(3);
      });

      test('excludes from both manual and adhoc items', () {
        final adhocB = _makeItem(
          id: 4,
          title: 'B2',
          audioUrl: 'https://b.mp3',
          isAdhoc: true,
        );
        final queue = PlaybackQueue(
          manualItems: [itemA],
          adhocItems: [adhocB, itemC],
        );

        final result = queue.upNextItems(nowPlayingUrl: 'https://b.mp3');

        check(result).length.equals(2);
        check(result[0].episode.title).equals('A');
        check(result[1].episode.title).equals('C');
      });

      test('returns empty when single item matches nowPlayingUrl', () {
        final queue = PlaybackQueue(manualItems: [itemA]);

        final result = queue.upNextItems(nowPlayingUrl: 'https://a.mp3');

        check(result).isEmpty();
      });
    });

    group('allItems', () {
      test('combines manual and adhoc items', () {
        final adhoc = _makeItem(
          id: 4,
          title: 'D',
          audioUrl: 'https://d.mp3',
          isAdhoc: true,
        );
        final queue = PlaybackQueue(
          manualItems: [itemA, itemB],
          adhocItems: [adhoc],
        );

        check(queue.allItems).length.equals(3);
      });
    });
  });
}
