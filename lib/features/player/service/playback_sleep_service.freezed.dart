// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_sleep_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlaybackSleepState {
  SleepMode get sleepMode => throw _privateConstructorUsedError;
  DateTime? get startedTime => throw _privateConstructorUsedError;
  Duration? get remaining => throw _privateConstructorUsedError;
  bool get fulfilled => throw _privateConstructorUsedError;

  /// Create a copy of PlaybackSleepState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaybackSleepStateCopyWith<PlaybackSleepState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaybackSleepStateCopyWith<$Res> {
  factory $PlaybackSleepStateCopyWith(
          PlaybackSleepState value, $Res Function(PlaybackSleepState) then) =
      _$PlaybackSleepStateCopyWithImpl<$Res, PlaybackSleepState>;
  @useResult
  $Res call(
      {SleepMode sleepMode,
      DateTime? startedTime,
      Duration? remaining,
      bool fulfilled});

  $SleepModeCopyWith<$Res> get sleepMode;
}

/// @nodoc
class _$PlaybackSleepStateCopyWithImpl<$Res, $Val extends PlaybackSleepState>
    implements $PlaybackSleepStateCopyWith<$Res> {
  _$PlaybackSleepStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaybackSleepState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sleepMode = null,
    Object? startedTime = freezed,
    Object? remaining = freezed,
    Object? fulfilled = null,
  }) {
    return _then(_value.copyWith(
      sleepMode: null == sleepMode
          ? _value.sleepMode
          : sleepMode // ignore: cast_nullable_to_non_nullable
              as SleepMode,
      startedTime: freezed == startedTime
          ? _value.startedTime
          : startedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remaining: freezed == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as Duration?,
      fulfilled: null == fulfilled
          ? _value.fulfilled
          : fulfilled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of PlaybackSleepState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SleepModeCopyWith<$Res> get sleepMode {
    return $SleepModeCopyWith<$Res>(_value.sleepMode, (value) {
      return _then(_value.copyWith(sleepMode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaybackSleepStateImplCopyWith<$Res>
    implements $PlaybackSleepStateCopyWith<$Res> {
  factory _$$PlaybackSleepStateImplCopyWith(_$PlaybackSleepStateImpl value,
          $Res Function(_$PlaybackSleepStateImpl) then) =
      __$$PlaybackSleepStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SleepMode sleepMode,
      DateTime? startedTime,
      Duration? remaining,
      bool fulfilled});

  @override
  $SleepModeCopyWith<$Res> get sleepMode;
}

/// @nodoc
class __$$PlaybackSleepStateImplCopyWithImpl<$Res>
    extends _$PlaybackSleepStateCopyWithImpl<$Res, _$PlaybackSleepStateImpl>
    implements _$$PlaybackSleepStateImplCopyWith<$Res> {
  __$$PlaybackSleepStateImplCopyWithImpl(_$PlaybackSleepStateImpl _value,
      $Res Function(_$PlaybackSleepStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaybackSleepState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sleepMode = null,
    Object? startedTime = freezed,
    Object? remaining = freezed,
    Object? fulfilled = null,
  }) {
    return _then(_$PlaybackSleepStateImpl(
      sleepMode: null == sleepMode
          ? _value.sleepMode
          : sleepMode // ignore: cast_nullable_to_non_nullable
              as SleepMode,
      startedTime: freezed == startedTime
          ? _value.startedTime
          : startedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remaining: freezed == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as Duration?,
      fulfilled: null == fulfilled
          ? _value.fulfilled
          : fulfilled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PlaybackSleepStateImpl implements _PlaybackSleepState {
  _$PlaybackSleepStateImpl(
      {required this.sleepMode,
      this.startedTime,
      this.remaining,
      this.fulfilled = false});

  @override
  final SleepMode sleepMode;
  @override
  final DateTime? startedTime;
  @override
  final Duration? remaining;
  @override
  @JsonKey()
  final bool fulfilled;

  @override
  String toString() {
    return 'PlaybackSleepState(sleepMode: $sleepMode, startedTime: $startedTime, remaining: $remaining, fulfilled: $fulfilled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaybackSleepStateImpl &&
            (identical(other.sleepMode, sleepMode) ||
                other.sleepMode == sleepMode) &&
            (identical(other.startedTime, startedTime) ||
                other.startedTime == startedTime) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.fulfilled, fulfilled) ||
                other.fulfilled == fulfilled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sleepMode, startedTime, remaining, fulfilled);

  /// Create a copy of PlaybackSleepState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaybackSleepStateImplCopyWith<_$PlaybackSleepStateImpl> get copyWith =>
      __$$PlaybackSleepStateImplCopyWithImpl<_$PlaybackSleepStateImpl>(
          this, _$identity);
}

abstract class _PlaybackSleepState implements PlaybackSleepState {
  factory _PlaybackSleepState(
      {required final SleepMode sleepMode,
      final DateTime? startedTime,
      final Duration? remaining,
      final bool fulfilled}) = _$PlaybackSleepStateImpl;

  @override
  SleepMode get sleepMode;
  @override
  DateTime? get startedTime;
  @override
  Duration? get remaining;
  @override
  bool get fulfilled;

  /// Create a copy of PlaybackSleepState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaybackSleepStateImplCopyWith<_$PlaybackSleepStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
