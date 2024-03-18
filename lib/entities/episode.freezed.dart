// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Episode _$EpisodeFromJson(Map<String, dynamic> json) {
  return _Episode.fromJson(json);
}

/// @nodoc
mixin _$Episode {
  /// A String GUID for the episode.
  String get guid => throw _privateConstructorUsedError;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid => throw _privateConstructorUsedError;

  /// The name of the podcast the episode is part of.
  String get title => throw _privateConstructorUsedError;

  /// The episode description. This could be plain text or HTML.
  String get description => throw _privateConstructorUsedError;

  /// More detailed description - optional.
  String? get content => throw _privateConstructorUsedError;

  /// External link
  String? get link => throw _privateConstructorUsedError;

  /// URL to the episode artwork image.
  String? get imageUrl => throw _privateConstructorUsedError;

  /// URL to a thumbnail version of the episode artwork image.
  String? get thumbImageUrl => throw _privateConstructorUsedError;

  /// The date the episode was published (if known).
  DateTime? get publicationDate => throw _privateConstructorUsedError;

  /// The URL for the episode location.
  String? get contentUrl => throw _privateConstructorUsedError;

  /// Author of the episode if known.
  String? get author => throw _privateConstructorUsedError;

  /// The season the episode is part of if available.
  int? get season => throw _privateConstructorUsedError;

  /// The episode number within a season if available.
  int? get episode => throw _privateConstructorUsedError;

  /// The duration of the episode in milliseconds. This can be populated
  /// either from the RSS if available, or determined from the MP3 file at
  /// stream/download time.
  Duration? get duration => throw _privateConstructorUsedError;

  /// URL pointing to a JSON file containing chapter information if available.
  String? get chaptersUrl => throw _privateConstructorUsedError;

  /// List of chapters for the episode if available.
  List<Chapter> get chapters => throw _privateConstructorUsedError;

  /// List of transcript URLs for the episode if available.
  List<TranscriptUrl> get transcriptUrls => throw _privateConstructorUsedError;

  /// List of people of interest to the podcast.
  List<Person> get persons => throw _privateConstructorUsedError;

  /// True indicates this episode data contains only [EpisodeMetadata] fields.
  bool get metadataOnly => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EpisodeCopyWith<Episode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeCopyWith<$Res> {
  factory $EpisodeCopyWith(Episode value, $Res Function(Episode) then) =
      _$EpisodeCopyWithImpl<$Res, Episode>;
  @useResult
  $Res call(
      {String guid,
      String pguid,
      String title,
      String description,
      String? content,
      String? link,
      String? imageUrl,
      String? thumbImageUrl,
      DateTime? publicationDate,
      String? contentUrl,
      String? author,
      int? season,
      int? episode,
      Duration? duration,
      String? chaptersUrl,
      List<Chapter> chapters,
      List<TranscriptUrl> transcriptUrls,
      List<Person> persons,
      bool metadataOnly});
}

/// @nodoc
class _$EpisodeCopyWithImpl<$Res, $Val extends Episode>
    implements $EpisodeCopyWith<$Res> {
  _$EpisodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? pguid = null,
    Object? title = null,
    Object? description = null,
    Object? content = freezed,
    Object? link = freezed,
    Object? imageUrl = freezed,
    Object? thumbImageUrl = freezed,
    Object? publicationDate = freezed,
    Object? contentUrl = freezed,
    Object? author = freezed,
    Object? season = freezed,
    Object? episode = freezed,
    Object? duration = freezed,
    Object? chaptersUrl = freezed,
    Object? chapters = null,
    Object? transcriptUrls = null,
    Object? persons = null,
    Object? metadataOnly = null,
  }) {
    return _then(_value.copyWith(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      link: freezed == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbImageUrl: freezed == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      publicationDate: freezed == publicationDate
          ? _value.publicationDate
          : publicationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contentUrl: freezed == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as int?,
      episode: freezed == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      chaptersUrl: freezed == chaptersUrl
          ? _value.chaptersUrl
          : chaptersUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      chapters: null == chapters
          ? _value.chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<Chapter>,
      transcriptUrls: null == transcriptUrls
          ? _value.transcriptUrls
          : transcriptUrls // ignore: cast_nullable_to_non_nullable
              as List<TranscriptUrl>,
      persons: null == persons
          ? _value.persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
      metadataOnly: null == metadataOnly
          ? _value.metadataOnly
          : metadataOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodeImplCopyWith<$Res> implements $EpisodeCopyWith<$Res> {
  factory _$$EpisodeImplCopyWith(
          _$EpisodeImpl value, $Res Function(_$EpisodeImpl) then) =
      __$$EpisodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String guid,
      String pguid,
      String title,
      String description,
      String? content,
      String? link,
      String? imageUrl,
      String? thumbImageUrl,
      DateTime? publicationDate,
      String? contentUrl,
      String? author,
      int? season,
      int? episode,
      Duration? duration,
      String? chaptersUrl,
      List<Chapter> chapters,
      List<TranscriptUrl> transcriptUrls,
      List<Person> persons,
      bool metadataOnly});
}

/// @nodoc
class __$$EpisodeImplCopyWithImpl<$Res>
    extends _$EpisodeCopyWithImpl<$Res, _$EpisodeImpl>
    implements _$$EpisodeImplCopyWith<$Res> {
  __$$EpisodeImplCopyWithImpl(
      _$EpisodeImpl _value, $Res Function(_$EpisodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? pguid = null,
    Object? title = null,
    Object? description = null,
    Object? content = freezed,
    Object? link = freezed,
    Object? imageUrl = freezed,
    Object? thumbImageUrl = freezed,
    Object? publicationDate = freezed,
    Object? contentUrl = freezed,
    Object? author = freezed,
    Object? season = freezed,
    Object? episode = freezed,
    Object? duration = freezed,
    Object? chaptersUrl = freezed,
    Object? chapters = null,
    Object? transcriptUrls = null,
    Object? persons = null,
    Object? metadataOnly = null,
  }) {
    return _then(_$EpisodeImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      link: freezed == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbImageUrl: freezed == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      publicationDate: freezed == publicationDate
          ? _value.publicationDate
          : publicationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contentUrl: freezed == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as int?,
      episode: freezed == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      chaptersUrl: freezed == chaptersUrl
          ? _value.chaptersUrl
          : chaptersUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      chapters: null == chapters
          ? _value._chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<Chapter>,
      transcriptUrls: null == transcriptUrls
          ? _value._transcriptUrls
          : transcriptUrls // ignore: cast_nullable_to_non_nullable
              as List<TranscriptUrl>,
      persons: null == persons
          ? _value._persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
      metadataOnly: null == metadataOnly
          ? _value.metadataOnly
          : metadataOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeImpl with DiagnosticableTreeMixin implements _Episode {
  const _$EpisodeImpl(
      {required this.guid,
      required this.pguid,
      required this.title,
      required this.description,
      this.content,
      this.link,
      required this.imageUrl,
      required this.thumbImageUrl,
      this.publicationDate,
      this.contentUrl,
      this.author,
      this.season,
      this.episode,
      required this.duration,
      this.chaptersUrl,
      final List<Chapter> chapters = const [],
      final List<TranscriptUrl> transcriptUrls = const [],
      final List<Person> persons = const [],
      this.metadataOnly = false})
      : _chapters = chapters,
        _transcriptUrls = transcriptUrls,
        _persons = persons;

  factory _$EpisodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeImplFromJson(json);

  /// A String GUID for the episode.
  @override
  final String guid;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  @override
  final String pguid;

  /// The name of the podcast the episode is part of.
  @override
  final String title;

  /// The episode description. This could be plain text or HTML.
  @override
  final String description;

  /// More detailed description - optional.
  @override
  final String? content;

  /// External link
  @override
  final String? link;

  /// URL to the episode artwork image.
  @override
  final String? imageUrl;

  /// URL to a thumbnail version of the episode artwork image.
  @override
  final String? thumbImageUrl;

  /// The date the episode was published (if known).
  @override
  final DateTime? publicationDate;

  /// The URL for the episode location.
  @override
  final String? contentUrl;

  /// Author of the episode if known.
  @override
  final String? author;

  /// The season the episode is part of if available.
  @override
  final int? season;

  /// The episode number within a season if available.
  @override
  final int? episode;

  /// The duration of the episode in milliseconds. This can be populated
  /// either from the RSS if available, or determined from the MP3 file at
  /// stream/download time.
  @override
  final Duration? duration;

  /// URL pointing to a JSON file containing chapter information if available.
  @override
  final String? chaptersUrl;

  /// List of chapters for the episode if available.
  final List<Chapter> _chapters;

  /// List of chapters for the episode if available.
  @override
  @JsonKey()
  List<Chapter> get chapters {
    if (_chapters is EqualUnmodifiableListView) return _chapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chapters);
  }

  /// List of transcript URLs for the episode if available.
  final List<TranscriptUrl> _transcriptUrls;

  /// List of transcript URLs for the episode if available.
  @override
  @JsonKey()
  List<TranscriptUrl> get transcriptUrls {
    if (_transcriptUrls is EqualUnmodifiableListView) return _transcriptUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transcriptUrls);
  }

  /// List of people of interest to the podcast.
  final List<Person> _persons;

  /// List of people of interest to the podcast.
  @override
  @JsonKey()
  List<Person> get persons {
    if (_persons is EqualUnmodifiableListView) return _persons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_persons);
  }

  /// True indicates this episode data contains only [EpisodeMetadata] fields.
  @override
  @JsonKey()
  final bool metadataOnly;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Episode(guid: $guid, pguid: $pguid, title: $title, description: $description, content: $content, link: $link, imageUrl: $imageUrl, thumbImageUrl: $thumbImageUrl, publicationDate: $publicationDate, contentUrl: $contentUrl, author: $author, season: $season, episode: $episode, duration: $duration, chaptersUrl: $chaptersUrl, chapters: $chapters, transcriptUrls: $transcriptUrls, persons: $persons, metadataOnly: $metadataOnly)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Episode'))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('pguid', pguid))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('link', link))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('thumbImageUrl', thumbImageUrl))
      ..add(DiagnosticsProperty('publicationDate', publicationDate))
      ..add(DiagnosticsProperty('contentUrl', contentUrl))
      ..add(DiagnosticsProperty('author', author))
      ..add(DiagnosticsProperty('season', season))
      ..add(DiagnosticsProperty('episode', episode))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('chaptersUrl', chaptersUrl))
      ..add(DiagnosticsProperty('chapters', chapters))
      ..add(DiagnosticsProperty('transcriptUrls', transcriptUrls))
      ..add(DiagnosticsProperty('persons', persons))
      ..add(DiagnosticsProperty('metadataOnly', metadataOnly));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.publicationDate, publicationDate) ||
                other.publicationDate == publicationDate) &&
            (identical(other.contentUrl, contentUrl) ||
                other.contentUrl == contentUrl) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.chaptersUrl, chaptersUrl) ||
                other.chaptersUrl == chaptersUrl) &&
            const DeepCollectionEquality().equals(other._chapters, _chapters) &&
            const DeepCollectionEquality()
                .equals(other._transcriptUrls, _transcriptUrls) &&
            const DeepCollectionEquality().equals(other._persons, _persons) &&
            (identical(other.metadataOnly, metadataOnly) ||
                other.metadataOnly == metadataOnly));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        guid,
        pguid,
        title,
        description,
        content,
        link,
        imageUrl,
        thumbImageUrl,
        publicationDate,
        contentUrl,
        author,
        season,
        episode,
        duration,
        chaptersUrl,
        const DeepCollectionEquality().hash(_chapters),
        const DeepCollectionEquality().hash(_transcriptUrls),
        const DeepCollectionEquality().hash(_persons),
        metadataOnly
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeImplCopyWith<_$EpisodeImpl> get copyWith =>
      __$$EpisodeImplCopyWithImpl<_$EpisodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodeImplToJson(
      this,
    );
  }
}

abstract class _Episode implements Episode {
  const factory _Episode(
      {required final String guid,
      required final String pguid,
      required final String title,
      required final String description,
      final String? content,
      final String? link,
      required final String? imageUrl,
      required final String? thumbImageUrl,
      final DateTime? publicationDate,
      final String? contentUrl,
      final String? author,
      final int? season,
      final int? episode,
      required final Duration? duration,
      final String? chaptersUrl,
      final List<Chapter> chapters,
      final List<TranscriptUrl> transcriptUrls,
      final List<Person> persons,
      final bool metadataOnly}) = _$EpisodeImpl;

  factory _Episode.fromJson(Map<String, dynamic> json) = _$EpisodeImpl.fromJson;

  @override

  /// A String GUID for the episode.
  String get guid;
  @override

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid;
  @override

  /// The name of the podcast the episode is part of.
  String get title;
  @override

  /// The episode description. This could be plain text or HTML.
  String get description;
  @override

  /// More detailed description - optional.
  String? get content;
  @override

  /// External link
  String? get link;
  @override

  /// URL to the episode artwork image.
  String? get imageUrl;
  @override

  /// URL to a thumbnail version of the episode artwork image.
  String? get thumbImageUrl;
  @override

  /// The date the episode was published (if known).
  DateTime? get publicationDate;
  @override

  /// The URL for the episode location.
  String? get contentUrl;
  @override

  /// Author of the episode if known.
  String? get author;
  @override

  /// The season the episode is part of if available.
  int? get season;
  @override

  /// The episode number within a season if available.
  int? get episode;
  @override

  /// The duration of the episode in milliseconds. This can be populated
  /// either from the RSS if available, or determined from the MP3 file at
  /// stream/download time.
  Duration? get duration;
  @override

  /// URL pointing to a JSON file containing chapter information if available.
  String? get chaptersUrl;
  @override

  /// List of chapters for the episode if available.
  List<Chapter> get chapters;
  @override

  /// List of transcript URLs for the episode if available.
  List<TranscriptUrl> get transcriptUrls;
  @override

  /// List of people of interest to the podcast.
  List<Person> get persons;
  @override

  /// True indicates this episode data contains only [EpisodeMetadata] fields.
  bool get metadataOnly;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeImplCopyWith<_$EpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EpisodeStats _$EpisodeStatsFromJson(Map<String, dynamic> json) {
  return _EpisodeStats.fromJson(json);
}

/// @nodoc
mixin _$EpisodeStats {
  /// The GUID for an associated podcast.
  String get pguid => throw _privateConstructorUsedError;

  /// A String GUID for the episode.
  String get guid => throw _privateConstructorUsedError;

  /// Current position in the episode
  Duration get position => throw _privateConstructorUsedError;

  /// Number of times of start playing
  int get playCount => throw _privateConstructorUsedError;

  /// Total playing time
  Duration get playTotal => throw _privateConstructorUsedError;

  /// Number of times of complete playing
  int get completeCount => throw _privateConstructorUsedError;

  /// Whether the episode is in the queue
  bool get inQueue => throw _privateConstructorUsedError;

  /// Downloaded time
  DateTime? get downloadedTime => throw _privateConstructorUsedError;

  /// Latest playing start time
  DateTime? get lastPlayedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EpisodeStatsCopyWith<EpisodeStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeStatsCopyWith<$Res> {
  factory $EpisodeStatsCopyWith(
          EpisodeStats value, $Res Function(EpisodeStats) then) =
      _$EpisodeStatsCopyWithImpl<$Res, EpisodeStats>;
  @useResult
  $Res call(
      {String pguid,
      String guid,
      Duration position,
      int playCount,
      Duration playTotal,
      int completeCount,
      bool inQueue,
      DateTime? downloadedTime,
      DateTime? lastPlayedAt});
}

/// @nodoc
class _$EpisodeStatsCopyWithImpl<$Res, $Val extends EpisodeStats>
    implements $EpisodeStatsCopyWith<$Res> {
  _$EpisodeStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pguid = null,
    Object? guid = null,
    Object? position = null,
    Object? playCount = null,
    Object? playTotal = null,
    Object? completeCount = null,
    Object? inQueue = null,
    Object? downloadedTime = freezed,
    Object? lastPlayedAt = freezed,
  }) {
    return _then(_value.copyWith(
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      playTotal: null == playTotal
          ? _value.playTotal
          : playTotal // ignore: cast_nullable_to_non_nullable
              as Duration,
      completeCount: null == completeCount
          ? _value.completeCount
          : completeCount // ignore: cast_nullable_to_non_nullable
              as int,
      inQueue: null == inQueue
          ? _value.inQueue
          : inQueue // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadedTime: freezed == downloadedTime
          ? _value.downloadedTime
          : downloadedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayedAt: freezed == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodeStatsImplCopyWith<$Res>
    implements $EpisodeStatsCopyWith<$Res> {
  factory _$$EpisodeStatsImplCopyWith(
          _$EpisodeStatsImpl value, $Res Function(_$EpisodeStatsImpl) then) =
      __$$EpisodeStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String pguid,
      String guid,
      Duration position,
      int playCount,
      Duration playTotal,
      int completeCount,
      bool inQueue,
      DateTime? downloadedTime,
      DateTime? lastPlayedAt});
}

/// @nodoc
class __$$EpisodeStatsImplCopyWithImpl<$Res>
    extends _$EpisodeStatsCopyWithImpl<$Res, _$EpisodeStatsImpl>
    implements _$$EpisodeStatsImplCopyWith<$Res> {
  __$$EpisodeStatsImplCopyWithImpl(
      _$EpisodeStatsImpl _value, $Res Function(_$EpisodeStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pguid = null,
    Object? guid = null,
    Object? position = null,
    Object? playCount = null,
    Object? playTotal = null,
    Object? completeCount = null,
    Object? inQueue = null,
    Object? downloadedTime = freezed,
    Object? lastPlayedAt = freezed,
  }) {
    return _then(_$EpisodeStatsImpl(
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      playTotal: null == playTotal
          ? _value.playTotal
          : playTotal // ignore: cast_nullable_to_non_nullable
              as Duration,
      completeCount: null == completeCount
          ? _value.completeCount
          : completeCount // ignore: cast_nullable_to_non_nullable
              as int,
      inQueue: null == inQueue
          ? _value.inQueue
          : inQueue // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadedTime: freezed == downloadedTime
          ? _value.downloadedTime
          : downloadedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayedAt: freezed == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeStatsImpl with DiagnosticableTreeMixin implements _EpisodeStats {
  const _$EpisodeStatsImpl(
      {required this.pguid,
      required this.guid,
      this.position = Duration.zero,
      this.playCount = 0,
      this.playTotal = Duration.zero,
      this.completeCount = 0,
      this.inQueue = false,
      this.downloadedTime,
      this.lastPlayedAt});

  factory _$EpisodeStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeStatsImplFromJson(json);

  /// The GUID for an associated podcast.
  @override
  final String pguid;

  /// A String GUID for the episode.
  @override
  final String guid;

  /// Current position in the episode
  @override
  @JsonKey()
  final Duration position;

  /// Number of times of start playing
  @override
  @JsonKey()
  final int playCount;

  /// Total playing time
  @override
  @JsonKey()
  final Duration playTotal;

  /// Number of times of complete playing
  @override
  @JsonKey()
  final int completeCount;

  /// Whether the episode is in the queue
  @override
  @JsonKey()
  final bool inQueue;

  /// Downloaded time
  @override
  final DateTime? downloadedTime;

  /// Latest playing start time
  @override
  final DateTime? lastPlayedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EpisodeStats(pguid: $pguid, guid: $guid, position: $position, playCount: $playCount, playTotal: $playTotal, completeCount: $completeCount, inQueue: $inQueue, downloadedTime: $downloadedTime, lastPlayedAt: $lastPlayedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EpisodeStats'))
      ..add(DiagnosticsProperty('pguid', pguid))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('playCount', playCount))
      ..add(DiagnosticsProperty('playTotal', playTotal))
      ..add(DiagnosticsProperty('completeCount', completeCount))
      ..add(DiagnosticsProperty('inQueue', inQueue))
      ..add(DiagnosticsProperty('downloadedTime', downloadedTime))
      ..add(DiagnosticsProperty('lastPlayedAt', lastPlayedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeStatsImpl &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.playTotal, playTotal) ||
                other.playTotal == playTotal) &&
            (identical(other.completeCount, completeCount) ||
                other.completeCount == completeCount) &&
            (identical(other.inQueue, inQueue) || other.inQueue == inQueue) &&
            (identical(other.downloadedTime, downloadedTime) ||
                other.downloadedTime == downloadedTime) &&
            (identical(other.lastPlayedAt, lastPlayedAt) ||
                other.lastPlayedAt == lastPlayedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, pguid, guid, position, playCount,
      playTotal, completeCount, inQueue, downloadedTime, lastPlayedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeStatsImplCopyWith<_$EpisodeStatsImpl> get copyWith =>
      __$$EpisodeStatsImplCopyWithImpl<_$EpisodeStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodeStatsImplToJson(
      this,
    );
  }
}

abstract class _EpisodeStats implements EpisodeStats {
  const factory _EpisodeStats(
      {required final String pguid,
      required final String guid,
      final Duration position,
      final int playCount,
      final Duration playTotal,
      final int completeCount,
      final bool inQueue,
      final DateTime? downloadedTime,
      final DateTime? lastPlayedAt}) = _$EpisodeStatsImpl;

  factory _EpisodeStats.fromJson(Map<String, dynamic> json) =
      _$EpisodeStatsImpl.fromJson;

  @override

  /// The GUID for an associated podcast.
  String get pguid;
  @override

  /// A String GUID for the episode.
  String get guid;
  @override

  /// Current position in the episode
  Duration get position;
  @override

  /// Number of times of start playing
  int get playCount;
  @override

  /// Total playing time
  Duration get playTotal;
  @override

  /// Number of times of complete playing
  int get completeCount;
  @override

  /// Whether the episode is in the queue
  bool get inQueue;
  @override

  /// Downloaded time
  DateTime? get downloadedTime;
  @override

  /// Latest playing start time
  DateTime? get lastPlayedAt;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeStatsImplCopyWith<_$EpisodeStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EpisodeMetadata _$EpisodeMetadataFromJson(Map<String, dynamic> json) {
  return _EpisodeMetadata.fromJson(json);
}

/// @nodoc
mixin _$EpisodeMetadata {
  String get guid => throw _privateConstructorUsedError;
  String get pguid => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get thumbImageUrl => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  DateTime? get publicationDate => throw _privateConstructorUsedError;
  String? get contentUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EpisodeMetadataCopyWith<EpisodeMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeMetadataCopyWith<$Res> {
  factory $EpisodeMetadataCopyWith(
          EpisodeMetadata value, $Res Function(EpisodeMetadata) then) =
      _$EpisodeMetadataCopyWithImpl<$Res, EpisodeMetadata>;
  @useResult
  $Res call(
      {String guid,
      String pguid,
      String title,
      String imageUrl,
      String thumbImageUrl,
      Duration duration,
      DateTime? publicationDate,
      String? contentUrl});
}

/// @nodoc
class _$EpisodeMetadataCopyWithImpl<$Res, $Val extends EpisodeMetadata>
    implements $EpisodeMetadataCopyWith<$Res> {
  _$EpisodeMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? pguid = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? thumbImageUrl = null,
    Object? duration = null,
    Object? publicationDate = freezed,
    Object? contentUrl = freezed,
  }) {
    return _then(_value.copyWith(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      publicationDate: freezed == publicationDate
          ? _value.publicationDate
          : publicationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contentUrl: freezed == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodeMetadataImplCopyWith<$Res>
    implements $EpisodeMetadataCopyWith<$Res> {
  factory _$$EpisodeMetadataImplCopyWith(_$EpisodeMetadataImpl value,
          $Res Function(_$EpisodeMetadataImpl) then) =
      __$$EpisodeMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String guid,
      String pguid,
      String title,
      String imageUrl,
      String thumbImageUrl,
      Duration duration,
      DateTime? publicationDate,
      String? contentUrl});
}

/// @nodoc
class __$$EpisodeMetadataImplCopyWithImpl<$Res>
    extends _$EpisodeMetadataCopyWithImpl<$Res, _$EpisodeMetadataImpl>
    implements _$$EpisodeMetadataImplCopyWith<$Res> {
  __$$EpisodeMetadataImplCopyWithImpl(
      _$EpisodeMetadataImpl _value, $Res Function(_$EpisodeMetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? pguid = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? thumbImageUrl = null,
    Object? duration = null,
    Object? publicationDate = freezed,
    Object? contentUrl = freezed,
  }) {
    return _then(_$EpisodeMetadataImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      publicationDate: freezed == publicationDate
          ? _value.publicationDate
          : publicationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contentUrl: freezed == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeMetadataImpl
    with DiagnosticableTreeMixin
    implements _EpisodeMetadata {
  _$EpisodeMetadataImpl(
      {required this.guid,
      required this.pguid,
      required this.title,
      required this.imageUrl,
      required this.thumbImageUrl,
      required this.duration,
      required this.publicationDate,
      required this.contentUrl});

  factory _$EpisodeMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeMetadataImplFromJson(json);

  @override
  final String guid;
  @override
  final String pguid;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final String thumbImageUrl;
  @override
  final Duration duration;
  @override
  final DateTime? publicationDate;
  @override
  final String? contentUrl;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EpisodeMetadata(guid: $guid, pguid: $pguid, title: $title, imageUrl: $imageUrl, thumbImageUrl: $thumbImageUrl, duration: $duration, publicationDate: $publicationDate, contentUrl: $contentUrl)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EpisodeMetadata'))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('pguid', pguid))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('thumbImageUrl', thumbImageUrl))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('publicationDate', publicationDate))
      ..add(DiagnosticsProperty('contentUrl', contentUrl));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeMetadataImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.publicationDate, publicationDate) ||
                other.publicationDate == publicationDate) &&
            (identical(other.contentUrl, contentUrl) ||
                other.contentUrl == contentUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, guid, pguid, title, imageUrl,
      thumbImageUrl, duration, publicationDate, contentUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeMetadataImplCopyWith<_$EpisodeMetadataImpl> get copyWith =>
      __$$EpisodeMetadataImplCopyWithImpl<_$EpisodeMetadataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodeMetadataImplToJson(
      this,
    );
  }
}

abstract class _EpisodeMetadata implements EpisodeMetadata {
  factory _EpisodeMetadata(
      {required final String guid,
      required final String pguid,
      required final String title,
      required final String imageUrl,
      required final String thumbImageUrl,
      required final Duration duration,
      required final DateTime? publicationDate,
      required final String? contentUrl}) = _$EpisodeMetadataImpl;

  factory _EpisodeMetadata.fromJson(Map<String, dynamic> json) =
      _$EpisodeMetadataImpl.fromJson;

  @override
  String get guid;
  @override
  String get pguid;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  String get thumbImageUrl;
  @override
  Duration get duration;
  @override
  DateTime? get publicationDate;
  @override
  String? get contentUrl;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeMetadataImplCopyWith<_$EpisodeMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
