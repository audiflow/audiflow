// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_player_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioPlayerState {
  Episode get episode => throw _privateConstructorUsedError;
  Duration get position => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  PlayerPhase get phase => throw _privateConstructorUsedError;
  AudioState get audioState => throw _privateConstructorUsedError;
  bool get interrupted => throw _privateConstructorUsedError;
  int get playbackError => throw _privateConstructorUsedError;

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioPlayerStateCopyWith<AudioPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioPlayerStateCopyWith<$Res> {
  factory $AudioPlayerStateCopyWith(
          AudioPlayerState value, $Res Function(AudioPlayerState) then) =
      _$AudioPlayerStateCopyWithImpl<$Res, AudioPlayerState>;
  @useResult
  $Res call(
      {Episode episode,
      Duration position,
      Duration duration,
      PlayerPhase phase,
      AudioState audioState,
      bool interrupted,
      int playbackError});
}

/// @nodoc
class _$AudioPlayerStateCopyWithImpl<$Res, $Val extends AudioPlayerState>
    implements $AudioPlayerStateCopyWith<$Res> {
  _$AudioPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? position = null,
    Object? duration = null,
    Object? phase = null,
    Object? audioState = null,
    Object? interrupted = null,
    Object? playbackError = null,
  }) {
    return _then(_value.copyWith(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as PlayerPhase,
      audioState: null == audioState
          ? _value.audioState
          : audioState // ignore: cast_nullable_to_non_nullable
              as AudioState,
      interrupted: null == interrupted
          ? _value.interrupted
          : interrupted // ignore: cast_nullable_to_non_nullable
              as bool,
      playbackError: null == playbackError
          ? _value.playbackError
          : playbackError // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioPlayerStateImplCopyWith<$Res>
    implements $AudioPlayerStateCopyWith<$Res> {
  factory _$$AudioPlayerStateImplCopyWith(_$AudioPlayerStateImpl value,
          $Res Function(_$AudioPlayerStateImpl) then) =
      __$$AudioPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Episode episode,
      Duration position,
      Duration duration,
      PlayerPhase phase,
      AudioState audioState,
      bool interrupted,
      int playbackError});
}

/// @nodoc
class __$$AudioPlayerStateImplCopyWithImpl<$Res>
    extends _$AudioPlayerStateCopyWithImpl<$Res, _$AudioPlayerStateImpl>
    implements _$$AudioPlayerStateImplCopyWith<$Res> {
  __$$AudioPlayerStateImplCopyWithImpl(_$AudioPlayerStateImpl _value,
      $Res Function(_$AudioPlayerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? position = null,
    Object? duration = null,
    Object? phase = null,
    Object? audioState = null,
    Object? interrupted = null,
    Object? playbackError = null,
  }) {
    return _then(_$AudioPlayerStateImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as PlayerPhase,
      audioState: null == audioState
          ? _value.audioState
          : audioState // ignore: cast_nullable_to_non_nullable
              as AudioState,
      interrupted: null == interrupted
          ? _value.interrupted
          : interrupted // ignore: cast_nullable_to_non_nullable
              as bool,
      playbackError: null == playbackError
          ? _value.playbackError
          : playbackError // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AudioPlayerStateImpl implements _AudioPlayerState {
  const _$AudioPlayerStateImpl(
      {required this.episode,
      required this.position,
      required this.duration,
      required this.phase,
      required this.audioState,
      this.interrupted = false,
      this.playbackError = 0});

  @override
  final Episode episode;
  @override
  final Duration position;
  @override
  final Duration duration;
  @override
  final PlayerPhase phase;
  @override
  final AudioState audioState;
  @override
  @JsonKey()
  final bool interrupted;
  @override
  @JsonKey()
  final int playbackError;

  @override
  String toString() {
    return 'AudioPlayerState(episode: $episode, position: $position, duration: $duration, phase: $phase, audioState: $audioState, interrupted: $interrupted, playbackError: $playbackError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioPlayerStateImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.audioState, audioState) ||
                other.audioState == audioState) &&
            (identical(other.interrupted, interrupted) ||
                other.interrupted == interrupted) &&
            (identical(other.playbackError, playbackError) ||
                other.playbackError == playbackError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode, position, duration,
      phase, audioState, interrupted, playbackError);

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioPlayerStateImplCopyWith<_$AudioPlayerStateImpl> get copyWith =>
      __$$AudioPlayerStateImplCopyWithImpl<_$AudioPlayerStateImpl>(
          this, _$identity);
}

abstract class _AudioPlayerState implements AudioPlayerState {
  const factory _AudioPlayerState(
      {required final Episode episode,
      required final Duration position,
      required final Duration duration,
      required final PlayerPhase phase,
      required final AudioState audioState,
      final bool interrupted,
      final int playbackError}) = _$AudioPlayerStateImpl;

  @override
  Episode get episode;
  @override
  Duration get position;
  @override
  Duration get duration;
  @override
  PlayerPhase get phase;
  @override
  AudioState get audioState;
  @override
  bool get interrupted;
  @override
  int get playbackError;

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioPlayerStateImplCopyWith<_$AudioPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
