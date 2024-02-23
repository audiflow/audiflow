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
  List<QueueItem> get queue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QueueCopyWith<Queue> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueCopyWith<$Res> {
  factory $QueueCopyWith(Queue value, $Res Function(Queue) then) =
      _$QueueCopyWithImpl<$Res, Queue>;
  @useResult
  $Res call({List<QueueItem> queue});
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
    Object? queue = null,
  }) {
    return _then(_value.copyWith(
      queue: null == queue
          ? _value.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<QueueItem>,
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
  $Res call({List<QueueItem> queue});
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
    Object? queue = null,
  }) {
    return _then(_$QueueImpl(
      queue: null == queue
          ? _value._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<QueueItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueImpl implements _Queue {
  const _$QueueImpl({final List<QueueItem> queue = const <QueueItem>[]})
      : _queue = queue;

  factory _$QueueImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueueImplFromJson(json);

  final List<QueueItem> _queue;
  @override
  @JsonKey()
  List<QueueItem> get queue {
    if (_queue is EqualUnmodifiableListView) return _queue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queue);
  }

  @override
  String toString() {
    return 'Queue(queue: $queue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueImpl &&
            const DeepCollectionEquality().equals(other._queue, _queue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_queue));

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
  const factory _Queue({final List<QueueItem> queue}) = _$QueueImpl;

  factory _Queue.fromJson(Map<String, dynamic> json) = _$QueueImpl.fromJson;

  @override
  List<QueueItem> get queue;
  @override
  @JsonKey(ignore: true)
  _$$QueueImplCopyWith<_$QueueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QueueItem _$QueueItemFromJson(Map<String, dynamic> json) {
  return _QueueItem.fromJson(json);
}

/// @nodoc
mixin _$QueueItem {
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
  $Res call({String guid, QueueType type});
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
    Object? guid = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
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
  $Res call({String guid, QueueType type});
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
    Object? guid = null,
    Object? type = null,
  }) {
    return _then(_$QueueItemImpl(
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
  const _$QueueItemImpl({required this.guid, required this.type});

  factory _$QueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueueItemImplFromJson(json);

  @override
  final String guid;
  @override
  final QueueType type;

  @override
  String toString() {
    return 'QueueItem(guid: $guid, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueItemImpl &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, guid, type);

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
      {required final String guid,
      required final QueueType type}) = _$QueueItemImpl;

  factory _QueueItem.fromJson(Map<String, dynamic> json) =
      _$QueueItemImpl.fromJson;

  @override
  String get guid;
  @override
  QueueType get type;
  @override
  @JsonKey(ignore: true)
  _$$QueueItemImplCopyWith<_$QueueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
