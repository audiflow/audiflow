// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:audiflow/api/podcast/podcast_api.dart';
import 'package:audiflow/core/environment.dart';
import 'package:audiflow/entities/transcript.dart';
import 'package:audiflow/services/http/cached_http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_feed/podcast_feed.dart'
    hide TranscriptFormat, TranscriptUrl;
import 'package:podcast_search/podcast_search.dart' as podcast_search;

/// An implementation of the [PodcastApi].
///
/// A simple wrapper class that interacts with the iTunes/PodcastIndex search API
/// via the podcast_search package.
class MobilePodcastApi extends PodcastApi {
  MobilePodcastApi(this._ref);

  void ensureInitialized() {
    _http = _ref.read(cachedHttpProvider);
  }

  final Ref _ref;
  late CachedHttp _http;

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

  /// Set when using a custom certificate authority.
  SecurityContext? _defaultSecurityContext;

  /// Bytes containing a custom certificate authority.
  List<int> _certificateAuthorityBytes = [];

  @override
  Future<podcast_search.SearchResult> search(
    String term, {
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
    String? searchProvider,
  }) async {
    final searchParams = {
      'term': term,
      'searchProvider': searchProvider,
    };

    return compute(_search, searchParams);
  }

  @override
  Future<List<ITunesChartItem>> charts({
    int? size = 20,
    String? genre,
    String? searchProvider,
    String? countryCode = '',
  }) async {
    final searchParams = {
      'size': size.toString(),
      'genre': genre,
      'searchProvider': searchProvider,
      'countryCode': countryCode,
    };

    return _charts(searchParams);
  }

  @override
  Future<podcast_search.Item?> lookup({required int collectionId}) async {
    return podcast_search.Search(
      userAgent: Environment.userAgent(),
    ).lookup(collectionId: collectionId);
  }

  @override
  List<String> genres(String searchProvider) {
    final provider = searchProvider == 'itunes'
        ? const podcast_search.ITunesProvider()
        : podcast_search.PodcastIndexProvider(
            key: podcastIndexKey,
            secret: podcastIndexSecret,
          );

    return podcast_search.Search(
      userAgent: Environment.userAgent(),
      searchProvider: provider,
    ).genres();
  }

  @override
  Future<podcast_search.Podcast> loadFeed(String url) async {
    return _loadFeed(url);
  }

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

  static Future<podcast_search.SearchResult> _search(
    Map<String, String?> searchParams,
  ) {
    final term = searchParams['term']!;
    final provider = searchParams['searchProvider'] == 'itunes'
        ? const podcast_search.ITunesProvider()
        : podcast_search.PodcastIndexProvider(
            key: podcastIndexKey,
            secret: podcastIndexSecret,
          );

    return podcast_search.Search(
      userAgent: Environment.userAgent(),
      searchProvider: provider,
    ).search(term).timeout(const Duration(seconds: 30));
  }

  Future<List<ITunesChartItem>> _charts(
    Map<String, String?> searchParams,
  ) async {
    final countryCode = searchParams['countryCode'];
    final country = countryCode?.isNotEmpty == true
        ? Country.values
        .where((element) => element.code == countryCode)
        .first
        : Country.none;

    final limit = int.tryParse(searchParams['size'] ?? '*') ?? 50;
    final url = _buildChartsUrl(
      country: country,
      limit: limit,
      genre: searchParams['genre'] ?? '',
    );

    final json = await _http.fetch(url).timeout(const Duration(seconds: 30));
    if (json == null) {
      debugPrint('json is null, url=$url');
      return [];
    }

    final message = <String, String>{
      'url': url,
      'json': json as String,
    };
    return compute(_parseCharts, message);
  }

  static List<ITunesChartItem> _parseCharts(Map<String, String> message) {
    final url = message['url']!;
    final json = message['json']!;

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
        .map((e) => ITunesChartItem.fromJson(json: e as Map<String, dynamic>))
        .toList();
  }

  Future<podcast_search.Podcast> _loadFeed(String url) {
    _setupSecurityContext();
    return podcast_search.Podcast.loadFeed(
      url: url,
      userAgent: Environment.userAgent(),
    );
  }

  void _setupSecurityContext() {
    if (_certificateAuthorityBytes.isNotEmpty &&
        _defaultSecurityContext == null) {
      SecurityContext.defaultContext
          .setTrustedCertificatesBytes(_certificateAuthorityBytes);
      _defaultSecurityContext = SecurityContext.defaultContext;
    }
  }

  @override
  void addClientAuthorityBytes(List<int> certificateAuthorityBytes) {
    _certificateAuthorityBytes = certificateAuthorityBytes;
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
}
