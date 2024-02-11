// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:seasoning/entities/entities.dart';

part 'podcast.freezed.dart';
part 'podcast.g.dart';

/// A class that represents an instance of a podcast.
///
/// When persisted to disk this represents a podcast that is being followed.
@freezed
class Podcast with _$Podcast {
  const factory Podcast({
    /// Database ID
    int? id,

    /// Unique identifier for podcast.
    required String guid,

    /// The link to the podcast RSS feed.
    required String url,

    /// RSS link URL.
    String? link,

    /// Podcast title.
    required String title,

    /// Podcast description. Can be either plain text or HTML.
    String? description,

    /// URL to the full size artwork image.
    String? imageUrl,

    /// URL for thumbnail version of artwork image. Not contained within
    /// the RSS but may be calculated or provided within search results.
    String? thumbImageUrl,

    /// Copyright owner of the podcast.
    String? copyright,

    /// Date and time user subscribed to the podcast.
    DateTime? subscribedDate,

    /// Zero or more funding links.
    @Default([]) List<Funding> funding,

    @Default([])
    List<Person> persons,

    /// Date and time podcast was last updated/refreshed.
    DateTime? lastUpdated,
  }) = _Podcast;

  factory Podcast.fromJson(Map<String, dynamic> json) =>
      _$PodcastFromJson(json);

// ignore: prefer_constructors_over_static_methods
  static Podcast fromUrl({required String url}) => Podcast(
        url: url,
        guid: '',
        title: '',
      );

// ignore: prefer_constructors_over_static_methods
  static Podcast fromSearchResultItem(search.Item item) => Podcast(
        guid: item.guid ?? '',
        url: item.feedUrl ?? '',
        link: item.feedUrl,
        title: item.trackName!,
        imageUrl: item.bestArtworkUrl ?? item.artworkUrl,
        thumbImageUrl: item.thumbnailArtworkUrl,
        copyright: item.artistName,
      );
}

extension PodcastExt on Podcast {
  bool get subscribed => id != null;
}
