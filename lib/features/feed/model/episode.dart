import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/hash.dart';
import 'package:audiflow/utils/html.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart'
    show ChannelItemValues, EpisodeType;

part 'episode.g.dart';

/// An object that represents an individual episode of a Podcast.
@collection
class Episode implements Comparable<Episode> {
  Episode({
    required this.pid,
    required this.guid,
    required this.contentUrl,
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
      contentUrl: item.enclosure.url,
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
  @Index()
  final int pid;

  /// The URL of the media file.
  final String contentUrl;

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
  @Index()
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
  final String? imageUrl;

  /// The parental advisory information for a podcast.
  final bool explicit;

  /// A list of URLs containing a transcript.
  final transcripts = IsarLinks<TranscriptUrl>();

  /// The chronological number that is associated with a podcast episode.
  /// Must be a non-zero integer. This is required for serial podcasts.
  @Index()
  final int? episode;

  /// The chronological number associated with a podcast episode's season.
  /// Must be a non-zero integer.
  @Index()
  final int? season;

  /// The type of episode.
  @enumerated
  final EpisodeType type;

  /// A list of [Block] tags.
  final block = IsarLinks<Block>();

  /// A list of [Person] tags.
  final person = IsarLinks<Person>();

  @override
  String toString() {
    return '''Episode(guid: '$guid', title: '$title')''';
  }

  @override
  int compareTo(Episode other) {
    if (episode != null && other.episode != null) {
      return episode!.compareTo(other.episode!);
    }

    if (publicationDate != null) {
      if (other.publicationDate != null) {
        return publicationDate!.compareTo(other.publicationDate!);
      } else {
        return 1;
      }
    } else if (other.publicationDate != null) {
      return -1;
    }

    return title.compareTo(other.title);
  }
}

class PartialEpisode {
  PartialEpisode({
    required this.id,
    required this.pid,
    required this.title,
    required this.guid,
    this.publicationDate,
    this.episode,
    this.season,
    required this.type,
  });

  PartialEpisode.fromEpisode(Episode episode)
      : this(
          id: episode.id,
          pid: episode.pid,
          title: episode.title,
          guid: episode.guid,
          publicationDate: episode.publicationDate,
          episode: episode.episode,
          season: episode.season,
          type: episode.type,
        );

  final int id;
  final int pid;
  final String title;
  final String guid;
  final DateTime? publicationDate;
  final int? episode;
  final int? season;
  final EpisodeType type;
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
    required this.id,
    required this.pid,
    this.durationMS,
    this.positionMS = 0,
    this.playCount = 0,
    this.playTotalMS = 0,
    this.played = false,
    this.completeCount = 0,
    this.lastPlayedAt,
  });

  final Id id;

  /// The Isar ID of the parent podcast.
  @Index()
  final int pid;

  /// Actual duration of the episode.
  final int? durationMS;

  /// Current position in the episode
  final int positionMS;

  /// Number of times of start playing
  final int playCount;

  /// Total playing time
  final int playTotalMS;

  /// Whether the episode has been marked as played
  @Index()
  final bool played;

  /// Number of times of complete playing
  @Index()
  final int completeCount;

  /// Latest playing start time
  @Index()
  final DateTime? lastPlayedAt;
}

extension EpisodeStatsExt on EpisodeStats {
  Duration? get duration =>
      durationMS == null ? null : Duration(milliseconds: durationMS!);

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
    required this.id,
    required this.pid,
    this.duration,
    this.position,
    this.played,
    this.playTotalDelta,
    this.completed,
    this.lastPlayedAt,
  });

  final Id id;
  final int pid;
  final Duration? duration;
  final Duration? position;
  final bool? played;
  final Duration? playTotalDelta;
  final bool? completed;
  final DateTime? lastPlayedAt;

  EpisodeStatsUpdateParam copyWith({
    Duration? duration,
    Duration? position,
    bool? startPlaying,
    bool? played,
    Duration? playTotalDelta,
    bool? completed,
    DateTime? lastPlayedAt,
  }) {
    return EpisodeStatsUpdateParam(
      id: id,
      pid: pid,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      played: played ?? this.played,
      playTotalDelta: playTotalDelta ?? this.playTotalDelta,
      completed: completed ?? this.completed,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  bool get isEmpty =>
      duration == null &&
      position == null &&
      played == null &&
      playTotalDelta == null &&
      completed == null &&
      lastPlayedAt == null;
}
