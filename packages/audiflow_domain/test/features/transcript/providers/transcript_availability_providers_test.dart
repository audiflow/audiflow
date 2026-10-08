import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
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
}) {
  final service = _FakeTranscriptService(loadedTranscriptId);
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
  });
}

/// Answers a fixed load result instead of fetching.
class _FakeTranscriptService implements TranscriptService {
  _FakeTranscriptService(this._transcriptId);

  final int? _transcriptId;

  @override
  Future<int?> ensureContent(int episodeId) async => _transcriptId;
}
