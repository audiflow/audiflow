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

/// A class that represents an instance of a podcast search result item.
@freezed
class PodcastMetadata with _$PodcastMetadata {
  const factory PodcastMetadata({
    /// Unique identifier for podcast.
    required String guid,

    /// The collection ID(iTunesID).
    required int collectionId,

    /// The link to the podcast RSS feed.
    required String? feedUrl,

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
  }) = _PodcastMetadata;

  factory PodcastMetadata.fromJson(Map<String, dynamic> json) =>
      _$PodcastMetadataFromJson(json);

  factory PodcastMetadata.fromSearchResultItem(search.Item item) {
    final guid = '${item.collectionId ?? item.feedUrl}';
    final thumbImageUrl = item.thumbnailArtworkUrl;
    final imageUrl = item.bestArtworkUrl;

    return PodcastMetadata(
      guid: guid,
      feedUrl: item.feedUrl,
      collectionId: item.collectionId ?? 0,
      title: item.collectionName ?? item.trackName ?? '',
      thumbImageUrl: thumbImageUrl,
      imageUrl: imageUrl,
      copyright: item.artistName ?? '',
      releaseDate: item.releaseDate!,
    );
  }

  factory PodcastMetadata.fromPodcast(Podcast podcast) {
    return PodcastMetadata(
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
    required String? feedUrl,

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

  factory Podcast.fromSearch(search.Podcast podcast, PodcastMetadata metadata) {
    final episodes = podcast.episodes
        .map(
          (e) => Episode.fromSearch(
            e,
            pguid: metadata.guid,
            thumbImageUrl: metadata.thumbImageUrl,
            imageUrl: podcast.image ?? metadata.imageUrl,
          ),
        )
        .toList();
    final funding = podcast.funding
        .where((f) => f.url?.isNotEmpty == true)
        .map(Funding.fromSearch)
        .toList();
    final persons = podcast.persons.map(Person.fromSearch).toList();

    return Podcast(
      guid: metadata.guid,
      collectionId: metadata.collectionId,
      feedUrl: podcast.url,
      linkUrl: podcast.link ?? '',
      title: metadata.title,
      description: removeHtmlPadding(podcast.description),
      copyright: metadata.copyright,
      thumbImageUrl: metadata.thumbImageUrl,
      imageUrl: podcast.image ?? metadata.imageUrl,
      releaseDate: metadata.releaseDate,
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

  PodcastMetadata get metadata {
    return PodcastMetadata(
      guid: guid,
      collectionId: collectionId,
      feedUrl: feedUrl,
      title: title,
      thumbImageUrl: thumbImageUrl,
      imageUrl: imageUrl,
      copyright: copyright,
      releaseDate: releaseDate,
    );
  }
}

enum PodcastDetailViewMode {
  episodes,
  seasons,
  played,
  unplayed,
  downloaded;

  String get label {
    switch (this) {
      case PodcastDetailViewMode.episodes:
        return 'Episodes';
      case PodcastDetailViewMode.seasons:
        return 'Seasons';
      case PodcastDetailViewMode.played:
        return 'Played';
      case PodcastDetailViewMode.unplayed:
        return 'Unplayed';
      case PodcastDetailViewMode.downloaded:
        return 'Downloaded';
    }
  }
}

@freezed
class PodcastStats with _$PodcastStats {
  const factory PodcastStats({
    required String guid,
    DateTime? subscribedDate,
    @Default(PodcastDetailViewMode.episodes) PodcastDetailViewMode viewMode,
    @Default(false) bool ascend,
    DateTime? lastCheckedAt,
  }) = _PodcastStats;

  factory PodcastStats.fromJson(Map<String, dynamic> json) =>
      _$PodcastStatsFromJson(json);
}

extension PodcastStatsExt on PodcastStats {
  bool get subscribed => subscribedDate != null;
}

class PodcastStatsUpdateParam {
  const PodcastStatsUpdateParam({
    required this.guid,
    this.subscribedDate,
    this.viewMode,
    this.ascend,
    this.lastCheckedAt,
  });

  final String guid;
  final DateTime? subscribedDate;
  final PodcastDetailViewMode? viewMode;
  final bool? ascend;
  final DateTime? lastCheckedAt;

  PodcastStatsUpdateParam copyWith({
    DateTime? subscribedDate,
    PodcastDetailViewMode? viewMode,
    bool? ascend,
    DateTime? lastCheckedAt,
  }) {
    return PodcastStatsUpdateParam(
      guid: guid,
      subscribedDate: subscribedDate ?? this.subscribedDate,
      viewMode: viewMode ?? this.viewMode,
      ascend: ascend ?? this.ascend,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}
