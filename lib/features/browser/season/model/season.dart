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

  /// The GUID of the season.
  final String guid;

  /// The Isar ID of the parent podcast.
  @Index()
  final int pid;

  /// The season number.
  @Index()
  final int? seasonNum;

  /// The season title.
  final String? title;

  /// Image URL of the season.
  final String? imageUrl;

  /// Episodes under the season.
  final List<Id> episodeIds;

  /// The publication date of the first episode in the season.
  @Index()
  final DateTime? firstPublicationDate;

  /// The publication date of the last episode in the season.
  @Index()
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

  @override
  bool operator ==(Object other) {
    return other is Season &&
        id == other.id &&
        guid == other.guid &&
        title == other.title &&
        imageUrl == other.imageUrl &&
        episodeIds.length == other.episodeIds.length &&
        episodeIds.every(other.episodeIds.contains);
  }

  @override
  int get hashCode {
    return Object.hash(id, guid, title, imageUrl, episodeIds);
  }
}

extension SeasonExt on Season {
  Duration get totalDuration => Duration(milliseconds: totalDurationMS);
}

String calcSeasonGuid({required String feedUrl, required int? seasonNum}) {
  return md5.convert(utf8.encode('$feedUrl/$seasonNum')).toString();
}

@collection
class SeasonStats {
  SeasonStats({
    required this.id,
    required this.completedEpisodeIds,
  });

  final Id id;

  /// List of episode IDs that have been played to the end.
  final List<Id> completedEpisodeIds;

  SeasonStats copyWith({
    List<Id>? completedEpisodeIds,
  }) {
    return SeasonStats(
      id: id,
      completedEpisodeIds: completedEpisodeIds ?? this.completedEpisodeIds,
    );
  }
}

class SeasonStatsUpdateParam {
  SeasonStatsUpdateParam({
    required this.id,
    this.completedEpisodeIds,
  });

  final Id id;
  List<Id>? completedEpisodeIds;

  SeasonStatsUpdateParam copyWith({
    List<Id>? completedEpisodeIds,
  }) {
    return SeasonStatsUpdateParam(
      id: id,
      completedEpisodeIds: completedEpisodeIds ?? this.completedEpisodeIds,
    );
  }

  bool get isEmpty => completedEpisodeIds == null;
}
