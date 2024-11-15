import 'dart:convert';
import 'dart:io';

import 'package:audiflow/common/data/user_agent.dart';
import 'package:audiflow/constants/attribute.dart';
import 'package:audiflow/constants/country.dart';
import 'package:audiflow/constants/env.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/model/itunes_chart_item.dart';
import 'package:audiflow/features/browser/common/model/itunes_search_item.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/cached_http.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart' as podcast_search;

/// An implementation of the [PodcastApiRepository].
///
/// A simple wrapper class that interacts with the iTunes/PodcastIndex search API
/// via the podcast_search package.
class DefaultPodcastApiRepository implements PodcastApiRepository {
  DefaultPodcastApiRepository({required this.cacheDir});

  static String feedApiEndpoint = 'https://itunes.apple.com';
  static String searchApiEndpoint = 'https://itunes.apple.com/search';

  static const _genres = <String, int>{
    '': -1,
    'Arts': 1301,
    'Business': 1321,
    'Comedy': 1303,
    'Education': 1304,
    'Fiction': 1483,
    'Government': 1511,
    'Health & Fitness': 1512,
    'History': 1487,
    'Kids & Family': 1305,
    'Leisure': 1502,
    'Music': 1301,
    'News': 1489,
    'Religion & Spirituality': 1314,
    'Science': 1533,
    'Society & Culture': 1324,
    'Sports': 1545,
    'TV & Film': 1309,
    'Technology': 1318,
    'True Crime': 1488,
  };

  final String cacheDir;

  /// Bytes containing a custom certificate authority.
  List<int> _certificateAuthorityBytes = [];

  @override
  void setClientAuthorityBytes(List<int> certificateAuthorityBytes) {
    _certificateAuthorityBytes = certificateAuthorityBytes;
    if (certificateAuthorityBytes.isNotEmpty) {
      SecurityContext.defaultContext
          .setTrustedCertificatesBytes(_certificateAuthorityBytes);
    }
  }

  @override
  Future<ITunesSearchItem?> lookup({required int collectionId}) async {
    final url = _buildLookupUrl(iTunesId: collectionId);
    final message = <String, dynamic>{
      'url': url,
      'cacheDir': cacheDir,
    };
    final list = await compute(_search, message);
    return list.firstOrNull;
  }

  @override
  Future<List<ITunesSearchItem>> search(
    String term, {
    int limit = 20,
    Country? country,
    Attribute? attribute,
    String? language,
    int? version,
    bool explicit = false,
  }) async {
    final url = _buildSearchUrl(
      term: term,
      country: country,
      limit: limit,
      attribute: attribute,
      explicit: explicit,
      language: language,
      version: version,
    );

    final message = <String, dynamic>{
      'url': url,
      'cacheDir': cacheDir,
    };
    return compute(_search, message);
  }

  @override
  Future<List<ITunesChartItem>> charts({
    int size = 20,
    String genre = '',
    Country country = Country.none,
  }) async {
    final url = _buildChartsUrl(
      country: country,
      limit: size,
      genre: genre,
    );

    final message = <String, dynamic>{
      'url': url,
      'cacheDir': cacheDir,
    };
    return compute(_charts, message);
  }

  @override
  List<String> genres(String searchProvider) {
    final provider = searchProvider == 'itunes'
        ? const podcast_search.ITunesProvider()
        : podcast_search.PodcastIndexProvider(
            key: Env.podcastIndexKey,
            secret: Env.podcastIndexSecret,
          );

    return podcast_search.Search(
      userAgent: getUserAgent(),
      searchProvider: provider,
    ).genres();
  }

  /// Load episode chapters via JSON file.
  @override
  Future<podcast_search.Chapters> loadChapters(String url) async {
    return podcast_search.Podcast.loadChaptersByUrl(url: url);
  }

  @override
  Future<podcast_search.Transcript> loadTranscript(
    TranscriptUrl transcriptUrl,
  ) async {
    late podcast_search.TranscriptFormat format;

    switch (transcriptUrl.type) {
      case TranscriptFormat.subrip:
        format = podcast_search.TranscriptFormat.subrip;
      case TranscriptFormat.json:
        format = podcast_search.TranscriptFormat.json;
      case TranscriptFormat.unsupported:
        format = podcast_search.TranscriptFormat.unsupported;
    }

    return podcast_search.Podcast.loadTranscriptByUrl(
      transcriptUrl:
          podcast_search.TranscriptUrl(url: transcriptUrl.url, type: format),
    );
  }

  static Future<List<ITunesChartItem>> _charts(
    Map<String, dynamic> message,
  ) async {
    final url = message['url'] as String;
    final cacheDir = message['cacheDir'] as String;
    final http = CachedHttp(cacheDir);
    final json =
        await http.fetch<String>(url).timeout(const Duration(seconds: 30));
    if (json == null) {
      debugPrint('json is null, url=$url');
      return [];
    }

    final decoded = jsonDecode(json) as Map<String, dynamic>?;
    if (decoded == null) {
      debugPrint('decoded is null, url=$url');
      return [];
    }

    final feed = decoded['feed'] as Map<String, dynamic>?;
    if (feed == null) {
      debugPrint('feed is null, url=$url');
      return [];
    }

    final list = feed['entry'] as List<dynamic>?;
    if (list == null) {
      debugPrint('list is null, url=$url');
      return [];
    }

    return list
        .map(
          (e) => ITunesChartItem.fromResponse(json: e as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<List<ITunesSearchItem>> _search(
    Map<String, dynamic> message,
  ) async {
    final url = message['url'] as String;
    final cacheDir = message['cacheDir'] as String;
    final http = CachedHttp(cacheDir);
    final json =
        await http.fetch<String>(url).timeout(const Duration(seconds: 30));
    if (json == null) {
      debugPrint('json is null, url=$url');
      return [];
    }

    return _parseSearchResult(url: url, json: json);
  }

  static List<ITunesSearchItem> _parseSearchResult({
    required String url,
    required String json,
  }) {
    final decoded = jsonDecode(json) as Map<String, dynamic>?;
    if (decoded == null) {
      debugPrint('decoded is null, url=$url');
      return [];
    }

    final results = decoded['results'] as List<dynamic>?;
    if (results == null) {
      debugPrint('results is null, url=$url');
      return [];
    }
    return results
        .map((e) {
          try {
            return ITunesSearchItem.fromJson(e as Map<String, dynamic>);
            // ignore: avoid_catches_without_on_clauses
          } catch (e) {
            logger.w('$e: url=$url');
            return null;
          }
        })
        .whereNotNull()
        .toList();
  }

  static String _buildChartsUrl({
    Country country = Country.none,
    int limit = 20,
    bool explicit = false,
    String genre = '',
  }) {
    final buf = StringBuffer(feedApiEndpoint)
      ..write(country.code.isNotEmpty ? '/' : '')
      ..write(country.code)
      ..write('/rss/toppodcasts/limit=')
      ..write(limit);

    if (genre != '') {
      final g = _genres[genre];
      if (g != null) {
        buf.write('/genre=$g');
      }
    }

    buf
      ..write('/explicit=')
      ..write(explicit)
      ..write('/json');

    return buf.toString();
  }

  /// This internal method constructs a correctly encoded URL which is then
  /// used to perform the search.
  static String _buildSearchUrl({
    required String term,
    required int limit,
    Country? country,
    Attribute? attribute,
    String? language,
    int? version,
    bool? explicit,
  }) {
    final queryParams = <String, String>{
      'term': term,
      'limit': limit.toString(),
    };
    if (country != null && country != Country.none) {
      queryParams['country'] = country.code;
    }
    if (attribute != null && attribute != Attribute.none) {
      queryParams['attribute'] = attribute.attribute;
    }
    if (language != null) {
      queryParams['language'] = language;
    }
    if (version != null && 0 < version) {
      queryParams['version'] = version.toString();
    }
    if (explicit != null) {
      queryParams['explicit'] = explicit ? 'yes' : 'no';
    }
    queryParams['media'] = 'podcast';
    queryParams['entity'] = 'podcast';

    return Uri.parse(searchApiEndpoint)
        .replace(queryParameters: queryParams)
        .toString();
  }

  static String _buildLookupUrl({required int iTunesId}) {
    return Uri.parse('$feedApiEndpoint/lookup?id=$iTunesId').toString();
  }
}
