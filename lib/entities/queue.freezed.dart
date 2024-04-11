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

QueueItem _$QueueItemFromJson(Map<String, dynamic> json) {
  return _QueueItem.fromJson(json);
}

/// @nodoc
mixin _$QueueItem {
  String get id => throw _privateConstructorUsedError;
  String get pguid => throw _privateConstructorUsedError;
  String get guid => throw _privateConstructorUsedError;
  QueueType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QueueItemCopyWith<QueueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueItemCopyWith<$Res> {
  factory $QueueItemCopyWith(QueueItem value, $Res Function(QueueItem) then) =
      _$QueueItemCopyWithImpl<$Res, QueueItem>;
  @useResult
  $Res call({String id, String pguid, String guid, QueueType type});
}

/// @nodoc
class _$QueueItemCopyWithImpl<$Res, $Val extends QueueItem>
    implements $QueueItemCopyWith<$Res> {
  _$QueueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pguid = null,
    Object? guid = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QueueType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueueItemImplCopyWith<$Res>
    implements $QueueItemCopyWith<$Res> {
  factory _$$QueueItemImplCopyWith(
          _$QueueItemImpl value, $Res Function(_$QueueItemImpl) then) =
      __$$QueueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String pguid, String guid, QueueType type});
}

/// @nodoc
class __$$QueueItemImplCopyWithImpl<$Res>
    extends _$QueueItemCopyWithImpl<$Res, _$QueueItemImpl>
    implements _$$QueueItemImplCopyWith<$Res> {
  __$$QueueItemImplCopyWithImpl(
      _$QueueItemImpl _value, $Res Function(_$QueueItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pguid = null,
    Object? guid = null,
    Object? type = null,
  }) {
    return _then(_$QueueItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QueueType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueItemImpl implements _QueueItem {
  const _$QueueItemImpl(
      {required this.id,
      required this.pguid,
      required this.guid,
      required this.type});

  factory _$QueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueueItemImplFromJson(json);

  @override
  final String id;
  @override
  final String pguid;
  @override
  final String guid;
  @override
  final QueueType type;

  @override
  String toString() {
    return 'QueueItem(id: $id, pguid: $pguid, guid: $guid, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, pguid, guid, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueItemImplCopyWith<_$QueueItemImpl> get copyWith =>
      __$$QueueItemImplCopyWithImpl<_$QueueItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueueItemImplToJson(
      this,
    );
  }
}

abstract class _QueueItem implements QueueItem {
  const factory _QueueItem(
      {required final String id,
      required final String pguid,
      required final String guid,
      required final QueueType type}) = _$QueueItemImpl;

  factory _QueueItem.fromJson(Map<String, dynamic> json) =
      _$QueueItemImpl.fromJson;

  @override
  String get id;
  @override
  String get pguid;
  @override
  String get guid;
  @override
  QueueType get type;
  @override
  @JsonKey(ignore: true)
  _$$QueueItemImplCopyWith<_$QueueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
