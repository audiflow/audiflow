import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_search/src/utils/http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  const podcastId = '603013428';
  const url = '${ItunesChartsClient.lookupBaseUrl}?id=$podcastId';

  late DioAdapter server;
  late ItunesChartsClient client;

  setUp(() {
    final dio = Dio();
    server = DioAdapter(dio: dio);
    client = ItunesChartsClient(httpClient: HttpClient(dio: dio));
  });

  group('fetchPodcast', () {
    test('returns the podcast', () async {
      server.onGet(
        url,
        (s) => s.reply(200, {
          'resultCount': 1,
          'results': [
            {
              'collectionId': int.parse(podcastId),
              'collectionName': 'Show',
              'artistName': 'Host',
              'feedUrl': 'https://example.com/feed.xml',
            },
          ],
        }),
      );

      final podcast = await client.fetchPodcast(podcastId);

      expect(podcast.id, podcastId);
      expect(podcast.feedUrl, 'https://example.com/feed.xml');
    });

    // The real lookup API answers with `text/javascript`, which Dio
    // leaves undecoded.
    test('returns the podcast from a text/javascript response', () async {
      server.onGet(
        url,
        (s) => s.reply(
          200,
          '{"resultCount":1,"results":[{"collectionId":$podcastId,'
          '"collectionName":"Show","artistName":"Host",'
          '"feedUrl":"https://example.com/feed.xml"}]}',
          headers: {
            Headers.contentTypeHeader: ['text/javascript; charset=utf-8'],
          },
        ),
      );

      final podcast = await client.fetchPodcast(podcastId);

      expect(podcast.id, podcastId);
      expect(podcast.feedUrl, 'https://example.com/feed.xml');
    });

    test('throws a SearchException on a malformed text response', () async {
      server.onGet(
        url,
        (s) => s.reply(
          200,
          'not json',
          headers: {
            Headers.contentTypeHeader: ['text/javascript; charset=utf-8'],
          },
        ),
      );

      await expectLater(
        client.fetchPodcast(podcastId),
        throwsA(isA<SearchException>()),
      );
    });

    test('throws notFound when no podcast has the ID', () async {
      server.onGet(
        url,
        (s) => s.reply(200, {'resultCount': 0, 'results': <Object>[]}),
      );

      await expectLater(
        client.fetchPodcast(podcastId),
        throwsA(
          isA<SearchException>().having(
            (e) => e.code,
            'code',
            StatusCode.notFound,
          ),
        ),
      );
    });

    test('throws a network exception when unreachable', () async {
      server.onGet(
        url,
        (s) => s.throws(
          0,
          DioException.connectionError(
            requestOptions: RequestOptions(path: url),
            reason: 'offline',
          ),
        ),
      );

      await expectLater(
        client.fetchPodcast(podcastId),
        throwsA(isA<SearchNetworkException>()),
      );
    });
  });

  test('lookupPodcast returns null on failure', () async {
    server.onGet(
      url,
      (s) => s.reply(200, {'resultCount': 0, 'results': <Object>[]}),
    );

    expect(await client.lookupPodcast(podcastId), isNull);
  });
}
