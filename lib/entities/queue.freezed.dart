// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Queue _$QueueFromJson(Map<String, dynamic> json) {
  return _Queue.fromJson(json);
}

/// @nodoc
mixin _$Queue {
  List<String> get guids => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QueueCopyWith<Queue> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueCopyWith<$Res> {
  factory $QueueCopyWith(Queue value, $Res Function(Queue) then) =
      _$QueueCopyWithImpl<$Res, Queue>;
  @useResult
  $Res call({List<String> guids});
}

/// @nodoc
class _$QueueCopyWithImpl<$Res, $Val extends Queue>
    implements $QueueCopyWith<$Res> {
  _$QueueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guids = null,
  }) {
    return _then(_value.copyWith(
      guids: null == guids
          ? _value.guids
          : guids // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueueImplCopyWith<$Res> implements $QueueCopyWith<$Res> {
  factory _$$QueueImplCopyWith(
          _$QueueImpl value, $Res Function(_$QueueImpl) then) =
      __$$QueueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> guids});
}

/// @nodoc
class __$$QueueImplCopyWithImpl<$Res>
    extends _$QueueCopyWithImpl<$Res, _$QueueImpl>
    implements _$$QueueImplCopyWith<$Res> {
  __$$QueueImplCopyWithImpl(
      _$QueueImpl _value, $Res Function(_$QueueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guids = null,
  }) {
    return _then(_$QueueImpl(
      guids: null == guids
          ? _value._guids
          : guids // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueImpl implements _Queue {
  const _$QueueImpl({final List<String> guids = const <String>[]})
      : _guids = guids;

  factory _$QueueImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueueImplFromJson(json);

  final List<String> _guids;
  @override
  @JsonKey()
  List<String> get guids {
    if (_guids is EqualUnmodifiableListView) return _guids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_guids);
  }

  @override
  String toString() {
    return 'Queue(guids: $guids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueImpl &&
            const DeepCollectionEquality().equals(other._guids, _guids));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_guids));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueImplCopyWith<_$QueueImpl> get copyWith =>
      __$$QueueImplCopyWithImpl<_$QueueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueueImplToJson(
      this,
    );
  }
}

abstract class _Queue implements Queue {
  const factory _Queue({final List<String> guids}) = _$QueueImpl;

  factory _Queue.fromJson(Map<String, dynamic> json) = _$QueueImpl.fromJson;

  @override
  List<String> get guids;
  @override
  @JsonKey(ignore: true)
  _$$QueueImplCopyWith<_$QueueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
