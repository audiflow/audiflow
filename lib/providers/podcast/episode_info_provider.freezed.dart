// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_info_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EpisodeState {
  Episode get episode => throw _privateConstructorUsedError;
  EpisodeStats? get stats => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EpisodeStateCopyWith<EpisodeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeStateCopyWith<$Res> {
  factory $EpisodeStateCopyWith(
          EpisodeState value, $Res Function(EpisodeState) then) =
      _$EpisodeStateCopyWithImpl<$Res, EpisodeState>;
  @useResult
  $Res call({Episode episode, EpisodeStats? stats});

  $EpisodeCopyWith<$Res> get episode;
  $EpisodeStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$EpisodeStateCopyWithImpl<$Res, $Val extends EpisodeState>
    implements $EpisodeStateCopyWith<$Res> {
  _$EpisodeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? stats = freezed,
  }) {
    return _then(_value.copyWith(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as EpisodeStats?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get episode {
    return $EpisodeCopyWith<$Res>(_value.episode, (value) {
      return _then(_value.copyWith(episode: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $EpisodeStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EpisodeStateImplCopyWith<$Res>
    implements $EpisodeStateCopyWith<$Res> {
  factory _$$EpisodeStateImplCopyWith(
          _$EpisodeStateImpl value, $Res Function(_$EpisodeStateImpl) then) =
      __$$EpisodeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Episode episode, EpisodeStats? stats});

  @override
  $EpisodeCopyWith<$Res> get episode;
  @override
  $EpisodeStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$EpisodeStateImplCopyWithImpl<$Res>
    extends _$EpisodeStateCopyWithImpl<$Res, _$EpisodeStateImpl>
    implements _$$EpisodeStateImplCopyWith<$Res> {
  __$$EpisodeStateImplCopyWithImpl(
      _$EpisodeStateImpl _value, $Res Function(_$EpisodeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? stats = freezed,
  }) {
    return _then(_$EpisodeStateImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as EpisodeStats?,
    ));
  }
}

/// @nodoc

class _$EpisodeStateImpl implements _EpisodeState {
  const _$EpisodeStateImpl({required this.episode, this.stats});

  @override
  final Episode episode;
  @override
  final EpisodeStats? stats;

  @override
  String toString() {
    return 'EpisodeState(episode: $episode, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeStateImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode, stats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      __$$EpisodeStateImplCopyWithImpl<_$EpisodeStateImpl>(this, _$identity);
}

abstract class _EpisodeState implements EpisodeState {
  const factory _EpisodeState(
      {required final Episode episode,
      final EpisodeStats? stats}) = _$EpisodeStateImpl;

  @override
  Episode get episode;
  @override
  EpisodeStats? get stats;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
