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

    /// Zero or more funding links.
    @Default([]) List<Funding> funding,
    @Default([]) List<Person> persons,

    /// Date and time user subscribed to the podcast.
    DateTime? subscribedDate,

    /// Date and time podcast was last updated/refreshed.
    DateTime? lastUpdated,
  }) = _Podcast;

  factory Podcast.fromJson(Map<String, dynamic> json) =>
      _$PodcastFromJson(json);

  factory Podcast.fromSearchResultItem(search.Item item) => Podcast(
        guid: item.feedUrl!,
        url: item.feedUrl!,
        link: item.feedUrl,
        title: item.trackName ?? item.collectionName!,
        imageUrl: item.bestArtworkUrl ?? item.artworkUrl,
        thumbImageUrl: item.thumbnailArtworkUrl,
        copyright: item.artistName,
      );

  factory Podcast.fromSearch(search.Podcast loadedPodcast) {
    final funding = loadedPodcast.funding
        .where((f) => f.url?.isNotEmpty == true)
        .map((f) => Funding(url: f.url!, value: f.value ?? ''))
        .toList(growable: false);

    final persons = loadedPodcast.persons
        .map(
          (p) => Person(
            name: p.name,
            role: p.role,
            group: p.group,
            image: p.image,
            link: p.link,
          ),
        )
        .toList(growable: false);

    return Podcast(
      guid: loadedPodcast.url!,
      url: loadedPodcast.url!,
      link: loadedPodcast.link,
      title: _format(loadedPodcast.title),
      description: _format(loadedPodcast.description),
      imageUrl: loadedPodcast.image,
      thumbImageUrl: loadedPodcast.image,
      copyright: _format(loadedPodcast.copyright),
      funding: funding,
      persons: persons,
    );
  }
}

extension PodcastExt on Podcast {
  bool get subscribed => subscribedDate != null;
}

final descriptionRegExp1 =
    RegExp(r'(</p><br>|</p></br>|<p><br></p>|<p></br></p>)');
final descriptionRegExp2 = RegExp(r'(<p><br></p>|<p></br></p>)');

/// Remove HTML padding from the content. The padding may look fine within
/// the context of a browser, but can look out of place on a mobile screen.
String _format(String? input) {
  return input
          ?.trim()
          .replaceAll(descriptionRegExp2, '')
          .replaceAll(descriptionRegExp1, '</p>') ??
      '';
}
