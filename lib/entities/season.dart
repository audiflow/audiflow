import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:coten_player/entities/episode.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';

/// An object that represents an individual season of a Podcast.
///
/// A season is a collection of episodes that are grouped together by
/// `Episode.season`.
/// This class is used to represent a season in the database and is used
/// to display a season in the UI.
class Season {
  final log = Logger('Season');

  /// Database ID
  int? id;

  /// A String GUID for the season.
  final String guid;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String? pguid;

  /// The name of the podcast the season is part of.
  String podcast;

  /// The season title.
  String? title;

  /// The season number.
  int seasonNum;

  /// More detailed description - optional.
  List<Episode> _episodes;

  Season({
    required this.pguid,
    required this.podcast,
    this.id,
    required this.title,
    required this.seasonNum,
    required List<Episode> episodes,
  })  : guid = _calcGUID(podcast, seasonNum),
        _episodes = _sorted(episodes);

  List<Episode> get episodes => _episodes;

  set episodes(List<Episode> newValue) => _episodes = _sorted(newValue);

  bool get playedAllEpisodes => _episodes.every((element) => element.played);

  int get totalDuration =>
      _episodes.fold(0, (ms, episode) => ms + episode.duration);

  bool get played {
    return _episodes.every((element) => element.played);
  }

  String? get thumbImageUrl {
    return _episodes.first.thumbImageUrl;
  }

  String? get imageUrl {
    return _episodes.first.imageUrl;
  }

  double get percentagePlayed {
    return _episodes.fold(
            0.0, (total, episode) => total + episode.percentagePlayed) /
        _episodes.length;
  }

  DateTime? get publicationDate {
    return _episodes.first.publicationDate;
  }

  int get duration {
    return _episodes.fold(0, (total, episode) => total + episode.duration);
  }

  Duration get timeRemaining {
    return _episodes.fold(
        Duration.zero,
        (total, episode) =>
            total + Duration(seconds: episode.timeRemaining.inSeconds));
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pguid': pguid,
      'podcast': podcast,
      'title': title,
      'seasonNum': seasonNum,
    };
  }

  static Season fromMap(int? key, Map<String, dynamic> season) {
    return Season(
      id: key,
      pguid: season['pguid'] as String?,
      podcast: season['podcast'] as String,
      title: season['title'] as String?,
      seasonNum: season['seasonNum'] as int,
      episodes: [],
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Season &&
            runtimeType == other.runtimeType &&
            pguid == other.pguid &&
            podcast == other.podcast &&
            title == other.title &&
            seasonNum == other.seasonNum;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      pguid.hashCode ^
      podcast.hashCode ^
      title.hashCode ^
      seasonNum.hashCode;

  @override
  String toString() {
    return 'Season{id: $id, pguid: $pguid, podcast: $podcast, seasonNum: $seasonNum, title: $title}';
  }
}

List<Episode> _sorted(List<Episode> episodes) =>
    episodes.sorted((a, b) => a.episode - b.episode);

String _calcGUID(String podcast, int seasonNum) {
  final id = md5.convert(utf8.encode(podcast)).toString();
  return '${id}_$seasonNum';
}
