// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recently_played_episodes_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RecentlyPlayedEpisodesState {
  List<Episode> get episodes => throw _privateConstructorUsedError;
  int? get cursor => throw _privateConstructorUsedError;

  /// Create a copy of RecentlyPlayedEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentlyPlayedEpisodesStateCopyWith<RecentlyPlayedEpisodesState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentlyPlayedEpisodesStateCopyWith<$Res> {
  factory $RecentlyPlayedEpisodesStateCopyWith(
          RecentlyPlayedEpisodesState value,
          $Res Function(RecentlyPlayedEpisodesState) then) =
      _$RecentlyPlayedEpisodesStateCopyWithImpl<$Res,
          RecentlyPlayedEpisodesState>;
  @useResult
  $Res call({List<Episode> episodes, int? cursor});
}

/// @nodoc
class _$RecentlyPlayedEpisodesStateCopyWithImpl<$Res,
        $Val extends RecentlyPlayedEpisodesState>
    implements $RecentlyPlayedEpisodesStateCopyWith<$Res> {
  _$RecentlyPlayedEpisodesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentlyPlayedEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentlyPlayedEpisodesStateImplCopyWith<$Res>
    implements $RecentlyPlayedEpisodesStateCopyWith<$Res> {
  factory _$$RecentlyPlayedEpisodesStateImplCopyWith(
          _$RecentlyPlayedEpisodesStateImpl value,
          $Res Function(_$RecentlyPlayedEpisodesStateImpl) then) =
      __$$RecentlyPlayedEpisodesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Episode> episodes, int? cursor});
}

/// @nodoc
class __$$RecentlyPlayedEpisodesStateImplCopyWithImpl<$Res>
    extends _$RecentlyPlayedEpisodesStateCopyWithImpl<$Res,
        _$RecentlyPlayedEpisodesStateImpl>
    implements _$$RecentlyPlayedEpisodesStateImplCopyWith<$Res> {
  __$$RecentlyPlayedEpisodesStateImplCopyWithImpl(
      _$RecentlyPlayedEpisodesStateImpl _value,
      $Res Function(_$RecentlyPlayedEpisodesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecentlyPlayedEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? cursor = freezed,
  }) {
    return _then(_$RecentlyPlayedEpisodesStateImpl(
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RecentlyPlayedEpisodesStateImpl
    implements _RecentlyPlayedEpisodesState {
  const _$RecentlyPlayedEpisodesStateImpl(
      {required final List<Episode> episodes, required this.cursor})
      : _episodes = episodes;

  final List<Episode> _episodes;
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  final int? cursor;

  @override
  String toString() {
    return 'RecentlyPlayedEpisodesState(episodes: $episodes, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentlyPlayedEpisodesStateImpl &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_episodes), cursor);

  /// Create a copy of RecentlyPlayedEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentlyPlayedEpisodesStateImplCopyWith<_$RecentlyPlayedEpisodesStateImpl>
      get copyWith => __$$RecentlyPlayedEpisodesStateImplCopyWithImpl<
          _$RecentlyPlayedEpisodesStateImpl>(this, _$identity);
}

abstract class _RecentlyPlayedEpisodesState
    implements RecentlyPlayedEpisodesState {
  const factory _RecentlyPlayedEpisodesState(
      {required final List<Episode> episodes,
      required final int? cursor}) = _$RecentlyPlayedEpisodesStateImpl;

  @override
  List<Episode> get episodes;
  @override
  int? get cursor;

  /// Create a copy of RecentlyPlayedEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentlyPlayedEpisodesStateImplCopyWith<_$RecentlyPlayedEpisodesStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
