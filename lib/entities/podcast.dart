// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/hash.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' show ShowType;

part 'podcast.g.dart';

/// A class that represents an instance of a podcast search result item.
@collection
class Podcast {
  Podcast({
    required this.feedUrl,
    required this.collectionId,
    this.newFeedUrl,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    this.subcategory,
    required this.explicit,
    required this.image,
    this.link,
    this.guid,
    this.author,
    this.copyright,
    this.complete = false,
    this.type = ShowType.episodic,
  });

  static int pidFrom(String feedUrl) => fastHash(feedUrl);

  Id get id => pidFrom(feedUrl);

  /// The declared canonical feed URL for the podcast.
  @Index(unique: true)
  final String feedUrl;

  /// The collection ID(iTunesID).
  @Index(unique: true)
  final int collectionId;

  /// The new podcast RSS Feed URL.
  final String? newFeedUrl;

  /// The podcast title. A string containing the name of a podcast and nothing
  /// else.
  final String title;

  /// Text that describes a podcast to potential listeners.
  final String description;

  /// The language that is spoken on the podcast, specified in the ISO 639
  /// format.
  final String language;

  /// The category that best fits a podcast, selected from the list of Apple
  /// Podcasts categories (https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
  final String category;
  final String? subcategory;

  /// The parental advisory information for a podcast.
  /// The value can be true, indicating the presence of explicit content, or
  /// false, indicating that a podcast doesn’t contain explicit language or
  /// adult content.
  final bool explicit;

  /// The artwork for the podcast.
  /// Image must be a minimum size of 1400 x 1400 pixels and a maximum size of
  /// 3000 x 3000 pixels, in JPEG or PNG format, 72 dpi, with appropriate file
  /// extensions (.jpg, .png), and in the RGB color-space. File type extension
  /// must match the actual file type of the image file.
  final String image;

  /// The website or web page associated with a podcast.
  final String? link;

  /// Tells podcast hosting platforms whether they are allowed to import this
  /// feed.
  final locked = IsarLinks<Locked>();

  /// The Podcasting 2.0 GUID value (optional).
  /// https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#guid
  final String? guid;

  /// The group, person, or people responsible for creating the podcast.
  final String? author;

  /// The copyright details for a podcast.
  final String? copyright;

  /// If the podcast supports funding this will contain an instance of [Funding]
  /// that contains the Url and optional description.
  final funding = IsarLinks<Funding>();

  /// The type of show.
  @enumerated
  final ShowType type;

  /// Specifies that a podcast is complete and will not post any more episodes
  /// in the future.
  final bool complete;

  /// A value block designates single or multiple destinations for these
  /// micro-payments.
  final value = IsarLinks<Value>();

  /// A list of [Block] tags.
  final block = IsarLinks<Block>();

  /// A list of [Person] tags.
  final person = IsarLinks<Person>();

  @override
  String toString() {
    return '''Podcast(title: '$title', feedUrl: '$feedUrl')''';
  }
}

@collection
class PodcastStats {
  PodcastStats({
    required this.id,
    this.subscribedDate,
    this.lastCheckedAt,
  });

  final Id id;
  @Index()
  final DateTime? subscribedDate;
  final DateTime? lastCheckedAt;

  PodcastStats copyWith({
    DateTime? subscribedDate,
    DateTime? lastCheckedAt,
  }) {
    return PodcastStats(
      id: id,
      subscribedDate: subscribedDate ?? this.subscribedDate,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

extension PodcastStatsExt on PodcastStats {
  bool get subscribed => subscribedDate != null;
}

class PodcastStatsUpdateParam {
  const PodcastStatsUpdateParam({
    required this.id,
    this.subscribed,
    this.lastCheckedAt,
  });

  final Id id;
  final bool? subscribed;
  final DateTime? lastCheckedAt;

  PodcastStatsUpdateParam copyWith({
    bool? subscribed,
    DateTime? lastCheckedAt,
  }) {
    return PodcastStatsUpdateParam(
      id: id,
      subscribed: subscribed ?? this.subscribed,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

enum PodcastDetailViewMode {
  episodes,
  seasons,
  played,
  unplayed,
  downloaded;
}

@collection
class PodcastViewStats {
  PodcastViewStats({
    required this.id,
    this.viewMode = PodcastDetailViewMode.seasons,
    this.ascend = false,
    this.ascendSeasonEpisodes = true,
  });

  final Id id;
  @enumerated
  final PodcastDetailViewMode viewMode;
  final bool ascend;
  final bool ascendSeasonEpisodes;

  PodcastViewStats copyWith({
    PodcastDetailViewMode? viewMode,
    bool? ascend,
    bool? ascendSeasonEpisodes,
  }) {
    return PodcastViewStats(
      id: id,
      viewMode: viewMode ?? this.viewMode,
      ascend: ascend ?? this.ascend,
      ascendSeasonEpisodes: ascendSeasonEpisodes ?? this.ascendSeasonEpisodes,
    );
  }
}

class PodcastViewStatsUpdateParam {
  const PodcastViewStatsUpdateParam({
    required this.id,
    this.viewMode,
    this.ascend,
    this.ascendSeasonEpisodes,
    this.listenedEpisodes,
  });

  final Id id;
  final PodcastDetailViewMode? viewMode;
  final bool? ascend;
  final bool? ascendSeasonEpisodes;
  final Map<String, DateTime>? listenedEpisodes;

  PodcastViewStatsUpdateParam copyWith({
    PodcastDetailViewMode? viewMode,
    bool? ascend,
    bool? ascendSeasonEpisodes,
    Map<String, DateTime>? listenedEpisodes,
  }) {
    return PodcastViewStatsUpdateParam(
      id: id,
      viewMode: viewMode ?? this.viewMode,
      ascend: ascend ?? this.ascend,
      ascendSeasonEpisodes: ascendSeasonEpisodes ?? this.ascendSeasonEpisodes,
      listenedEpisodes: listenedEpisodes,
    );
  }
}
