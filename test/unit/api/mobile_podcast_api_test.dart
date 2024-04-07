//  Copyright (c) 2024 by HANAI, Tohru.
//  Copyright (c) 2024 Reedom, Inc.
//  Additional contributions from project contributors.
//  All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/api/podcast/podcast_api_provider.dart';
import 'package:audiflow/services/http/cached_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../test_common/riverpod.dart';
import '../mocks/mock_path_provider.dart';

void main() {
  late PodcastApi podcastApi;
  late CachedHttp cachedHttp;

  Future<void> createService() async {
    final container = createContainer();
    cachedHttp = container.read(cachedHttpProvider);
    await cachedHttp.ensureInitialized();
    podcastApi = container.read(podcastApiProvider);
  }

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    TestWidgetsFlutterBinding.ensureInitialized();
    final mockPath = MockPathProvider();
    PathProviderPlatform.instance = mockPath;
    await createService();
  });

  test('iTunes charts', () async {
    final f = File('test_resources/itunes_chart.json');
    final rss = await f.readAsString();
    DioAdapter(dio: cachedHttp.dio).onGet(
      'https://itunes.apple.com/rss/toppodcasts/limit=20/explicit=false/json',
      (server) => server.reply(
        200,
        rss,
        headers: {
          'content-type': ['application/json'],
          'etag': ['1234'],
          'age': ['10'],
        },
      ),
    );
    final charts = await podcastApi.charts();
    expect(charts, hasLength(1));
    expect(charts[0].trackName, 'A Longer Title');
    expect(charts[0].releaseDate, DateTime.parse('2024-04-04T03:00:00-07:00'));
  });

  test('iTunes search', () async {
    final f = File('test_resources/itunes_search.json');
    final rss = await f.readAsString();
    DioAdapter(dio: cachedHttp.dio).onGet(
      'https://itunes.apple.com/search?term=example&limit=20&explicit=no',
          (server) => server.reply(
        200,
        rss,
        headers: {
          'content-type': ['application/json'],
          'etag': ['12345'],
          'age': ['10'],
        },
      ),
    );
    final charts = await podcastApi.search('example');
    expect(charts, hasLength(1));
    expect(charts[0].trackName, 'Track Name');
    expect(charts[0].releaseDate, DateTime.parse('2024-04-05T04:00:00Z'));
  });

  test('feed', () async {
    final f = File('test_resources/podcast1.rss');
    final rss = await f.readAsString();
    const url = 'https://example.com/feed.rss';
    DioAdapter(dio: cachedHttp.dio).onGet(
      url,
          (server) => server.reply(
        200,
        rss,
        headers: {
          'content-type': ['application/json'],
          'etag': ['12345'],
          'age': ['10'],
        },
      ),
    );
    final (a, b) = await podcastApi.loadFeed(url);
  });}
