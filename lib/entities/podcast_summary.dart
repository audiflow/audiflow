// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;

part 'podcast_summary.freezed.dart';
part 'podcast_summary.g.dart';

/// A class that represents an instance of a podcast search result item.
@freezed
class PodcastSummary with _$PodcastSummary {
  const factory PodcastSummary({
    /// Database ID
    int? id,

    /// Unique identifier for podcast.
    required String guid,

    /// The link to the podcast RSS feed.
    required String url,

    /// Podcast title.
    required String title,

    /// URL for thumbnail version of artwork image.
    required String thumbImageUrl,

    /// Copyright owner of the podcast.
    required String copyright,

    /// Release date of the latest episode.
    required DateTime? releaseDate,

    /// Date and time user subscribed to the podcast.
    DateTime? subscribedDate,
  }) = _PodcastSummary;

  factory PodcastSummary.fromJson(Map<String, dynamic> json) =>
      _$PodcastSummaryFromJson(json);

  factory PodcastSummary.fromSearchResultItem(search.Item item) =>
      PodcastSummary(
        guid: item.feedUrl ?? '',
        url: item.feedUrl ?? '',
        title: item.trackName ?? item.collectionName ?? '',
        thumbImageUrl: item.thumbnailArtworkUrl ?? '',
        copyright: item.artistName ?? '',
        releaseDate: item.releaseDate,
      );
}

extension PodcastSummaryExt on PodcastSummary {
  bool get subscribed => id != null;
}
