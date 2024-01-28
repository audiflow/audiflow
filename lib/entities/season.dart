import 'package:coten_player/entities/episode.dart';
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

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String? pguid;

  /// The name of the podcast the season is part of.
  String? podcast;

  /// The season title.
  String? title;

  /// The season number.
  int? seasonNum;

  /// More detailed description - optional.
  List<Episode>? episodes;

  Season({
    this.pguid,
    required this.podcast,
    this.id,
    this.title,
    this.seasonNum,
    this.episodes = const <Episode>[],
  });

  bool get playedAllEpisodes => episodes!.every((element) => element.played);

  int get totalDuration =>
      episodes!.fold(0, (ms, episode) => ms + episode.duration);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pguid': pguid,
      'podcast': podcast,
      'title': title,
      'seasonNum': seasonNum,
    };
  }

  static Season fromMap(int? key, Map<String, dynamic> episode) {
    return Season(
      id: key,
      pguid: episode['pguid'] as String?,
      podcast: episode['podcast'] as String?,
      title: episode['title'] as String?,
      seasonNum: episode['seasonNum'] as int?,
    );
  }

  String get guid {
    return '${podcast!}-$seasonNum';
  }

  bool get played {
    return episodes!.every((element) => element.played);
  }

  String? get thumbImageUrl {
    return episodes!.first.thumbImageUrl;
  }

  String? get imageUrl {
    return episodes!.first.imageUrl;
  }

  double get percentagePlayed {
    return episodes!
            .fold(0.0, (total, episode) => total + episode.percentagePlayed) /
        episodes!.length;
  }

  DateTime? get publicationDate {
    return episodes!.first.publicationDate;
  }

  int get duration {
    return episodes!.fold(0, (total, episode) => total + episode.duration);
  }

  Duration get timeRemaining {
    return episodes!.fold(
        Duration.zero,
        (total, episode) =>
            total + Duration(seconds: episode.timeRemaining.inSeconds));
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
    return 'Season{id: $id, pguid: $pguid, podcast: $podcast, title: $title, seasonNum: $seasonNum}';
  }
}
