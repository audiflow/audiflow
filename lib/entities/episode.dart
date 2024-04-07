// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/hash.dart';
import 'package:audiflow/core/utils.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart'
    show ChannelItemValues, EpisodeType;

part 'episode.g.dart';

/// An object that represents an individual episode of a Podcast.
///
/// An Episode can be used in conjunction with a [Downloadable] to
/// determine if the Episode is available on the local filesystem.

@collection
class Episode {
  Episode({
    required this.pid,
    required this.guid,
    required this.title,
    this.author,
    this.link,
    this.publicationDate,
    this.description,
    this.durationMS,
    this.imageUrl,
    this.explicit = false,
    this.season,
    this.episode,
    this.type = EpisodeType.full,
  });

  factory Episode.fromChannelItem(int pid, ChannelItemValues item) {
    return Episode(
      pid: pid,
      guid: item.guid,
      title: removeHtmlPadding(item.title),
      author: item.author?.replaceAll('\n', ', ').trim() ?? '',
      link: item.link,
      publicationDate: item.pubDate,
      description: item.description,
      durationMS: item.duration?.inMilliseconds,
      imageUrl: item.imageUrl,
      explicit: item.explicit,
      season: item.season,
      episode: item.episode,
      type: item.type,
    );
  }

  static Id idFrom(String guid) => fastHash(guid);

  Id get id => idFrom(guid);

  /// The Isar ID of the parent podcast.
  final int pid;

  /// The title for the podcast episode.
  final String title;

  /// The globally unique identifier (GUID) for a podcast episode.
  @Index(unique: true)
  final String guid;

  /// The group responsible for creating the show.
  String? author;

  /// The URL of a web page associated with the podcast episode.
  String? link;

  /// The release date and time of an episode.
  final DateTime? publicationDate;

  /// The episode description.
  /// The maximum amount of text allowed for this tag is 4000 bytes.
  /// Some HTML is permitted
  /// (<p>, <ol>, <ul>, <li>, <a>, <b>, <i>, <strong>, <em>)
  /// if wrapped in the <CDATA> tag.
  final String? description;

  /// Length of the episode in milli seconds.
  final int? durationMS;

  /// The episode-specific artwork.
  /// Image must be a minimum size of 1400 x 1400 pixels and a maximum size of
  /// 3000 x 3000 pixels, in JPEG or PNG format, 72 dpi, with appropriate file
  /// extensions (.jpg, .png), and in the sRGB color-space. File type extension
  /// must match the actual file type of the image file.
  String? imageUrl;

  /// The parental advisory information for a podcast.
  final bool explicit;

  /// A list of URLs containing a transcript.
  final transcripts = IsarLinks<TranscriptUrl>();

  /// The chronological number that is associated with a podcast episode.
  /// Must be a non-zero integer. This is required for serial podcasts.
  int? episode;

  /// The chronological number associated with a podcast episode's season.
  /// Must be a non-zero integer.
  int? season;

  /// The type of episode.
  @enumerated
  EpisodeType type;

  /// A list of [Block] tags.
  final block = IsarLinks<Block>();

  /// A list of [Person] tags.
  final person = IsarLinks<Person>();

  @override
  String toString() {
    return '''Episode(guid: '$guid', title: '$title')''';
  }
}

extension EpisodeExtension on Episode {
  Duration? get duration =>
      durationMS == null ? null : Duration(milliseconds: durationMS!);

  String get descriptionText {
    if (description?.isNotEmpty == true) {
      final stripped = description!.replaceAll(RegExp(r'(<br/?>)+'), ' ');
      return parseFragment(stripped).text ?? '';
    } else {
      return '';
    }
  }
//
// bool get hasChapters => chaptersUrl != null && chaptersUrl!.isNotEmpty;
//
// bool get hasTranscripts => transcriptUrls.isNotEmpty;
}

@collection
class EpisodeStats {
  EpisodeStats({
    required this.pid,
    required this.id,
    this.positionMS = 0,
    this.playCount = 0,
    this.playTotalMS = 0,
    this.played = false,
    this.completeCount = 0,
    this.inQueue = false,
    this.downloadedTime,
    this.lastPlayedAt,
  });

  final Id id;

  /// The Isar ID of the parent podcast.
  final int pid;

  /// Current position in the episode
  final int positionMS;

  /// Number of times of start playing
  final int playCount;

  /// Total playing time
  final int playTotalMS;

  /// Whether the episode has been marked as played
  final bool played;

  /// Number of times of complete playing
  final int completeCount;

  /// Whether the episode is in the queue
  final bool inQueue;

  /// Downloaded time
  final DateTime? downloadedTime;

  /// Latest playing start time
  final DateTime? lastPlayedAt;
}

extension EpisodeStatsExt on EpisodeStats {
  bool get downloaded => downloadedTime != null;

  Duration get playTotal => Duration(milliseconds: playTotalMS);

  Duration get position => Duration(milliseconds: positionMS);

  double percentagePlayed(Duration? duration) {
    return duration == null
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;
  }

  Duration timeRemaining(Duration? duration) {
    return duration == null ? Duration.zero : duration - position;
  }
}

class EpisodeStatsUpdateParam {
  const EpisodeStatsUpdateParam({
    required this.pguid,
    required this.id,
    this.position,
    this.played,
    this.playTotalDelta,
    this.completeCountDelta,
    this.inQueue,
    this.downloaded,
    this.lastPlayedAt,
  });

  final String pguid;
  final Id id;
  final Duration? position;
  final bool? played;
  final Duration? playTotalDelta;
  final int? completeCountDelta;
  final bool? inQueue;
  final bool? downloaded;
  final DateTime? lastPlayedAt;

  EpisodeStatsUpdateParam copyWith({
    Duration? position,
    bool? startPlaying,
    bool? played,
    Duration? playTotalDelta,
    int? completeCountDelta,
    bool? inQueue,
    bool? downloaded,
    DateTime? lastPlayedAt,
  }) {
    return EpisodeStatsUpdateParam(
      pguid: pguid,
      id: id,
      position: position ?? this.position,
      played: played ?? this.played,
      playTotalDelta: playTotalDelta ?? this.playTotalDelta,
      completeCountDelta: completeCountDelta ?? this.completeCountDelta,
      inQueue: inQueue ?? this.inQueue,
      downloaded: downloaded ?? this.downloaded,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  bool get isEmpty =>
      position == null &&
      played == null &&
      playTotalDelta == null &&
      completeCountDelta == null &&
      inQueue == null &&
      downloaded == null &&
      lastPlayedAt == null;
}
