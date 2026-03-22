import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_app/features/share/presentation/helpers/share_helper.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShareLinkBuilder implements ShareLinkBuilder {
  String? episodeLinkResult;
  String? podcastLinkResult;

  @override
  Future<String?> buildEpisodeLink({
    required String itunesId,
    required String episodeGuid,
  }) async => episodeLinkResult;

  @override
  Future<String?> buildPodcastLink({required String itunesId}) async =>
      podcastLinkResult;
}

void main() {
  group('buildEpisodeShareUrl', () {
    test(
      'returns universal link when itunesId and guid are available',
      () async {
        final builder = FakeShareLinkBuilder()
          ..episodeLinkResult = 'https://audiflow.app/episodes/42/abc-123';

        final result = await buildEpisodeShareUrl(
          shareLinkBuilder: builder,
          itunesId: '42',
          episodeGuid: 'abc-123',
          fallbackLink: 'https://example.com/fallback',
        );

        check(result).equals('https://audiflow.app/episodes/42/abc-123');
      },
    );

    test('falls back to fallbackLink when episodeGuid is null', () async {
      final builder = FakeShareLinkBuilder()
        ..episodeLinkResult = 'https://audiflow.app/episodes/42/abc-123';

      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: builder,
        itunesId: '42',
        episodeGuid: null,
        fallbackLink: 'https://example.com/fallback',
      );

      check(result).equals('https://example.com/fallback');
    });

    test('falls back to fallbackLink when builder returns null', () async {
      final builder = FakeShareLinkBuilder()..episodeLinkResult = null;

      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: builder,
        itunesId: '42',
        episodeGuid: 'abc-123',
        fallbackLink: 'https://example.com/fallback',
      );

      check(result).equals('https://example.com/fallback');
    });

    test('returns null when all sources are null', () async {
      final builder = FakeShareLinkBuilder()..episodeLinkResult = null;

      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: builder,
        itunesId: null,
        episodeGuid: null,
        fallbackLink: null,
      );

      check(result).isNull();
    });
  });
}
