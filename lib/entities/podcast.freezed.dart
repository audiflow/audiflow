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

PodcastPreview _$PodcastPreviewFromJson(Map<String, dynamic> json) {
  return _PodcastPreview.fromJson(json);
}

/// @nodoc
mixin _$PodcastPreview {
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

  /// Last updated date.
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastPreviewCopyWith<PodcastPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastPreviewCopyWith<$Res> {
  factory $PodcastPreviewCopyWith(
          PodcastPreview value, $Res Function(PodcastPreview) then) =
      _$PodcastPreviewCopyWithImpl<$Res, PodcastPreview>;
  @useResult
  $Res call(
      {String guid,
      int collectionId,
      String? feedUrl,
      String title,
      String thumbImageUrl,
      DateTime lastUpdated});
}

/// @nodoc
class _$PodcastPreviewCopyWithImpl<$Res, $Val extends PodcastPreview>
    implements $PodcastPreviewCopyWith<$Res> {
  _$PodcastPreviewCopyWithImpl(this._value, this._then);

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
    Object? lastUpdated = null,
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
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastPreviewImplCopyWith<$Res>
    implements $PodcastPreviewCopyWith<$Res> {
  factory _$$PodcastPreviewImplCopyWith(_$PodcastPreviewImpl value,
          $Res Function(_$PodcastPreviewImpl) then) =
      __$$PodcastPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String guid,
      int collectionId,
      String? feedUrl,
      String title,
      String thumbImageUrl,
      DateTime lastUpdated});
}

/// @nodoc
class __$$PodcastPreviewImplCopyWithImpl<$Res>
    extends _$PodcastPreviewCopyWithImpl<$Res, _$PodcastPreviewImpl>
    implements _$$PodcastPreviewImplCopyWith<$Res> {
  __$$PodcastPreviewImplCopyWithImpl(
      _$PodcastPreviewImpl _value, $Res Function(_$PodcastPreviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? collectionId = null,
    Object? feedUrl = freezed,
    Object? title = null,
    Object? thumbImageUrl = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$PodcastPreviewImpl(
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
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastPreviewImpl implements _PodcastPreview {
  const _$PodcastPreviewImpl(
      {required this.guid,
      required this.collectionId,
      this.feedUrl,
      required this.title,
      required this.thumbImageUrl,
      required this.lastUpdated});

  factory _$PodcastPreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastPreviewImplFromJson(json);

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

  /// Last updated date.
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'PodcastPreview(guid: $guid, collectionId: $collectionId, feedUrl: $feedUrl, title: $title, thumbImageUrl: $thumbImageUrl, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastPreviewImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, guid, collectionId, feedUrl,
      title, thumbImageUrl, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastPreviewImplCopyWith<_$PodcastPreviewImpl> get copyWith =>
      __$$PodcastPreviewImplCopyWithImpl<_$PodcastPreviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastPreviewImplToJson(
      this,
    );
  }
}

abstract class _PodcastPreview implements PodcastPreview {
  const factory _PodcastPreview(
      {required final String guid,
      required final int collectionId,
      final String? feedUrl,
      required final String title,
      required final String thumbImageUrl,
      required final DateTime lastUpdated}) = _$PodcastPreviewImpl;

  factory _PodcastPreview.fromJson(Map<String, dynamic> json) =
      _$PodcastPreviewImpl.fromJson;

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

  /// Last updated date.
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$PodcastPreviewImplCopyWith<_$PodcastPreviewImpl> get copyWith =>
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

PodcastSearchResultItem _$PodcastSearchResultItemFromJson(
    Map<String, dynamic> json) {
  return _PodcastSearchResultItem.fromJson(json);
}

/// @nodoc
mixin _$PodcastSearchResultItem {
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
  $PodcastSearchResultItemCopyWith<PodcastSearchResultItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastSearchResultItemCopyWith<$Res> {
  factory $PodcastSearchResultItemCopyWith(PodcastSearchResultItem value,
          $Res Function(PodcastSearchResultItem) then) =
      _$PodcastSearchResultItemCopyWithImpl<$Res, PodcastSearchResultItem>;
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
class _$PodcastSearchResultItemCopyWithImpl<$Res,
        $Val extends PodcastSearchResultItem>
    implements $PodcastSearchResultItemCopyWith<$Res> {
  _$PodcastSearchResultItemCopyWithImpl(this._value, this._then);

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
abstract class _$$PodcastSearchResultItemImplCopyWith<$Res>
    implements $PodcastSearchResultItemCopyWith<$Res> {
  factory _$$PodcastSearchResultItemImplCopyWith(
          _$PodcastSearchResultItemImpl value,
          $Res Function(_$PodcastSearchResultItemImpl) then) =
      __$$PodcastSearchResultItemImplCopyWithImpl<$Res>;
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
class __$$PodcastSearchResultItemImplCopyWithImpl<$Res>
    extends _$PodcastSearchResultItemCopyWithImpl<$Res,
        _$PodcastSearchResultItemImpl>
    implements _$$PodcastSearchResultItemImplCopyWith<$Res> {
  __$$PodcastSearchResultItemImplCopyWithImpl(
      _$PodcastSearchResultItemImpl _value,
      $Res Function(_$PodcastSearchResultItemImpl) _then)
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
    return _then(_$PodcastSearchResultItemImpl(
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
class _$PodcastSearchResultItemImpl implements _PodcastSearchResultItem {
  const _$PodcastSearchResultItemImpl(
      {required this.guid,
      required this.collectionId,
      required this.feedUrl,
      required this.title,
      required this.thumbImageUrl,
      required this.imageUrl,
      required this.copyright,
      required this.releaseDate});

  factory _$PodcastSearchResultItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastSearchResultItemImplFromJson(json);

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
    return 'PodcastSearchResultItem(guid: $guid, collectionId: $collectionId, feedUrl: $feedUrl, title: $title, thumbImageUrl: $thumbImageUrl, imageUrl: $imageUrl, copyright: $copyright, releaseDate: $releaseDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastSearchResultItemImpl &&
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
  _$$PodcastSearchResultItemImplCopyWith<_$PodcastSearchResultItemImpl>
      get copyWith => __$$PodcastSearchResultItemImplCopyWithImpl<
          _$PodcastSearchResultItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastSearchResultItemImplToJson(
      this,
    );
  }
}

abstract class _PodcastSearchResultItem implements PodcastSearchResultItem {
  const factory _PodcastSearchResultItem(
      {required final String guid,
      required final int collectionId,
      required final String? feedUrl,
      required final String title,
      required final String thumbImageUrl,
      required final String imageUrl,
      required final String copyright,
      required final DateTime releaseDate}) = _$PodcastSearchResultItemImpl;

  factory _PodcastSearchResultItem.fromJson(Map<String, dynamic> json) =
      _$PodcastSearchResultItemImpl.fromJson;

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
  _$$PodcastSearchResultItemImplCopyWith<_$PodcastSearchResultItemImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PodcastStats _$PodcastStatsFromJson(Map<String, dynamic> json) {
  return _PodcastStats.fromJson(json);
}

/// @nodoc
mixin _$PodcastStats {
  String get guid => throw _privateConstructorUsedError;
  DateTime? get subscribedDate => throw _privateConstructorUsedError;
  PodcastDetailViewMode get viewMode => throw _privateConstructorUsedError;
  bool get ascend => throw _privateConstructorUsedError;
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
  $Res call(
      {String guid,
      DateTime? subscribedDate,
      PodcastDetailViewMode viewMode,
      bool ascend,
      DateTime? lastCheckedAt});
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
    Object? viewMode = null,
    Object? ascend = null,
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
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as PodcastDetailViewMode,
      ascend: null == ascend
          ? _value.ascend
          : ascend // ignore: cast_nullable_to_non_nullable
              as bool,
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
  $Res call(
      {String guid,
      DateTime? subscribedDate,
      PodcastDetailViewMode viewMode,
      bool ascend,
      DateTime? lastCheckedAt});
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
    Object? viewMode = null,
    Object? ascend = null,
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
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as PodcastDetailViewMode,
      ascend: null == ascend
          ? _value.ascend
          : ascend // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {required this.guid,
      this.subscribedDate,
      this.viewMode = PodcastDetailViewMode.episodes,
      this.ascend = false,
      this.lastCheckedAt});

  factory _$PodcastStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastStatsImplFromJson(json);

  @override
  final String guid;
  @override
  final DateTime? subscribedDate;
  @override
  @JsonKey()
  final PodcastDetailViewMode viewMode;
  @override
  @JsonKey()
  final bool ascend;
  @override
  final DateTime? lastCheckedAt;

  @override
  String toString() {
    return 'PodcastStats(guid: $guid, subscribedDate: $subscribedDate, viewMode: $viewMode, ascend: $ascend, lastCheckedAt: $lastCheckedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastStatsImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.subscribedDate, subscribedDate) ||
                other.subscribedDate == subscribedDate) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.ascend, ascend) || other.ascend == ascend) &&
            (identical(other.lastCheckedAt, lastCheckedAt) ||
                other.lastCheckedAt == lastCheckedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, guid, subscribedDate, viewMode, ascend, lastCheckedAt);

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
      final PodcastDetailViewMode viewMode,
      final bool ascend,
      final DateTime? lastCheckedAt}) = _$PodcastStatsImpl;

  factory _PodcastStats.fromJson(Map<String, dynamic> json) =
      _$PodcastStatsImpl.fromJson;

  @override
  String get guid;
  @override
  DateTime? get subscribedDate;
  @override
  PodcastDetailViewMode get viewMode;
  @override
  bool get ascend;
  @override
  DateTime? get lastCheckedAt;
  @override
  @JsonKey(ignore: true)
  _$$PodcastStatsImplCopyWith<_$PodcastStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
