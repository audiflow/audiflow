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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Season {
  /// A String GUID for the season.
  String get guid => throw _privateConstructorUsedError;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid => throw _privateConstructorUsedError;

  /// Episodes under the season.
  List<Episode> get episodes => throw _privateConstructorUsedError;

  /// The season title.
  String? get title => throw _privateConstructorUsedError;

  /// The season number.
  int? get seasonNum => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SeasonCopyWith<Season> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonCopyWith<$Res> {
  factory $SeasonCopyWith(Season value, $Res Function(Season) then) =
      _$SeasonCopyWithImpl<$Res, Season>;
  @useResult
  $Res call(
      {String guid,
      String pguid,
      List<Episode> episodes,
      String? title,
      int? seasonNum});
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
    Object? guid = null,
    Object? pguid = null,
    Object? episodes = null,
    Object? title = freezed,
    Object? seasonNum = freezed,
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
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonNum: freezed == seasonNum
          ? _value.seasonNum
          : seasonNum // ignore: cast_nullable_to_non_nullable
              as int?,
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
      {String guid,
      String pguid,
      List<Episode> episodes,
      String? title,
      int? seasonNum});
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
    Object? guid = null,
    Object? pguid = null,
    Object? episodes = null,
    Object? title = freezed,
    Object? seasonNum = freezed,
  }) {
    return _then(_$SeasonImpl(
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonNum: freezed == seasonNum
          ? _value.seasonNum
          : seasonNum // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$SeasonImpl implements _Season {
  const _$SeasonImpl(
      {required this.guid,
      required this.pguid,
      required final List<Episode> episodes,
      this.title,
      this.seasonNum})
      : _episodes = episodes;

  /// A String GUID for the season.
  @override
  final String guid;

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  @override
  final String pguid;

  /// Episodes under the season.
  final List<Episode> _episodes;

  /// Episodes under the season.
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  /// The season title.
  @override
  final String? title;

  /// The season number.
  @override
  final int? seasonNum;

  @override
  String toString() {
    return 'Season(guid: $guid, pguid: $pguid, episodes: $episodes, title: $title, seasonNum: $seasonNum)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.seasonNum, seasonNum) ||
                other.seasonNum == seasonNum));
  }

  @override
  int get hashCode => Object.hash(runtimeType, guid, pguid,
      const DeepCollectionEquality().hash(_episodes), title, seasonNum);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      __$$SeasonImplCopyWithImpl<_$SeasonImpl>(this, _$identity);
}

abstract class _Season implements Season {
  const factory _Season(
      {required final String guid,
      required final String pguid,
      required final List<Episode> episodes,
      final String? title,
      final int? seasonNum}) = _$SeasonImpl;

  @override

  /// A String GUID for the season.
  String get guid;
  @override

  /// The GUID for an associated podcast. If an episode has been downloaded
  /// without subscribing to a podcast this may be null.
  String get pguid;
  @override

  /// Episodes under the season.
  List<Episode> get episodes;
  @override

  /// The season title.
  String? get title;
  @override

  /// The season number.
  int? get seasonNum;
  @override
  @JsonKey(ignore: true)
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
