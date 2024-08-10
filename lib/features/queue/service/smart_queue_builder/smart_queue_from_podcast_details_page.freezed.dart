// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smart_queue_from_podcast_details_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

_Info _$InfoFromJson(Map<String, dynamic> json) {
  return __Info.fromJson(json);
}

/// @nodoc
mixin _$Info {
  int get pid => throw _privateConstructorUsedError;
  int get ordinal => throw _privateConstructorUsedError;
  EpisodeFilterMode get filterMode => throw _privateConstructorUsedError;

  /// Serializes this _Info to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of _Info
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$InfoCopyWith<_Info> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$InfoCopyWith<$Res> {
  factory _$InfoCopyWith(_Info value, $Res Function(_Info) then) =
      __$InfoCopyWithImpl<$Res, _Info>;
  @useResult
  $Res call({int pid, int ordinal, EpisodeFilterMode filterMode});
}

/// @nodoc
class __$InfoCopyWithImpl<$Res, $Val extends _Info>
    implements _$InfoCopyWith<$Res> {
  __$InfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of _Info
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pid = null,
    Object? ordinal = null,
    Object? filterMode = null,
  }) {
    return _then(_value.copyWith(
      pid: null == pid
          ? _value.pid
          : pid // ignore: cast_nullable_to_non_nullable
              as int,
      ordinal: null == ordinal
          ? _value.ordinal
          : ordinal // ignore: cast_nullable_to_non_nullable
              as int,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InfoImplCopyWith<$Res> implements _$InfoCopyWith<$Res> {
  factory _$$_InfoImplCopyWith(
          _$_InfoImpl value, $Res Function(_$_InfoImpl) then) =
      __$$_InfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pid, int ordinal, EpisodeFilterMode filterMode});
}

/// @nodoc
class __$$_InfoImplCopyWithImpl<$Res>
    extends __$InfoCopyWithImpl<$Res, _$_InfoImpl>
    implements _$$_InfoImplCopyWith<$Res> {
  __$$_InfoImplCopyWithImpl(
      _$_InfoImpl _value, $Res Function(_$_InfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of _Info
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pid = null,
    Object? ordinal = null,
    Object? filterMode = null,
  }) {
    return _then(_$_InfoImpl(
      pid: null == pid
          ? _value.pid
          : pid // ignore: cast_nullable_to_non_nullable
              as int,
      ordinal: null == ordinal
          ? _value.ordinal
          : ordinal // ignore: cast_nullable_to_non_nullable
              as int,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InfoImpl implements __Info {
  const _$_InfoImpl(
      {required this.pid, required this.ordinal, required this.filterMode});

  factory _$_InfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$_InfoImplFromJson(json);

  @override
  final int pid;
  @override
  final int ordinal;
  @override
  final EpisodeFilterMode filterMode;

  @override
  String toString() {
    return '_Info(pid: $pid, ordinal: $ordinal, filterMode: $filterMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InfoImpl &&
            (identical(other.pid, pid) || other.pid == pid) &&
            (identical(other.ordinal, ordinal) || other.ordinal == ordinal) &&
            (identical(other.filterMode, filterMode) ||
                other.filterMode == filterMode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pid, ordinal, filterMode);

  /// Create a copy of _Info
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$_InfoImplCopyWith<_$_InfoImpl> get copyWith =>
      __$$_InfoImplCopyWithImpl<_$_InfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InfoImplToJson(
      this,
    );
  }
}

abstract class __Info implements _Info {
  const factory __Info(
      {required final int pid,
      required final int ordinal,
      required final EpisodeFilterMode filterMode}) = _$_InfoImpl;

  factory __Info.fromJson(Map<String, dynamic> json) = _$_InfoImpl.fromJson;

  @override
  int get pid;
  @override
  int get ordinal;
  @override
  EpisodeFilterMode get filterMode;

  /// Create a copy of _Info
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$_InfoImplCopyWith<_$_InfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
