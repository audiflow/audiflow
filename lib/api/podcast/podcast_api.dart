// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:podcast_feed/parsers/channel_item_parser.dart';
import 'package:podcast_feed/parsers/channel_parser.dart';
import 'package:podcast_search/podcast_search.dart' as pslib;

/// A simple wrapper class that interacts with the search API via
/// the podcast_search package.
///
// TODO(unknown): Make this more generic so it's not tied to podcast_search
abstract class PodcastApi {
  Future<void> ensureInitialized();

  /// Search for podcasts matching the search criteria.
  Future<List<ITunesSearchItem>> search(
    String term, {
    int limit = 20,
    Country? country,
    Attribute? attribute,
    String? language,
    int? version,
    bool explicit = false,
  });

  /// Request the top podcast charts from iTunes, and at most [size] records.
  Future<List<ITunesChartItem>> charts({
    int size = 20,
    String genre = '',
    Country country = Country.none,
  });

  Future<ITunesSearchItem?> lookup({required int collectionId});

  List<String> genres(
    String searchProvider,
  );

  /// URL representing the RSS feed for a podcast.
  Future<(ChannelValues?, ItemParser?)> loadFeed(String url);

  /// Load episode chapters via JSON file.
  Future<pslib.Chapters> loadChapters(String url);

  /// Load episode transcript via SRT or JSON file.
  Future<pslib.Transcript> loadTranscript(TranscriptUrl transcriptUrl);

  /// Allow adding of custom certificates. Required as default context
  /// does not apply when running in separate Isolate.
  void addClientAuthorityBytes(List<int> certificateAuthorityBytes);
}
