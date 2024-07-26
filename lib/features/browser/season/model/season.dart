import 'dart:convert';

import 'package:audiflow/utils/hash.dart';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

part 'season.g.dart';

/// An object that represents an individual season of a Podcast.
///
/// A season is a collection of episodes that are grouped together by
/// `Episode.season`.
/// This class is used to represent a season in the database and is used
/// to display a season in the UI.
@collection
class Season {
  Season({
    required this.guid,
    required this.pid,
    required this.seasonNum,
    required this.title,
    required this.imageUrl,
    required this.episodeIds,
    required this.firstPublicationDate,
    required this.latestPublicationDate,
    required this.totalDurationMS,
  });

  Id get id => fastHash(guid);

  /// The GUID for an associated podcast.
  final String guid;

  /// The Isar ID of the parent podcast.
  final int pid;

  /// The season number.
  final int? seasonNum;

  /// The season title.
  final String? title;

  /// Image URL of the season.
  final String? imageUrl;

  /// Episodes under the season.
  final List<Id> episodeIds;

  /// The publication date of the first episode in the season.
  final DateTime? firstPublicationDate;

  /// The publication date of the last episode in the season.
  final DateTime? latestPublicationDate;

  /// Total duration of all episodes in the season.
  final int totalDurationMS;

  Season copyWith({
    String? title,
    String? imageUrl,
    int? seasonNum,
    List<Id>? episodeIds,
    DateTime? firstPublicationDate,
    DateTime? latestPublicationDate,
    int? totalDurationMS,
  }) {
    return Season(
      guid: guid,
      pid: pid,
      seasonNum: seasonNum ?? this.seasonNum,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      episodeIds: episodeIds ?? this.episodeIds,
      firstPublicationDate: firstPublicationDate ?? this.firstPublicationDate,
      latestPublicationDate:
          latestPublicationDate ?? this.latestPublicationDate,
      totalDurationMS: totalDurationMS ?? this.totalDurationMS,
    );
  }
}

extension SeasonExt on Season {
  Duration get totalDuration => Duration(milliseconds: totalDurationMS);
// bool get playedAll =>
//     episodes.map((e) => e.$2).every((stats) => stats?.played == true);

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

String calcSeasonGuid({required String feedUrl, required int? seasonNum}) {
  return md5.convert(utf8.encode('$feedUrl/$seasonNum')).toString();
}
