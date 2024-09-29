// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_player_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioPlayerPreferenceState {
  double get speed => throw _privateConstructorUsedError;
  bool get trimSilence => throw _privateConstructorUsedError;
  bool get volumeBoost => throw _privateConstructorUsedError;

  /// Create a copy of AudioPlayerPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioPlayerPreferenceStateCopyWith<AudioPlayerPreferenceState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioPlayerPreferenceStateCopyWith<$Res> {
  factory $AudioPlayerPreferenceStateCopyWith(AudioPlayerPreferenceState value,
          $Res Function(AudioPlayerPreferenceState) then) =
      _$AudioPlayerPreferenceStateCopyWithImpl<$Res,
          AudioPlayerPreferenceState>;
  @useResult
  $Res call({double speed, bool trimSilence, bool volumeBoost});
}

/// @nodoc
class _$AudioPlayerPreferenceStateCopyWithImpl<$Res,
        $Val extends AudioPlayerPreferenceState>
    implements $AudioPlayerPreferenceStateCopyWith<$Res> {
  _$AudioPlayerPreferenceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioPlayerPreferenceState
  /// with the given fields replaced by the non-null parameter values.
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
abstract class _$$AudioPlayerPreferenceStateImplCopyWith<$Res>
    implements $AudioPlayerPreferenceStateCopyWith<$Res> {
  factory _$$AudioPlayerPreferenceStateImplCopyWith(
          _$AudioPlayerPreferenceStateImpl value,
          $Res Function(_$AudioPlayerPreferenceStateImpl) then) =
      __$$AudioPlayerPreferenceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double speed, bool trimSilence, bool volumeBoost});
}

/// @nodoc
class __$$AudioPlayerPreferenceStateImplCopyWithImpl<$Res>
    extends _$AudioPlayerPreferenceStateCopyWithImpl<$Res,
        _$AudioPlayerPreferenceStateImpl>
    implements _$$AudioPlayerPreferenceStateImplCopyWith<$Res> {
  __$$AudioPlayerPreferenceStateImplCopyWithImpl(
      _$AudioPlayerPreferenceStateImpl _value,
      $Res Function(_$AudioPlayerPreferenceStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioPlayerPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speed = null,
    Object? trimSilence = null,
    Object? volumeBoost = null,
  }) {
    return _then(_$AudioPlayerPreferenceStateImpl(
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

class _$AudioPlayerPreferenceStateImpl implements _AudioPlayerPreferenceState {
  const _$AudioPlayerPreferenceStateImpl(
      {this.speed = 1.0, this.trimSilence = false, this.volumeBoost = false});

  @override
  @JsonKey()
  final double speed;
  @override
  @JsonKey()
  final bool trimSilence;
  @override
  @JsonKey()
  final bool volumeBoost;

  @override
  String toString() {
    return 'AudioPlayerPreferenceState(speed: $speed, trimSilence: $trimSilence, volumeBoost: $volumeBoost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioPlayerPreferenceStateImpl &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.trimSilence, trimSilence) ||
                other.trimSilence == trimSilence) &&
            (identical(other.volumeBoost, volumeBoost) ||
                other.volumeBoost == volumeBoost));
  }

  @override
  int get hashCode => Object.hash(runtimeType, speed, trimSilence, volumeBoost);

  /// Create a copy of AudioPlayerPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioPlayerPreferenceStateImplCopyWith<_$AudioPlayerPreferenceStateImpl>
      get copyWith => __$$AudioPlayerPreferenceStateImplCopyWithImpl<
          _$AudioPlayerPreferenceStateImpl>(this, _$identity);
}

abstract class _AudioPlayerPreferenceState
    implements AudioPlayerPreferenceState {
  const factory _AudioPlayerPreferenceState(
      {final double speed,
      final bool trimSilence,
      final bool volumeBoost}) = _$AudioPlayerPreferenceStateImpl;

  @override
  double get speed;
  @override
  bool get trimSilence;
  @override
  bool get volumeBoost;

  /// Create a copy of AudioPlayerPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioPlayerPreferenceStateImplCopyWith<_$AudioPlayerPreferenceStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
