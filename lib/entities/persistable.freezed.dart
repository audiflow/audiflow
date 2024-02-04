// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persistable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Persistable _$PersistableFromJson(Map<String, dynamic> json) {
  return _Persistable.fromJson(json);
}

/// @nodoc
mixin _$Persistable {
  /// The Podcast GUID.
  String get pguid => throw _privateConstructorUsedError;

  /// The episode ID (provided by the DB layer).
  int get episodeId => throw _privateConstructorUsedError;

  /// The current position in seconds;
  int get position => throw _privateConstructorUsedError;

  /// The current playback state.
  LastState get state => throw _privateConstructorUsedError;

  /// Date & time episode was last updated.
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersistableCopyWith<Persistable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersistableCopyWith<$Res> {
  factory $PersistableCopyWith(
          Persistable value, $Res Function(Persistable) then) =
      _$PersistableCopyWithImpl<$Res, Persistable>;
  @useResult
  $Res call(
      {String pguid,
      int episodeId,
      int position,
      LastState state,
      DateTime? lastUpdated});
}

/// @nodoc
class _$PersistableCopyWithImpl<$Res, $Val extends Persistable>
    implements $PersistableCopyWith<$Res> {
  _$PersistableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pguid = null,
    Object? episodeId = null,
    Object? position = null,
    Object? state = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      episodeId: null == episodeId
          ? _value.episodeId
          : episodeId // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as LastState,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersistableImplCopyWith<$Res>
    implements $PersistableCopyWith<$Res> {
  factory _$$PersistableImplCopyWith(
          _$PersistableImpl value, $Res Function(_$PersistableImpl) then) =
      __$$PersistableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String pguid,
      int episodeId,
      int position,
      LastState state,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$PersistableImplCopyWithImpl<$Res>
    extends _$PersistableCopyWithImpl<$Res, _$PersistableImpl>
    implements _$$PersistableImplCopyWith<$Res> {
  __$$PersistableImplCopyWithImpl(
      _$PersistableImpl _value, $Res Function(_$PersistableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pguid = null,
    Object? episodeId = null,
    Object? position = null,
    Object? state = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$PersistableImpl(
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      episodeId: null == episodeId
          ? _value.episodeId
          : episodeId // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as LastState,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersistableImpl implements _Persistable {
  const _$PersistableImpl(
      {required this.pguid,
      required this.episodeId,
      required this.position,
      required this.state,
      this.lastUpdated});

  factory _$PersistableImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersistableImplFromJson(json);

  /// The Podcast GUID.
  @override
  final String pguid;

  /// The episode ID (provided by the DB layer).
  @override
  final int episodeId;

  /// The current position in seconds;
  @override
  final int position;

  /// The current playback state.
  @override
  final LastState state;

  /// Date & time episode was last updated.
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'Persistable(pguid: $pguid, episodeId: $episodeId, position: $position, state: $state, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersistableImpl &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.episodeId, episodeId) ||
                other.episodeId == episodeId) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, pguid, episodeId, position, state, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersistableImplCopyWith<_$PersistableImpl> get copyWith =>
      __$$PersistableImplCopyWithImpl<_$PersistableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersistableImplToJson(
      this,
    );
  }
}

abstract class _Persistable implements Persistable {
  const factory _Persistable(
      {required final String pguid,
      required final int episodeId,
      required final int position,
      required final LastState state,
      final DateTime? lastUpdated}) = _$PersistableImpl;

  factory _Persistable.fromJson(Map<String, dynamic> json) =
      _$PersistableImpl.fromJson;

  @override

  /// The Podcast GUID.
  String get pguid;
  @override

  /// The episode ID (provided by the DB layer).
  int get episodeId;
  @override

  /// The current position in seconds;
  int get position;
  @override

  /// The current playback state.
  LastState get state;
  @override

  /// Date & time episode was last updated.
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$PersistableImplCopyWith<_$PersistableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
