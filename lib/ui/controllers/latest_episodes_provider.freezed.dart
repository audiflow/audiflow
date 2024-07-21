// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'latest_episodes_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LatestEpisodesState {
  Set<String> get podcasts => throw _privateConstructorUsedError;
  List<Episode> get episodes => throw _privateConstructorUsedError;
  Set<String> get played => throw _privateConstructorUsedError;

  /// Create a copy of LatestEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatestEpisodesStateCopyWith<LatestEpisodesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatestEpisodesStateCopyWith<$Res> {
  factory $LatestEpisodesStateCopyWith(
          LatestEpisodesState value, $Res Function(LatestEpisodesState) then) =
      _$LatestEpisodesStateCopyWithImpl<$Res, LatestEpisodesState>;
  @useResult
  $Res call({Set<String> podcasts, List<Episode> episodes, Set<String> played});
}

/// @nodoc
class _$LatestEpisodesStateCopyWithImpl<$Res, $Val extends LatestEpisodesState>
    implements $LatestEpisodesStateCopyWith<$Res> {
  _$LatestEpisodesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatestEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcasts = null,
    Object? episodes = null,
    Object? played = null,
  }) {
    return _then(_value.copyWith(
      podcasts: null == podcasts
          ? _value.podcasts
          : podcasts // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      played: null == played
          ? _value.played
          : played // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LatestEpisodesStateImplCopyWith<$Res>
    implements $LatestEpisodesStateCopyWith<$Res> {
  factory _$$LatestEpisodesStateImplCopyWith(_$LatestEpisodesStateImpl value,
          $Res Function(_$LatestEpisodesStateImpl) then) =
      __$$LatestEpisodesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Set<String> podcasts, List<Episode> episodes, Set<String> played});
}

/// @nodoc
class __$$LatestEpisodesStateImplCopyWithImpl<$Res>
    extends _$LatestEpisodesStateCopyWithImpl<$Res, _$LatestEpisodesStateImpl>
    implements _$$LatestEpisodesStateImplCopyWith<$Res> {
  __$$LatestEpisodesStateImplCopyWithImpl(_$LatestEpisodesStateImpl _value,
      $Res Function(_$LatestEpisodesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LatestEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcasts = null,
    Object? episodes = null,
    Object? played = null,
  }) {
    return _then(_$LatestEpisodesStateImpl(
      podcasts: null == podcasts
          ? _value._podcasts
          : podcasts // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      played: null == played
          ? _value._played
          : played // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$LatestEpisodesStateImpl implements _LatestEpisodesState {
  const _$LatestEpisodesStateImpl(
      {final Set<String> podcasts = const <String>{},
      final List<Episode> episodes = const <Episode>[],
      final Set<String> played = const <String>{}})
      : _podcasts = podcasts,
        _episodes = episodes,
        _played = played;

  final Set<String> _podcasts;
  @override
  @JsonKey()
  Set<String> get podcasts {
    if (_podcasts is EqualUnmodifiableSetView) return _podcasts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_podcasts);
  }

  final List<Episode> _episodes;
  @override
  @JsonKey()
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  final Set<String> _played;
  @override
  @JsonKey()
  Set<String> get played {
    if (_played is EqualUnmodifiableSetView) return _played;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_played);
  }

  @override
  String toString() {
    return 'LatestEpisodesState(podcasts: $podcasts, episodes: $episodes, played: $played)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatestEpisodesStateImpl &&
            const DeepCollectionEquality().equals(other._podcasts, _podcasts) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            const DeepCollectionEquality().equals(other._played, _played));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_podcasts),
      const DeepCollectionEquality().hash(_episodes),
      const DeepCollectionEquality().hash(_played));

  /// Create a copy of LatestEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatestEpisodesStateImplCopyWith<_$LatestEpisodesStateImpl> get copyWith =>
      __$$LatestEpisodesStateImplCopyWithImpl<_$LatestEpisodesStateImpl>(
          this, _$identity);
}

abstract class _LatestEpisodesState implements LatestEpisodesState {
  const factory _LatestEpisodesState(
      {final Set<String> podcasts,
      final List<Episode> episodes,
      final Set<String> played}) = _$LatestEpisodesStateImpl;

  @override
  Set<String> get podcasts;
  @override
  List<Episode> get episodes;
  @override
  Set<String> get played;

  /// Create a copy of LatestEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatestEpisodesStateImplCopyWith<_$LatestEpisodesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
