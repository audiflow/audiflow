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
      List<Person> persons});
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
      List<Person> persons});
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
      final List<Person> persons = const []})
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Episode(guid: $guid, pguid: $pguid, title: $title, description: $description, content: $content, link: $link, imageUrl: $imageUrl, thumbImageUrl: $thumbImageUrl, publicationDate: $publicationDate, contentUrl: $contentUrl, author: $author, season: $season, episode: $episode, duration: $duration, chaptersUrl: $chaptersUrl, chapters: $chapters, transcriptUrls: $transcriptUrls, persons: $persons)';
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
      ..add(DiagnosticsProperty('persons', persons));
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
            const DeepCollectionEquality().equals(other._persons, _persons));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
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
      const DeepCollectionEquality().hash(_persons));

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
      final List<Person> persons}) = _$EpisodeImpl;

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
  @JsonKey(ignore: true)
  _$$EpisodeImplCopyWith<_$EpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EpisodeStats _$EpisodeStatsFromJson(Map<String, dynamic> json) {
  return _EpisodeStats.fromJson(json);
}

/// @nodoc
mixin _$EpisodeStats {
  int get id => throw _privateConstructorUsedError;
  String get guid => throw _privateConstructorUsedError;
  Duration get position => throw _privateConstructorUsedError;
  Duration? get duration => throw _privateConstructorUsedError;
  bool get played => throw _privateConstructorUsedError;
  int get playCount => throw _privateConstructorUsedError;
  Duration get playTotal => throw _privateConstructorUsedError;
  bool get inQueue => throw _privateConstructorUsedError;
  bool get downloaded => throw _privateConstructorUsedError;

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
      {int id,
      String guid,
      Duration position,
      Duration? duration,
      bool played,
      int playCount,
      Duration playTotal,
      bool inQueue,
      bool downloaded});
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
    Object? id = null,
    Object? guid = null,
    Object? position = null,
    Object? duration = freezed,
    Object? played = null,
    Object? playCount = null,
    Object? playTotal = null,
    Object? inQueue = null,
    Object? downloaded = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      played: null == played
          ? _value.played
          : played // ignore: cast_nullable_to_non_nullable
              as bool,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      playTotal: null == playTotal
          ? _value.playTotal
          : playTotal // ignore: cast_nullable_to_non_nullable
              as Duration,
      inQueue: null == inQueue
          ? _value.inQueue
          : inQueue // ignore: cast_nullable_to_non_nullable
              as bool,
      downloaded: null == downloaded
          ? _value.downloaded
          : downloaded // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {int id,
      String guid,
      Duration position,
      Duration? duration,
      bool played,
      int playCount,
      Duration playTotal,
      bool inQueue,
      bool downloaded});
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
    Object? id = null,
    Object? guid = null,
    Object? position = null,
    Object? duration = freezed,
    Object? played = null,
    Object? playCount = null,
    Object? playTotal = null,
    Object? inQueue = null,
    Object? downloaded = null,
  }) {
    return _then(_$EpisodeStatsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      played: null == played
          ? _value.played
          : played // ignore: cast_nullable_to_non_nullable
              as bool,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      playTotal: null == playTotal
          ? _value.playTotal
          : playTotal // ignore: cast_nullable_to_non_nullable
              as Duration,
      inQueue: null == inQueue
          ? _value.inQueue
          : inQueue // ignore: cast_nullable_to_non_nullable
              as bool,
      downloaded: null == downloaded
          ? _value.downloaded
          : downloaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeStatsImpl with DiagnosticableTreeMixin implements _EpisodeStats {
  const _$EpisodeStatsImpl(
      {this.id = 0,
      required this.guid,
      this.position = Duration.zero,
      this.duration,
      this.played = false,
      this.playCount = 0,
      this.playTotal = Duration.zero,
      this.inQueue = false,
      this.downloaded = false});

  factory _$EpisodeStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeStatsImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String guid;
  @override
  @JsonKey()
  final Duration position;
  @override
  final Duration? duration;
  @override
  @JsonKey()
  final bool played;
  @override
  @JsonKey()
  final int playCount;
  @override
  @JsonKey()
  final Duration playTotal;
  @override
  @JsonKey()
  final bool inQueue;
  @override
  @JsonKey()
  final bool downloaded;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EpisodeStats(id: $id, guid: $guid, position: $position, duration: $duration, played: $played, playCount: $playCount, playTotal: $playTotal, inQueue: $inQueue, downloaded: $downloaded)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EpisodeStats'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('played', played))
      ..add(DiagnosticsProperty('playCount', playCount))
      ..add(DiagnosticsProperty('playTotal', playTotal))
      ..add(DiagnosticsProperty('inQueue', inQueue))
      ..add(DiagnosticsProperty('downloaded', downloaded));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeStatsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.played, played) || other.played == played) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.playTotal, playTotal) ||
                other.playTotal == playTotal) &&
            (identical(other.inQueue, inQueue) || other.inQueue == inQueue) &&
            (identical(other.downloaded, downloaded) ||
                other.downloaded == downloaded));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, guid, position, duration,
      played, playCount, playTotal, inQueue, downloaded);

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
      {final int id,
      required final String guid,
      final Duration position,
      final Duration? duration,
      final bool played,
      final int playCount,
      final Duration playTotal,
      final bool inQueue,
      final bool downloaded}) = _$EpisodeStatsImpl;

  factory _EpisodeStats.fromJson(Map<String, dynamic> json) =
      _$EpisodeStatsImpl.fromJson;

  @override
  int get id;
  @override
  String get guid;
  @override
  Duration get position;
  @override
  Duration? get duration;
  @override
  bool get played;
  @override
  int get playCount;
  @override
  Duration get playTotal;
  @override
  bool get inQueue;
  @override
  bool get downloaded;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeStatsImplCopyWith<_$EpisodeStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
