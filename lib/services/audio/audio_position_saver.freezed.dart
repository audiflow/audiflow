// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_position_saver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioPositionSaverState {
  Episode? get episode => throw _privateConstructorUsedError;
  Duration? get lastSavedPosition => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioPositionSaverStateCopyWith<AudioPositionSaverState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioPositionSaverStateCopyWith<$Res> {
  factory $AudioPositionSaverStateCopyWith(AudioPositionSaverState value,
          $Res Function(AudioPositionSaverState) then) =
      _$AudioPositionSaverStateCopyWithImpl<$Res, AudioPositionSaverState>;
  @useResult
  $Res call({Episode? episode, Duration? lastSavedPosition});

  $EpisodeCopyWith<$Res>? get episode;
}

/// @nodoc
class _$AudioPositionSaverStateCopyWithImpl<$Res,
        $Val extends AudioPositionSaverState>
    implements $AudioPositionSaverStateCopyWith<$Res> {
  _$AudioPositionSaverStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = freezed,
    Object? lastSavedPosition = freezed,
  }) {
    return _then(_value.copyWith(
      episode: freezed == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode?,
      lastSavedPosition: freezed == lastSavedPosition
          ? _value.lastSavedPosition
          : lastSavedPosition // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res>? get episode {
    if (_value.episode == null) {
      return null;
    }

    return $EpisodeCopyWith<$Res>(_value.episode!, (value) {
      return _then(_value.copyWith(episode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AudioPositionSaverStateImplCopyWith<$Res>
    implements $AudioPositionSaverStateCopyWith<$Res> {
  factory _$$AudioPositionSaverStateImplCopyWith(
          _$AudioPositionSaverStateImpl value,
          $Res Function(_$AudioPositionSaverStateImpl) then) =
      __$$AudioPositionSaverStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Episode? episode, Duration? lastSavedPosition});

  @override
  $EpisodeCopyWith<$Res>? get episode;
}

/// @nodoc
class __$$AudioPositionSaverStateImplCopyWithImpl<$Res>
    extends _$AudioPositionSaverStateCopyWithImpl<$Res,
        _$AudioPositionSaverStateImpl>
    implements _$$AudioPositionSaverStateImplCopyWith<$Res> {
  __$$AudioPositionSaverStateImplCopyWithImpl(
      _$AudioPositionSaverStateImpl _value,
      $Res Function(_$AudioPositionSaverStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = freezed,
    Object? lastSavedPosition = freezed,
  }) {
    return _then(_$AudioPositionSaverStateImpl(
      episode: freezed == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode?,
      lastSavedPosition: freezed == lastSavedPosition
          ? _value.lastSavedPosition
          : lastSavedPosition // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc

class _$AudioPositionSaverStateImpl implements _AudioPositionSaverState {
  const _$AudioPositionSaverStateImpl({this.episode, this.lastSavedPosition});

  @override
  final Episode? episode;
  @override
  final Duration? lastSavedPosition;

  @override
  String toString() {
    return 'AudioPositionSaverState(episode: $episode, lastSavedPosition: $lastSavedPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioPositionSaverStateImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.lastSavedPosition, lastSavedPosition) ||
                other.lastSavedPosition == lastSavedPosition));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode, lastSavedPosition);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioPositionSaverStateImplCopyWith<_$AudioPositionSaverStateImpl>
      get copyWith => __$$AudioPositionSaverStateImplCopyWithImpl<
          _$AudioPositionSaverStateImpl>(this, _$identity);
}

abstract class _AudioPositionSaverState implements AudioPositionSaverState {
  const factory _AudioPositionSaverState(
      {final Episode? episode,
      final Duration? lastSavedPosition}) = _$AudioPositionSaverStateImpl;

  @override
  Episode? get episode;
  @override
  Duration? get lastSavedPosition;
  @override
  @JsonKey(ignore: true)
  _$$AudioPositionSaverStateImplCopyWith<_$AudioPositionSaverStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
