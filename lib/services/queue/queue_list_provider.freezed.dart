// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_list_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QueueListState {
  List<QueuedEpisode> get queue => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QueueListStateCopyWith<QueueListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueListStateCopyWith<$Res> {
  factory $QueueListStateCopyWith(
          QueueListState value, $Res Function(QueueListState) then) =
      _$QueueListStateCopyWithImpl<$Res, QueueListState>;
  @useResult
  $Res call({List<QueuedEpisode> queue});
}

/// @nodoc
class _$QueueListStateCopyWithImpl<$Res, $Val extends QueueListState>
    implements $QueueListStateCopyWith<$Res> {
  _$QueueListStateCopyWithImpl(this._value, this._then);

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
              as List<QueuedEpisode>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueueListStateImplCopyWith<$Res>
    implements $QueueListStateCopyWith<$Res> {
  factory _$$QueueListStateImplCopyWith(_$QueueListStateImpl value,
          $Res Function(_$QueueListStateImpl) then) =
      __$$QueueListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<QueuedEpisode> queue});
}

/// @nodoc
class __$$QueueListStateImplCopyWithImpl<$Res>
    extends _$QueueListStateCopyWithImpl<$Res, _$QueueListStateImpl>
    implements _$$QueueListStateImplCopyWith<$Res> {
  __$$QueueListStateImplCopyWithImpl(
      _$QueueListStateImpl _value, $Res Function(_$QueueListStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queue = null,
  }) {
    return _then(_$QueueListStateImpl(
      queue: null == queue
          ? _value._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<QueuedEpisode>,
    ));
  }
}

/// @nodoc

class _$QueueListStateImpl implements _QueueListState {
  const _$QueueListStateImpl(
      {final List<QueuedEpisode> queue = const <QueuedEpisode>[]})
      : _queue = queue;

  final List<QueuedEpisode> _queue;
  @override
  @JsonKey()
  List<QueuedEpisode> get queue {
    if (_queue is EqualUnmodifiableListView) return _queue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queue);
  }

  @override
  String toString() {
    return 'QueueListState(queue: $queue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueListStateImpl &&
            const DeepCollectionEquality().equals(other._queue, _queue));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_queue));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueListStateImplCopyWith<_$QueueListStateImpl> get copyWith =>
      __$$QueueListStateImplCopyWithImpl<_$QueueListStateImpl>(
          this, _$identity);
}

abstract class _QueueListState implements QueueListState {
  const factory _QueueListState({final List<QueuedEpisode> queue}) =
      _$QueueListStateImpl;

  @override
  List<QueuedEpisode> get queue;
  @override
  @JsonKey(ignore: true)
  _$$QueueListStateImplCopyWith<_$QueueListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QueuedEpisode {
  QueueItem get item => throw _privateConstructorUsedError;
  Episode get episode => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QueuedEpisodeCopyWith<QueuedEpisode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueuedEpisodeCopyWith<$Res> {
  factory $QueuedEpisodeCopyWith(
          QueuedEpisode value, $Res Function(QueuedEpisode) then) =
      _$QueuedEpisodeCopyWithImpl<$Res, QueuedEpisode>;
  @useResult
  $Res call({QueueItem item, Episode episode});

  $QueueItemCopyWith<$Res> get item;
}

/// @nodoc
class _$QueuedEpisodeCopyWithImpl<$Res, $Val extends QueuedEpisode>
    implements $QueuedEpisodeCopyWith<$Res> {
  _$QueuedEpisodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? episode = null,
  }) {
    return _then(_value.copyWith(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as QueueItem,
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $QueueItemCopyWith<$Res> get item {
    return $QueueItemCopyWith<$Res>(_value.item, (value) {
      return _then(_value.copyWith(item: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QueuedEpisodeImplCopyWith<$Res>
    implements $QueuedEpisodeCopyWith<$Res> {
  factory _$$QueuedEpisodeImplCopyWith(
          _$QueuedEpisodeImpl value, $Res Function(_$QueuedEpisodeImpl) then) =
      __$$QueuedEpisodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({QueueItem item, Episode episode});

  @override
  $QueueItemCopyWith<$Res> get item;
}

/// @nodoc
class __$$QueuedEpisodeImplCopyWithImpl<$Res>
    extends _$QueuedEpisodeCopyWithImpl<$Res, _$QueuedEpisodeImpl>
    implements _$$QueuedEpisodeImplCopyWith<$Res> {
  __$$QueuedEpisodeImplCopyWithImpl(
      _$QueuedEpisodeImpl _value, $Res Function(_$QueuedEpisodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? episode = null,
  }) {
    return _then(_$QueuedEpisodeImpl(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as QueueItem,
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
    ));
  }
}

/// @nodoc

class _$QueuedEpisodeImpl implements _QueuedEpisode {
  const _$QueuedEpisodeImpl({required this.item, required this.episode});

  @override
  final QueueItem item;
  @override
  final Episode episode;

  @override
  String toString() {
    return 'QueuedEpisode(item: $item, episode: $episode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueuedEpisodeImpl &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.episode, episode) || other.episode == episode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item, episode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueuedEpisodeImplCopyWith<_$QueuedEpisodeImpl> get copyWith =>
      __$$QueuedEpisodeImplCopyWithImpl<_$QueuedEpisodeImpl>(this, _$identity);
}

abstract class _QueuedEpisode implements QueuedEpisode {
  const factory _QueuedEpisode(
      {required final QueueItem item,
      required final Episode episode}) = _$QueuedEpisodeImpl;

  @override
  QueueItem get item;
  @override
  Episode get episode;
  @override
  @JsonKey(ignore: true)
  _$$QueuedEpisodeImplCopyWith<_$QueuedEpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
