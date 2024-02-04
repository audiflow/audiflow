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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Episode _$EpisodeFromJson(Map<String, dynamic> json) {
  return _Episode.fromJson(json);
}

/// @nodoc
mixin _$Episode {
  /// Database ID
  int? get id => throw _privateConstructorUsedError;

  /// A String GUID for the episode.
  String get guid => throw _privateConstructorUsedError;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid => throw _privateConstructorUsedError;

  /// The path to the directory containing the download for this episode;
  /// or null.
  String? get filepath => throw _privateConstructorUsedError;

  /// The filename of the downloaded episode; or null.
  String? get filename => throw _privateConstructorUsedError;

  /// The name of the podcast the episode is part of.
  String get podcast => throw _privateConstructorUsedError;

  /// The name of the podcast the episode is part of.
  String get title => throw _privateConstructorUsedError;

  /// The episode description. This could be plain text or HTML.
  String get description => throw _privateConstructorUsedError;

  /// More detailed description - optional.
  String? get content => throw _privateConstructorUsedError;

  /// External link
  String? get link => throw _privateConstructorUsedError;

  /// URL to the episode artwork image.
  String get imageUrl => throw _privateConstructorUsedError;

  /// URL to a thumbnail version of the episode artwork image.
  String get thumbImageUrl => throw _privateConstructorUsedError;

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
  int get duration => throw _privateConstructorUsedError;

  /// Stores the current position within the episode in milliseconds.
  /// Used for resuming.
  int get position => throw _privateConstructorUsedError;

  /// True if this episode is 'marked as played'.
  bool get played => throw _privateConstructorUsedError;

  /// URL pointing to a JSON file containing chapter information if available.
  String? get chaptersUrl => throw _privateConstructorUsedError;

  /// List of chapters for the episode if available.
  List<Chapter> get chapters => throw _privateConstructorUsedError;

  /// Index of the currently playing chapter it available. Transient.
  int? get chapterIndex => throw _privateConstructorUsedError;

  /// Current chapter we are listening to if this episode has chapters.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  Chapter? get currentChapter => throw _privateConstructorUsedError;

  /// List of transcript URLs for the episode if available.
  List<TranscriptUrl> get transcriptUrls => throw _privateConstructorUsedError;
  List<Person> get persons => throw _privateConstructorUsedError;

  /// Currently downloaded or in use transcript for the episode.To minimise
  /// memory
  /// use, this is cleared when an episode download is deleted, or a streamed
  /// episode stopped.
  Transcript? get transcript => throw _privateConstructorUsedError;

  /// Link to a currently stored transcript for this episode.
  int? get transcriptId => throw _privateConstructorUsedError;

  /// Date and time episode was last updated and persisted.
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Processed version of episode description.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get parsedDescriptionText => throw _privateConstructorUsedError;

  /// If the episode is currently being downloaded, this contains the unique
  /// ID supplied by the download manager for the episode.
  String? get downloadTaskId => throw _privateConstructorUsedError;

  /// The current downloading state of the episode.
  DownloadState get downloadState => throw _privateConstructorUsedError;

  /// Stores the progress of the current download progress if available.
  int get downloadPercentage =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get chaptersLoading =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get highlight =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get queued =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get streaming => throw _privateConstructorUsedError;

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
      {int? id,
      String guid,
      String pguid,
      String? filepath,
      String? filename,
      String podcast,
      String title,
      String description,
      String? content,
      String? link,
      String imageUrl,
      String thumbImageUrl,
      DateTime? publicationDate,
      String? contentUrl,
      String? author,
      int? season,
      int? episode,
      int duration,
      int position,
      bool played,
      String? chaptersUrl,
      List<Chapter> chapters,
      int? chapterIndex,
      @JsonKey(includeToJson: false, includeFromJson: false)
      Chapter? currentChapter,
      List<TranscriptUrl> transcriptUrls,
      List<Person> persons,
      Transcript? transcript,
      int? transcriptId,
      DateTime? lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false)
      String? parsedDescriptionText,
      String? downloadTaskId,
      DownloadState downloadState,
      int downloadPercentage,
      @JsonKey(includeToJson: false, includeFromJson: false)
      bool chaptersLoading,
      @JsonKey(includeToJson: false, includeFromJson: false) bool highlight,
      @JsonKey(includeToJson: false, includeFromJson: false) bool queued,
      @JsonKey(includeToJson: false, includeFromJson: false) bool streaming});

  $ChapterCopyWith<$Res>? get currentChapter;
  $TranscriptCopyWith<$Res>? get transcript;
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
    Object? id = freezed,
    Object? guid = null,
    Object? pguid = null,
    Object? filepath = freezed,
    Object? filename = freezed,
    Object? podcast = null,
    Object? title = null,
    Object? description = null,
    Object? content = freezed,
    Object? link = freezed,
    Object? imageUrl = null,
    Object? thumbImageUrl = null,
    Object? publicationDate = freezed,
    Object? contentUrl = freezed,
    Object? author = freezed,
    Object? season = freezed,
    Object? episode = freezed,
    Object? duration = null,
    Object? position = null,
    Object? played = null,
    Object? chaptersUrl = freezed,
    Object? chapters = null,
    Object? chapterIndex = freezed,
    Object? currentChapter = freezed,
    Object? transcriptUrls = null,
    Object? persons = null,
    Object? transcript = freezed,
    Object? transcriptId = freezed,
    Object? lastUpdated = freezed,
    Object? parsedDescriptionText = freezed,
    Object? downloadTaskId = freezed,
    Object? downloadState = null,
    Object? downloadPercentage = null,
    Object? chaptersLoading = null,
    Object? highlight = null,
    Object? queued = null,
    Object? streaming = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      filepath: freezed == filepath
          ? _value.filepath
          : filepath // ignore: cast_nullable_to_non_nullable
              as String?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
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
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      played: null == played
          ? _value.played
          : played // ignore: cast_nullable_to_non_nullable
              as bool,
      chaptersUrl: freezed == chaptersUrl
          ? _value.chaptersUrl
          : chaptersUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      chapters: null == chapters
          ? _value.chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<Chapter>,
      chapterIndex: freezed == chapterIndex
          ? _value.chapterIndex
          : chapterIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      currentChapter: freezed == currentChapter
          ? _value.currentChapter
          : currentChapter // ignore: cast_nullable_to_non_nullable
              as Chapter?,
      transcriptUrls: null == transcriptUrls
          ? _value.transcriptUrls
          : transcriptUrls // ignore: cast_nullable_to_non_nullable
              as List<TranscriptUrl>,
      persons: null == persons
          ? _value.persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
      transcript: freezed == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as Transcript?,
      transcriptId: freezed == transcriptId
          ? _value.transcriptId
          : transcriptId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      parsedDescriptionText: freezed == parsedDescriptionText
          ? _value.parsedDescriptionText
          : parsedDescriptionText // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadTaskId: freezed == downloadTaskId
          ? _value.downloadTaskId
          : downloadTaskId // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadState: null == downloadState
          ? _value.downloadState
          : downloadState // ignore: cast_nullable_to_non_nullable
              as DownloadState,
      downloadPercentage: null == downloadPercentage
          ? _value.downloadPercentage
          : downloadPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      chaptersLoading: null == chaptersLoading
          ? _value.chaptersLoading
          : chaptersLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      highlight: null == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as bool,
      queued: null == queued
          ? _value.queued
          : queued // ignore: cast_nullable_to_non_nullable
              as bool,
      streaming: null == streaming
          ? _value.streaming
          : streaming // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ChapterCopyWith<$Res>? get currentChapter {
    if (_value.currentChapter == null) {
      return null;
    }

    return $ChapterCopyWith<$Res>(_value.currentChapter!, (value) {
      return _then(_value.copyWith(currentChapter: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TranscriptCopyWith<$Res>? get transcript {
    if (_value.transcript == null) {
      return null;
    }

    return $TranscriptCopyWith<$Res>(_value.transcript!, (value) {
      return _then(_value.copyWith(transcript: value) as $Val);
    });
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
      {int? id,
      String guid,
      String pguid,
      String? filepath,
      String? filename,
      String podcast,
      String title,
      String description,
      String? content,
      String? link,
      String imageUrl,
      String thumbImageUrl,
      DateTime? publicationDate,
      String? contentUrl,
      String? author,
      int? season,
      int? episode,
      int duration,
      int position,
      bool played,
      String? chaptersUrl,
      List<Chapter> chapters,
      int? chapterIndex,
      @JsonKey(includeToJson: false, includeFromJson: false)
      Chapter? currentChapter,
      List<TranscriptUrl> transcriptUrls,
      List<Person> persons,
      Transcript? transcript,
      int? transcriptId,
      DateTime? lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false)
      String? parsedDescriptionText,
      String? downloadTaskId,
      DownloadState downloadState,
      int downloadPercentage,
      @JsonKey(includeToJson: false, includeFromJson: false)
      bool chaptersLoading,
      @JsonKey(includeToJson: false, includeFromJson: false) bool highlight,
      @JsonKey(includeToJson: false, includeFromJson: false) bool queued,
      @JsonKey(includeToJson: false, includeFromJson: false) bool streaming});

  @override
  $ChapterCopyWith<$Res>? get currentChapter;
  @override
  $TranscriptCopyWith<$Res>? get transcript;
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
    Object? id = freezed,
    Object? guid = null,
    Object? pguid = null,
    Object? filepath = freezed,
    Object? filename = freezed,
    Object? podcast = null,
    Object? title = null,
    Object? description = null,
    Object? content = freezed,
    Object? link = freezed,
    Object? imageUrl = null,
    Object? thumbImageUrl = null,
    Object? publicationDate = freezed,
    Object? contentUrl = freezed,
    Object? author = freezed,
    Object? season = freezed,
    Object? episode = freezed,
    Object? duration = null,
    Object? position = null,
    Object? played = null,
    Object? chaptersUrl = freezed,
    Object? chapters = null,
    Object? chapterIndex = freezed,
    Object? currentChapter = freezed,
    Object? transcriptUrls = null,
    Object? persons = null,
    Object? transcript = freezed,
    Object? transcriptId = freezed,
    Object? lastUpdated = freezed,
    Object? parsedDescriptionText = freezed,
    Object? downloadTaskId = freezed,
    Object? downloadState = null,
    Object? downloadPercentage = null,
    Object? chaptersLoading = null,
    Object? highlight = null,
    Object? queued = null,
    Object? streaming = null,
  }) {
    return _then(_$EpisodeImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      filepath: freezed == filepath
          ? _value.filepath
          : filepath // ignore: cast_nullable_to_non_nullable
              as String?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
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
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      played: null == played
          ? _value.played
          : played // ignore: cast_nullable_to_non_nullable
              as bool,
      chaptersUrl: freezed == chaptersUrl
          ? _value.chaptersUrl
          : chaptersUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      chapters: null == chapters
          ? _value._chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<Chapter>,
      chapterIndex: freezed == chapterIndex
          ? _value.chapterIndex
          : chapterIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      currentChapter: freezed == currentChapter
          ? _value.currentChapter
          : currentChapter // ignore: cast_nullable_to_non_nullable
              as Chapter?,
      transcriptUrls: null == transcriptUrls
          ? _value._transcriptUrls
          : transcriptUrls // ignore: cast_nullable_to_non_nullable
              as List<TranscriptUrl>,
      persons: null == persons
          ? _value._persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
      transcript: freezed == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as Transcript?,
      transcriptId: freezed == transcriptId
          ? _value.transcriptId
          : transcriptId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      parsedDescriptionText: freezed == parsedDescriptionText
          ? _value.parsedDescriptionText
          : parsedDescriptionText // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadTaskId: freezed == downloadTaskId
          ? _value.downloadTaskId
          : downloadTaskId // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadState: null == downloadState
          ? _value.downloadState
          : downloadState // ignore: cast_nullable_to_non_nullable
              as DownloadState,
      downloadPercentage: null == downloadPercentage
          ? _value.downloadPercentage
          : downloadPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      chaptersLoading: null == chaptersLoading
          ? _value.chaptersLoading
          : chaptersLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      highlight: null == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as bool,
      queued: null == queued
          ? _value.queued
          : queued // ignore: cast_nullable_to_non_nullable
              as bool,
      streaming: null == streaming
          ? _value.streaming
          : streaming // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeImpl with DiagnosticableTreeMixin implements _Episode {
  const _$EpisodeImpl(
      {this.id,
      required this.guid,
      required this.pguid,
      this.filepath,
      this.filename,
      required this.podcast,
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
      this.duration = 0,
      this.position = 0,
      this.played = false,
      this.chaptersUrl,
      final List<Chapter> chapters = const [],
      this.chapterIndex,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.currentChapter,
      final List<TranscriptUrl> transcriptUrls = const [],
      final List<Person> persons = const [],
      this.transcript,
      this.transcriptId,
      this.lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.parsedDescriptionText,
      this.downloadTaskId,
      this.downloadState = DownloadState.none,
      this.downloadPercentage = 0,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.chaptersLoading = false,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.highlight = false,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.queued = false,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.streaming = false})
      : _chapters = chapters,
        _transcriptUrls = transcriptUrls,
        _persons = persons;

  factory _$EpisodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeImplFromJson(json);

  /// Database ID
  @override
  final int? id;

  /// A String GUID for the episode.
  @override
  final String guid;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  @override
  final String pguid;

  /// The path to the directory containing the download for this episode;
  /// or null.
  @override
  final String? filepath;

  /// The filename of the downloaded episode; or null.
  @override
  final String? filename;

  /// The name of the podcast the episode is part of.
  @override
  final String podcast;

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
  final String imageUrl;

  /// URL to a thumbnail version of the episode artwork image.
  @override
  final String thumbImageUrl;

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
  @JsonKey()
  final int duration;

  /// Stores the current position within the episode in milliseconds.
  /// Used for resuming.
  @override
  @JsonKey()
  final int position;

  /// True if this episode is 'marked as played'.
  @override
  @JsonKey()
  final bool played;

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

  /// Index of the currently playing chapter it available. Transient.
  @override
  final int? chapterIndex;

  /// Current chapter we are listening to if this episode has chapters.
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final Chapter? currentChapter;

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

  final List<Person> _persons;
  @override
  @JsonKey()
  List<Person> get persons {
    if (_persons is EqualUnmodifiableListView) return _persons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_persons);
  }

  /// Currently downloaded or in use transcript for the episode.To minimise
  /// memory
  /// use, this is cleared when an episode download is deleted, or a streamed
  /// episode stopped.
  @override
  final Transcript? transcript;

  /// Link to a currently stored transcript for this episode.
  @override
  final int? transcriptId;

  /// Date and time episode was last updated and persisted.
  @override
  final DateTime? lastUpdated;

  /// Processed version of episode description.
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? parsedDescriptionText;

  /// If the episode is currently being downloaded, this contains the unique
  /// ID supplied by the download manager for the episode.
  @override
  final String? downloadTaskId;

  /// The current downloading state of the episode.
  @override
  @JsonKey()
  final DownloadState downloadState;

  /// Stores the progress of the current download progress if available.
  @override
  @JsonKey()
  final int downloadPercentage;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool chaptersLoading;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool highlight;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool queued;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool streaming;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Episode(id: $id, guid: $guid, pguid: $pguid, filepath: $filepath, filename: $filename, podcast: $podcast, title: $title, description: $description, content: $content, link: $link, imageUrl: $imageUrl, thumbImageUrl: $thumbImageUrl, publicationDate: $publicationDate, contentUrl: $contentUrl, author: $author, season: $season, episode: $episode, duration: $duration, position: $position, played: $played, chaptersUrl: $chaptersUrl, chapters: $chapters, chapterIndex: $chapterIndex, currentChapter: $currentChapter, transcriptUrls: $transcriptUrls, persons: $persons, transcript: $transcript, transcriptId: $transcriptId, lastUpdated: $lastUpdated, parsedDescriptionText: $parsedDescriptionText, downloadTaskId: $downloadTaskId, downloadState: $downloadState, downloadPercentage: $downloadPercentage, chaptersLoading: $chaptersLoading, highlight: $highlight, queued: $queued, streaming: $streaming)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Episode'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('pguid', pguid))
      ..add(DiagnosticsProperty('filepath', filepath))
      ..add(DiagnosticsProperty('filename', filename))
      ..add(DiagnosticsProperty('podcast', podcast))
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
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('played', played))
      ..add(DiagnosticsProperty('chaptersUrl', chaptersUrl))
      ..add(DiagnosticsProperty('chapters', chapters))
      ..add(DiagnosticsProperty('chapterIndex', chapterIndex))
      ..add(DiagnosticsProperty('currentChapter', currentChapter))
      ..add(DiagnosticsProperty('transcriptUrls', transcriptUrls))
      ..add(DiagnosticsProperty('persons', persons))
      ..add(DiagnosticsProperty('transcript', transcript))
      ..add(DiagnosticsProperty('transcriptId', transcriptId))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated))
      ..add(DiagnosticsProperty('parsedDescriptionText', parsedDescriptionText))
      ..add(DiagnosticsProperty('downloadTaskId', downloadTaskId))
      ..add(DiagnosticsProperty('downloadState', downloadState))
      ..add(DiagnosticsProperty('downloadPercentage', downloadPercentage))
      ..add(DiagnosticsProperty('chaptersLoading', chaptersLoading))
      ..add(DiagnosticsProperty('highlight', highlight))
      ..add(DiagnosticsProperty('queued', queued))
      ..add(DiagnosticsProperty('streaming', streaming));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.filepath, filepath) ||
                other.filepath == filepath) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.podcast, podcast) || other.podcast == podcast) &&
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
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.played, played) || other.played == played) &&
            (identical(other.chaptersUrl, chaptersUrl) ||
                other.chaptersUrl == chaptersUrl) &&
            const DeepCollectionEquality().equals(other._chapters, _chapters) &&
            (identical(other.chapterIndex, chapterIndex) ||
                other.chapterIndex == chapterIndex) &&
            (identical(other.currentChapter, currentChapter) ||
                other.currentChapter == currentChapter) &&
            const DeepCollectionEquality()
                .equals(other._transcriptUrls, _transcriptUrls) &&
            const DeepCollectionEquality().equals(other._persons, _persons) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.transcriptId, transcriptId) ||
                other.transcriptId == transcriptId) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.parsedDescriptionText, parsedDescriptionText) ||
                other.parsedDescriptionText == parsedDescriptionText) &&
            (identical(other.downloadTaskId, downloadTaskId) ||
                other.downloadTaskId == downloadTaskId) &&
            (identical(other.downloadState, downloadState) ||
                other.downloadState == downloadState) &&
            (identical(other.downloadPercentage, downloadPercentage) ||
                other.downloadPercentage == downloadPercentage) &&
            (identical(other.chaptersLoading, chaptersLoading) ||
                other.chaptersLoading == chaptersLoading) &&
            (identical(other.highlight, highlight) ||
                other.highlight == highlight) &&
            (identical(other.queued, queued) || other.queued == queued) &&
            (identical(other.streaming, streaming) ||
                other.streaming == streaming));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        guid,
        pguid,
        filepath,
        filename,
        podcast,
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
        position,
        played,
        chaptersUrl,
        const DeepCollectionEquality().hash(_chapters),
        chapterIndex,
        currentChapter,
        const DeepCollectionEquality().hash(_transcriptUrls),
        const DeepCollectionEquality().hash(_persons),
        transcript,
        transcriptId,
        lastUpdated,
        parsedDescriptionText,
        downloadTaskId,
        downloadState,
        downloadPercentage,
        chaptersLoading,
        highlight,
        queued,
        streaming
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
      {final int? id,
      required final String guid,
      required final String pguid,
      final String? filepath,
      final String? filename,
      required final String podcast,
      required final String title,
      required final String description,
      final String? content,
      final String? link,
      required final String imageUrl,
      required final String thumbImageUrl,
      final DateTime? publicationDate,
      final String? contentUrl,
      final String? author,
      final int? season,
      final int? episode,
      final int duration,
      final int position,
      final bool played,
      final String? chaptersUrl,
      final List<Chapter> chapters,
      final int? chapterIndex,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final Chapter? currentChapter,
      final List<TranscriptUrl> transcriptUrls,
      final List<Person> persons,
      final Transcript? transcript,
      final int? transcriptId,
      final DateTime? lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final String? parsedDescriptionText,
      final String? downloadTaskId,
      final DownloadState downloadState,
      final int downloadPercentage,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool chaptersLoading,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool highlight,
      @JsonKey(includeToJson: false, includeFromJson: false) final bool queued,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool streaming}) = _$EpisodeImpl;

  factory _Episode.fromJson(Map<String, dynamic> json) = _$EpisodeImpl.fromJson;

  @override

  /// Database ID
  int? get id;
  @override

  /// A String GUID for the episode.
  String get guid;
  @override

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid;
  @override

  /// The path to the directory containing the download for this episode;
  /// or null.
  String? get filepath;
  @override

  /// The filename of the downloaded episode; or null.
  String? get filename;
  @override

  /// The name of the podcast the episode is part of.
  String get podcast;
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
  String get imageUrl;
  @override

  /// URL to a thumbnail version of the episode artwork image.
  String get thumbImageUrl;
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
  int get duration;
  @override

  /// Stores the current position within the episode in milliseconds.
  /// Used for resuming.
  int get position;
  @override

  /// True if this episode is 'marked as played'.
  bool get played;
  @override

  /// URL pointing to a JSON file containing chapter information if available.
  String? get chaptersUrl;
  @override

  /// List of chapters for the episode if available.
  List<Chapter> get chapters;
  @override

  /// Index of the currently playing chapter it available. Transient.
  int? get chapterIndex;
  @override

  /// Current chapter we are listening to if this episode has chapters.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  Chapter? get currentChapter;
  @override

  /// List of transcript URLs for the episode if available.
  List<TranscriptUrl> get transcriptUrls;
  @override
  List<Person> get persons;
  @override

  /// Currently downloaded or in use transcript for the episode.To minimise
  /// memory
  /// use, this is cleared when an episode download is deleted, or a streamed
  /// episode stopped.
  Transcript? get transcript;
  @override

  /// Link to a currently stored transcript for this episode.
  int? get transcriptId;
  @override

  /// Date and time episode was last updated and persisted.
  DateTime? get lastUpdated;
  @override

  /// Processed version of episode description.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get parsedDescriptionText;
  @override

  /// If the episode is currently being downloaded, this contains the unique
  /// ID supplied by the download manager for the episode.
  String? get downloadTaskId;
  @override

  /// The current downloading state of the episode.
  DownloadState get downloadState;
  @override

  /// Stores the progress of the current download progress if available.
  int get downloadPercentage;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get chaptersLoading;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get highlight;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get queued;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get streaming;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeImplCopyWith<_$EpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
