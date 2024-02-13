// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioPlayerState {
  double get speed => throw _privateConstructorUsedError;
  bool get trimSilence => throw _privateConstructorUsedError;
  bool get volumeBoost => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double speed, bool trimSilence, bool volumeBoost)
        empty,
    required TResult Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)
        ready,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double speed, bool trimSilence, bool volumeBoost)? empty,
    TResult? Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)?
        ready,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double speed, bool trimSilence, bool volumeBoost)? empty,
    TResult Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)?
        ready,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmptyAudioPlayerState value) empty,
    required TResult Function(ReadyAudioPlayerState value) ready,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmptyAudioPlayerState value)? empty,
    TResult? Function(ReadyAudioPlayerState value)? ready,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmptyAudioPlayerState value)? empty,
    TResult Function(ReadyAudioPlayerState value)? ready,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioPlayerStateCopyWith<AudioPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioPlayerStateCopyWith<$Res> {
  factory $AudioPlayerStateCopyWith(
          AudioPlayerState value, $Res Function(AudioPlayerState) then) =
      _$AudioPlayerStateCopyWithImpl<$Res, AudioPlayerState>;
  @useResult
  $Res call({double speed, bool trimSilence, bool volumeBoost});
}

/// @nodoc
class _$AudioPlayerStateCopyWithImpl<$Res, $Val extends AudioPlayerState>
    implements $AudioPlayerStateCopyWith<$Res> {
  _$AudioPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speed = null,
    Object? trimSilence = null,
    Object? volumeBoost = null,
  }) {
    return _then(_value.copyWith(
      speed: null == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double,
      trimSilence: null == trimSilence
          ? _value.trimSilence
          : trimSilence // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeBoost: null == volumeBoost
          ? _value.volumeBoost
          : volumeBoost // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmptyAudioPlayerStateImplCopyWith<$Res>
    implements $AudioPlayerStateCopyWith<$Res> {
  factory _$$EmptyAudioPlayerStateImplCopyWith(
          _$EmptyAudioPlayerStateImpl value,
          $Res Function(_$EmptyAudioPlayerStateImpl) then) =
      __$$EmptyAudioPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double speed, bool trimSilence, bool volumeBoost});
}

/// @nodoc
class __$$EmptyAudioPlayerStateImplCopyWithImpl<$Res>
    extends _$AudioPlayerStateCopyWithImpl<$Res, _$EmptyAudioPlayerStateImpl>
    implements _$$EmptyAudioPlayerStateImplCopyWith<$Res> {
  __$$EmptyAudioPlayerStateImplCopyWithImpl(_$EmptyAudioPlayerStateImpl _value,
      $Res Function(_$EmptyAudioPlayerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speed = null,
    Object? trimSilence = null,
    Object? volumeBoost = null,
  }) {
    return _then(_$EmptyAudioPlayerStateImpl(
      speed: null == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double,
      trimSilence: null == trimSilence
          ? _value.trimSilence
          : trimSilence // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeBoost: null == volumeBoost
          ? _value.volumeBoost
          : volumeBoost // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EmptyAudioPlayerStateImpl implements EmptyAudioPlayerState {
  const _$EmptyAudioPlayerStateImpl(
      {required this.speed,
      required this.trimSilence,
      required this.volumeBoost});

  @override
  final double speed;
  @override
  final bool trimSilence;
  @override
  final bool volumeBoost;

  @override
  String toString() {
    return 'AudioPlayerState.empty(speed: $speed, trimSilence: $trimSilence, volumeBoost: $volumeBoost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmptyAudioPlayerStateImpl &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.trimSilence, trimSilence) ||
                other.trimSilence == trimSilence) &&
            (identical(other.volumeBoost, volumeBoost) ||
                other.volumeBoost == volumeBoost));
  }

  @override
  int get hashCode => Object.hash(runtimeType, speed, trimSilence, volumeBoost);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmptyAudioPlayerStateImplCopyWith<_$EmptyAudioPlayerStateImpl>
      get copyWith => __$$EmptyAudioPlayerStateImplCopyWithImpl<
          _$EmptyAudioPlayerStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double speed, bool trimSilence, bool volumeBoost)
        empty,
    required TResult Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)
        ready,
  }) {
    return empty(speed, trimSilence, volumeBoost);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double speed, bool trimSilence, bool volumeBoost)? empty,
    TResult? Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)?
        ready,
  }) {
    return empty?.call(speed, trimSilence, volumeBoost);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double speed, bool trimSilence, bool volumeBoost)? empty,
    TResult Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)?
        ready,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(speed, trimSilence, volumeBoost);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmptyAudioPlayerState value) empty,
    required TResult Function(ReadyAudioPlayerState value) ready,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmptyAudioPlayerState value)? empty,
    TResult? Function(ReadyAudioPlayerState value)? ready,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmptyAudioPlayerState value)? empty,
    TResult Function(ReadyAudioPlayerState value)? ready,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class EmptyAudioPlayerState implements AudioPlayerState {
  const factory EmptyAudioPlayerState(
      {required final double speed,
      required final bool trimSilence,
      required final bool volumeBoost}) = _$EmptyAudioPlayerStateImpl;

  @override
  double get speed;
  @override
  bool get trimSilence;
  @override
  bool get volumeBoost;
  @override
  @JsonKey(ignore: true)
  _$$EmptyAudioPlayerStateImplCopyWith<_$EmptyAudioPlayerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReadyAudioPlayerStateImplCopyWith<$Res>
    implements $AudioPlayerStateCopyWith<$Res> {
  factory _$$ReadyAudioPlayerStateImplCopyWith(
          _$ReadyAudioPlayerStateImpl value,
          $Res Function(_$ReadyAudioPlayerStateImpl) then) =
      __$$ReadyAudioPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double speed,
      bool trimSilence,
      bool volumeBoost,
      Episode nowPlaying,
      AudioState playingState,
      TranscriptState? transcript,
      double transitionPosition,
      int playbackError});

  $EpisodeCopyWith<$Res> get nowPlaying;
  $TranscriptStateCopyWith<$Res>? get transcript;
}

/// @nodoc
class __$$ReadyAudioPlayerStateImplCopyWithImpl<$Res>
    extends _$AudioPlayerStateCopyWithImpl<$Res, _$ReadyAudioPlayerStateImpl>
    implements _$$ReadyAudioPlayerStateImplCopyWith<$Res> {
  __$$ReadyAudioPlayerStateImplCopyWithImpl(_$ReadyAudioPlayerStateImpl _value,
      $Res Function(_$ReadyAudioPlayerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speed = null,
    Object? trimSilence = null,
    Object? volumeBoost = null,
    Object? nowPlaying = null,
    Object? playingState = null,
    Object? transcript = freezed,
    Object? transitionPosition = null,
    Object? playbackError = null,
  }) {
    return _then(_$ReadyAudioPlayerStateImpl(
      speed: null == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double,
      trimSilence: null == trimSilence
          ? _value.trimSilence
          : trimSilence // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeBoost: null == volumeBoost
          ? _value.volumeBoost
          : volumeBoost // ignore: cast_nullable_to_non_nullable
              as bool,
      nowPlaying: null == nowPlaying
          ? _value.nowPlaying
          : nowPlaying // ignore: cast_nullable_to_non_nullable
              as Episode,
      playingState: null == playingState
          ? _value.playingState
          : playingState // ignore: cast_nullable_to_non_nullable
              as AudioState,
      transcript: freezed == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as TranscriptState?,
      transitionPosition: null == transitionPosition
          ? _value.transitionPosition
          : transitionPosition // ignore: cast_nullable_to_non_nullable
              as double,
      playbackError: null == playbackError
          ? _value.playbackError
          : playbackError // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get nowPlaying {
    return $EpisodeCopyWith<$Res>(_value.nowPlaying, (value) {
      return _then(_value.copyWith(nowPlaying: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TranscriptStateCopyWith<$Res>? get transcript {
    if (_value.transcript == null) {
      return null;
    }

    return $TranscriptStateCopyWith<$Res>(_value.transcript!, (value) {
      return _then(_value.copyWith(transcript: value));
    });
  }
}

/// @nodoc

class _$ReadyAudioPlayerStateImpl implements ReadyAudioPlayerState {
  const _$ReadyAudioPlayerStateImpl(
      {required this.speed,
      required this.trimSilence,
      required this.volumeBoost,
      required this.nowPlaying,
      required this.playingState,
      this.transcript,
      this.transitionPosition = 0,
      this.playbackError = 0});

  @override
  final double speed;
  @override
  final bool trimSilence;
  @override
  final bool volumeBoost;
  @override
  final Episode nowPlaying;
  @override
  final AudioState playingState;
  @override
  final TranscriptState? transcript;
  @override
  @JsonKey()
  final double transitionPosition;
  @override
  @JsonKey()
  final int playbackError;

  @override
  String toString() {
    return 'AudioPlayerState.ready(speed: $speed, trimSilence: $trimSilence, volumeBoost: $volumeBoost, nowPlaying: $nowPlaying, playingState: $playingState, transcript: $transcript, transitionPosition: $transitionPosition, playbackError: $playbackError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadyAudioPlayerStateImpl &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.trimSilence, trimSilence) ||
                other.trimSilence == trimSilence) &&
            (identical(other.volumeBoost, volumeBoost) ||
                other.volumeBoost == volumeBoost) &&
            (identical(other.nowPlaying, nowPlaying) ||
                other.nowPlaying == nowPlaying) &&
            (identical(other.playingState, playingState) ||
                other.playingState == playingState) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.transitionPosition, transitionPosition) ||
                other.transitionPosition == transitionPosition) &&
            (identical(other.playbackError, playbackError) ||
                other.playbackError == playbackError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, speed, trimSilence, volumeBoost,
      nowPlaying, playingState, transcript, transitionPosition, playbackError);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadyAudioPlayerStateImplCopyWith<_$ReadyAudioPlayerStateImpl>
      get copyWith => __$$ReadyAudioPlayerStateImplCopyWithImpl<
          _$ReadyAudioPlayerStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double speed, bool trimSilence, bool volumeBoost)
        empty,
    required TResult Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)
        ready,
  }) {
    return ready(speed, trimSilence, volumeBoost, nowPlaying, playingState,
        transcript, transitionPosition, playbackError);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double speed, bool trimSilence, bool volumeBoost)? empty,
    TResult? Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)?
        ready,
  }) {
    return ready?.call(speed, trimSilence, volumeBoost, nowPlaying,
        playingState, transcript, transitionPosition, playbackError);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double speed, bool trimSilence, bool volumeBoost)? empty,
    TResult Function(
            double speed,
            bool trimSilence,
            bool volumeBoost,
            Episode nowPlaying,
            AudioState playingState,
            TranscriptState? transcript,
            double transitionPosition,
            int playbackError)?
        ready,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(speed, trimSilence, volumeBoost, nowPlaying, playingState,
          transcript, transitionPosition, playbackError);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmptyAudioPlayerState value) empty,
    required TResult Function(ReadyAudioPlayerState value) ready,
  }) {
    return ready(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmptyAudioPlayerState value)? empty,
    TResult? Function(ReadyAudioPlayerState value)? ready,
  }) {
    return ready?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmptyAudioPlayerState value)? empty,
    TResult Function(ReadyAudioPlayerState value)? ready,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class ReadyAudioPlayerState implements AudioPlayerState {
  const factory ReadyAudioPlayerState(
      {required final double speed,
      required final bool trimSilence,
      required final bool volumeBoost,
      required final Episode nowPlaying,
      required final AudioState playingState,
      final TranscriptState? transcript,
      final double transitionPosition,
      final int playbackError}) = _$ReadyAudioPlayerStateImpl;

  @override
  double get speed;
  @override
  bool get trimSilence;
  @override
  bool get volumeBoost;
  Episode get nowPlaying;
  AudioState get playingState;
  TranscriptState? get transcript;
  double get transitionPosition;
  int get playbackError;
  @override
  @JsonKey(ignore: true)
  _$$ReadyAudioPlayerStateImplCopyWith<_$ReadyAudioPlayerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
