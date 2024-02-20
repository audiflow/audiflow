import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/episode.dart';

part 'season.freezed.dart';

/// An object that represents an individual season of a Podcast.
///
/// A season is a collection of episodes that are grouped together by
/// `Episode.season`.
/// This class is used to represent a season in the database and is used
/// to display a season in the UI.
@freezed
class Season with _$Season {
  const factory Season({
    /// A String GUID for the season.
    required String guid,

    /// The GUID for an associated podcast. If an episode has been downloaded
    /// without subscribing to a podcast this may be null.
    required String pguid,

    /// Episodes under the season.
    required List<Episode> episodes,

    /// The season title.
    String? title,

    /// The season number.
    int? seasonNum,
  }) = _Season;
}

extension SeasonExt on Season {
  // bool get playedAll =>
  //     episodes.map((e) => e.$2).every((stats) => stats?.played == true);

  Duration get totalDuration => episodes
      .fold(Duration.zero, (ms, episode) => ms + episode.duration);

  String? get thumbImageUrl {
    return episodes.first.thumbImageUrl;
  }

  String? get imageUrl {
    return episodes.first.imageUrl;
  }

  DateTime? get publicationDate {
    return episodes.first.publicationDate;
  }

  Duration get duration {
    return episodes
        .fold(Duration.zero, (total, episode) => total + episode.duration);
  }

  // Duration get timeRemaining {
  //   final playedTotal =
  //       episodes.map((e) => e.$2).fold(Duration.zero, (total, stats) {
  //     final maxPosition = stats == null
  //         ? Duration.zero
  //         : stats.played
  //             ? stats.duration
  //             : stats.position;
  //     return total + maxPosition;
  //   });
  //   return totalDuration - playedTotal;
  // }
}

List<Episode> sortedSeasonEpisodes(List<Episode> episodes) =>
    0 < (episodes.firstOrNull?.season ?? 0)
        ? episodes.sorted((a, b) => (a.episode ?? 0) - (b.episode ?? 0))
        : episodes.sorted((a, b) => (b.episode ?? 0) - (a.episode ?? 0));

String calcSeasonGuid({required String podcast, required int seasonNum}) {
  final id = md5.convert(utf8.encode(podcast)).toString();
  return '${id}_$seasonNum';
}
