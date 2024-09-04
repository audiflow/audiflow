// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seekbar_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SeekbarState {
  Duration get position => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  /// Create a copy of SeekbarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeekbarStateCopyWith<SeekbarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeekbarStateCopyWith<$Res> {
  factory $SeekbarStateCopyWith(
          SeekbarState value, $Res Function(SeekbarState) then) =
      _$SeekbarStateCopyWithImpl<$Res, SeekbarState>;
  @useResult
  $Res call({Duration position, Duration duration});
}

/// @nodoc
class _$SeekbarStateCopyWithImpl<$Res, $Val extends SeekbarState>
    implements $SeekbarStateCopyWith<$Res> {
  _$SeekbarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeekbarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeekbarStateImplCopyWith<$Res>
    implements $SeekbarStateCopyWith<$Res> {
  factory _$$SeekbarStateImplCopyWith(
          _$SeekbarStateImpl value, $Res Function(_$SeekbarStateImpl) then) =
      __$$SeekbarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Duration position, Duration duration});
}

/// @nodoc
class __$$SeekbarStateImplCopyWithImpl<$Res>
    extends _$SeekbarStateCopyWithImpl<$Res, _$SeekbarStateImpl>
    implements _$$SeekbarStateImplCopyWith<$Res> {
  __$$SeekbarStateImplCopyWithImpl(
      _$SeekbarStateImpl _value, $Res Function(_$SeekbarStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeekbarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? duration = null,
  }) {
    return _then(_$SeekbarStateImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$SeekbarStateImpl implements _SeekbarState {
  const _$SeekbarStateImpl({required this.position, required this.duration});

  @override
  final Duration position;
  @override
  final Duration duration;

  @override
  String toString() {
    return 'SeekbarState(position: $position, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeekbarStateImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, position, duration);

  /// Create a copy of SeekbarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeekbarStateImplCopyWith<_$SeekbarStateImpl> get copyWith =>
      __$$SeekbarStateImplCopyWithImpl<_$SeekbarStateImpl>(this, _$identity);
}

abstract class _SeekbarState implements SeekbarState {
  const factory _SeekbarState(
      {required final Duration position,
      required final Duration duration}) = _$SeekbarStateImpl;

  @override
  Duration get position;
  @override
  Duration get duration;

  /// Create a copy of SeekbarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeekbarStateImplCopyWith<_$SeekbarStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
