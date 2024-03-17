// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PodcastMetadata _$PodcastMetadataFromJson(Map<String, dynamic> json) {
  return _PodcastMetadata.fromJson(json);
}

/// @nodoc
mixin _$PodcastMetadata {
  /// Unique identifier for podcast.
  String get guid => throw _privateConstructorUsedError;

  /// The collection ID(iTunesID).
  int get collectionId => throw _privateConstructorUsedError;

  /// The link to the podcast RSS feed.
  String? get feedUrl => throw _privateConstructorUsedError;

  /// Podcast title.
  String get title => throw _privateConstructorUsedError;

  /// URL for thumbnail version of artwork image.
  String get thumbImageUrl => throw _privateConstructorUsedError;

  /// URL to the full size artwork image.
  String get imageUrl => throw _privateConstructorUsedError;

  /// Copyright owner of the podcast.
  String get copyright => throw _privateConstructorUsedError;

  /// Release date of the latest episode.
  DateTime get releaseDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastMetadataCopyWith<PodcastMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastMetadataCopyWith<$Res> {
  factory $PodcastMetadataCopyWith(
          PodcastMetadata value, $Res Function(PodcastMetadata) then) =
      _$PodcastMetadataCopyWithImpl<$Res, PodcastMetadata>;
  @useResult
  $Res call(
      {String guid,
      int collectionId,
      String? feedUrl,
      String title,
      String thumbImageUrl,
      String imageUrl,
      String copyright,
      DateTime releaseDate});
}

/// @nodoc
class _$PodcastMetadataCopyWithImpl<$Res, $Val extends PodcastMetadata>
    implements $PodcastMetadataCopyWith<$Res> {
  _$PodcastMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? collectionId = null,
    Object? feedUrl = freezed,
    Object? title = null,
    Object? thumbImageUrl = null,
    Object? imageUrl = null,
    Object? copyright = null,
    Object? releaseDate = null,
  }) {
    return _then(_value.copyWith(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int,
      feedUrl: freezed == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastMetadataImplCopyWith<$Res>
    implements $PodcastMetadataCopyWith<$Res> {
  factory _$$PodcastMetadataImplCopyWith(_$PodcastMetadataImpl value,
          $Res Function(_$PodcastMetadataImpl) then) =
      __$$PodcastMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String guid,
      int collectionId,
      String? feedUrl,
      String title,
      String thumbImageUrl,
      String imageUrl,
      String copyright,
      DateTime releaseDate});
}

/// @nodoc
class __$$PodcastMetadataImplCopyWithImpl<$Res>
    extends _$PodcastMetadataCopyWithImpl<$Res, _$PodcastMetadataImpl>
    implements _$$PodcastMetadataImplCopyWith<$Res> {
  __$$PodcastMetadataImplCopyWithImpl(
      _$PodcastMetadataImpl _value, $Res Function(_$PodcastMetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? collectionId = null,
    Object? feedUrl = freezed,
    Object? title = null,
    Object? thumbImageUrl = null,
    Object? imageUrl = null,
    Object? copyright = null,
    Object? releaseDate = null,
  }) {
    return _then(_$PodcastMetadataImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int,
      feedUrl: freezed == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastMetadataImpl implements _PodcastMetadata {
  const _$PodcastMetadataImpl(
      {required this.guid,
      required this.collectionId,
      required this.feedUrl,
      required this.title,
      required this.thumbImageUrl,
      required this.imageUrl,
      required this.copyright,
      required this.releaseDate});

  factory _$PodcastMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastMetadataImplFromJson(json);

  /// Unique identifier for podcast.
  @override
  final String guid;

  /// The collection ID(iTunesID).
  @override
  final int collectionId;

  /// The link to the podcast RSS feed.
  @override
  final String? feedUrl;

  /// Podcast title.
  @override
  final String title;

  /// URL for thumbnail version of artwork image.
  @override
  final String thumbImageUrl;

  /// URL to the full size artwork image.
  @override
  final String imageUrl;

  /// Copyright owner of the podcast.
  @override
  final String copyright;

  /// Release date of the latest episode.
  @override
  final DateTime releaseDate;

  @override
  String toString() {
    return 'PodcastMetadata(guid: $guid, collectionId: $collectionId, feedUrl: $feedUrl, title: $title, thumbImageUrl: $thumbImageUrl, imageUrl: $imageUrl, copyright: $copyright, releaseDate: $releaseDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastMetadataImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.copyright, copyright) ||
                other.copyright == copyright) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, guid, collectionId, feedUrl,
      title, thumbImageUrl, imageUrl, copyright, releaseDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastMetadataImplCopyWith<_$PodcastMetadataImpl> get copyWith =>
      __$$PodcastMetadataImplCopyWithImpl<_$PodcastMetadataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastMetadataImplToJson(
      this,
    );
  }
}

abstract class _PodcastMetadata implements PodcastMetadata {
  const factory _PodcastMetadata(
      {required final String guid,
      required final int collectionId,
      required final String? feedUrl,
      required final String title,
      required final String thumbImageUrl,
      required final String imageUrl,
      required final String copyright,
      required final DateTime releaseDate}) = _$PodcastMetadataImpl;

  factory _PodcastMetadata.fromJson(Map<String, dynamic> json) =
      _$PodcastMetadataImpl.fromJson;

  @override

  /// Unique identifier for podcast.
  String get guid;
  @override

  /// The collection ID(iTunesID).
  int get collectionId;
  @override

  /// The link to the podcast RSS feed.
  String? get feedUrl;
  @override

  /// Podcast title.
  String get title;
  @override

  /// URL for thumbnail version of artwork image.
  String get thumbImageUrl;
  @override

  /// URL to the full size artwork image.
  String get imageUrl;
  @override

  /// Copyright owner of the podcast.
  String get copyright;
  @override

  /// Release date of the latest episode.
  DateTime get releaseDate;
  @override
  @JsonKey(ignore: true)
  _$$PodcastMetadataImplCopyWith<_$PodcastMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Podcast _$PodcastFromJson(Map<String, dynamic> json) {
  return _Podcast.fromJson(json);
}

/// @nodoc
mixin _$Podcast {
  /// Unique identifier for podcast.
  String get guid => throw _privateConstructorUsedError;

  /// The collection ID(iTunesID).
  int get collectionId => throw _privateConstructorUsedError;

  /// The link to the podcast RSS feed.
  String? get feedUrl => throw _privateConstructorUsedError;

  /// RSS link URL.
  String get linkUrl => throw _privateConstructorUsedError;

  /// Podcast title.
  String get title => throw _privateConstructorUsedError;

  /// Podcast description. Can be either plain text or HTML.
  String get description => throw _privateConstructorUsedError;

  /// Copyright owner of the podcast.
  String get copyright => throw _privateConstructorUsedError;

  /// URL for thumbnail version of artwork image. Not contained within
  /// the RSS but may be calculated or provided within search results.
  String get thumbImageUrl => throw _privateConstructorUsedError;

  /// URL to the full size artwork image.
  String get imageUrl => throw _privateConstructorUsedError;

  /// Release date of the latest episode.
  DateTime get releaseDate => throw _privateConstructorUsedError;

  /// List of episodes.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes => throw _privateConstructorUsedError;

  /// List of  funding links.
  List<Funding> get funding => throw _privateConstructorUsedError;

  /// List of people of interest to the podcast.
  List<Person> get persons => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastCopyWith<Podcast> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastCopyWith<$Res> {
  factory $PodcastCopyWith(Podcast value, $Res Function(Podcast) then) =
      _$PodcastCopyWithImpl<$Res, Podcast>;
  @useResult
  $Res call(
      {String guid,
      int collectionId,
      String? feedUrl,
      String linkUrl,
      String title,
      String description,
      String copyright,
      String thumbImageUrl,
      String imageUrl,
      DateTime releaseDate,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Episode> episodes,
      List<Funding> funding,
      List<Person> persons});
}

/// @nodoc
class _$PodcastCopyWithImpl<$Res, $Val extends Podcast>
    implements $PodcastCopyWith<$Res> {
  _$PodcastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? collectionId = null,
    Object? feedUrl = freezed,
    Object? linkUrl = null,
    Object? title = null,
    Object? description = null,
    Object? copyright = null,
    Object? thumbImageUrl = null,
    Object? imageUrl = null,
    Object? releaseDate = null,
    Object? episodes = null,
    Object? funding = null,
    Object? persons = null,
  }) {
    return _then(_value.copyWith(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int,
      feedUrl: freezed == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      linkUrl: null == linkUrl
          ? _value.linkUrl
          : linkUrl // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      funding: null == funding
          ? _value.funding
          : funding // ignore: cast_nullable_to_non_nullable
              as List<Funding>,
      persons: null == persons
          ? _value.persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastImplCopyWith<$Res> implements $PodcastCopyWith<$Res> {
  factory _$$PodcastImplCopyWith(
          _$PodcastImpl value, $Res Function(_$PodcastImpl) then) =
      __$$PodcastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String guid,
      int collectionId,
      String? feedUrl,
      String linkUrl,
      String title,
      String description,
      String copyright,
      String thumbImageUrl,
      String imageUrl,
      DateTime releaseDate,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Episode> episodes,
      List<Funding> funding,
      List<Person> persons});
}

/// @nodoc
class __$$PodcastImplCopyWithImpl<$Res>
    extends _$PodcastCopyWithImpl<$Res, _$PodcastImpl>
    implements _$$PodcastImplCopyWith<$Res> {
  __$$PodcastImplCopyWithImpl(
      _$PodcastImpl _value, $Res Function(_$PodcastImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? collectionId = null,
    Object? feedUrl = freezed,
    Object? linkUrl = null,
    Object? title = null,
    Object? description = null,
    Object? copyright = null,
    Object? thumbImageUrl = null,
    Object? imageUrl = null,
    Object? releaseDate = null,
    Object? episodes = null,
    Object? funding = null,
    Object? persons = null,
  }) {
    return _then(_$PodcastImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int,
      feedUrl: freezed == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      linkUrl: null == linkUrl
          ? _value.linkUrl
          : linkUrl // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      funding: null == funding
          ? _value._funding
          : funding // ignore: cast_nullable_to_non_nullable
              as List<Funding>,
      persons: null == persons
          ? _value._persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastImpl implements _Podcast {
  const _$PodcastImpl(
      {required this.guid,
      required this.collectionId,
      required this.feedUrl,
      required this.linkUrl,
      required this.title,
      required this.description,
      required this.copyright,
      required this.thumbImageUrl,
      required this.imageUrl,
      required this.releaseDate,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Episode> episodes = const [],
      final List<Funding> funding = const [],
      final List<Person> persons = const []})
      : _episodes = episodes,
        _funding = funding,
        _persons = persons;

  factory _$PodcastImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastImplFromJson(json);

  /// Unique identifier for podcast.
  @override
  final String guid;

  /// The collection ID(iTunesID).
  @override
  final int collectionId;

  /// The link to the podcast RSS feed.
  @override
  final String? feedUrl;

  /// RSS link URL.
  @override
  final String linkUrl;

  /// Podcast title.
  @override
  final String title;

  /// Podcast description. Can be either plain text or HTML.
  @override
  final String description;

  /// Copyright owner of the podcast.
  @override
  final String copyright;

  /// URL for thumbnail version of artwork image. Not contained within
  /// the RSS but may be calculated or provided within search results.
  @override
  final String thumbImageUrl;

  /// URL to the full size artwork image.
  @override
  final String imageUrl;

  /// Release date of the latest episode.
  @override
  final DateTime releaseDate;

  /// List of episodes.
// ignore: invalid_annotation_target
  final List<Episode> _episodes;

  /// List of episodes.
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  /// List of  funding links.
  final List<Funding> _funding;

  /// List of  funding links.
  @override
  @JsonKey()
  List<Funding> get funding {
    if (_funding is EqualUnmodifiableListView) return _funding;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_funding);
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
  String toString() {
    return 'Podcast(guid: $guid, collectionId: $collectionId, feedUrl: $feedUrl, linkUrl: $linkUrl, title: $title, description: $description, copyright: $copyright, thumbImageUrl: $thumbImageUrl, imageUrl: $imageUrl, releaseDate: $releaseDate, episodes: $episodes, funding: $funding, persons: $persons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.copyright, copyright) ||
                other.copyright == copyright) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            const DeepCollectionEquality().equals(other._funding, _funding) &&
            const DeepCollectionEquality().equals(other._persons, _persons));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      guid,
      collectionId,
      feedUrl,
      linkUrl,
      title,
      description,
      copyright,
      thumbImageUrl,
      imageUrl,
      releaseDate,
      const DeepCollectionEquality().hash(_episodes),
      const DeepCollectionEquality().hash(_funding),
      const DeepCollectionEquality().hash(_persons));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastImplCopyWith<_$PodcastImpl> get copyWith =>
      __$$PodcastImplCopyWithImpl<_$PodcastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastImplToJson(
      this,
    );
  }
}

abstract class _Podcast implements Podcast {
  const factory _Podcast(
      {required final String guid,
      required final int collectionId,
      required final String? feedUrl,
      required final String linkUrl,
      required final String title,
      required final String description,
      required final String copyright,
      required final String thumbImageUrl,
      required final String imageUrl,
      required final DateTime releaseDate,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Episode> episodes,
      final List<Funding> funding,
      final List<Person> persons}) = _$PodcastImpl;

  factory _Podcast.fromJson(Map<String, dynamic> json) = _$PodcastImpl.fromJson;

  @override

  /// Unique identifier for podcast.
  String get guid;
  @override

  /// The collection ID(iTunesID).
  int get collectionId;
  @override

  /// The link to the podcast RSS feed.
  String? get feedUrl;
  @override

  /// RSS link URL.
  String get linkUrl;
  @override

  /// Podcast title.
  String get title;
  @override

  /// Podcast description. Can be either plain text or HTML.
  String get description;
  @override

  /// Copyright owner of the podcast.
  String get copyright;
  @override

  /// URL for thumbnail version of artwork image. Not contained within
  /// the RSS but may be calculated or provided within search results.
  String get thumbImageUrl;
  @override

  /// URL to the full size artwork image.
  String get imageUrl;
  @override

  /// Release date of the latest episode.
  DateTime get releaseDate;
  @override

  /// List of episodes.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes;
  @override

  /// List of  funding links.
  List<Funding> get funding;
  @override

  /// List of people of interest to the podcast.
  List<Person> get persons;
  @override
  @JsonKey(ignore: true)
  _$$PodcastImplCopyWith<_$PodcastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PodcastStats _$PodcastStatsFromJson(Map<String, dynamic> json) {
  return _PodcastStats.fromJson(json);
}

/// @nodoc
mixin _$PodcastStats {
  String get guid => throw _privateConstructorUsedError;
  DateTime? get subscribedDate => throw _privateConstructorUsedError;
  DateTime? get lastCheckedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastStatsCopyWith<PodcastStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastStatsCopyWith<$Res> {
  factory $PodcastStatsCopyWith(
          PodcastStats value, $Res Function(PodcastStats) then) =
      _$PodcastStatsCopyWithImpl<$Res, PodcastStats>;
  @useResult
  $Res call({String guid, DateTime? subscribedDate, DateTime? lastCheckedAt});
}

/// @nodoc
class _$PodcastStatsCopyWithImpl<$Res, $Val extends PodcastStats>
    implements $PodcastStatsCopyWith<$Res> {
  _$PodcastStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? subscribedDate = freezed,
    Object? lastCheckedAt = freezed,
  }) {
    return _then(_value.copyWith(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      subscribedDate: freezed == subscribedDate
          ? _value.subscribedDate
          : subscribedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastCheckedAt: freezed == lastCheckedAt
          ? _value.lastCheckedAt
          : lastCheckedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastStatsImplCopyWith<$Res>
    implements $PodcastStatsCopyWith<$Res> {
  factory _$$PodcastStatsImplCopyWith(
          _$PodcastStatsImpl value, $Res Function(_$PodcastStatsImpl) then) =
      __$$PodcastStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String guid, DateTime? subscribedDate, DateTime? lastCheckedAt});
}

/// @nodoc
class __$$PodcastStatsImplCopyWithImpl<$Res>
    extends _$PodcastStatsCopyWithImpl<$Res, _$PodcastStatsImpl>
    implements _$$PodcastStatsImplCopyWith<$Res> {
  __$$PodcastStatsImplCopyWithImpl(
      _$PodcastStatsImpl _value, $Res Function(_$PodcastStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? subscribedDate = freezed,
    Object? lastCheckedAt = freezed,
  }) {
    return _then(_$PodcastStatsImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      subscribedDate: freezed == subscribedDate
          ? _value.subscribedDate
          : subscribedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastCheckedAt: freezed == lastCheckedAt
          ? _value.lastCheckedAt
          : lastCheckedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastStatsImpl implements _PodcastStats {
  const _$PodcastStatsImpl(
      {required this.guid, this.subscribedDate, this.lastCheckedAt});

  factory _$PodcastStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastStatsImplFromJson(json);

  @override
  final String guid;
  @override
  final DateTime? subscribedDate;
  @override
  final DateTime? lastCheckedAt;

  @override
  String toString() {
    return 'PodcastStats(guid: $guid, subscribedDate: $subscribedDate, lastCheckedAt: $lastCheckedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastStatsImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.subscribedDate, subscribedDate) ||
                other.subscribedDate == subscribedDate) &&
            (identical(other.lastCheckedAt, lastCheckedAt) ||
                other.lastCheckedAt == lastCheckedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, guid, subscribedDate, lastCheckedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastStatsImplCopyWith<_$PodcastStatsImpl> get copyWith =>
      __$$PodcastStatsImplCopyWithImpl<_$PodcastStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastStatsImplToJson(
      this,
    );
  }
}

abstract class _PodcastStats implements PodcastStats {
  const factory _PodcastStats(
      {required final String guid,
      final DateTime? subscribedDate,
      final DateTime? lastCheckedAt}) = _$PodcastStatsImpl;

  factory _PodcastStats.fromJson(Map<String, dynamic> json) =
      _$PodcastStatsImpl.fromJson;

  @override
  String get guid;
  @override
  DateTime? get subscribedDate;
  @override
  DateTime? get lastCheckedAt;
  @override
  @JsonKey(ignore: true)
  _$$PodcastStatsImplCopyWith<_$PodcastStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PodcastViewStats _$PodcastViewStatsFromJson(Map<String, dynamic> json) {
  return _PodcastViewStats.fromJson(json);
}

/// @nodoc
mixin _$PodcastViewStats {
  String get guid => throw _privateConstructorUsedError;
  PodcastDetailViewMode get viewMode => throw _privateConstructorUsedError;
  bool get ascend => throw _privateConstructorUsedError;
  bool get ascendSeasonEpisodes => throw _privateConstructorUsedError;
  Map<String, DateTime> get listenedEpisodes =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastViewStatsCopyWith<PodcastViewStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastViewStatsCopyWith<$Res> {
  factory $PodcastViewStatsCopyWith(
          PodcastViewStats value, $Res Function(PodcastViewStats) then) =
      _$PodcastViewStatsCopyWithImpl<$Res, PodcastViewStats>;
  @useResult
  $Res call(
      {String guid,
      PodcastDetailViewMode viewMode,
      bool ascend,
      bool ascendSeasonEpisodes,
      Map<String, DateTime> listenedEpisodes});
}

/// @nodoc
class _$PodcastViewStatsCopyWithImpl<$Res, $Val extends PodcastViewStats>
    implements $PodcastViewStatsCopyWith<$Res> {
  _$PodcastViewStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? viewMode = null,
    Object? ascend = null,
    Object? ascendSeasonEpisodes = null,
    Object? listenedEpisodes = null,
  }) {
    return _then(_value.copyWith(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as PodcastDetailViewMode,
      ascend: null == ascend
          ? _value.ascend
          : ascend // ignore: cast_nullable_to_non_nullable
              as bool,
      ascendSeasonEpisodes: null == ascendSeasonEpisodes
          ? _value.ascendSeasonEpisodes
          : ascendSeasonEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      listenedEpisodes: null == listenedEpisodes
          ? _value.listenedEpisodes
          : listenedEpisodes // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastViewStatsImplCopyWith<$Res>
    implements $PodcastViewStatsCopyWith<$Res> {
  factory _$$PodcastViewStatsImplCopyWith(_$PodcastViewStatsImpl value,
          $Res Function(_$PodcastViewStatsImpl) then) =
      __$$PodcastViewStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String guid,
      PodcastDetailViewMode viewMode,
      bool ascend,
      bool ascendSeasonEpisodes,
      Map<String, DateTime> listenedEpisodes});
}

/// @nodoc
class __$$PodcastViewStatsImplCopyWithImpl<$Res>
    extends _$PodcastViewStatsCopyWithImpl<$Res, _$PodcastViewStatsImpl>
    implements _$$PodcastViewStatsImplCopyWith<$Res> {
  __$$PodcastViewStatsImplCopyWithImpl(_$PodcastViewStatsImpl _value,
      $Res Function(_$PodcastViewStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? viewMode = null,
    Object? ascend = null,
    Object? ascendSeasonEpisodes = null,
    Object? listenedEpisodes = null,
  }) {
    return _then(_$PodcastViewStatsImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as PodcastDetailViewMode,
      ascend: null == ascend
          ? _value.ascend
          : ascend // ignore: cast_nullable_to_non_nullable
              as bool,
      ascendSeasonEpisodes: null == ascendSeasonEpisodes
          ? _value.ascendSeasonEpisodes
          : ascendSeasonEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      listenedEpisodes: null == listenedEpisodes
          ? _value._listenedEpisodes
          : listenedEpisodes // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastViewStatsImpl implements _PodcastViewStats {
  const _$PodcastViewStatsImpl(
      {required this.guid,
      this.viewMode = PodcastDetailViewMode.seasons,
      this.ascend = false,
      this.ascendSeasonEpisodes = true,
      final Map<String, DateTime> listenedEpisodes =
          const <String, DateTime>{}})
      : _listenedEpisodes = listenedEpisodes;

  factory _$PodcastViewStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastViewStatsImplFromJson(json);

  @override
  final String guid;
  @override
  @JsonKey()
  final PodcastDetailViewMode viewMode;
  @override
  @JsonKey()
  final bool ascend;
  @override
  @JsonKey()
  final bool ascendSeasonEpisodes;
  final Map<String, DateTime> _listenedEpisodes;
  @override
  @JsonKey()
  Map<String, DateTime> get listenedEpisodes {
    if (_listenedEpisodes is EqualUnmodifiableMapView) return _listenedEpisodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_listenedEpisodes);
  }

  @override
  String toString() {
    return 'PodcastViewStats(guid: $guid, viewMode: $viewMode, ascend: $ascend, ascendSeasonEpisodes: $ascendSeasonEpisodes, listenedEpisodes: $listenedEpisodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastViewStatsImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.ascend, ascend) || other.ascend == ascend) &&
            (identical(other.ascendSeasonEpisodes, ascendSeasonEpisodes) ||
                other.ascendSeasonEpisodes == ascendSeasonEpisodes) &&
            const DeepCollectionEquality()
                .equals(other._listenedEpisodes, _listenedEpisodes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      guid,
      viewMode,
      ascend,
      ascendSeasonEpisodes,
      const DeepCollectionEquality().hash(_listenedEpisodes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastViewStatsImplCopyWith<_$PodcastViewStatsImpl> get copyWith =>
      __$$PodcastViewStatsImplCopyWithImpl<_$PodcastViewStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastViewStatsImplToJson(
      this,
    );
  }
}

abstract class _PodcastViewStats implements PodcastViewStats {
  const factory _PodcastViewStats(
      {required final String guid,
      final PodcastDetailViewMode viewMode,
      final bool ascend,
      final bool ascendSeasonEpisodes,
      final Map<String, DateTime> listenedEpisodes}) = _$PodcastViewStatsImpl;

  factory _PodcastViewStats.fromJson(Map<String, dynamic> json) =
      _$PodcastViewStatsImpl.fromJson;

  @override
  String get guid;
  @override
  PodcastDetailViewMode get viewMode;
  @override
  bool get ascend;
  @override
  bool get ascendSeasonEpisodes;
  @override
  Map<String, DateTime> get listenedEpisodes;
  @override
  @JsonKey(ignore: true)
  _$$PodcastViewStatsImplCopyWith<_$PodcastViewStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
