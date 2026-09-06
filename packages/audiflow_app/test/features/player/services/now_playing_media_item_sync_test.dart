import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiflow_app/features/player/services/now_playing_artwork_preparer.dart';
import 'package:audiflow_app/features/player/services/now_playing_media_item_sync.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

const _artworkUrl = 'https://example.com/art.jpg';
final _preparedUri = Uri.file('/cache/now_playing_artwork/abc.png');

const _info = NowPlayingInfo(
  episodeUrl: 'https://example.com/ep1.mp3',
  episodeTitle: 'Episode 1',
  podcastTitle: 'Podcast',
  artworkUrl: _artworkUrl,
  totalDuration: Duration(minutes: 30),
);

/// Lets each test decide when and how artwork preparation completes.
class _FakePreparer implements NowPlayingArtworkPreparer {
  final List<String> requested = [];
  final List<Completer<Uri?>> pending = [];

  @override
  Future<Uri?> prepare(String artworkUrl) {
    requested.add(artworkUrl);
    final completer = Completer<Uri?>();
    pending.add(completer);
    return completer.future;
  }
}

/// Stands in for audio_service's mediaItem subject: remembers the latest
/// value and records every emission in order.
class _MediaItemSink {
  final List<MediaItem?> emitted = [];
  MediaItem? current;

  void add(MediaItem? item) {
    emitted.add(item);
    current = item;
  }
}

void main() {
  late _FakePreparer preparer;
  late _MediaItemSink sink;
  late NowPlayingMediaItemSync sync;

  setUp(() {
    preparer = _FakePreparer();
    sink = _MediaItemSink();
    sync = NowPlayingMediaItemSync(
      readCurrent: () => sink.current,
      publish: sink.add,
      artworkPreparer: preparer,
      logger: Logger(level: Level.off),
    );
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('NowPlayingMediaItemSync.sync', () {
    test('clears the media item for null info', () {
      sync.sync(_info);
      sync.sync(null);

      check(sink.current).isNull();
    });

    test('publishes metadata immediately without waiting for artwork', () {
      sync.sync(_info);

      final item = sink.current!;
      check(item.id).equals(_info.episodeUrl);
      check(item.title).equals('Episode 1');
      check(item.artist).equals('Podcast');
      check(item.duration).equals(const Duration(minutes: 30));
      check(item.artUri).isNull();
      check(preparer.requested).deepEquals([_artworkUrl]);
    });

    test('attaches the prepared file URI once it is ready', () async {
      sync.sync(_info);
      preparer.pending.single.complete(_preparedUri);
      await settle();

      check(sink.current!.artUri).equals(_preparedUri);
      check(sink.emitted.length).equals(2);
    });

    test('falls back to the remote URL when preparation fails', () async {
      sync.sync(_info);
      preparer.pending.single.complete(null);
      await settle();

      check(sink.current!.artUri).equals(Uri.parse(_artworkUrl));
    });

    test('skips preparation when there is no artwork', () {
      sync.sync(_info.copyWith(artworkUrl: null));

      check(sink.current!.artUri).isNull();
      check(preparer.requested).isEmpty();
    });

    test('ignores artwork that finishes after a newer sync', () async {
      sync.sync(_info);
      final next = _info.copyWith(
        episodeUrl: 'https://example.com/ep2.mp3',
        artworkUrl: 'https://example.com/art2.jpg',
      );
      sync.sync(next);

      preparer.pending[0].complete(_preparedUri);
      await settle();

      check(sink.current!.id).equals(next.episodeUrl);
      check(sink.current!.artUri).isNull();
    });

    test('ignores artwork that finishes after the item was cleared', () async {
      sync.sync(_info);
      sync.sync(null);
      preparer.pending.single.complete(_preparedUri);
      await settle();

      check(sink.current).isNull();
    });

    test('keeps a duration update made while artwork was loading', () async {
      sync.sync(_info);
      sync.updateDuration(const Duration(minutes: 31));
      preparer.pending.single.complete(_preparedUri);
      await settle();

      check(sink.current!.duration).equals(const Duration(minutes: 31));
      check(sink.current!.artUri).equals(_preparedUri);
    });
  });

  group('NowPlayingMediaItemSync.updateDuration', () {
    test('does nothing without a media item', () {
      sync.updateDuration(const Duration(minutes: 1));

      check(sink.emitted).isEmpty();
    });

    test('does nothing when the duration is unchanged', () {
      sync.sync(_info);
      sync.updateDuration(const Duration(minutes: 30));

      check(sink.emitted.length).equals(1);
    });

    test('preserves the artwork when the duration changes', () async {
      sync.sync(_info);
      preparer.pending.single.complete(_preparedUri);
      await settle();

      sync.updateDuration(const Duration(minutes: 32));

      check(sink.current!.duration).equals(const Duration(minutes: 32));
      check(sink.current!.artUri).equals(_preparedUri);
    });
  });
}
