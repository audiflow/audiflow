// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/chapter.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/person.dart';
import 'package:seasoning/entities/transcript.dart';

part 'episode.freezed.dart';
part 'episode.g.dart';

/// An object that represents an individual episode of a Podcast.
///
/// An Episode can be used in conjunction with a [Downloadable] to
/// determine if the Episode is available on the local filesystem.

@freezed
class Episode with _$Episode {
  const factory Episode({
    /// A String GUID for the episode.
    required String guid,

    /// The GUID for an associated podcast. If an episode has been downloaded
    /// without subscribing to a podcast this may be null.
    required String pguid,

    /// The name of the podcast the episode is part of.
    required String title,

    /// The episode description. This could be plain text or HTML.
    required String description,

    /// More detailed description - optional.
    String? content,

    /// External link
    String? link,

    /// URL to the episode artwork image.
    required String? imageUrl,

    /// URL to a thumbnail version of the episode artwork image.
    required String? thumbImageUrl,

    /// The date the episode was published (if known).
    DateTime? publicationDate,

    /// The URL for the episode location.
    String? contentUrl,

    /// Author of the episode if known.
    String? author,

    /// The season the episode is part of if available.
    int? season,

    /// The episode number within a season if available.
    int? episode,

    /// The duration of the episode in milliseconds. This can be populated
    /// either from the RSS if available, or determined from the MP3 file at
    /// stream/download time.
    required Duration? duration,

    /// URL pointing to a JSON file containing chapter information if available.
    String? chaptersUrl,

    /// List of chapters for the episode if available.
    @Default([]) List<Chapter> chapters,

    /// List of transcript URLs for the episode if available.
    @Default([]) List<TranscriptUrl> transcriptUrls,

    /// List of people of interest to the podcast.
    @Default([]) List<Person> persons,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);

  factory Episode.fromSearch(
    search.Episode episode, {
    required String pguid,
    String? imageUrl,
    String? thumbImageUrl,
  }) {
    final author = episode.author?.replaceAll('\n', '').trim() ?? '';
    final title = removeHtmlPadding(episode.title);
    final description = removeHtmlPadding(episode.description);
    final content = episode.content;

    final episodeImage =
        episode.imageUrl?.isNotEmpty == true ? episode.imageUrl : imageUrl;
    final episodeThumbImage =
        episode.imageUrl?.isNotEmpty == true ? episode.imageUrl : thumbImageUrl;
    final duration = episode.duration ?? Duration.zero;

    return Episode(
      pguid: pguid,
      guid: episode.guid,
      title: title,
      description: description,
      content: content,
      author: author,
      season: episode.season,
      episode: episode.episode,
      contentUrl: episode.contentUrl,
      link: episode.link,
      imageUrl: episodeImage,
      thumbImageUrl: episodeThumbImage,
      duration: Duration.zero < duration ? duration : null,
      publicationDate: episode.publicationDate,
      chaptersUrl: episode.chapters?.url,
      persons: episode.persons.map(Person.fromSearch).toList(),
      chapters: <Chapter>[],
      transcriptUrls:
          episode.transcripts.map(TranscriptUrl.fromSearch).toList(),
    );
  }
}

extension EpisodeExtension on Episode {
  String get descriptionText {
    if (description.isEmpty) {
      return '';
    } else {
      final stripped = description.replaceAll(RegExp(r'(<br/?>)+'), ' ');
      return parseFragment(stripped).text ?? '';
    }
  }

  bool get hasChapters => chaptersUrl != null && chaptersUrl!.isNotEmpty;

  bool get hasTranscripts => transcriptUrls.isNotEmpty;
}

@freezed
class EpisodeStats with _$EpisodeStats {
  const factory EpisodeStats({
    @Default(0) int id,
    required String guid,
    @Default(Duration.zero) Duration position,
    Duration? duration,
    @Default(false) bool played,
    @Default(0) int playCount,
    @Default(Duration.zero) Duration playTotal,
    @Default(false) bool inQueue,
    @Default(false) bool downloaded,
  }) = _EpisodeStats;

  factory EpisodeStats.fromJson(Map<String, dynamic> json) =>
      _$EpisodeStatsFromJson(json);

  factory EpisodeStats.fromEpisode(Episode episode) {
    return EpisodeStats(
      guid: episode.guid,
      duration: episode.duration,
    );
  }
}

class EpisodeStatsUpdateParam {
  const EpisodeStatsUpdateParam({
    this.id,
    required this.guid,
    this.position,
    this.duration,
    this.completed,
    this.playCount,
    this.playTotal,
    this.inQueue,
    this.downloaded,
  });

  final int? id;
  final String guid;
  final Duration? position;
  final Duration? duration;
  final bool? completed;
  final int? playCount;
  final Duration? playTotal;
  final bool? inQueue;
  final bool? downloaded;

  EpisodeStatsUpdateParam copyWith({
    int? id,
    String? guid,
    Duration? position,
    Duration? duration,
    bool? played,
    int? playCount,
    Duration? playTotal,
    bool? inQueue,
    bool? downloaded,
  }) {
    return EpisodeStatsUpdateParam(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      completed: played ?? this.completed,
      playCount: playCount ?? this.playCount,
      playTotal: playTotal ?? this.playTotal,
      inQueue: inQueue ?? this.inQueue,
      downloaded: downloaded ?? this.downloaded,
    );
  }
}

extension EpisodeStatsExt on EpisodeStats {
  double get percentagePlayed => duration == null
      ? 0.0
      : position.inMilliseconds / duration!.inMilliseconds;

  Duration get timeRemaining =>
      duration == null ? Duration.zero : duration! - position;
}
