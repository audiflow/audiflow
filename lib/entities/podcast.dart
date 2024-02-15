// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/entities.dart';

part 'podcast.freezed.dart';
part 'podcast.g.dart';

/// A class that represents an instance of a podcast.
///
/// When persisted to disk this represents a podcast that is being followed.
@freezed
class Podcast with _$Podcast {
  const factory Podcast({
    /// Unique identifier for podcast.
    required String guid,

    /// The collection ID(iTunesID).
    required int collectionId,

    /// The link to the podcast RSS feed.
    required String feedUrl,

    /// RSS link URL.
    required String linkUrl,

    /// Podcast title.
    required String title,

    /// Podcast description. Can be either plain text or HTML.
    required String description,

    /// Copyright owner of the podcast.
    required String copyright,

    /// URL for thumbnail version of artwork image. Not contained within
    /// the RSS but may be calculated or provided within search results.
    required String thumbImageUrl,

    /// URL to the full size artwork image.
    required String imageUrl,

    /// Release date of the latest episode.
    required DateTime releaseDate,

    /// List of episodes.
    // ignore: invalid_annotation_target
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default([])
    List<Episode> episodes,

    /// List of  funding links.
    @Default([]) List<Funding> funding,

    /// List of people of interest to the podcast.
    @Default([]) List<Person> persons,
  }) = _Podcast;

  factory Podcast.fromJson(Map<String, dynamic> json) =>
      _$PodcastFromJson(json);

  factory Podcast.fromSearch(search.Item item, search.Podcast podcast) {
    final guid = '${item.collectionId ?? item.feedUrl}';
    final imageUrl = item.bestArtworkUrl;
    final thumbImageUrl = item.thumbnailArtworkUrl;
    final episodes = podcast.episodes
        .map(
          (e) => Episode.fromSearch(
            e,
            pguid: guid,
            imageUrl: imageUrl,
            thumbImageUrl: thumbImageUrl,
          ),
        )
        .toList();
    final funding = podcast.funding
        .where((f) => f.url?.isNotEmpty == true)
        .map(Funding.fromSearch)
        .toList();
    final persons = podcast.persons.map(Person.fromSearch).toList();

    return Podcast(
      guid: guid,
      collectionId: item.collectionId ?? 0,
      feedUrl: podcast.url!,
      linkUrl: podcast.link ?? '',
      title: item.collectionName!,
      description: removeHtmlPadding(podcast.description),
      copyright: item.artistName ?? '',
      thumbImageUrl: thumbImageUrl,
      imageUrl: imageUrl,
      releaseDate: item.releaseDate!,
      episodes: episodes,
      funding: funding,
      persons: persons,
    );
  }
}

extension PodcastExtension on Podcast {
  int get contentHash => Object.hash(
    guid,
    collectionId,
    feedUrl,
    linkUrl,
    title,
    description,
    thumbImageUrl,
    imageUrl,
    releaseDate,
    funding,
    persons,
  );
}

/// A class that represents an instance of a podcast search result item.
@freezed
class PodcastSummary with _$PodcastSummary {
  const factory PodcastSummary({
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

@freezed
class PodcastStats with _$PodcastStats {
  const factory PodcastStats({
    required int id,
    required String guid,
    DateTime? subscribedDate,
    @Default(Duration.zero) Duration playTotal,
  }) = _PodcastStats;
}
