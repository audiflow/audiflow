// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/chapter.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/person.dart';
import 'package:seasoning/entities/podcast.dart';
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
    /// Database ID
    int? id,

    /// A String GUID for the episode.
    required String guid,

    /// The GUID for an associated podcast. If an episode has been downloaded
    /// without subscribing to a podcast this may be null.
    required String pguid,

    /// The path to the directory containing the download for this episode;
    /// or null.
    String? filepath,

    /// The filename of the downloaded episode; or null.
    String? filename,

    /// The name of the podcast the episode is part of.
    required String podcast,

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
    @Default(0) int duration,

    /// Stores the current position within the episode in milliseconds.
    /// Used for resuming.
    @Default(0) int position,

    /// True if this episode is 'marked as played'.
    @Default(false) bool played,

    /// URL pointing to a JSON file containing chapter information if available.
    String? chaptersUrl,

    /// List of chapters for the episode if available.
    @Default([]) List<Chapter> chapters,

    /// Index of the currently playing chapter it available. Transient.
    int? chapterIndex,

    /// Current chapter we are listening to if this episode has chapters.
    // ignore: invalid_annotation_target
    @JsonKey(includeToJson: false, includeFromJson: false)
    Chapter? currentChapter,

    /// List of transcript URLs for the episode if available.
    @Default([]) List<TranscriptUrl> transcriptUrls,
    @Default([]) List<Person> persons,

    /// Processed version of episode description.
    // ignore: invalid_annotation_target
    @JsonKey(includeToJson: false, includeFromJson: false)
    String? parsedDescriptionText,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);

  factory Episode.fromSearch(search.Episode episode, Podcast pc) {
    final author = episode.author?.replaceAll('\n', '').trim() ?? '';
    final title = removeHtmlPadding(episode.title);
    final description = removeHtmlPadding(episode.description);
    final content = episode.content;

    final episodeImage =
        episode.imageUrl?.isNotEmpty == true ? episode.imageUrl : pc.imageUrl;
    final episodeThumbImage = episode.imageUrl?.isNotEmpty == true
        ? episode.imageUrl
        : pc.thumbImageUrl;
    final duration = episode.duration?.inSeconds ?? 0;
    final transcriptUrls = <TranscriptUrl>[];
    final episodePersons = <Person>[];

    for (final t in episode.transcripts) {
      late TranscriptFormat type;

      switch (t.type) {
        case search.TranscriptFormat.subrip:
          type = TranscriptFormat.subrip;
        case search.TranscriptFormat.json:
          type = TranscriptFormat.json;
        case search.TranscriptFormat.unsupported:
          type = TranscriptFormat.unsupported;
      }

      transcriptUrls.add(TranscriptUrl(url: t.url, type: type));
    }

    if (episode.persons.isNotEmpty) {
      for (final p in episode.persons) {
        episodePersons.add(
          Person(
            name: p.name,
            role: p.role,
            group: p.group,
            image: p.image,
            link: p.link,
          ),
        );
      }
    } else if (pc.persons.isNotEmpty) {
      episodePersons.addAll(pc.persons);
    }

    return Episode(
      pguid: pc.guid,
      guid: episode.guid,
      podcast: pc.title,
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
      duration: duration,
      publicationDate: episode.publicationDate,
      chaptersUrl: episode.chapters?.url,
      persons: episodePersons,
      chapters: <Chapter>[],
    );
  }
}

extension EpisodeExtension on Episode {
  Duration get timeRemaining {
    if (position > 0 && duration > 0) {
      final currentPosition = Duration(milliseconds: position);

      final tr = duration - currentPosition.inSeconds;

      return Duration(seconds: tr);
    }

    return Duration.zero;
  }

  double get percentagePlayed {
    if (position > 0 && duration > 0) {
      var pc = (position / (duration * 1000)) * 100;

      if (pc > 100.0) {
        pc = 100.0;
      }

      return pc;
    }

    return 0;
  }

  // String? get descriptionText {
  //   if (parsedDescriptionText == null || parsedDescriptionText!.isEmpty) {
  //     if (description.isEmpty) {
  //       parsedDescriptionText = '';
  //     } else {
  //       // Replace break tags with space character for readability
  //       var formattedDescription =
  //           description!.replaceAll(RegExp(r'(<br/?>)+'), ' ');
  //       parsedDescriptionText = parseFragment(formattedDescription).text;
  //     }
  //   }
  //
  //   return parsedDescriptionText;
  // }

  bool get hasChapters => chaptersUrl != null && chaptersUrl!.isNotEmpty;

  bool get hasTranscripts => transcriptUrls.isNotEmpty;

  String? get positionalImageUrl {
    if (currentChapter != null &&
        currentChapter!.imageUrl != null &&
        currentChapter!.imageUrl!.isNotEmpty) {
      return currentChapter!.imageUrl;
    }

    return imageUrl;
  }
}
