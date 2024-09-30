// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_player_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PartialAudioPlayerState {
  Episode get episode => throw _privateConstructorUsedError;
  PlayerPhase get phase => throw _privateConstructorUsedError;
  AudioState get audioState => throw _privateConstructorUsedError;
  bool get interrupted => throw _privateConstructorUsedError;

  /// Create a copy of PartialAudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartialAudioPlayerStateCopyWith<PartialAudioPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartialAudioPlayerStateCopyWith<$Res> {
  factory $PartialAudioPlayerStateCopyWith(PartialAudioPlayerState value,
          $Res Function(PartialAudioPlayerState) then) =
      _$PartialAudioPlayerStateCopyWithImpl<$Res, PartialAudioPlayerState>;
  @useResult
  $Res call(
      {Episode episode,
      PlayerPhase phase,
      AudioState audioState,
      bool interrupted});
}

/// @nodoc
class _$PartialAudioPlayerStateCopyWithImpl<$Res,
        $Val extends PartialAudioPlayerState>
    implements $PartialAudioPlayerStateCopyWith<$Res> {
  _$PartialAudioPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartialAudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? phase = null,
    Object? audioState = null,
    Object? interrupted = null,
  }) {
    return _then(_value.copyWith(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PartialAudioPlayerStateImplCopyWith<$Res>
    implements $PartialAudioPlayerStateCopyWith<$Res> {
  factory _$$PartialAudioPlayerStateImplCopyWith(
          _$PartialAudioPlayerStateImpl value,
          $Res Function(_$PartialAudioPlayerStateImpl) then) =
      __$$PartialAudioPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Episode episode,
      PlayerPhase phase,
      AudioState audioState,
      bool interrupted});
}

/// @nodoc
class __$$PartialAudioPlayerStateImplCopyWithImpl<$Res>
    extends _$PartialAudioPlayerStateCopyWithImpl<$Res,
        _$PartialAudioPlayerStateImpl>
    implements _$$PartialAudioPlayerStateImplCopyWith<$Res> {
  __$$PartialAudioPlayerStateImplCopyWithImpl(
      _$PartialAudioPlayerStateImpl _value,
      $Res Function(_$PartialAudioPlayerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PartialAudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? phase = null,
    Object? audioState = null,
    Object? interrupted = null,
  }) {
    return _then(_$PartialAudioPlayerStateImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
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
    ));
  }
}

/// @nodoc

class _$PartialAudioPlayerStateImpl implements _PartialAudioPlayerState {
  _$PartialAudioPlayerStateImpl(
      {required this.episode,
      required this.phase,
      required this.audioState,
      required this.interrupted});

  @override
  final Episode episode;
  @override
  final PlayerPhase phase;
  @override
  final AudioState audioState;
  @override
  final bool interrupted;

  @override
  String toString() {
    return 'PartialAudioPlayerState(episode: $episode, phase: $phase, audioState: $audioState, interrupted: $interrupted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartialAudioPlayerStateImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.audioState, audioState) ||
                other.audioState == audioState) &&
            (identical(other.interrupted, interrupted) ||
                other.interrupted == interrupted));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, episode, phase, audioState, interrupted);

  /// Create a copy of PartialAudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartialAudioPlayerStateImplCopyWith<_$PartialAudioPlayerStateImpl>
      get copyWith => __$$PartialAudioPlayerStateImplCopyWithImpl<
          _$PartialAudioPlayerStateImpl>(this, _$identity);
}

abstract class _PartialAudioPlayerState implements PartialAudioPlayerState {
  factory _PartialAudioPlayerState(
      {required final Episode episode,
      required final PlayerPhase phase,
      required final AudioState audioState,
      required final bool interrupted}) = _$PartialAudioPlayerStateImpl;

  @override
  Episode get episode;
  @override
  PlayerPhase get phase;
  @override
  AudioState get audioState;
  @override
  bool get interrupted;

  /// Create a copy of PartialAudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartialAudioPlayerStateImplCopyWith<_$PartialAudioPlayerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
