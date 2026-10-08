import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:riverpod/riverpod.dart';

const _episodeId = 7;

EpisodeTranscript _declared({
  String type = 'text/vtt',
  bool unusable = false,
}) => EpisodeTranscript()
  ..episodeId = _episodeId
  ..url = 'https://example.com/ep.vtt'
  ..type = type
  ..unusableAt = unusable ? DateTime(2026) : null;

ProviderContainer _container({
  List<EpisodeTranscript> metas = const [],
  int? loadedTranscriptId,
  _FakeTranscriptService? service,
}) {
  service ??= _FakeTranscriptService(Future.value(loadedTranscriptId));
  final container = ProviderContainer(
    overrides: [
      episodeTranscriptMetasProvider.overrideWith((ref, _) async => metas),
      transcriptServiceProvider.overrideWithValue(service),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<bool> _badge(ProviderContainer container) async {
  final subscription = container.listen(
    episodeHasTranscriptProvider(_episodeId),
    (_, _) {},
  );
  addTearDown(subscription.close);
  return container.read(episodeHasTranscriptProvider(_episodeId).future);
}

void main() {
  group('episodeHasTranscriptProvider before any fetch', () {
    test('is false without a declared transcript', () async {
      check(await _badge(_container())).isFalse();
    });

    test('trusts a declared, supported file', () async {
      check(await _badge(_container(metas: [_declared()]))).isTrue();
    });

    test('ignores an unsupported format', () async {
      final container = _container(metas: [_declared(type: 'text/html')]);
      check(await _badge(container)).isFalse();
    });

    test('ignores a file already found unusable', () async {
      final container = _container(metas: [_declared(unusable: true)]);
      check(await _badge(container)).isFalse();
    });
  });

  group('usableTranscriptIdProvider', () {
    test('answers the id of a transcript that loads', () async {
      final container = _container(metas: [_declared()], loadedTranscriptId: 3);

      final id = await container.read(
        usableTranscriptIdProvider(_episodeId).future,
      );

      check(id).equals(3);
      check(await _badge(container)).isTrue();
    });

    test('a declared file that fails to load clears the badge', () async {
      final container = _container(metas: [_declared()]);
      check(await _badge(container)).isTrue();

      final id = await container.read(
        usableTranscriptIdProvider(_episodeId).future,
      );

      check(id).isNull();
      check(await _badge(container)).isFalse();
    });

    test('does not fetch again after a failure this session', () async {
      final service = _FakeTranscriptService(Future.value());
      final container = _container(metas: [_declared()], service: service);
      container
          .read(transcriptFetchOutcomesProvider.notifier)
          .record(_episodeId, usable: false);

      final id = await container.read(
        usableTranscriptIdProvider(_episodeId).future,
      );

      check(id).isNull();
      check(service.calls).equals(0);
    });

    test('cancels the download when no longer watched', () async {
      final pending = Completer<int?>();
      final service = _FakeTranscriptService(pending.future);
      final container = _container(metas: [_declared()], service: service);
      final subscription = container.listen(
        usableTranscriptIdProvider(_episodeId),
        (_, _) {},
      );
      await pumpEventQueue();
      check(service.lastCancelToken!.isCancelled).isFalse();

      subscription.close();
      await pumpEventQueue();
      pending.complete(null);
      await pumpEventQueue();

      check(service.lastCancelToken!.isCancelled).isTrue();
      check(container.read(transcriptFetchOutcomesProvider)).isEmpty();
    });
  });
}

/// Answers a given load result instead of fetching, recording each call.
class _FakeTranscriptService implements TranscriptService {
  _FakeTranscriptService(this._result);

  final Future<int?> _result;
  int calls = 0;
  CancelToken? lastCancelToken;

  @override
  Future<int?> ensureContent(int episodeId, {CancelToken? cancelToken}) {
    calls++;
    lastCancelToken = cancelToken;
    return _result;
  }
}
