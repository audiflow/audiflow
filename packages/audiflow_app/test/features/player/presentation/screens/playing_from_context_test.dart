import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

QueueItemWithEpisode _item(int id, {required bool adhoc, String? source}) =>
    QueueItemWithEpisode(
      queueItem: QueueItem()
        ..id = id
        ..episodeId = id
        ..position = id
        ..isAdhoc = adhoc
        ..sourceContext = source
        ..addedAt = DateTime(2026),
      episode: Episode()
        ..id = id
        ..podcastId = 1
        ..guid = 'g$id'
        ..title = 'E$id'
        ..audioUrl = 'https://example.com/$id.mp3',
    );

void main() {
  final queue = PlaybackQueue(
    manualItems: [_item(1, adhoc: false)],
    adhocItems: [_item(2, adhoc: true, source: 'Season A')],
    adhocSourceContext: 'Season A',
  );

  test('uses the source of the episode own ad hoc entry', () {
    check(
      playingFromContext(queue, 'https://example.com/2.mp3'),
    ).equals('Season A');
  });

  test('a manually queued episode does not borrow the ad hoc source', () {
    check(playingFromContext(queue, 'https://example.com/1.mp3')).isNull();
  });

  test('an episode no longer in the queue has no source', () {
    check(playingFromContext(queue, 'https://example.com/9.mp3')).isNull();
    check(playingFromContext(null, 'https://example.com/2.mp3')).isNull();
  });
}
