// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Season _$SeasonFromJson(Map<String, dynamic> json) {
  return _Season.fromJson(json);
}

/// @nodoc
mixin _$Season {
  /// Database ID
  int? get id => throw _privateConstructorUsedError;

  /// A String GUID for the season.
  String get guid => throw _privateConstructorUsedError;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid => throw _privateConstructorUsedError;

  /// The name of the podcast the season is part of.
  String get podcast => throw _privateConstructorUsedError;

  /// The season title.
  String? get title => throw _privateConstructorUsedError;

  /// The season number.
  int? get seasonNum => throw _privateConstructorUsedError;

  /// Season episodes.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonCopyWith<Season> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonCopyWith<$Res> {
  factory $SeasonCopyWith(Season value, $Res Function(Season) then) =
      _$SeasonCopyWithImpl<$Res, Season>;
  @useResult
  $Res call(
      {int? id,
      String guid,
      String pguid,
      String podcast,
      String? title,
      int? seasonNum,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Episode> episodes});
}

/// @nodoc
class _$SeasonCopyWithImpl<$Res, $Val extends Season>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._value, this._then);

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
    Object? podcast = null,
    Object? title = freezed,
    Object? seasonNum = freezed,
    Object? episodes = null,
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
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonNum: freezed == seasonNum
          ? _value.seasonNum
          : seasonNum // ignore: cast_nullable_to_non_nullable
              as int?,
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonImplCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$$SeasonImplCopyWith(
          _$SeasonImpl value, $Res Function(_$SeasonImpl) then) =
      __$$SeasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String guid,
      String pguid,
      String podcast,
      String? title,
      int? seasonNum,
      @JsonKey(includeToJson: false, includeFromJson: false)
      List<Episode> episodes});
}

/// @nodoc
class __$$SeasonImplCopyWithImpl<$Res>
    extends _$SeasonCopyWithImpl<$Res, _$SeasonImpl>
    implements _$$SeasonImplCopyWith<$Res> {
  __$$SeasonImplCopyWithImpl(
      _$SeasonImpl _value, $Res Function(_$SeasonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? guid = null,
    Object? pguid = null,
    Object? podcast = null,
    Object? title = freezed,
    Object? seasonNum = freezed,
    Object? episodes = null,
  }) {
    return _then(_$SeasonImpl(
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
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonNum: freezed == seasonNum
          ? _value.seasonNum
          : seasonNum // ignore: cast_nullable_to_non_nullable
              as int?,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonImpl implements _Season {
  const _$SeasonImpl(
      {this.id,
      required this.guid,
      required this.pguid,
      required this.podcast,
      this.title,
      this.seasonNum,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Episode> episodes = const <Episode>[]})
      : _episodes = episodes;

  factory _$SeasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonImplFromJson(json);

  /// Database ID
  @override
  final int? id;

  /// A String GUID for the season.
  @override
  final String guid;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  @override
  final String pguid;

  /// The name of the podcast the season is part of.
  @override
  final String podcast;

  /// The season title.
  @override
  final String? title;

  /// The season number.
  @override
  final int? seasonNum;

  /// Season episodes.
// ignore: invalid_annotation_target
  final List<Episode> _episodes;

  /// Season episodes.
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  String toString() {
    return 'Season(id: $id, guid: $guid, pguid: $pguid, podcast: $podcast, title: $title, seasonNum: $seasonNum, episodes: $episodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.podcast, podcast) || other.podcast == podcast) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.seasonNum, seasonNum) ||
                other.seasonNum == seasonNum) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, guid, pguid, podcast, title,
      seasonNum, const DeepCollectionEquality().hash(_episodes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      __$$SeasonImplCopyWithImpl<_$SeasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonImplToJson(
      this,
    );
  }
}

abstract class _Season implements Season {
  const factory _Season(
      {final int? id,
      required final String guid,
      required final String pguid,
      required final String podcast,
      final String? title,
      final int? seasonNum,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final List<Episode> episodes}) = _$SeasonImpl;

  factory _Season.fromJson(Map<String, dynamic> json) = _$SeasonImpl.fromJson;

  @override

  /// Database ID
  int? get id;
  @override

  /// A String GUID for the season.
  String get guid;
  @override

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid;
  @override

  /// The name of the podcast the season is part of.
  String get podcast;
  @override

  /// The season title.
  String? get title;
  @override

  /// The season number.
  int? get seasonNum;
  @override

  /// Season episodes.
// ignore: invalid_annotation_target
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Episode> get episodes;
  @override
  @JsonKey(ignore: true)
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
