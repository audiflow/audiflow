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

abstract class PodcastSummary {
  /// Unique identifier for podcast.
  String get guid;

  /// The collection ID(iTunesID).
  int get collectionId;

  /// The link to the podcast RSS feed.
  String get feedUrl;

  /// Podcast title.
  String get title;

  /// URL for thumbnail version of artwork image.
  String get thumbImageUrl;

  /// URL to the full size artwork image.
  String get imageUrl;

  /// Copyright owner of the podcast.
  String get copyright;

  /// Release date of the latest episode.
  DateTime get releaseDate;
}

/// A class that represents an instance of a podcast.
///
/// When persisted to disk this represents a podcast that is being followed.
@freezed
class Podcast with _$Podcast implements PodcastSummary {
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

  factory Podcast.fromSearch(search.Podcast podcast, PodcastSummary baseInfo) {
    final episodes = podcast.episodes
        .map(
          (e) => Episode.fromSearch(
            e,
            pguid: baseInfo.guid,
            thumbImageUrl: baseInfo.thumbImageUrl,
            imageUrl: baseInfo.imageUrl,
          ),
        )
        .toList();
    final funding = podcast.funding
        .where((f) => f.url?.isNotEmpty == true)
        .map(Funding.fromSearch)
        .toList();
    final persons = podcast.persons.map(Person.fromSearch).toList();

    return Podcast(
      guid: baseInfo.guid,
      collectionId: baseInfo.collectionId,
      feedUrl: podcast.url!,
      linkUrl: podcast.link ?? '',
      title: baseInfo.title,
      description: removeHtmlPadding(podcast.description),
      copyright: baseInfo.copyright,
      thumbImageUrl: baseInfo.thumbImageUrl,
      imageUrl: baseInfo.imageUrl,
      releaseDate: baseInfo.releaseDate,
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
class PodcastSearchResultItem
    with _$PodcastSearchResultItem
    implements PodcastSummary {
  const factory PodcastSearchResultItem({
    /// Unique identifier for podcast.
    required String guid,

    /// The collection ID(iTunesID).
    required int collectionId,

    /// The link to the podcast RSS feed.
    required String feedUrl,

    /// Podcast title.
    required String title,

    /// URL for thumbnail version of artwork image.
    required String thumbImageUrl,

    /// URL to the full size artwork image.
    required String imageUrl,

    /// Copyright owner of the podcast.
    required String copyright,

    /// Release date of the latest episode.
    required DateTime releaseDate,
  }) = _PodcastSearchResultItem;

  factory PodcastSearchResultItem.fromJson(Map<String, dynamic> json) =>
      _$PodcastSearchResultItemFromJson(json);

  factory PodcastSearchResultItem.fromSearchResultItem(search.Item item) {
    final guid = '${item.collectionId ?? item.feedUrl}';
    final thumbImageUrl = item.thumbnailArtworkUrl;
    final imageUrl = item.bestArtworkUrl;

    return PodcastSearchResultItem(
      guid: guid,
      feedUrl: item.feedUrl ?? '',
      collectionId: item.collectionId ?? 0,
      title: item.collectionName!,
      thumbImageUrl: thumbImageUrl,
      imageUrl: imageUrl,
      copyright: item.artistName ?? '',
      releaseDate: item.releaseDate!,
    );
  }

  factory PodcastSearchResultItem.fromPodcast(Podcast podcast) {
    return PodcastSearchResultItem(
      guid: podcast.guid,
      feedUrl: podcast.feedUrl,
      collectionId: podcast.collectionId,
      title: podcast.title,
      thumbImageUrl: podcast.thumbImageUrl,
      imageUrl: podcast.imageUrl,
      copyright: podcast.copyright,
      releaseDate: podcast.releaseDate,
    );
  }
}

@freezed
class PodcastStats with _$PodcastStats {
  const factory PodcastStats({
    @Default(0) int id,
    required String guid,
    DateTime? subscribedDate,
    @Default(Duration.zero) Duration playTotal,
  }) = _PodcastStats;

  factory PodcastStats.fromJson(Map<String, dynamic> json) =>
      _$PodcastStatsFromJson(json);

  factory PodcastStats.fromPodcast(Podcast podcast) => PodcastStats(
        guid: podcast.guid,
      );
}
