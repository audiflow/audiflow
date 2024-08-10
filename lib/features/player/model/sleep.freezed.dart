// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sleep _$SleepFromJson(Map<String, dynamic> json) {
  return _Sleep.fromJson(json);
}

/// @nodoc
mixin _$Sleep {
  SleepType get type => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  /// Serializes this Sleep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sleep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SleepCopyWith<Sleep> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepCopyWith<$Res> {
  factory $SleepCopyWith(Sleep value, $Res Function(Sleep) then) =
      _$SleepCopyWithImpl<$Res, Sleep>;
  @useResult
  $Res call({SleepType type, Duration duration});
}

/// @nodoc
class _$SleepCopyWithImpl<$Res, $Val extends Sleep>
    implements $SleepCopyWith<$Res> {
  _$SleepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sleep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SleepType,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SleepImplCopyWith<$Res> implements $SleepCopyWith<$Res> {
  factory _$$SleepImplCopyWith(
          _$SleepImpl value, $Res Function(_$SleepImpl) then) =
      __$$SleepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SleepType type, Duration duration});
}

/// @nodoc
class __$$SleepImplCopyWithImpl<$Res>
    extends _$SleepCopyWithImpl<$Res, _$SleepImpl>
    implements _$$SleepImplCopyWith<$Res> {
  __$$SleepImplCopyWithImpl(
      _$SleepImpl _value, $Res Function(_$SleepImpl) _then)
      : super(_value, _then);

  /// Create a copy of Sleep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? duration = null,
  }) {
    return _then(_$SleepImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SleepType,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepImpl implements _Sleep {
  const _$SleepImpl({required this.type, this.duration = Duration.zero});

  factory _$SleepImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepImplFromJson(json);

  @override
  final SleepType type;
  @override
  @JsonKey()
  final Duration duration;

  @override
  String toString() {
    return 'Sleep(type: $type, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, duration);

  /// Create a copy of Sleep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepImplCopyWith<_$SleepImpl> get copyWith =>
      __$$SleepImplCopyWithImpl<_$SleepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepImplToJson(
      this,
    );
  }
}

abstract class _Sleep implements Sleep {
  const factory _Sleep(
      {required final SleepType type, final Duration duration}) = _$SleepImpl;

  factory _Sleep.fromJson(Map<String, dynamic> json) = _$SleepImpl.fromJson;

  @override
  SleepType get type;
  @override
  Duration get duration;

  /// Create a copy of Sleep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SleepImplCopyWith<_$SleepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
