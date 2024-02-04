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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Podcast _$PodcastFromJson(Map<String, dynamic> json) {
  return _Podcast.fromJson(json);
}

/// @nodoc
mixin _$Podcast {
  /// Database ID
  int? get id => throw _privateConstructorUsedError;

  /// Unique identifier for podcast.
  String get guid => throw _privateConstructorUsedError;

  /// The link to the podcast RSS feed.
  String get url => throw _privateConstructorUsedError;

  /// RSS link URL.
  String? get link => throw _privateConstructorUsedError;

  /// Podcast title.
  String get title => throw _privateConstructorUsedError;

  /// Podcast description. Can be either plain text or HTML.
  String? get description => throw _privateConstructorUsedError;

  /// URL to the full size artwork image.
  String? get imageUrl => throw _privateConstructorUsedError;

  /// URL for thumbnail version of artwork image. Not contained within
  /// the RSS but may be calculated or provided within search results.
  String? get thumbImageUrl => throw _privateConstructorUsedError;

  /// Copyright owner of the podcast.
  String? get copyright => throw _privateConstructorUsedError;

  /// Date and time user subscribed to the podcast.
  DateTime? get subscribedDate => throw _privateConstructorUsedError;

  /// Zero or more funding links.
  List<Funding> get funding => throw _privateConstructorUsedError;

  /// One or more seasons for this podcast.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Season> get seasons => throw _privateConstructorUsedError;

  /// One or more episodes for this podcast.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Person> get persons => throw _privateConstructorUsedError;

  /// Date and time podcast was last updated/refreshed.
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Indicates whether the user wants to see the podcast as a list of seasons
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get seasonView =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get newEpisodes =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get updatedEpisodes => throw _privateConstructorUsedError;

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
      {int? id,
      String guid,
      String url,
      String? link,
      String title,
      String? description,
      String? imageUrl,
      String? thumbImageUrl,
      String? copyright,
      DateTime? subscribedDate,
      List<Funding> funding,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Season> seasons,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Episode> episodes,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Person> persons,
      DateTime? lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false) bool seasonView,
      @JsonKey(includeToJson: false, includeFromJson: false) bool newEpisodes,
      @JsonKey(includeToJson: false, includeFromJson: false)
      bool updatedEpisodes});
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
    Object? id = freezed,
    Object? guid = null,
    Object? url = null,
    Object? link = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? thumbImageUrl = freezed,
    Object? copyright = freezed,
    Object? subscribedDate = freezed,
    Object? funding = null,
    Object? seasons = null,
    Object? episodes = null,
    Object? persons = null,
    Object? lastUpdated = freezed,
    Object? seasonView = null,
    Object? newEpisodes = null,
    Object? updatedEpisodes = null,
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
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      link: freezed == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbImageUrl: freezed == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      copyright: freezed == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String?,
      subscribedDate: freezed == subscribedDate
          ? _value.subscribedDate
          : subscribedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      funding: null == funding
          ? _value.funding
          : funding // ignore: cast_nullable_to_non_nullable
              as List<Funding>,
      seasons: null == seasons
          ? _value.seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<Season>,
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      persons: null == persons
          ? _value.persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      seasonView: null == seasonView
          ? _value.seasonView
          : seasonView // ignore: cast_nullable_to_non_nullable
              as bool,
      newEpisodes: null == newEpisodes
          ? _value.newEpisodes
          : newEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedEpisodes: null == updatedEpisodes
          ? _value.updatedEpisodes
          : updatedEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {int? id,
      String guid,
      String url,
      String? link,
      String title,
      String? description,
      String? imageUrl,
      String? thumbImageUrl,
      String? copyright,
      DateTime? subscribedDate,
      List<Funding> funding,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Season> seasons,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Episode> episodes,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Person> persons,
      DateTime? lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false) bool seasonView,
      @JsonKey(includeToJson: false, includeFromJson: false) bool newEpisodes,
      @JsonKey(includeToJson: false, includeFromJson: false)
      bool updatedEpisodes});
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
    Object? id = freezed,
    Object? guid = null,
    Object? url = null,
    Object? link = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? thumbImageUrl = freezed,
    Object? copyright = freezed,
    Object? subscribedDate = freezed,
    Object? funding = null,
    Object? seasons = null,
    Object? episodes = null,
    Object? persons = null,
    Object? lastUpdated = freezed,
    Object? seasonView = null,
    Object? newEpisodes = null,
    Object? updatedEpisodes = null,
  }) {
    return _then(_$PodcastImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      link: freezed == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbImageUrl: freezed == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      copyright: freezed == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String?,
      subscribedDate: freezed == subscribedDate
          ? _value.subscribedDate
          : subscribedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      funding: null == funding
          ? _value._funding
          : funding // ignore: cast_nullable_to_non_nullable
              as List<Funding>,
      seasons: null == seasons
          ? _value._seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<Season>,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      persons: null == persons
          ? _value._persons
          : persons // ignore: cast_nullable_to_non_nullable
              as List<Person>,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      seasonView: null == seasonView
          ? _value.seasonView
          : seasonView // ignore: cast_nullable_to_non_nullable
              as bool,
      newEpisodes: null == newEpisodes
          ? _value.newEpisodes
          : newEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedEpisodes: null == updatedEpisodes
          ? _value.updatedEpisodes
          : updatedEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastImpl implements _Podcast {
  const _$PodcastImpl(
      {this.id,
      required this.guid,
      required this.url,
      this.link,
      required this.title,
      this.description,
      this.imageUrl,
      this.thumbImageUrl,
      this.copyright,
      this.subscribedDate,
      final List<Funding> funding = const [],
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Season> seasons = const [],
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Episode> episodes = const [],
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Person> persons = const [],
      this.lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.seasonView = false,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.newEpisodes = false,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.updatedEpisodes = false})
      : _funding = funding,
        _seasons = seasons,
        _episodes = episodes,
        _persons = persons;

  factory _$PodcastImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastImplFromJson(json);

  /// Database ID
  @override
  final int? id;

  /// Unique identifier for podcast.
  @override
  final String guid;

  /// The link to the podcast RSS feed.
  @override
  final String url;

  /// RSS link URL.
  @override
  final String? link;

  /// Podcast title.
  @override
  final String title;

  /// Podcast description. Can be either plain text or HTML.
  @override
  final String? description;

  /// URL to the full size artwork image.
  @override
  final String? imageUrl;

  /// URL for thumbnail version of artwork image. Not contained within
  /// the RSS but may be calculated or provided within search results.
  @override
  final String? thumbImageUrl;

  /// Copyright owner of the podcast.
  @override
  final String? copyright;

  /// Date and time user subscribed to the podcast.
  @override
  final DateTime? subscribedDate;

  /// Zero or more funding links.
  final List<Funding> _funding;

  /// Zero or more funding links.
  @override
  @JsonKey()
  List<Funding> get funding {
    if (_funding is EqualUnmodifiableListView) return _funding;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_funding);
  }

  /// One or more seasons for this podcast.
// ignore: invalid_annotation_target
  final List<Season> _seasons;

  /// One or more seasons for this podcast.
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Season> get seasons {
    if (_seasons is EqualUnmodifiableListView) return _seasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasons);
  }

  /// One or more episodes for this podcast.
// ignore: invalid_annotation_target
  final List<Episode> _episodes;

  /// One or more episodes for this podcast.
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

// ignore: invalid_annotation_target
  final List<Person> _persons;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Person> get persons {
    if (_persons is EqualUnmodifiableListView) return _persons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_persons);
  }

  /// Date and time podcast was last updated/refreshed.
  @override
  final DateTime? lastUpdated;

  /// Indicates whether the user wants to see the podcast as a list of seasons
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool seasonView;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool newEpisodes;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool updatedEpisodes;

  @override
  String toString() {
    return 'Podcast(id: $id, guid: $guid, url: $url, link: $link, title: $title, description: $description, imageUrl: $imageUrl, thumbImageUrl: $thumbImageUrl, copyright: $copyright, subscribedDate: $subscribedDate, funding: $funding, seasons: $seasons, episodes: $episodes, persons: $persons, lastUpdated: $lastUpdated, seasonView: $seasonView, newEpisodes: $newEpisodes, updatedEpisodes: $updatedEpisodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.copyright, copyright) ||
                other.copyright == copyright) &&
            (identical(other.subscribedDate, subscribedDate) ||
                other.subscribedDate == subscribedDate) &&
            const DeepCollectionEquality().equals(other._funding, _funding) &&
            const DeepCollectionEquality().equals(other._seasons, _seasons) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            const DeepCollectionEquality().equals(other._persons, _persons) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.seasonView, seasonView) ||
                other.seasonView == seasonView) &&
            (identical(other.newEpisodes, newEpisodes) ||
                other.newEpisodes == newEpisodes) &&
            (identical(other.updatedEpisodes, updatedEpisodes) ||
                other.updatedEpisodes == updatedEpisodes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      guid,
      url,
      link,
      title,
      description,
      imageUrl,
      thumbImageUrl,
      copyright,
      subscribedDate,
      const DeepCollectionEquality().hash(_funding),
      const DeepCollectionEquality().hash(_seasons),
      const DeepCollectionEquality().hash(_episodes),
      const DeepCollectionEquality().hash(_persons),
      lastUpdated,
      seasonView,
      newEpisodes,
      updatedEpisodes);

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
      {final int? id,
      required final String guid,
      required final String url,
      final String? link,
      required final String title,
      final String? description,
      final String? imageUrl,
      final String? thumbImageUrl,
      final String? copyright,
      final DateTime? subscribedDate,
      final List<Funding> funding,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Season> seasons,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Episode> episodes,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Person> persons,
      final DateTime? lastUpdated,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool seasonView,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool newEpisodes,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool updatedEpisodes}) = _$PodcastImpl;

  factory _Podcast.fromJson(Map<String, dynamic> json) = _$PodcastImpl.fromJson;

  @override

  /// Database ID
  int? get id;
  @override

  /// Unique identifier for podcast.
  String get guid;
  @override

  /// The link to the podcast RSS feed.
  String get url;
  @override

  /// RSS link URL.
  String? get link;
  @override

  /// Podcast title.
  String get title;
  @override

  /// Podcast description. Can be either plain text or HTML.
  String? get description;
  @override

  /// URL to the full size artwork image.
  String? get imageUrl;
  @override

  /// URL for thumbnail version of artwork image. Not contained within
  /// the RSS but may be calculated or provided within search results.
  String? get thumbImageUrl;
  @override

  /// Copyright owner of the podcast.
  String? get copyright;
  @override

  /// Date and time user subscribed to the podcast.
  DateTime? get subscribedDate;
  @override

  /// Zero or more funding links.
  List<Funding> get funding;
  @override

  /// One or more seasons for this podcast.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Season> get seasons;
  @override

  /// One or more episodes for this podcast.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Person> get persons;
  @override

  /// Date and time podcast was last updated/refreshed.
  DateTime? get lastUpdated;
  @override

  /// Indicates whether the user wants to see the podcast as a list of seasons
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get seasonView;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get newEpisodes;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get updatedEpisodes;
  @override
  @JsonKey(ignore: true)
  _$$PodcastImplCopyWith<_$PodcastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
