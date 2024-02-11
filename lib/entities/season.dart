import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/episode.dart';

part 'season.freezed.dart';
part 'season.g.dart';

/// An object that represents an individual season of a Podcast.
///
/// A season is a collection of episodes that are grouped together by
/// `Episode.season`.
/// This class is used to represent a season in the database and is used
/// to display a season in the UI.
@freezed
class Season with _$Season {
  const factory Season({
    /// Database ID
    int? id,

    /// A String GUID for the season.
    required String guid,

    /// The GUID for an associated podcast. If an episode has been downloaded
    /// without subscribing to a podcast this may be null.
    required String pguid,

    /// The name of the podcast the season is part of.
    required String podcast,

    /// The season title.
    String? title,

    /// The season number.
    int? seasonNum,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}

extension SeasonExt on Season {
  // bool get playedAllEpisodes => episodes.every((element) => element.played);
  //
  // int get totalDuration =>
  //     episodes.fold(0, (ms, episode) => ms + episode.duration);
  //
  // bool get played {
  //   return episodes.every((element) => element.played);
  // }
  //
  // String? get thumbImageUrl {
  //   return episodes.first.thumbImageUrl;
  // }
  //
  // String? get imageUrl {
  //   return episodes.first.imageUrl;
  // }
  //
  // double get percentagePlayed {
  //   return episodes.fold(
  //           0.0, (total, episode) => total + episode.percentagePlayed) /
  //       episodes.length;
  // }
  //
  // DateTime? get publicationDate {
  //   return episodes.first.publicationDate;
  // }
  //
  // int get duration {
  //   return episodes.fold(0, (total, episode) => total + episode.duration);
  // }
  //
  // Duration get timeRemaining {
  //   return episodes.fold(
  //       Duration.zero,
  //       (total, episode) =>
  //           total + Duration(seconds: episode.timeRemaining.inSeconds));
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
